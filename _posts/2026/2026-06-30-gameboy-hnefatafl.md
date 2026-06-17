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

[Hnefatafl](https://en.wikipedia.org/wiki/Tafl_games#Hnefatafl), the Viking board game known as Viking Chess, and its cousins [Brandubh](https://en.wikipedia.org/wiki/Tafl_games#Brandubh) (Irish) and [Tablut](https://en.wikipedia.org/wiki/Tafl_games#Tablut) (Sámi) now run on the original Game Boy. After finishing [The Royal Game of Ur]({% post_url 2026/2026-03-15-gameboy-royal-game-of-ur %}), I still had a few corners of DMG Game Boy development left unexplored before moving on to something bigger: background scrolling, scanline-based effects, a save system, Super Game Boy support, multiple memory banks and decent music ... and my asset pipeline could use some work too. Porting this family of historic Tafl games gave me the perfect excuse to dig into all of it.

<!-- Want to try the game! Link to itch.io + embed, and GitHub repo link, once published (mirrors the Royal Game of Ur post intro). -->

![Boxart for a homebrew game boy game Hnefatafl](/assets/posts/2026-06-30-gameboy-hnefatafl/hnefatafl_boxart.jpg){:.medium-image}

## The Tafl Family: Hnefatafl, Brandubh, and Tablut

Long before chess arrived in Northern Europe, the Tafl games were *the* board games to play, for roughly a thousand years from around the 4th to the 12th century. "Tafl" just means "board" or "table" in Old Norse, and as the Vikings travelled and traded, the game travelled with them, picking up local flavors along the way: Hnefatafl ("the king's table") in Scandinavia, Brandubh ("black raven") in Ireland, and Tablut among the Sámi in the far north of Scandinavia. None of these games survived as a living tradition, what we know of the rules comes from a patchwork of old manuscripts, fragments of boards, and one famous, slightly ambiguous description written down by Carl Linnaeus during his travels through Lapland in 1732.

What makes the Tafl games so different from chess is the asymmetry. Rather than two mirrored armies, you get a king and a small group of defenders huddled in the centre of the board, surrounded on all sides by a much larger force of attackers. The attackers win by trapping the king so he can't move, while the defenders win by getting him to safety on one of the board's edges or corners, depending on the variant. Captures work by "sandwiching" a piece between two of your opponent's pieces along a row or column, easy enough to explain, but the lopsided starting position means attackers and defenders need almost completely different strategies, which makes for a surprisingly deep little game given how few rules there are.

The variants mostly differ in board size, and that turned out to matter quite a bit for a Game Boy port. Brandubh is played on a tidy 7x7 board, Tablut on 9x9, and Hnefatafl, in the most common modern reconstruction, on 11x11. The Game Boy's 160x144 pixel screen works out to a 20x18 tile grid, so even the 11x11 Hnefatafl board fits, but only if every square maps to a single 8x8 pixel tile with nothing larger. That ruled out giving each square its own bigger, more detailed tile, an approach that would have worked fine for Brandubh's 7x7 or Tablut's 9x9 board, and meant the board art and pieces all had to stay legible at 8x8 pixels.

## One Engine, Three Rulesets

Before writing a line of GBDK code, I built the game engine in Python: board state, move validation, capture rules, and win conditions for all three variants, parameterized by board size and starting layout. That gave me a fast environment to write AI agents and pit them against each other, tuning move-selection strategies for Hnefatafl, Brandubh, and Tablut. This Python implementation then became the starting point for the C port, same rules and structure, translated to the constraints of the hardware.

Porting core logic to C is exactly the kind of place where small mistakes, an off-by-one in a capture check, a sign error in a direction vector, quietly break a game. So this time I had Claude add unit tests for the C implementation, and the approach it came up with was clever: the Python engine, already battle-tested from the agent-vs-agent runs, generates test fixtures (board states, moves, expected outcomes), which get compiled together with the C code into a small standalone binary. Running that binary replays the same scenarios through the C logic and compares the results against the Python-generated expectations, catching divergences before they ever show up on actual hardware. A neat trick, and exactly the kind of safety net I wish I'd had on the previous project.


## A Better Asset Pipeline
<!--
- What was painful about asset creation/management in the Royal Game of Ur project
- New tools/workflow adopted this time (tile/sprite export, palettes, automation scripts)
- Before/after comparison if useful
-->

## Visual Effects: Background Scrolling and Scanlines
<!--
- Where scrolling is used (board larger than the viewport? menus/transitions?)
- How it's implemented on hardware (SCX/SCY registers, etc.)
- What the scanline-based effect does and how it's achieved (STAT interrupts, per-row palette/background changes)
-->

## Saving Stats and Memory Banks

Since a round of Tafl doesn't take long, saving it in the middle didn't make much sense.  So as an excuse to add something that required reading/writing the battery-backed SRAM, I decided to keep track of lifetime win/loss tallies. Wiring that up turned out to be almost anticlimactic, it just worked, with Claude handling the read/write and persistence logic without much fuss.

Cartridges with SRAM also tend to come with multiple ROM banks (and I do want to make physical copies of these games at one point), and that extra headroom opened the door to more elaborate artwork for the side-select and win/loss screens than I'd have been able to fit otherwise. What surprised me most was how well Claude managed the bank-switching itself, memory layout across banks is exactly the kind of bookkeeping that's easy to get subtly wrong. To catch issues early, it built a small memory-bank agent that runs on every build, checking that everything is laid out correctly and flagging any overlaps or overflows before they turn into a hard-to-debug crash on hardware.


## Super Game Boy Support

Last time I tried adding a border that appears around the game screen when a Super Game Boy is used (or, more likely, emulated), but I ran into a wall. That ROM was targeting the simplest cartridge, and there just wasn't enough memory left over to fit the extra data the border needed.

![Hnefatafl running in an emulator with the SGB border visible](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/sbg_support.jpg)

This time I'm targeting a more advanced cartridge with multiple banks, which has plenty of headroom for SGB support, especially since I'd mostly be reusing tiles from the board. Here the latest Opus model (4.8) really impressed me. I described what I wanted, a Hnefatafl board split diagonally with one half in the top left and the other in the bottom right, and from that description alone it created a png, converted the asset, picked up that those tiles were already available, and implemented the border. When I then asked for a splash of color, that got added too, without any hiccups!


## Sound and Music

One advantage here is that there are known Scandinavian melodies which also can be used royalty free. So I started there and found a few candidates: [*Drömde mig en dröm i nat*](https://en.wikipedia.org/wiki/Dr%C3%B8mde_mik_en_dr%C3%B8m_i_nat) (a medieval Nordic ballad, the oldest known secular song in Scandinavia), [*Vem kan segla förutan vind*](https://en.wikipedia.org/wiki/Who_Can_Sail_Without_the_Wind%3F) (a Swedish folk song), and [*Herr Mannelig*](https://en.wikipedia.org/wiki/Herr_Mannelig) (a Swedish medieval ballad). Melodies that sound viking-like to me always have some type of bowed instrument which can sustain low notes very long, this is made using a bass tagelharpa. Which is a bit bigger and produces a lower sound than the more historically correct versions. Another modern addition is percussion, I liked to have a bit of a beat, but it seems this wasn't common in nordic traditional music. For the melody often shrill flutes are used

Last time Claude wasn't able to convert the songs to something [hUGEtracker](https://github.com/SuperDisk/hUGETracker) could load. This time, I knew which instruments I wanted to emulate, how I wanted them mapped onto the Game Boy's channels: droning bowed strings on the wave channel, the flute melody on a pulse channel, and the noise channel for percussion, while leaving CH1 free for in-game SFX. With this prompt, after a few tries, I got working .uge files back! A few tweaks later with hUGEtracker and they were ready to be added to the game. 

## What I Learned

Planning paid off on two fronts. Laying out full tile and sprite sheets before writing any game logic meant Claude Code could reuse tiles confidently instead of generating new ones, which is exactly what made the Super Game Boy border come together so quickly. On my side, after a full project's worth of GBDK work, I know the lingo better, SCX/SCY, STAT interrupts, VRAM banks, and the newer Opus model (4.8) clearly handles this kind of low-level work better too.

That combination paid off most with the link cable code: on the Royal Game of Ur this was by far the hardest part, burning through most of that $50 in API credits. This time, pointing Claude Code at that earlier implementation and iterating a handful of times produced a reliable version, turning last project's most painful feature into one of this project's smoothest. Music, often the weakest link in my games, got a similar boost. Together, these wins give me a lot more confidence that bigger, more ambitious handheld projects are within reach.


## Disclaimer

The game pieces depicted in the header and thumbnail of this post were AI generated. These were then further processed into the resulting box art and art included in the game. 
