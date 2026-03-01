---
layout: post
title:  "The Royal Game Boy of Ur"
byline: "Building a Game Boy version of the world's oldest board game"
date:   2026-03-15 08:00:00
author: Sebastian Proost
categories: ai programming gaming
tags:	python c nintendo gameboy
cover:  "/assets/posts/2026-03-15-gameboy-royal-game-of-ur/header.jpg"
thumbnail: "/assets/images/thumbnails/royal_gameboy_of_ur.jpg"
---

Years ago, a [documentary on "The Royal Game of Ur"](https://www.youtube.com/watch?v=WZskjLq040I), one of the oldest known board games, nearly 5,000 years old, instantly piqued my interest. When I later heard Prof. Dr. Irving Finkel discuss it on [a podcast](https://www.youtube.com/watch?v=_bBRVNkAfkQ), the fascination came flooding back. But this time, I had an idea: build a playable version of the Royal Game of Ur for the original Game Boy.


## Why the Game Boy? Why Agentic Coding?

I grew up with the Nintendo Game Boy, it was the first console I had and I have fond memories playing those games. But it is also an older system and Game Boy homebrew development, even with tools like [GBDK](https://gbdk.org/), is a niche with a small but dedicated community. For agentic coding tools like [Claude Code](https://claude.ai/), that matters: when working on a Python project with popular libraries like pandas or flask, there is plenty of reference material available. I wanted to test if Claude Code could handle a much less common ecosystem, where documentation is sparser and the community is smaller.

On a device like this, you are also working closer to the hardware; handling interrupts, managing memory, working within tight constraints. This is a far cry from modern application development, where most of this is abstracted away by frameworks. That unfamiliarity was part of the appeal: how do you prompt an agentic coding tool effectively when you yourself don't know the packages, functions, and terminology for the platform?

When developing games, creating the assets is often the limiting factor. The Game Boy's resolution (160×144 pixels) and color palette (2-bit: white, light gray, dark gray, and black) are more forgiving on that front. I'm a developer not an artist, so a platform where simple graphics are the norm rather than the exception suits me well. And the Royal Game of Ur, with its simple rules and turn-based gameplay, seemed like an ideal fit for these constraints.

So the goal was threefold: test how well Claude Code works for a less common platform, deepen my understanding of the Game Boy's hardware, and — if all went well — end up with a playable game.

## Testing the Waters: A Simpler First App

Diving right in didn't feel like a great option here, I wanted to set up my toolchain (VSCode, Docker and devcontainer) correctly first. Then check if I could get a simple application running, something that put some graphics on the screen, handled user input and played some sound... Zen Garden was born, a simple meditation app which just shows a few images on the background, has a menu the user can interact with and a simple background melody and sound effects. 

My Dockerfile, which I use with VSCode and devcontainer, is found below. I included Python (good to have access in case a quick script is needed to convert something), Node.js (to install and run Claude Code inside the container) and GBDK (the build tools for the Game Boy). Testing I did manually with [SameBoy](https://sameboy.github.io/) but later switched to [BGB](https://bgb.bircd.org/bgb-1510-released.html) which has better tools to debug ROMs. 

{:.large-code}
```dockerfile
# Game Boy Development Environment with GBDK-2020, Node.js, and development tools
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    unzip \
    git \
    make \
    cmake \
    pkg-config \
    libsdl2-dev \
    libsdl2-image-dev \
    python3 \
    python3-pip \
    sudo \
    bc \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (latest LTS) and npm for Claude Code
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && npm --version \
    && node --version

# Create development user to avoid running as root
RUN useradd -m -s /bin/bash gbdev \
    && echo "gbdev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to development user
USER gbdev
WORKDIR /home/gbdev

# Install GBDK-2020 (Game Boy Development Kit)
RUN wget https://github.com/gbdk-2020/gbdk-2020/releases/download/4.2.0/gbdk-linux64.tar.gz \
    && tar -xzf gbdk-linux64.tar.gz \
    && rm gbdk-linux64.tar.gz

# Set up environment variables for GBDK
ENV GBDK_HOME=/home/gbdev/gbdk
ENV PATH="${GBDK_HOME}/bin:${PATH}"

# Note: SameBoy emulator installation skipped in container
# SameBoy requires GUI/X11 which is complex in containers
# Install via: apt install sameboy (if available) or use BGB/other emulators
# For now, ROMs can be tested by copying to host machine

# Install Claude Code globally as gbdev user
RUN curl -fsSL https://claude.ai/install.sh | bash

USER gbdev
# Create project structure
RUN mkdir -p /home/gbdev/gameboy-project/{src,include,build,assets,tools}

# Set working directory for the project
WORKDIR /home/gbdev/gameboy-project

# Copy development files when container starts
VOLUME ["/home/gbdev/gameboy-project"]

# Default command
CMD ["/bin/bash"]
```

This all worked much smoother than I expected! Using Claude Code, prompting it to do small steps in plan mode (so I could check what was about to happen and if it made sense), this application came together nicely. Claude would run GBDK tools like `png2asset` to convert my images to tiles compatible with the Game Boy. Code to display graphics, pop up menus and transition between screens was also generated without huge issues. Some things, like clearing the screen with the background tiles after closing a menu, you have to handle explicitly and Claude often omitted these steps. Though once I got a handle on what caused some of the graphical issues, I was able to prompt Claude to fix them.

Probably the trickiest part was sound. For graphics you can rely on AI to generate artwork, and I have just enough experience with [GIMP](https://www.gimp.org/) to clean that up. But sound is another matter — using hUGETracker is quite the challenge, though I got something out I considered good enough. 

So this test checked most of my boxes: I got some rudimentary graphics running (however, only using the background layer, no sprites yet) and had basic sound and a pretty solid menu implementation. This gave me some more hope that this idea was actually feasible and in a reasonable timeframe. 

## Building the AI Opponent in Python

While the Royal Game of Ur is a dice-based game and there is some luck involved, there is more strategy to it than you might expect. Since you can have multiple pieces on the board and choose which one to move, there's room to position pieces strategically and set up captures more efficiently. 

So before starting, I wanted to explore options to implement an AI for the CPU opponent. Check if I could come up with a few different playstyles, test how well these worked and optimize parameters. This I opted to do in Python, the language I'm most familiar with, so it makes sense to prototype in this environment. This might warrant an entire post dedicated to it by itself, but the concept is relatively simple and very much in line with [my post about using an agent-based model]({% post_url 2020/2020-11-11-Gwent-Pro-Rank-ABM %}), except here we're not simulating a game ... the agents will actually play a game. Different agents can use different strategies (or the same strategy with different parameters), which allows me to pick a few options to include in the Game Boy ROM. I ultimately landed on four strategies that were conceptually distinct enough to link to four different CPU opponents in the game. Those strategies also match the characters' backgrounds — the merchant, for instance, uses a greedy strategy that goes for the best move in the short run.

The AI strategies and the groundwork from Zen Garden gave me the confidence I needed. Now came the real challenge: turning all of this into a polished Game Boy game.

## Building the Game: Menus, Graphics, and Controls

For most games there are a few screens to go through before the game is started. That is the case here as well: you are first welcomed with a title screen where you can start the game, then you pick the opponent, the difficulty, your side (dark/light) and then the game starts. This is a simple logic and allows building up to implementing the actual game, where we'll need to show the board, the pieces, the dice, ... But also implement the UI to select which move to make, ... 



<!--
The main development phase — break this into logical chunks:

### Menu System
- Title screen, difficulty selection, game mode selection
- Navigating Game Boy UI constraints (no touch, limited buttons)

### The Game Board
- Designing the board layout for a 160×144 pixel screen
- Tile design and sprite work: fitting an ancient board game 
  into the Game Boy's aesthetic
- Representing game state visually: pieces, valid moves, dice rolls

### Controls
- Mapping a board game's interactions to a D-pad and two buttons
- Making move selection intuitive despite the limited input
-->

## Multiplayer: Adding Link Cable Support

Around the time I had a working version, I was thinking about wrapping it up and calling it good. Though this could be a two player game with link cable support ... Given that the Game Boy link cable system is essentially a direct connection between the two console's CPUs, this is somewhat easier said then done, you'd really have to implement the whole communication protocol. However, Antropic released Opus 4.6 and gifted 50$ worth of API credits for users to play with the new model. With a stronger model and the extra credits, I decided to give it a go! 

This certainly was the most challenging part of implementing this game! More then once, large chunck of code needed to be refactored, the logic how the two devices should communicate wasn't obvious, and testing was time consuming. Claude's changes often had to be reverted as even the Opus 4.6 model with high effort couldn't always figure out the correct implementation. Despite having to take a step or two back every once and a while, by testing the code, checking the implementation and pushing the model in the right direction it ultimately worked. 

To test this, the [Emulicious](https://emulicious.net/) emulator should be used. On my system BGB couldn't connect two instances ... 



## Sound and Music

<!--
The audio layer:
- The Game Boy's sound hardware: four channels, what each can do
- How you composed or created the music and sound effects
- Tools used for sound design
- Balancing audio with the rest of the ROM's memory budget
-->

## What I Learned

<!--
Reflections and takeaways:

### On Agentic Coding
- Where AI-assisted development shone (boilerplate, unfamiliar APIs, 
  debugging cryptic errors)
- Where it struggled (hardware-specific quirks, niche platform knowledge)
- Would you use this approach again for unfamiliar platforms?

### A New Appreciation for Game Boy Games
- Now that you understand the hardware constraints firsthand, 
  specific games impress you in new ways:
  - Jurassic Park: the character walking *under* trees — how layering 
    and window tricks make that possible
  - Pokémon Gold/Silver/Crystal: the sheer scale of content squeezed 
    into a tiny ROM
  - Donkey Kong Land: impressive graphical fidelity given the hardware
  - (add more examples as you like)
- The gap between "playing" and "understanding" a platform

### On the Royal Game of Ur Itself
- Did building it deepen your understanding or appreciation of the game?
- Any historical or mechanical insights that surprised you?
-->


## Acknowledgements

The header image was generated using [Gemini](https://gemini.google.com/app) starting from a [public domain image](https://commons.wikimedia.org/wiki/File:British_Museum_Royal_Game_of_Ur.jpg)


