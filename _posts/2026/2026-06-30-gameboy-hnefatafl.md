---
layout: post
title:  "Hnefatafl, Viking Chess for Game Boy"
byline: "Building Hnefatafl, Brandubh, and Tablut for the original Game Boy"
description: "Building Hnefatafl, the Viking Chess game, along with Brandubh and Tablut, for the original Game Boy, exploring background scrolling, save systems, and Super Game Boy support."
date:   2026-06-30 08:00:00
author: Sebastian Proost
post_id: gameboy-hnefatafl
categories: ai programming games
tags:	python c nintendo gameboy retrogaming homebrew ai claude-code agent-based-modeling
cover:  "/assets/posts/2026-06-30-gameboy-hnefatafl/hnefatafl_pieces.jpg"
thumbnail: "/assets/images/thumbnails/hnefatafl_pieces.jpg"
---

On [The Royal Game of Ur]({% post_url 2026/2026-03-15-gameboy-royal-game-of-ur %}), getting two Game Boys to talk to each other using the link cable proved to be quite difficult. I got $50 worth of tokens and burned them all on this feature. Getting semi-decent music was a hurdle too, and I'm still not quite happy with the result. So when I set out to port the family of [Tafl games](https://en.wikipedia.org/wiki/Tafl_games) to the original Game Boy, I half expected hitting these same walls again. Though with some more experience under my belt and a better understanding of the system as well as agentic coding, this time around things might also be different...

![A game of Tablut in progress on the Game Boy](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/game_playing.jpg){:.small-image}

... and they were! With improved tools and better knowledge how to wield them implementing these games turned out to be a breeze. In this post I'll discuss how I got [Hnefatafl](https://en.wikipedia.org/wiki/Tafl_games#Hnefatafl), the Viking board game known as Viking Chess, and its cousins [Brandubh](https://en.wikipedia.org/wiki/Tafl_games#Brandubh) (Irish) and [Tablut](https://en.wikipedia.org/wiki/Tafl_games#Tablut) (Sámi) now all running on the original Game Boy. Which also allowed me to explore a few corners of DMG development I didn't previously touch: background scrolling, scanline-based effects, a save system, Super Game Boy support, and multiple memory banks.

![The Hnefatafl title screen running on a Game Boy](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/title_screen.jpg){:.small-image}

Want to try the game? [Download Hnefatafl on itch.io](https://sebastianproost.itch.io/hnefatafl-viking-chess) for free!

<div style="text-align: center;">
<iframe frameborder="0" src="https://itch.io/embed/4667078?link_color=5ba9fa" width="552" height="167"  style="max-width: 100%;"><a href="https://sebastianproost.itch.io/hnefatafl-viking-chess">Hnefatafl - Viking Chess by sebastian.proost</a></iframe>
</div>


## The Tafl Family: Hnefatafl, Brandubh, and Tablut

These Tafl games were *the* board games to play, for roughly a thousand years from around the 4th to the 12th century. "Tafl" just means "board" or "table" in Old Norse, and as the Vikings travelled and traded, the game travelled with them, picking up local flavors along the way: Hnefatafl ("the king's table") in Scandinavia, Brandubh ("black raven") in Ireland, and Tablut among the Sámi in the far north of Scandinavia. None of these games survived, so what we know of the rules comes from a patchwork of old manuscripts, fragments of boards, and one famous, slightly ambiguous description written down by [Carl Linnaeus](https://en.wikipedia.org/wiki/Carl_Linnaeus) during his travels through Lapland in 1732. So the modern games' rules are an educated guess, but are likely not too far from the original.

What makes the Tafl games so different from chess is the asymmetry. Rather than two identical armies facing each other, players each play a different role. One gets a king and a small group of defenders huddled in the centre of the board, surrounded on all sides by the other player's attackers. The attackers win by trapping the king so he can't move, while the defenders win by getting him to safety on one of the board's edges or corners. Captures work by "sandwiching" an opponent's piece between two of yours along a row or column, easy enough to explain, but the lopsided starting position means attackers and defenders need almost completely different strategies, which makes for surprisingly deep gameplay.

The variants mostly differ in board size, and that turned out to matter quite a bit for a Game Boy port. Brandubh is played on a tidy 7x7 board, Tablut on 9x9, and Hnefatafl, in the most common modern reconstruction, on 11x11. The Game Boy's 160x144 pixel screen works out to a 20x18 grid of 8x8 pixel tiles, so even the 11x11 Hnefatafl board fits, but only if every square maps to a single tile with nothing larger. As I wanted to support all games using the same tileset, I opted to make each board square a single tile and all art hence had to be legible at that 8x8 pixel size.

## One Engine, Three Rulesets

![Boxart for a homebrew game boy game Hnefatafl](/assets/posts/2026-06-30-gameboy-hnefatafl/hnefatafl_boxart.jpg){:.medium-image}

Before writing a line of GBDK code, I built the game engine in Python: board state, move validation, capture rules, and win conditions for all three variants, parameterized by board size and starting layout. That gave me a fast environment to write AI agents and pit them against each other, tuning move-selection strategies for Hnefatafl, Brandubh, and Tablut. This Python implementation then became the starting point for the C port, same rules and structure, translated to the constraints of the hardware. I've [written before about how well Claude can port code from Python to other languages]({% post_url 2025/2025-12-20-rust-experiment %}), and this is a solid approach when working with agentic coding, get a prototype running in an environment you are familiar with, hammer out the details and iron out the kinks, then port the thing to a better suited framework. 

Unit tests can be extremely valuable, though I didn't consider them for the previous game. This time I had Claude add unit tests for the C implementation, and the approach it came up with was clever: the Python engine, already battle-tested from the agent-vs-agent runs, generates test fixtures (board states, moves, expected outcomes), which get compiled together with the C code into a small standalone binary. Running that binary replays the same scenarios through the C logic and compares the results against the Python-generated outcome. Truth be told, this is a strategy I wouldn't have come up with myself, but it makes so much sense for this use-case.



<div class="gallery-3-col" markdown="1">
![Menu showing Brandubh option](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_brandubh.jpg)
![Menu showing Tablut option](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_tablut.jpg)
![Menu showing Hnefatafl option](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_hnefatafl.jpg)
</div>

## Planning Made a Huge Difference

If there's one more thing that separated this project from the last, it's how much groundwork I laid before any game code existed! On the Royal Game of Ur I learned a lot of things by trial and error, I often committed to sub-optimal strategies, which caused unexpected issues later on. The way I provided assets for the board was a bit short-sighted and came back to haunt me, this time I planned ahead considerably more, and a lot of features that this time around "it just worked" can be traced back to this upfront effort.

In practice I started with Claude using the chat, I didn't dive into the code directly. Based on that conversation, the feature set was decided along with specs, the assets which needed to be provided and more. This was finally turned into a handoff HTML document with detailed descriptions that are easy to read for me while also being a guide for agents to implement. Then I created those assets to match the spec, rather than improvising them as I went. This made it far easier to reuse tiles (important to save memory on these old systems), draw the boards correctly and link the game state with them. I got a lot better at preparing the art itself, converting images to clean 2-bit indexed PNGs that `png2asset` could ingest without any hiccups. 

The other thing I could lean on this time was the source code from the Royal Game of Ur. The link-cable mode there took endless back and forth to get right. This time I simply pointed Claude at that earlier implementation and asked it to reuse the best parts and adapt them. It worked perfectly after 3-4 iterations in a single session, where last time it took over a week and burned through $50 of additional tokens (that I got for free). So if you can point an LLM to a working example, do it — the payoff here was substantial (and to be honest, if I were to implement this myself, I would appreciate working examples too).

## Visual Effects: Background Scrolling and Scanlines

While I haven't decided yet what type of game I ultimately want to make, I know single static screens won't do. I want the player to be able to explore a world without too many interruptions (think Pokémon), which means building a large map in the background layer and moving it around. For a board game that isn't required during play, but there's no reason the menu can't be a bit nicer, with images sliding as the player selects a different option.

<video style="display:block; margin:0 auto; width:100%; max-width:464px; max-height:464px;" controls>Your browser does not support the &lt;video&gt; tag.
    <source src="{{site.baseurl}}/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_animation.mp4"/>
</video>


I also played around with scanline effects, where you shift the background at a specific point while the screen is being redrawn. Old racing games used this trick to draw curved tracks; you can also often see it used for water ripples at the bottom of the screen while the sky stays static, and some of the attacks in Pokémon are animated this way too. I got it running, but the effect didn't really fit a board game, so it didn't make the cut. Still, it's exactly the kind of trick I'll want in the toolbox for later projects.

## Saving Stats and Memory Banks

Since a round of Tafl doesn't take long, saving a game in the middle didn't make much sense. So as an excuse to work with the battery-backed SRAM, I decided to keep lifetime win/loss tallies instead. Given saving data on a cartridge is quite different from a file system, I expected to wrestle with it. Here it was almost anticlimactic: Claude handled the read/write operations without any issues.

![The stats screen](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/stats_screen.jpg){:.small-image}

The most basic Game Boy cartridges have only 32kb of memory, which the CPU can directly read. [The Royal Game of Ur]({% post_url 2026/2026-03-15-gameboy-royal-game-of-ur %}) fits one of those cartridges. Cartridges with SRAM for saving tend to come with multiple 16kb ROM banks; that extra headroom opens the door to more elaborate artwork for the side-select and win/loss screens than I'd otherwise have been able to fit. Though it comes with a tradeoff: the CPU can't read all data at any time, so to read data from a specific bank, that bank needs to be activated first. One bank also can't easily access data from another. What surprised me most was how well Claude managed the bank-switching itself. To catch issues early, it built a small memory-bank agent that runs on every build, checking that everything is laid out correctly and flagging any overlaps or overflows before they turn into a hard-to-debug crash on hardware.

The side-select screens were one place that headroom paid off, each side getting its own character art rather than a plain text prompt.

<div class="gallery-2-col" markdown="1">
![The attacker side-select screen](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_side_attacker.jpg)
![The defender side-select screen](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_side_defender.jpg)
</div>

The win and loss screens got the same treatment, a dedicated end-of-game board state alongside a result screen showing the final tallies.

<div class="gallery-2-col" markdown="1">
![The defender-wins end screen](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/game_lost.jpg)
![The result screen with final tallies](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/result_lost.jpg)
</div>


## Super Game Boy Support

Last time I tried adding a border that appears around the game screen when a Super Game Boy is used (or, more likely, emulated), but I ran into a wall. That ROM targeted the simplest cartridge which in combination with my relatively poor asset management didn't leave enough memory to fit the extra data the border needed.

![Hnefatafl running in an emulator with the SGB border visible](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/sbg_support.jpg){:.medium-image}

This time I'm targeting a more advanced cartridge with multiple banks, which has plenty of headroom for SGB support, especially since the border could mostly reuse tiles I'd already laid out for the board. Here the latest Opus model (4.8) really impressed me. I described what I wanted, a Hnefatafl board split diagonally with one half in the top left and the other in the bottom right, and from that description alone it created a PNG, converted the asset, recognized that those tiles were already available, and implemented the border using the existing tiles. When I then asked for a splash of color, that got added too, without any hiccups.


## Sound and Music

Music was the other feature I dreaded after last time, when Claude couldn't get my songs into a format [hUGETracker](https://github.com/SuperDisk/hUGETracker) would load. One advantage here is that there are known Scandinavian melodies I could use royalty free, so I started there and found a few candidates: [*Drömde mig en dröm i nat*](https://en.wikipedia.org/wiki/Dr%C3%B8mde_mik_en_dr%C3%B8m_i_nat) (a medieval Nordic ballad, the oldest known secular song in Scandinavia), [*Vem kan segla förutan vind*](https://en.wikipedia.org/wiki/Who_Can_Sail_Without_the_Wind%3F) (a Swedish folk song), and [*Herr Mannelig*](https://en.wikipedia.org/wiki/Herr_Mannelig) (a Swedish medieval ballad).

The melodies that sound Viking-like to me usually have a bowed instrument that can sustain low notes for a long time. That sound comes from a bass tagelharpa, which is a bit bigger and lower than the more historically correct versions. Percussion is another modern addition; I wanted a bit of a beat, even though it doesn't seem to have been common in traditional Nordic music. The melody itself is often carried by shrill flutes.

The difference from last time came down to knowing what I wanted before I asked for it. I described which instruments to emulate and how to map them onto the Game Boy's channels: droning bowed strings on the wave channel, the flute melody on a pulse channel, and the noise channel for percussion, leaving CH1 free for in-game SFX. With that prompt, and after a few tries, I got working `.uge` files back. A few tweaks later in hUGETracker and they were ready to drop into the game.

## What I Learned

When working with agentic coding the planning turned previously hard problems into easy ones. Laying out full tile and sprite sheets before writing any game logic meant Claude Code could confidently reuse tiles instead of having to figure out if something could be re-used. Knowing up front which instruments I wanted and how to map them to channels is what finally got music working and sounding right.

The other half is experience: after a full project's worth of GBDK work, I simply know the lingo better — SCX/SCY, STAT interrupts, VRAM banks — so I can ask for the things with specific details using the right terms. The newer Opus model (4.8) clearly handles this kind of low-level work better too. The link cable code is the clearest case of everything coming together: on the Royal Game of Ur it was the most time-consuming feature by far. This time I pointed Claude Code at the earlier implementation, iterated a handful of times, and got a reliable version back. Last project's biggest headache became one of this project's smoothest features, and music, usually the weakest link in my games, got a similar boost.

Taken together, these wins leave me a lot more confident that bigger, more ambitious handheld projects are well within reach. I'm not sure yet what that next one will be, but I'm increasingly convinced the Game Boy still has plenty left to give.


## Disclaimer

The game pieces depicted in the header and thumbnail of this post were AI generated. These were then further processed into the resulting box art and the art included in the game.
