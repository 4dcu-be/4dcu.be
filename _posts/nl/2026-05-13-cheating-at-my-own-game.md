---
layout: post
title:  "Cheats maken voor mijn eigen Game Boy-game"
byline: "door in de ROM en RAM te speuren en te sleutelen"
description: "Hoe Game Boy-cheatapparaten zoals de Game Genie en GameShark werkten, en hoe ik werkende cheatcodes maakte voor mijn eigen homebrewgame The Royal Game of Ur door de ROM en RAM te doorzoeken."
date:   2026-05-13 08:00:00
author: Sebastian Proost
post_id: cheating-at-my-own-game
categories: games
tags:	nintendo gameboy retrogaming homebrew
cover:  "/assets/posts/2026-05-13-cheating-at-my-own-game/game_genie_header.jpg"
thumbnail: "/assets/images/thumbnails/game_genie.jpg"
---

De computerspellen die ik als kind speelde, hadden vaak ingebouwde cheatcodes waarmee je voorbij stukken kon raken waar je vastzat. Voor draagbare consoles zoals de Game Boy had je echter speciale hardware nodig. Een van mijn meest gekoesterde bezittingen uit mijn jeugd was zo'n apparaat: de Game Genie, een groot grijs toestel dat boven op de Game Boy zat en fysiek tussen de cartridge en de console werd geschoven. Wanneer je het apparaat opstartte, moest je een aantal codes invoeren die kleine delen van het spel veranderden: je kreeg oneindig veel levens, liep geen schade op, richtte meer schade aan, ... Ik had geen idee hoe het werkte, maar was heel blij dat ik er een had. Zo kon ik bij sommige spellen toch het einde bereiken (zoals bij Gremlins 2 een notoir moeilijk spel), iets wat me als 9-jarige nooit gelukt zou zijn.

In dit artikel wil ik dieper ingaan op deze apparaten, bekijken hoe ze precies werkten en nagaan of we enkele functionele cheatcodes kunnen maken voor mijn eigen Game Boy-game "The Royal Game of Ur", waarover ik enkele maanden geleden schreef.

## The Royal Game of Ur voor Game Boy

In een [vorig artikel]({% post_url 2026/2026-03-15-gameboy-royal-game-of-ur  %}) nam ik je mee door mijn avontuur om vanaf nul een Game Boy-game te ontwikkelen, weliswaar met behoorlijk wat hulp van Agentic Coding. Het is een oud bordspel, "The Royal Game of Ur", aangepast voor de DMG Game Boy. Het spel kun je momenteel downloaden via [itch.io](https://sebastianproost.itch.io/the-royal-game-of-ur). Het is in wezen een racespel: elke speler begint met zeven stukken in reserve en moet die over een route van 14 vakjes rond het bord verplaatsen. Het doel is om als eerste alle zeven stukken aan het andere uiteinde van het bord naar de finish te brengen. De routes overlappen in het midden van het bord, waar stukken elkaar kunnen vangen en een gevangen stuk wordt terug naar de reserve van de eigenaar gestuurd. Hoewel het vrij eenvoudig is om de CPU-tegenstander op de gemakkelijke moeilijkheidsgraad te verslaan en er niets wordt ontgrendeld als je een spel wint, er is dus geen echte reden om vals te spelen, wil ik toch zien of het kan! Omdat dit mijn allereerste poging is om met dit soort debugger wijs te raken uit het geheugen van een systeem, wilde ik dit liefst doen met een project waarvan ik weet hoe het geïmplementeerd is en waarbij ik indien nodig de broncode kan raadplegen.

## Game Genie versus Action Replay/GameShark

Er waren vroeger verschillende apparaten op de markt. Hoewel ze allemaal tussen de console en de cartridge werden geschoven en codes aanvaardden die iets veranderden, gebruikten ze in werkelijkheid verschillende trucs om cheats mogelijk te maken.

De Game Genie past een patch toe op de ROM (adresbereik `$0002-$7FFF`): een code verwijst steeds naar een adres in de ROM-bank en naar de waarde waarin de inhoud ervan moet worden veranderd. Zo kun je waarden in de ROM aanpassen of functies uitschakelen (bijvoorbeeld geen levens verliezen wanneer je schade oploopt). Op echte hardware aanvaardde de Game Genie slechts drie codes tegelijk, dus moest je je cheats zorgvuldig kiezen. Emulators hebben die beperking niet.

Daarnaast waren er apparaten die zich op het RAM-geheugen richtten (adressen `$8000+`). Afhankelijk van waar je er een kocht, droegen die de merknaam Action Replay of GameShark. Hier wijst een code naar een locatie in het RAM-geheugen en overschrijft die waarde op specifieke momenten (elk frame tijdens VBlank). Daarmee kun je vergelijkbare effecten bereiken: doordat je aantal levens elk frame opnieuw op het maximum wordt gezet, word je onkwetsbaar, je kunt power-ups inschakelen die je nog niet hebt opgepikt, ... Kortom, je kunt de speltoestand rechtstreeks manipuleren. Ook deze apparaten hadden een codelimiet: vier codes tegelijk op de DMG Game Boy. Emulators negeren die beperking uiteraard volledig.

Het RAM-geheugen leek begrijpelijker dan de opcodes in de ROM, dus besloot ik daar eerst mee te experimenteren.

## Het RAM-geheugen van mijn eigen game hacken

Omdat ik met de speltoestand wilde knoeien om te voorkomen dat de tegenstander zou winnen, leek het RAM-geheugen een goed vertrekpunt. Dat betekent dat we een emulator nodig hebben waarmee je het geheugen kunt doorzoeken en manipuleren. [BGB](https://bgb.bircd.org/) is daarvoor een goede keuze. Het hielp me bij het maken van het spel al vaak om problemen met tiles (VRAM) op te lossen en laat toe om het geheugen (ROM en RAM) te inspecteren en te wijzigen. 

Het spel houdt voor de speler en de CPU-tegenstander afzonderlijk bij hoeveel stukken er in reserve staan en hoeveel stukken een ronde hebben voltooid. Met BGB kun je zoeken naar geheugenadressen die een bepaalde waarde bevatten en die lijst later beperken tot adressen die intussen een andere waarde bevatten, ... Voor de stukken die de finish hebben bereikt, zoek je bijvoorbeeld eerst naar geheugenlocaties met de waarde `00`. Wanneer de tegenstander vervolgens een stuk van het bord haalt, beperk je de zoekopdracht tot de locaties die nu `01` bevatten, ... Na enkele iteraties bleef er nog maar één adres over: `$C0D3`. Door dat getal op nul vast te zetten, zou je in theorie moeten voorkomen dat de tegenstander het spel wint. Die geheugenpositie wordt immers vergeleken met het totale aantal stukken waarover een speler beschikt, en wanneer beide aantallen gelijk zijn, wordt die speler tot winnaar uitgeroepen.

![De ROM van The Royal Game of Ur die in BGB draait](/assets/posts/2026-05-13-cheating-at-my-own-game/game_running.png "Dit is een schermafbeelding van het draaiende spel. Naast R (reserve) en F (finished) staan waarden die aangeven hoeveel stukken zich daar bevinden. De eerste stap is achterhalen waar die waarden in het RAM-geheugen worden opgeslagen en testen of we ze kunnen manipuleren."){:.small-image}

Nu moeten we dit omzetten in een cheatcode. Als we de waarde op dat adres konden vastzetten op `00`, zou het aantal stukken dat van het bord is gegaan nooit de vereiste hoeveelheid bereiken. Codes voor de Action Replay bestaan uit 8 hexadecimale cijfers, opgebouwd zoals in de onderstaande tabel.

| Cijfers | Veld | Betekenis |
|--------|-------|---------|
| 1-2    | Externe RAM-bank | De SRAM-bank waarop de code is gericht. Voor gewone WRAM-cheats is dit altijd `01`. |
| 3-4    | Nieuwe waarde | De byte die naar het doeladres wordt geschreven. |
| 5-6    | Lage byte van het adres | De lage byte van het RAM-adres (little-endian — komt eerst). |
| 7-8    | Hoge byte van het adres | De hoge byte van het RAM-adres. |


In ons voorbeeld wordt de code dus `0100D3C0`. We kunnen die in BGB invoeren, activeren en testen. In de geheugenweergave zie je dat de waarde op positie `$C0D3` nu in een andere kleur wordt weergegeven, wat aangeeft dat ze vastgezet is.

Het werkte echter niet ... Er zat een fout in mijn redenering. De variabele die opslaat hoeveel stukken van het bord zijn gegaan, wordt berekend op basis van de bordtoestand en onmiddellijk gebruikt in de spellogica en om de aantallen op het scherm te tekenen. Tegen de tijd dat BGB of een Action Replay/GameShark op het geheugen ingrijpt om de waarde aan te passen, is het te laat: het spel heeft de juiste waarde al verwerkt en vastgesteld dat de CPU-speler gewonnen heeft. Om te voorkomen dat die wint, moeten we de bordtoestand zelf veranderen!

### De bordtoestand rechtstreeks aanpassen

De bordtoestand wordt opgeslagen als twee arrays (met een lengte van *n* stukken): één voor de menselijke speler en één voor de CPU. Elke array bewaart de positie van ieder stuk. Een waarde van `00` geeft aan dat het stuk in reserve staat, posities 1-14 zijn gecodeerd als `01` - `0E` en een stuk dat de finish bereikt heeft, krijgt de waarde `0F`. Met dezelfde aanpak als hiervoor — de bewegingen van stukken volgen en vervolgens geheugenadressen zoeken waarvan de waarden overeenkomstig veranderen — ontdekte ik dat `$C0C9-$C0CF` de posities van de CPU-stukken bevat en `$C0C2-$C0C8` die van de menselijke speler.

![BGB in werking, waarbij specifieke waarden in het RAM-geheugen worden vastgezet (hier geven we de CPU-speler een voordeel door zes van diens stukken onmiddellijk naar de finish te verplaatsen)](/assets/posts/2026-05-13-cheating-at-my-own-game/modified_ram.png "Met BGB kun je snel specifieke RAM-waarden vastzetten. Hier worden alle stukken van de CPU onmiddellijk naar de finish verplaatst (positie 0F).")

Nu kunnen we een code maken die een van de stukken van de speler vastzet op waarde `0F`. Daarmee wordt dat stuk als voltooid gemarkeerd en krijgt de menselijke speler tijdens het spelen een voordeel. Gemener zou zijn om de stukken van de CPU terug naar de reserve te dwingen, zodat die het spel nooit kan uitspelen. Merk op dat dit laatste wel werkt, maar dat de betreffende vakjes worden bijgewerkt wanneer het vastgezette stuk op het bord wordt geplaatst. Wanneer het stuk daarna enkel in het RAM wordt teruggezet, wordt die positie op het bord niet bijgewerkt. Visueel blijft er dus een stuk op het bord staan, hoewel het er in werkelijkheid niet meer is.

![Het Cheat-venster van BGB met een handvol geladen AR/GameShark-codes](/assets/posts/2026-05-13-cheating-at-my-own-game/ram_cheat_enabled.png "Wanneer je waarden in de debugger vastzet, worden automatisch RAM-gebaseerde cheats gegenereerd. Dit is de reeks die voorkomt dat de tegenstander een stuk op het bord kan plaatsen."){:.small-image}

## De ROM patchen

Hoewel ik erin slaagde enkele cheatcodes te maken, wilde ik er vooral een maken voor het apparaat dat ik vroeger zelf had: de Game Genie! Waarden met brute kracht in het RAM-geheugen duwen is efficiënt, maar veroorzaakt glitches en voelt meer alsof je met het spel vecht dan dat je een patch toepast. De aanpak van de Game Genie is dan ook iets eleganter, maar ook complexer. Eerst moeten we punten in de logica vinden waar we de ROM kunnen patchen om te voorkomen dat de CPU-speler het spel wint, of om onszelf een voordeel te geven. We zouden de code kunnen kapen die detecteert of een speler gewonnen heeft en vervolgens vastlegt welke speler won: de CPU of de menselijke speler. Als we precies kunnen achterhalen waar die controle in de ROM plaatsvindt en de menselijke speler steeds als winnaar kunnen markeren (zelfs wanneer de CPU als eerste al zijn stukken van het bord heeft gehaald) dan hebben we een werkende cheat. Dat heeft bovendien als voordeel dat er geen grafische glitches ontstaan, in tegenstelling tot wanneer we met het RAM-geheugen knoeien.

Eerst moeten we dus precies bepalen waar die waarde wordt opgeslagen. Daarvoor gebruiken we onze eerdere RAM-gebaseerde hack om de CPU een oneerlijk voordeel te geven: die begint al met 6 voltooide stukken, zodat hij snel wint en we de flags kunnen opsporen die informatie over de winnaar doorgeven aan het volgende scherm. Dat kan met de onderstaande cheatcodes.

```
010FC2C0
010FC3C0
010FC4C0
010FC5C0
010FC6C0
010FC7C0
```

Vervolgens bekeek ik de adressen die veranderden bij de overgang naar het overwinningsscherm. Een laatste filter met alle adressen die op het einde op 01 stonden, leverde de onderstaande lijst op.

```
  C0B4=01   C0B6=01   C1B7=01   DFBE=01   DFBF=01   DFCA=01   DFD3=01   DFD6=01 
  DFE1=01 
```

Nu passen we de onderstaande cheat toe, laten we de CPU winnen en controleren we welke van deze waarden 0 zijn op het overwinningsscherm nadat de CPU als winnaar uit de bus is gekomen. We nemen hier uiteraard aan dat de flag `01` is wanneer de menselijke speler wint en `00` wanneer de CPU wint. In dit geval hebben we toegang tot de broncode en weten we dat dit klopt, maar als we volledig in het duister tastten, zouden we ook het omgekeerde moeten testen.

```
010FCEC0
010FCDC0
010FCCC0
010FCBC0
010FCAC0
010FC9C0
```

Zodra de CPU gewonnen heeft, klikken we op de knop om de waarden bij te werken. Dan zien we dat `$C0B6` en `$C1B7` goede kandidaten zijn om die flag te bevatten.

```
  C0B4=02   C0B6=00   C1B7=00   DFBE=74   DFBF=EB   DFCA=01   DFD3=10   DFD6=D8 
  DFE1=1C 
```

Voor de zekerheid wisselde ik de cheatcodes om, won ik zelf en bekeek ik de locaties nogmaals. Zo bevestigde ik dat die twee adressen mogelijk iets te maken hadden met het bijhouden van wie gewonnen had.


```
  C0B4=01   C0B6=01   C1B7=01   DFBE=01   DFBF=01   DFCA=01   DFD3=01   DFD6=01 
  DFE1=01 
```

Normaal zou je nu waarschijnlijk in de code in de ROM gaan kijken om te bepalen welk adres het meest waarschijnlijk is. Omdat ik daar absoluut geen ervaring mee heb, raadpleeg ik eerst de RAM-map, aangezien we deze in dit geval beschikbaar hebben (dat bespaart me mogelijk ook enkele uren frustratie). Bij het compileren van het spel maakt gbdev een `.map`-bestand aan om de ROM te debuggen. Daarin zou een koppeling moeten staan tussen onze C-variabelen en de uiteindelijke RAM-locatie van die variabelen.

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

Uit het `.map`-bestand blijkt dat we het bij het rechte eind hadden! Het is `$C1B7` dat de variabele `human_won` bevat die we moesten identificeren. `$C0B6` is waarschijnlijk ergens een statische variabele. In C worden statische variabelen niet aan de linker doorgegeven en verschijnen ze dus niet in het `.map`-bestand.

Nu moeten we instructies in de ROM vinden waarin die specifieke waarde wordt vergeleken of ingesteld — laten we nog wat dieper graven. Om te zien wanneer de code die variabele aanraakt, moeten we een watchpoint instellen. Omdat we specifiek geïnteresseerd zijn in wat er gebeurt wanneer de CPU wint, laden we opnieuw de cheats die de CPU een voordeel geven (en spelen we zelf zo slecht mogelijk). Het watchpoint vond een regel die `$C1B7` op `00` zet wanneer de CPU wint.

![Watchpoint ingesteld om te controleren welke instructies de gewenste waarde wijzigen](/assets/posts/2026-05-13-cheating-at-my-own-game/watchpoint.png "De interface van BGB om een watchpoint in te stellen. We willen alle lees- en schrijfbewerkingen naar en vanaf adres $C1B7 controleren om te zien waar het op 00 wordt gezet wanneer de CPU-speler wint."){:.small-image}

Dat wees meteen naar deze regel:

```
ROM0:1DE8   36 00       ld (hl),00
```

Hier staan twee bytes: `36`, de opcode voor `LD (HL), n`, die de onmiddellijke waarde laadt in de geheugenlocatie waarnaar het `HL`-register verwijst (in dit geval `$C1B7`, ingesteld door een eerdere instructie `LD HL, $C1B7`), en `00`, de te laden waarde. Die bevinden zich op ROM-posities `$1DE8` en `$1DE9`. Als we `$1DE9` patchen naar `01`, zou dat het spel in theorie moeten doen geloven dat de menselijke speler gewonnen heeft, hoewel de CPU-tegenstander dat in werkelijkheid deed. Om dit te testen, kunnen we opnieuw spelen, de waarde veranderen naar `01` wanneer die regel wordt bereikt en vervolgens de code verder laten uitvoeren.

```
ROM0:1DE8   36 01       ld (hl),01
```

![Schermafbeelding van BGB waarop de ROM draait, maar met de opcode op $1DE9 aangepast](/assets/posts/2026-05-13-cheating-at-my-own-game/modified_opcode.png "Wanneer de rood gemarkeerde regel wordt aangepast, wordt het spel wijsgemaakt dat de menselijke speler gewonnen heeft, zelfs in dit geval waarin dat niet zo was!")

Zodra bevestigd was dat dit werkte, moest het nog worden omgezet in een Game Genie-cheat. De werkende code is `01D-E9E-E6A`, maar die vinden is lang niet zo eenvoudig als bij de Action Replay/GameShark. Je hebt daarvoor eigenlijk een scriptje nodig. Op [GitHub](https://github.com/jseaman/gbgenie) vind je er een waarin je het adres `0x1de9`, de doelwaarde `0x01` en de oorspronkelijke waarde `0x00` invoert, waarna de juiste code verschijnt. Je kunt ook het onderstaande script gebruiken, dat [Claude](https://claude.ai) maakte.

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

**Update:** Voor de DX-versie, met gekleurde sprites wanneer die op GBC-hardware draait, zijn de ROM-posities `$1EEB` en `$1EEC`. De bijbehorende cheatcode is dus `01E-ECE-E6A`. De RAM-map is identiek, dus de Action Replay/GameShark-codes werken voor beide versies van het spel.

## Conclusie

Het is gelukt! Er bestaan nu cheatcodes voor zowel de Action Replay/GameShark als de Game Genie voor mijn eigen Game Boy-game. Vooral de Game Genie vergde behoorlijk wat werk, en ik vraag me af hoe mensen dit vroeger konden uitzoeken. Er waren wel debuggers, maar die waren niet zo geavanceerd als BGB. Het moet heel wat opzoekwerk hebben gekost om te achterhalen hoe je de codes moest omzetten.


## Verder lezen
- **Mijn vorige artikel over de ontwikkeling van dit spel**: [{% post_url 2026/2026-03-15-gameboy-royal-game-of-ur  %}]({% post_url 2026/2026-03-15-gameboy-royal-game-of-ur  %})
- **The Royal Game of UR**: [https://sebastianproost.itch.io/the-royal-game-of-ur](https://sebastianproost.itch.io/the-royal-game-of-ur) — De pagina van het spel op itch.io, waar je de ROM kunt downloaden
- **Pan Docs — sectie over Game Genie en GameShark**: [https://gbdev.io/pandocs/Shark_Cheats.html](https://gbdev.io/pandocs/Shark_Cheats.html) — de gezaghebbende referentie voor beide codeformaten.
- **BGB-handleiding**: [https://bgb.bircd.org/manual.html](https://bgb.bircd.org/manual.html) — de debugger die hier wordt gebruikt, volledig gedocumenteerd. 
- **gbgenie (Python-encoder/decoder)**: [https://github.com/jseaman/gbgenie](https://github.com/jseaman/gbgenie) — een werkende referentie-implementatie die nuttig is om je eigen encoder te controleren. (Merk op dat de volgorde van de parameters in de oorspronkelijke gbgenie-repository door een bug niet overeenkomt met de documentatie!)
