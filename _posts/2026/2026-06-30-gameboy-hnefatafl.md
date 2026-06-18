---
layout: post
title:  "Hnefatafl, Viking Chess for Game Boy"
byline: "Building Hnefatafl, Brandubh, and Tablut for the original Game Boy"
description: "Building Hnefatafl, the Viking Chess game, along with Brandubh and Tablut, for the original Game Boy, exploring background scrolling, save systems, and Super Game Boy support."
date:   2026-06-30 08:00:00
author: Sebastian Proost
categories: ai programming games
tags:	python c nintendo gameboy retrogaming homebrew ai claude-code agent-based-modeling
cover:  "/assets/posts/2026-06-30-gameboy-hnefatafl/hnefatafl_pieces.jpg"
thumbnail: "/assets/images/thumbnails/hnefatafl_pieces.jpg"
---

On [The Royal Game of Ur]({% post_url 2026/2026-03-15-gameboy-royal-game-of-ur %}), the link cable nearly broke me. It was by far the hardest feature of that project, burning through most of $50 in API credits before it finally worked. Music was a close second, the part I was least happy with. So when I set out to port the family of [Tafl games](https://en.wikipedia.org/wiki/Tafl_games) to the original Game Boy, I half expected those same walls.

![A game of Tablut in progress on the Game Boy](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/game_playing.jpg){:.small-image}

They didn't show up. The features that had been the most painful last time turned out to be among the smoothest this time, and the reason why is the story of this project. Some of it is a stronger model, some of it is me knowing the system better, but the biggest factor was planning: laying the groundwork before writing a single line of game logic. More on that below, but first, the game.

[Hnefatafl](https://en.wikipedia.org/wiki/Tafl_games#Hnefatafl), the Viking board game known as Viking Chess, and its cousins [Brandubh](https://en.wikipedia.org/wiki/Tafl_games#Brandubh) (Irish) and [Tablut](https://en.wikipedia.org/wiki/Tafl_games#Tablut) (Sámi) now all run on the original Game Boy. Beyond the link cable and music, I still had a few corners of DMG development left unexplored: background scrolling, scanline-based effects, a save system, Super Game Boy support, and multiple memory banks. Porting this family of historic games gave me the perfect excuse to dig into all of it.

![The Hnefatafl title screen running on a Game Boy](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/title_screen.jpg){:.small-image}

Want to try the game? [Download Hnefatafl on itch.io](https://sebastianproost.itch.io/hnefatafl-viking-chess) for free!

<div style="text-align: center;">
<iframe frameborder="0" src="https://itch.io/embed/4667078?link_color=5ba9fa" width="552" height="167"  style="max-width: 100%;"><a href="https://sebastianproost.itch.io/hnefatafl-viking-chess">Hnefatafl - Viking Chess by sebastian.proost</a></iframe>
</div>


## The Tafl Family: Hnefatafl, Brandubh, and Tablut

Long before chess arrived in Northern Europe, the Tafl games were *the* board games to play, for roughly a thousand years from around the 4th to the 12th century. "Tafl" just means "board" or "table" in Old Norse, and as the Vikings travelled and traded, the game travelled with them, picking up local flavors along the way: Hnefatafl ("the king's table") in Scandinavia, Brandubh ("black raven") in Ireland, and Tablut among the Sámi in the far north of Scandinavia. None of these games survived as a living tradition, what we know of the rules comes from a patchwork of old manuscripts, fragments of boards, and one famous, slightly ambiguous description written down by [Carl Linnaeus](https://en.wikipedia.org/wiki/Carl_Linnaeus) during his travels through Lapland in 1732.

What makes the Tafl games so different from chess is the asymmetry. Rather than two mirrored armies, you get a king and a small group of defenders huddled in the centre of the board, surrounded on all sides by a much larger force of attackers. The attackers win by trapping the king so he can't move, while the defenders win by getting him to safety on one of the board's edges or corners, depending on the variant. Captures work by "sandwiching" a piece between two of your opponent's pieces along a row or column, easy enough to explain, but the lopsided starting position means attackers and defenders need almost completely different strategies, which makes for a surprisingly deep little game given how few rules there are.

The variants mostly differ in board size, and that turned out to matter quite a bit for a Game Boy port. Brandubh is played on a tidy 7x7 board, Tablut on 9x9, and Hnefatafl, in the most common modern reconstruction, on 11x11. The Game Boy's 160x144 pixel screen works out to a 20x18 tile grid, so even the 11x11 Hnefatafl board fits, but only if every square maps to a single 8x8 pixel tile with nothing larger. That ruled out giving each square its own bigger, more detailed tile, an approach that would have worked fine for Brandubh's 7x7 or Tablut's 9x9 board, and meant the board art and pieces all had to stay legible at 8x8 pixels.

## One Engine, Three Rulesets

![Boxart for a homebrew game boy game Hnefatafl](/assets/posts/2026-06-30-gameboy-hnefatafl/hnefatafl_boxart.jpg){:.medium-image}

Before writing a line of GBDK code, I built the game engine in Python: board state, move validation, capture rules, and win conditions for all three variants, parameterized by board size and starting layout. That gave me a fast environment to write AI agents and pit them against each other, tuning move-selection strategies for Hnefatafl, Brandubh, and Tablut. This Python implementation then became the starting point for the C port, same rules and structure, translated to the constraints of the hardware. This is the same approach I used previously and it works incredibly well; I've [written before about how well Claude can port code from Python to other languages]({% post_url 2025/2025-12-20-rust-experiment %}).

Porting core logic to C is exactly the kind of place where small mistakes, an off-by-one in a capture check, a sign error in a direction vector, quietly break a game. So this time I had Claude add unit tests for the C implementation, and the approach it came up with was clever: the Python engine, already battle-tested from the agent-vs-agent runs, generates test fixtures (board states, moves, expected outcomes), which get compiled together with the C code into a small standalone binary. Running that binary replays the same scenarios through the C logic and compares the results against the Python-generated expectations, catching divergences before they ever show up on actual hardware. A neat trick, and exactly the kind of safety net I wish I'd had on the previous project.



<div class="gallery-3-col" markdown="1">
![Menu showing Brandubh option](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_brandubh.jpg)
![Menu showing Tablut option](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_tablut.jpg)
![Menu showing Hnefatafl option](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_hnefatafl.jpg)
</div>

## Planning Made the Difference

If there's one thing that separated this project from the last, it's how much groundwork I laid before any game code existed. On the Royal Game of Ur I learned the hard way that feeding assets to an agent one image at a time leads to grief; this time I front-loaded the planning, and almost every "it just worked" moment later in the project traces back to it.

I improved in two concrete ways. First, I did far more planning with Claude up front: I prepared a handoff HTML document with detailed descriptions of how I wanted things implemented, which assets I would provide, and exactly how each should be used. Then I created those assets to match the spec, rather than improvising them as I went. Laying out full tile and sprite sheets ahead of time meant Claude Code could confidently reuse existing tiles instead of generating new ones, which paid off in ways I didn't fully anticipate (the Super Game Boy border below is the clearest example).

Second, I got a lot better at preparing the art itself, converting images to clean 2-bit indexed PNGs that `png2asset` could ingest without any hiccups. That one change removed a whole category of asset-pipeline friction that had dogged the previous project.

The other thing I could lean on this time was the source code from the Royal Game of Ur. The link cable mode there took endless back and forth to get right. This time I simply pointed Claude at that earlier implementation and asked it to reuse the best parts and adapt them. It worked after 3-4 iterations, where last time it had taken weeks and most of those API credits. That contrast, the previous project's biggest headache becoming one of this project's smoothest features, set the tone for everything that followed.

## Visual Effects: Background Scrolling and Scanlines

While I haven't decided yet what type of game I ultimately want to make, I know single static screens won't do. I want the player to be able to explore a world without too many interruptions, which means building a large map in the background layer and moving it around. For a board game that isn't required during play, but there's no reason the menu can't be a bit nicer, with images sliding as the player selects a different option.

<video style="display:block; margin:0 auto; width:100%; max-width:464px; max-height:464px;" controls>Your browser does not support the &lt;video&gt; tag.
    <source src="{{site.baseurl}}/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_animation.mp4"/>
</video>


I also played around with scanline effects, where you scroll the background at a specific point while the screen is being redrawn. Old racing games used this trick to draw curved tracks, you see it whenever water ripples at the bottom of the screen while the sky stays static, and some of the attacks in Pokémon are animated this way too. I got it running, but the effect didn't really fit a board game, so it didn't make the cut. Still, it's exactly the kind of trick I'll want in the toolbox for that bigger, more exploratory game down the line.

## Saving Stats and Memory Banks

Since a round of Tafl doesn't take long, saving a game in the middle didn't make much sense. So as an excuse to work with the battery-backed SRAM, I decided to keep lifetime win/loss tallies instead. On the previous project a save system was something I'd flagged as "next time" work and expected to wrestle with. Here it was almost anticlimactic: Claude handled the read/write and persistence logic without much fuss.

![The stats screen](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/stats_screen.jpg){:.small-image}

Cartridges with SRAM also tend to come with multiple ROM banks (and I do want to make physical copies of these games at some point), and that extra headroom opened the door to more elaborate artwork for the side-select and win/loss screens than I'd otherwise have been able to fit. What surprised me most was how well Claude managed the bank-switching itself; memory layout across banks is exactly the kind of bookkeeping that's easy to get subtly wrong. To catch issues early, it built a small memory-bank agent that runs on every build, checking that everything is laid out correctly and flagging any overlaps or overflows before they turn into a hard-to-debug crash on hardware.

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

This is the feature where the planning really showed its value. Last time I tried adding a border that appears around the game screen when a Super Game Boy is used (or, more likely, emulated), but I ran into a wall. That ROM targeted the simplest cartridge, and there just wasn't enough memory left over to fit the extra data the border needed.

![Hnefatafl running in an emulator with the SGB border visible](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/sbg_support.jpg){:.medium-image}

This time I'm targeting a more advanced cartridge with multiple banks, which has plenty of headroom for SGB support, especially since the border could mostly reuse tiles I'd already laid out for the board. Here the latest Opus model (4.8) really impressed me. I described what I wanted, a Hnefatafl board split diagonally with one half in the top left and the other in the bottom right, and from that description alone it created a PNG, converted the asset, recognized that those tiles were already available, and implemented the border. When I then asked for a splash of color, that got added too, without any hiccups. That only worked because the tiles were sitting there ready to be reused, exactly the payoff I was hoping for from all the up-front planning.


## Sound and Music

Music was the other feature I dreaded after last time, when Claude couldn't get my songs into a format [hUGETracker](https://github.com/SuperDisk/hUGETracker) would load. One advantage here is that there are known Scandinavian melodies I could use royalty free, so I started there and found a few candidates: [*Drömde mig en dröm i nat*](https://en.wikipedia.org/wiki/Dr%C3%B8mde_mik_en_dr%C3%B8m_i_nat) (a medieval Nordic ballad, the oldest known secular song in Scandinavia), [*Vem kan segla förutan vind*](https://en.wikipedia.org/wiki/Who_Can_Sail_Without_the_Wind%3F) (a Swedish folk song), and [*Herr Mannelig*](https://en.wikipedia.org/wiki/Herr_Mannelig) (a Swedish medieval ballad).

The melodies that sound Viking-like to me usually have a bowed instrument that can sustain low notes for a long time. That sound comes from a bass tagelharpa, which is a bit bigger and lower than the more historically correct versions. Percussion is another modern addition; I wanted a bit of a beat, even though it doesn't seem to have been common in traditional Nordic music. The melody itself is often carried by shrill flutes.

The difference from last time came down to knowing what I wanted before I asked for it. I described which instruments to emulate and how to map them onto the Game Boy's channels: droning bowed strings on the wave channel, the flute melody on a pulse channel, and the noise channel for percussion, leaving CH1 free for in-game SFX. With that prompt, and after a few tries, I got working `.uge` files back. A few tweaks later in hUGETracker and they were ready to drop into the game.

## What I Learned

The throughline of this whole project is that planning turns hard problems into easy ones. Laying out full tile and sprite sheets before writing any game logic meant Claude Code could confidently reuse tiles instead of generating new ones, which is exactly what made the Super Game Boy border come together so quickly. Knowing up front which instruments I wanted and how to map them to channels is what finally got music working. And describing assets in a detailed handoff document before building them kept the whole asset pipeline from snagging the way it had before.

The other half is experience, on both sides. After a full project's worth of GBDK work, I simply know the lingo better, SCX/SCY, STAT interrupts, VRAM banks, so I can ask for the right things. And the newer Opus model (4.8) clearly handles this kind of low-level work better too. The link cable code is the clearest case of everything coming together: on the Royal Game of Ur it was the most painful feature by far, burning through most of that $50 in API credits before it worked. This time I pointed Claude Code at the earlier implementation, iterated a handful of times, and got a reliable version back. Last project's biggest headache became one of this project's smoothest features, and music, usually the weakest link in my games, got a similar boost.

Taken together, these wins leave me a lot more confident that bigger, more ambitious handheld projects are well within reach. I'm not sure yet what that next one will be, but I'm increasingly convinced the Game Boy still has plenty left to give.


## Disclaimer

The game pieces depicted in the header and thumbnail of this post were AI generated. These were then further processed into the resulting box art and the art included in the game.
