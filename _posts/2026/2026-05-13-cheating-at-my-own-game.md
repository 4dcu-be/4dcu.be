---
layout: post
title:  "Creating Cheats for my Own Game Boy Game"
byline: "by probing and poking the ROM and RAM"
date:   2026-05-13 08:00:00
author: Sebastian Proost
categories: games
tags:	nintendo gameboy retrogaming homebrew
cover:  "/assets/posts/2026-05-13-cheating-at-my-own-game/game_genie_header.jpg"
thumbnail: "/assets/images/thumbnails/game_genie.jpg"
---

While the computer games I played in my childhood often came with cheat codes baked into the game that allowed you to pass parts where you got stuck, for handhelds like the Game Boy specialized hardware was needed. One of my most prized possessions from my childhood was such a device, the Game Genie, a large gray device that would sit on top of the Game Boy and physically slot between the cartridge and the console. When starting the device you needed to enter a number of codes which would change small parts of the game; you'd have infinite lives, wouldn't take damage, deal more damage, ... I had no idea how it worked, but I was very glad I owned one as it allowed me to get to the end credits of some games (like the notoriously difficult Gremlins 2) which 9-year-old me never would have been able to beat.

In this post I want to do a deep dive into these devices, see how they actually worked, and see if we can create some functional cheat codes for my very own Game Boy game "The Royal Game of Ur" which I covered a few months ago.

## The Royal Game of Ur for Game Boy

In a [previous]({% post_url 2026/2026-03-15-gameboy-royal-game-of-ur  %}) post I walked you through my journey developing a Game Boy game from scratch, albeit with some serious assistance from Agentic Coding. This is an ancient board game, "The Royal Game of Ur", adapted for the DMG Game Boy. The game can currently be downloaded from [itch.io](https://sebastianproost.itch.io/the-royal-game-of-ur). It is essentially a racing game: each player starts with seven pieces in a reserve pile and has to move them along a 14-tile route around the board, with the goal of being the first to get all seven pieces off the far end into the finished pile. Their tracks overlap in the middle of the board, where pieces can capture each other and send the captured piece back to its owner's reserve. While it is fairly easy to beat the CPU opponent on easy, and there is no content which unlocks after winning a game, so there is no real reason to cheat... I want to see if I can do so anyway! Given this is my first ever attempt to make any sense of a system's memory with this type of debugger, I also wanted to do this on a project where I know how things are implemented and can consult the source code if needed.

## Game Genie vs Action Replay/GameShark

There were different devices on the market and, while they all slot in between the console and cartridge and accept codes that change something, they actually leverage different tricks to create a cheat.

The Game Genie essentially applies a patch to the ROM (address range `$0002-$7FFF`): a code references an address in the ROM bank and a value to change that into. This allows you to change values within the ROM or disable functions (e.g. no life loss when taking damage). On real hardware the Game Genie only accepted three codes at a time, so you had to pick your cheats carefully; emulators have no such limit.

On the other hand, there are devices which target the RAM (addresses `$8000+`) ; depending on where you would pick one up this would be branded Action Replay or GameShark. Here a code points to a location in RAM and overwrites that value at specific points (each frame at VBlank). This can achieve similar effects: since it resets your life total to max each frame you become invulnerable, it can enable power-ups you didn't pick up yet, ... it can directly manipulate the game state. These devices also had a code limit: four codes at a time on the DMG Game Boy, emulators, of course, ignore the limit entirely.

The RAM seemed more comprehensible than opcodes in the ROM, so I decided to start tinkering there first.

## Hacking my Own Game's RAM

As I wanted to mess with the game's state to prevent the opponent from winning, the RAM seemed like a good place to start. That means we need an emulator which allows the memory to be searched and tampered with; [BGB](https://bgb.bircd.org/) is a solid choice for this, it helped me a lot fixing issues related with tiles (VRAM) when making the game and allows the memory (ROM and RAM) to be inspected and manipulated. 

The game tracks how many pieces are in the reserve pile and how many have finished a round separately for the player and the CPU opponent. BGB lets you search memory addresses which carry a specific value, and later narrow down that list to addresses that now contain another value, ... Specifically for the finished pieces, you'd search the memory for spots which initially have the value `00`, then as the opponent moves a piece off the board narrow it down to those which now have `01`, ... after a few iterations there was only one address left: `$C0D3`. So in theory, freezing that number to zero would prevent the opponent from winning the game, as that position is checked against the total number of pieces a player has available and if it matches that player is declared the winner.

![The Royal Game of Ur ROM running in BGB](/assets/posts/2026-05-13-cheating-at-my-own-game/game_running.png "This is a screenshot of the game running, there are values shown on the screen next to R (reserve pile) and F (finished) which indicate how many pieces are there. The first step is to find where those values are stored in the RAM and see if manipulating them works."){:.small-image}

Now we need to convert this into a cheat code. If we could lock the value at that address at `00`, the number of pieces that moved off the board would never reach the desired amount. For the Action Replay, codes are made up of 8 hex digits built up as shown in the table below.

| Digits | Field | Meaning |
|--------|-------|---------|
| 1-2    | External RAM bank | Which SRAM bank to target. For standard WRAM cheats this is always `01`. |
| 3-4    | New value | The byte to write at the target address. |
| 5-6    | Address low byte | The low byte of the RAM address (little-endian — comes first). |
| 7-8    | Address high byte | The high byte of the RAM address. |


So in our example the code would be `0100D3C0`, which we can enter in BGB, enable, and test. In the memory view you will see that the value at position `$C0D3` is now shown in a different color, indicating it is frozen.

However, it didn't work... there was a flaw in my logic. The variable that stores how many pieces moved off the board is computed from the board state and immediately used in the game's logic and to draw the counts on screen. The moment BGB or an Action Replay/GameShark hooks into the memory to mess with the value, it's too late: the game has already processed the correct value and noticed the CPU player won. To prevent them from winning, we need to change the board state itself!

### Targeting the Board State Directly

The board state is stored as two arrays (length of *n* pieces), one for the human player and one for the CPU, each storing the position of every piece. A value of `00` indicates that piece is in the reserve pile, positions 1-14 are encoded as `01` - `0E`, and a finished piece has value `0F`. Using the same strategy as before, looking at movements of pieces and then finding memory addresses whose values change accordingly, I found that `$C0C9-$C0CF` holds the positions of the CPU's pieces and `$C0C2-$C0C8` those of the human player.

![BGB running, fixing specific values in the RAM (here we are giving the CPU player an advantage by pushing six of their pieces into the final pile immediately)](/assets/posts/2026-05-13-cheating-at-my-own-game/modified_ram.png "BGB allows you to quickly freeze specific RAM values; here the CPU's pieces are all pushed into the final pile (position 0F) immediately.")

Now we can create a code that fixes one of the player's pieces to value `0F`, marking that piece as finished and giving the human player an advantage while playing. Nastier would be to force the CPU's pieces back to the reserve pile, so they can never actually finish the game. Note that while the latter works, if the clamped piece is placed on the board those tiles will be updated, and when the piece is then moved back, that board position is not updated, so visually there will be a piece on the board, even though there isn't.

![BGB Cheat window with a handful of AR/GameShark codes loaded](/assets/posts/2026-05-13-cheating-at-my-own-game/ram_cheat_enabled.png "When you freeze values in the debugger, RAM-based cheats are automatically generated; here is the set that will prevent the opponent from moving any piece onto the board."){:.small-image}

## Patching the ROM

While I did manage to create a few cheat codes, I really wanted to create one for the device I used to own: the Game Genie! Brute-forcing values into the RAM, while efficient, introduces glitches and feels like fighting with the game rather than applying a patch. The Game Genie's strategy is therefore somewhat more elegant, but also more involved. First, we need to find points in the logic where we can patch the ROM to prevent the CPU player from winning the game, or to give us an edge. We could hijack the code that detects whether a player won and then flags which player won, the CPU or the human player. If we can pinpoint where in the ROM that check occurs and flag the human player as the winner even when it was actually the CPU that moved all pieces off the board first, we have a working cheat. This has the added advantage that it won't cause any of the graphical glitches that meddling with the RAM causes.

So we first need to pinpoint where that value is stored. To do so we'll use our previous RAM-based hack to give the CPU an unfair advantage and start with 6 pieces finished already, so they will win quickly and give us a chance to find the flags that pass information on the victor of the game to the next screen. This can be done with the cheat codes below.

```
010FC2C0
010FC3C0
010FC4C0
010FC5C0
010FC6C0
010FC7C0
```

Now I looked at addresses which changed when moving to the victory screen. A final filter showing all those which were set to 01 at the end revealed the list below.

```
  C0B4=01   C0B6=01   C1B7=01   DFBE=01   DFBF=01   DFCA=01   DFD3=01   DFD6=01 
  DFE1=01 
```

Now we apply the cheat below, let the CPU win, and check which of these values are 0 in the win screen with the CPU coming out on top. Of course we are making the assumption here that the flag is `01` if the human wins and `00` if the CPU wins. In this case we have access to the source code, so we know this is the case, but when going in blind this would require the reverse to be tested as well.

```
010FCEC0
010FCDC0
010FCCC0
010FCBC0
010FCAC0
010FC9C0
```

Once the CPU won, we click the update button and now see that `$C0B6` and `$C1B7` are good candidates to hold that flag.

```
  C0B4=02   C0B6=00   C1B7=00   DFBE=74   DFBF=EB   DFCA=01   DFD3=10   DFD6=D8 
  DFE1=1C 
```

For good measure I switched the cheat codes, won myself, and looked at the locations once more, confirming that those two addresses might have something to do with holding the state of who won.


```
  C0B4=01   C0B6=01   C1B7=01   DFBE=01   DFBF=01   DFCA=01   DFD3=01   DFD6=01 
  DFE1=01 
```

Normally at this point you'd probably go look at the code in the ROM to see which one is likely, but since I have zero experience with this I'll consult the RAM map first, since we have one in this case (saves me a couple of hours of potential frustration). When compiling the game, gbdev creates a `.map` file to debug the ROM; this should contain a mapping between our C variables and the final RAM location of those variables.

```
Area                       Addr        Size        Decimal Bytes (Attributes)
--------------------       ----        ----        ------- ----- ------------
_INITIALIZED           0000C1A0    0000004C =          76. bytes (REL,CON)

        Value  Global            Value  Global            Value  Global    
        -----  ------            -----  ------            -----  ------    
     0000C1A0  _current_ |    0000C1A1  _next_sta |    0000C1A2  _selected
     0000C1A3  _coin_res |    0000C1A4  _starting |    0000C1AF  _selected
     0000C1B7  _human_wo |    0000C1B8  _game_mod |    0000C1B9  _selected
     0000C1BC  _link_sta |    0000C1BD  _link_rol |    0000C1BE  _link_ali
     0000C1C6  _link_loc |    0000C1C7  _link_rem |    0000C1D4  _opponent
     0000C1DC  _opponent |    0000C1EB  __map_til
```

Looking at the `.map` file reveals we had it correct! It is `$C1B7` that contains the `human_won` variable which we needed to identify. `$C0B6` is likely a static variable somewhere; in C, static variables aren't passed to the linker, so they don't appear in the `.map` file.

Now we need to find instructions in the ROM where that specific value is compared or set — let's dig some more. To see when the code touches that variable we need to set a watchpoint. As we are specifically interested in what happens when the CPU wins, we'll load the cheats again that give the CPU the advantage (and play as badly as possible ourselves). The watchpoint picked up a line that sets `$C1B7` to `00` when the CPU wins.

![Watchpoint set to monitor which instructions change the desired value](/assets/posts/2026-05-13-cheating-at-my-own-game/watchpoint.png "BGB's interface to set a watchpoint; we want to monitor all read/write operations to/from address $C1B7 to see where it is set to 00 when the CPU player wins."){:.small-image}

This immediately pointed to this line:

```
ROM0:1DE8   36 00       ld (hl),00
```

There are two bytes here: `36`, the opcode for `LD (HL), n`, which loads the immediate value into the memory location the `HL` register points to (in this case `$C1B7`, set by an earlier `LD HL, $C1B7` instruction), and `00`, the value to load. These are in ROM positions `$1DE8` and `$1DE9`, so in theory if we patch `$1DE9` to `01` that should fool the game into thinking the human won, even though the CPU opponent did. To test this, we can play again, and when that line hits, change the value to `01` and then proceed with running the code.

```
ROM0:1DE8   36 01       ld (hl),01
```

![Screenshot of BGB running the ROM but with the opcode in $1DE9 modified](/assets/posts/2026-05-13-cheating-at-my-own-game/modified_opcode.png "When the line highlighted in red is modified, the game is tricked into thinking the human player won the game, even in this case where they didn't!")

Once confirmed this worked, it now needs to be converted to a Game Genie cheat. The working code is `01D-E9E-E6A`, however it isn't nearly as trivial to find as with the Action Replay/GameShark. You actually need a little script to do this; you can find one on [GitHub](https://github.com/jseaman/gbgenie) where you punch in the address `0x1de9`, the target value `0x01`, and the original value `0x00`, and the correct code comes out. Alternatively you can use the script below that [Claude](https://claude.ai) created.

{:.large-code}
```python
"""
Game Boy Game Genie code encoder/decoder.

Verified against gbgenie's documented code "004-BCE-E66" = (addr=0x14BC, old=0x03, new=0x00).

Code layout (9 hex digits displayed as ABC-DEF-GHI):

  Position: 0  1  2  3  4  5  6  7  8
            ─────  ──────────  ───────
            new    address     compare
            value  (scrambled) (scrambled)

  - pos[0..1]: new value, plain hex (high nibble, low nibble)
  - pos[2]:    address bits 8-11
  - pos[3]:    address bits 4-7
  - pos[4]:    address bits 0-3 (low nibble of address)
  - pos[5]:    address bits 12-15 (high nibble), XORed with $F
  - pos[6]:    high nibble of "original_byte XOR $BA, rotated left 2"
  - pos[7]:    cloak nibble = pos[6] XOR 8 (validity check)
  - pos[8]:    low nibble of "original_byte XOR $BA, rotated left 2"
"""


def encode(new_value: int, address: int, original_byte: int) -> str:
    """Encode a cheat into a Game Genie code formatted as ABC-DEF-GHI."""
    if not 0 <= new_value <= 0xFF:
        raise ValueError("new_value must be a byte")
    if not 0x0002 <= address <= 0x7FFF:
        raise ValueError("Game Genie can only patch ROM addresses $0002-$7FFF")
    if not 0 <= original_byte <= 0xFF:
        raise ValueError("original_byte must be a byte")

    nv_hi = (new_value >> 4) & 0xF
    nv_lo = new_value & 0xF

    addr_hi     = (address >> 12) & 0xF
    addr_mid_hi = (address >> 8)  & 0xF
    addr_mid_lo = (address >> 4)  & 0xF
    addr_lo     = address & 0xF

    obfuscated = original_byte ^ 0xBA
    rotated_left_2 = ((obfuscated << 2) | (obfuscated >> 6)) & 0xFF
    cmp_hi = (rotated_left_2 >> 4) & 0xF
    cmp_lo = rotated_left_2 & 0xF
    cloak = cmp_hi ^ 0x8

    nibbles = [
        nv_hi, nv_lo,
        addr_mid_hi, addr_mid_lo, addr_lo, addr_hi ^ 0xF,
        cmp_hi, cloak, cmp_lo,
    ]
    s = "".join(f"{n:X}" for n in nibbles)
    return f"{s[0:3]}-{s[3:6]}-{s[6:9]}"


def decode(code: str) -> tuple[int, int, int]:
    """Decode a Game Genie code into (new_value, address, original_byte)."""
    clean = code.replace("-", "").replace(" ", "").upper()
    if len(clean) != 9:
        raise ValueError("expected 9 hex digits")
    n = [int(c, 16) for c in clean]

    new_value = (n[0] << 4) | n[1]
    address = ((n[5] ^ 0xF) << 12) | (n[2] << 8) | (n[3] << 4) | n[4]

    rotated = (n[6] << 4) | n[8]
    unrotated = ((rotated >> 2) | (rotated << 6)) & 0xFF
    original = unrotated ^ 0xBA

    return new_value, address, original


# Verification
print("Verification against gbgenie's documented example:")
code_str, exp_addr, exp_old, exp_new = "004-BCE-E66", 0x14BC, 0x03, 0x00
nv, addr, old = decode(code_str)
decode_ok = nv == exp_new and addr == exp_addr and old == exp_old
re_encoded = encode(exp_new, exp_addr, exp_old)
encode_ok = re_encoded == code_str
print(f"  decode({code_str}) -> new=0x{nv:02X}, addr=0x{addr:04X}, old=0x{old:02X}  "
      f"[{'OK' if decode_ok else 'FAIL'}]")
print(f"  encode back              -> {re_encoded}  [{'OK' if encode_ok else 'FAIL'}]")

print("\nRound-trip on other cases:")
for new_val, addr, old in [(0x01, 0x1DE9, 0x00), (0xFF, 0x4000, 0x42), (0x55, 0x7FFE, 0x99)]:
    c = encode(new_val, addr, old)
    rt = decode(c)
    ok = rt == (new_val, addr, old)
    print(f"  encode({new_val:#04x}, {addr:#06x}, {old:#04x}) -> {c} -> {rt}  "
          f"[{'OK' if ok else 'FAIL'}]")

print()
print("=" * 60)
print("Cheat for dmg-royal-game-of-ur:")
print("  Patch ROM $1DE9: replace $00 with $01")
print("  (forces human_won = 1 on what was the CPU-victory write)")
print(f"  Game Genie code: {encode(0x01, 0x1DE9, 0x00)}")
print("=" * 60)
```

**Update:** For the DX version, with colored sprites when running on GBC hardware the ROM positions are `$1EEB` and `$1EEC` so the corresponding cheat code is `01E-ECE-E6A`. The RAM map is identical, so the Action Replay/GameShark codes work for both versions of the game.

## Conclusion

It worked! There are now cheat codes for both the Action Replay/GameShark and the Game Genie for my very own Game Boy game. Especially the Game Genie took a fair amount of work, and I'm wondering how people were able to figure this out back in the day. There were debuggers, but they weren't as advanced as BGB, and it must have taken a fair bit of research to figure out how to convert the codes.


## Further Reading
- **My Previous Post Describing the development of this game**: [{% post_url 2026/2026-03-15-gameboy-royal-game-of-ur  %}]({% post_url 2026/2026-03-15-gameboy-royal-game-of-ur  %})
- **The Royal Game of UR**: [https://sebastianproost.itch.io/the-royal-game-of-ur](https://sebastianproost.itch.io/the-royal-game-of-ur) — The Game's page on itch.io where you can obtain the ROM
- **Pan Docs — Game Genie & GameShark section**: [https://gbdev.io/pandocs/Shark_Cheats.html](https://gbdev.io/pandocs/Shark_Cheats.html) — the canonical reference for both code formats.
- **BGB manual**: [https://bgb.bircd.org/manual.html](https://bgb.bircd.org/manual.html) — the debugger used here, fully documented. 
- **gbgenie (Python encoder/decoder)**: [https://github.com/jseaman/gbgenie](https://github.com/jseaman/gbgenie) — a working reference implementation; useful for sanity-checking your own encoder. (note that the original gbgenie repo has a bug with the order of parameters not matching the documentation!)
