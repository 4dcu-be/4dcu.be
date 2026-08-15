---
layout: post
title:  "The Royal Game Boy of Ur"
byline: "Een Game Boy-versie bouwen van het oudste bordspel ter wereld"
description: "Een speelbare Game Boy-versie bouwen van het 5.000 jaar oude Royal Game of Ur met GBDK en C, en daarbij agentic coding met Claude Code inzetten in een nichehomebrew-ecosysteem."
date:   2026-03-15 08:00:00
author: Sebastian Proost
post_id: gameboy-royal-game-of-ur
categories: ai programming games
tags:	python c nintendo gameboy retrogaming homebrew ai claude-code agent-based-modeling
cover:  "/assets/posts/2026-03-15-gameboy-royal-game-of-ur/header.jpg"
thumbnail: "/assets/images/thumbnails/royal_gameboy_of_ur.jpg"
---

Jaren geleden wekte een [documentaire over "The Royal Game of Ur"](https://www.youtube.com/watch?v=WZskjLq040I), een van de oudste bekende bordspellen van bijna 5.000 jaar oud, meteen mijn interesse. Toen ik dr. Irving Finkel er later over hoorde praten in [een podcast](https://www.youtube.com/watch?v=_bBRVNkAfkQ), kwam die fascinatie onmiddellijk terug. Maar deze keer had ik een idee om er zelf wat mee te doen: een speelbare versie van The Royal Game of Ur bouwen voor de originele Game Boy.

Wil je het spel uitproberen? Download het gratis op [itch.io](https://sebastianproost.itch.io/the-royal-game-of-ur)!

<div style="text-align: center;">
<iframe frameborder="0" src="https://itch.io/embed/4341652?link_color=579375" width="552" height="167" style="max-width: 100%;"><a href="https://sebastianproost.itch.io/the-royal-game-of-ur">The Royal Game of Ur door sebastian.proost</a></iframe>
</div>

Wil je de code van dit project bekijken, dan [vind je die op GitHub](https://github.com/sepro/dmg-royal-game-of-ur).

## Waarom de Game Boy? Waarom agentic coding?

Ik groeide op met de Nintendo Game Boy; het was de eerste console die ik had en ik heb mooie herinneringen aan die spellen. Maar het is ook een ouder systeem, en homebrewontwikkeling voor de Game Boy is, zelfs met tools als [GBDK](https://gbdk.org/), een niche met een kleine maar toegewijde gemeenschap. Voor agentic coding-tools zoals [Claude Code](https://claude.ai/) maakt dat een verschil: wanneer je aan een Python-project met populaire bibliotheken als pandas of Flask werkt, is er referentiemateriaal in overvloed. In [mijn vorige experiment]({% post_url nl/2025/2025-12-20-rust-experiment %}), het porten van een genetisch kunstalgoritme naar Rust, presteerde Claude Code indrukwekkend, maar Rust is een goed gedocumenteerde, populaire taal. Ik wilde testen of Claude Code overweg kon met een veel minder gangbaar ecosysteem, waar de documentatie schaarser is en de gemeenschap kleiner.

Op een toestel als dit werk je ook dichter bij de hardware: interrupts afhandelen, geheugen beheren, werken binnen strakke beperkingen. Dat staat mijlenver van moderne applicatieontwikkeling, waar dit alles grotendeels door frameworks wordt weggeabstraheerd. Net die onbekendheid maakte het aantrekkelijk: hoe stuur je een agentic coding-tool effectief aan wanneer je zelf de packages, functies en terminologie van het platform niet kent?

Bij het ontwikkelen van games zijn de assets vaak de beperkende factor. De resolutie van de Game Boy (160×144 pixels) en het kleurenpalet (2-bit: wit, lichtgrijs, donkergrijs en zwart) zijn op dat vlak wat vergevingsgezinder. Ik ben een ontwikkelaar, geen kunstenaar, dus een platform waar eenvoudige graphics eerder de norm dan de uitzondering zijn, past me goed. En The Royal Game of Ur leek me met zijn eenvoudige regels en beurtgebaseerde spelverloop ideaal geschikt voor deze beperkingen.

Het doel was dus drieledig: testen hoe goed Claude Code werkt voor een minder gangbaar platform, mijn begrip van de hardware van de Game Boy verdiepen en — als alles goed ging — eindigen met een speelbaar spel.

## Eerst even aftasten: een eenvoudigere app

Er meteen invliegen leek me hier geen goed idee. Ik wilde eerst mijn toolchain (VSCode, Docker en een devcontainer) correct opzetten en dan nagaan of ik een eenvoudige applicatie aan de praat kreeg: een app die enkele graphics op het scherm zette, gebruikersinvoer afhandelde en wat geluid afspeelde. Zo ontstond Zen Garden, een eenvoudige meditatie-app die een paar afbeeldingen op de achtergrond toont, een menu heeft waarmee de gebruiker kan interageren en een eenvoudig achtergrondmelodietje met geluidseffecten afspeelt.

Hieronder vind je mijn Dockerfile, die ik samen met VSCode en een devcontainer gebruik. Ik nam Python op (handig om bij de hand te hebben, mocht er snel een scriptje nodig zijn om iets te converteren), Node.js (om Claude Code in de container te installeren en uit te voeren) en GBDK (de buildtools voor de Game Boy). Testen deed ik manueel met [SameBoy](https://sameboy.github.io/), maar later stapte ik over op [BGB](https://bgb.bircd.org/), dat betere tools heeft om ROM's te debuggen.

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

Dit verliep allemaal veel vlotter dan verwacht! Met Claude Code, dat ik in plan mode telkens kleine stappen liet zetten (zodat ik kon controleren wat er ging gebeuren en of het zinnig was), kwam deze applicatie mooi tot stand. Claude voerde GBDK-tools zoals `png2asset` uit om mijn afbeeldingen om te zetten naar tiles die compatibel zijn met de Game Boy. Ook de code om graphics te tonen, menu's te openen en tussen schermen te wisselen werd zonder grote problemen gegenereerd. Sommige zaken, zoals het scherm na het sluiten van een menu weer met de achtergrondtiles opvullen, moet je expliciet afhandelen en die stappen liet Claude vaak achterwege. Maar zodra ik doorhad waardoor sommige grafische problemen ontstonden, kon ik Claude vragen ze op te lossen.

<div class="gallery-2-col" markdown="1">
![Schermafbeelding van Zen Garden in SameBoy, met het menu](/assets/posts/2026-03-15-gameboy-royal-game-of-ur/zen_garden_menu.png)
![Schermafbeelding van Zen Garden in SameBoy, met een meditatie aan de gang](/assets/posts/2026-03-15-gameboy-royal-game-of-ur/zen_garden_running.png)
</div>

Het lastigste onderdeel was waarschijnlijk het geluid. Voor graphics kun je op AI rekenen om illustraties te genereren, en ik heb net genoeg ervaring met [GIMP](https://www.gimp.org/) om die op te kuisen. Maar geluid is een ander verhaal — werken met hUGETracker is een hele uitdaging, al kreeg ik er iets uit dat ik goed genoeg vond.

Deze test vinkte dus de meeste van mijn vakjes af: ik had wat rudimentaire graphics draaiend (weliswaar enkel via de achtergrondlaag, nog geen sprites), basisgeluid en een vrij solide menu-implementatie. Dat gaf me wat meer hoop dat dit idee echt haalbaar was, en binnen een redelijke termijn.

## De AI-tegenstander bouwen in Python

Hoewel The Royal Game of Ur een dobbelspel is en er dus geluk bij komt kijken, zit er meer strategie in dan je zou denken. De [regels](https://royalur.net/rules) zijn eenvoudig: je racet met je stukken over het bord, vangt tegenstanders door op hen te landen en scoort door stukken aan het einde van het bord af te voeren. Omdat je meerdere stukken op het bord kunt hebben en zelf kiest welk stuk je verzet, is er ruimte om stukken strategisch te plaatsen en efficiënter vangsten op te zetten.

Voor ik eraan begon, wilde ik dus de opties verkennen om een AI voor de CPU-tegenstander te implementeren: nagaan of ik een paar verschillende speelstijlen kon bedenken, testen hoe goed die werkten en parameters optimaliseren. Dat deed ik in Python, de taal die ik het best ken, dus het was logisch om in die omgeving te prototypen. Dit verdient misschien een volledig artikel op zich, maar het concept is relatief eenvoudig en ligt sterk in lijn met [mijn artikel over het gebruik van een agentgebaseerd model]({% post_url 2020/2020-11-11-Gwent-Pro-Rank-ABM %}). Alleen simuleren we hier geen spel: de agents spelen daadwerkelijk een spel. Verschillende agents kunnen verschillende strategieën gebruiken (of dezelfde strategie met andere parameters), waardoor ik een paar opties kon kiezen om in de Game Boy-ROM op te nemen. Uiteindelijk kwam ik uit bij vier strategieën die conceptueel voldoende van elkaar verschilden om aan vier verschillende CPU-tegenstanders in het spel te koppelen. Die strategieën sluiten ook aan bij de achtergrond van de personages: de koopman gebruikt bijvoorbeeld een greedy-strategie die op korte termijn voor de beste zet gaat.


In de tabel hieronder zie je welke strategieën het best werkten en hoe ze zich tegenover elkaar verhielden.


{:.compact-table}
| Strategie | Elo-rating | Gespeelde partijen |
|----------|-----------|--------------|
| TurnEconomy-Optimized | 2170.8 | 6400 |
| TurnEconomy | 1955.3 | 6400 |
| TEExpectimax-D1 | 1914.0 | 6400 |
| PhaseBased-Optimized_V3 | 1865.5 | 6390 |
| PhaseBased-Optimized_V2 | 1689.4 | 6399 |
| Greedy-Default | 1653.6 | 6400 |
| Adaptive | 1647.3 | 6400 |
| PhaseBased-Optimized | 1567.1 | 6400 |
| VarianceAware-Aggr | 1467.1 | 6400 |
| PhaseBased | 1444.6 | 6400 |
| Greedy-Defensive | 1413.2 | 6400 |
| Priority | 1387.7 | 6400 |
| Expectimax-D1-Aggr | 1379.7 | 6400 |
| Greedy-Aggressive | 1179.8 | 6389 |
| VarianceAware-Optimized | 1039.3 | 6400 |
| Expectimax-D1-Def | 960.8 | 6400 |
| Random | 764.9 | 6400 |

De AI-strategieën en het voorbereidende werk van Zen Garden gaven me het vertrouwen dat ik nodig had. Nu kwam de echte uitdaging: dit alles omzetten in een afgewerkt Game Boy-spel.

## Het spel bouwen: menu's, graphics en besturing

Bij de meeste spellen moet je door een paar schermen voor het spel begint. Dat is hier ook het geval: je wordt eerst verwelkomd met een titelscherm waar je het spel kunt starten, daarna kies je de tegenstander, de moeilijkheidsgraad en je kant (donker/licht), en dan begint het spel. Dat is eenvoudige logica en laat toe om stap voor stap toe te werken naar de implementatie van het eigenlijke spel, waar we het bord, de stukken, de dobbelstenen enzovoort moeten tonen. Ook de UI waarmee je een zet kiest, moest nog worden gebouwd.

### Het titelscherm

Dit is doorheen de ontwikkeling sterk geëvolueerd, van een statische afbeelding met een klein menu naar een geanimeerd scherm dat de achtergrond en sprites benut om wat visuele interesse te wekken.

![The Royal Game of Ur als Game Boy-spel in BGB, met het titelscherm met het bord, het profiel van de tegenstander en het menu om het spel te starten](/assets/posts/2026-03-15-gameboy-royal-game-of-ur/title_screen.png){:.small-image}

### Het spel starten (singleplayer)

In de volgende schermen kan de speler de parameters van het spel instellen: hij kiest een tegenstander (die overeenkomt met een andere AI), stelt de moeilijkheidsgraad in (die bepaalt hoe strikt de AI zijn strategie volgt) en kiest de kant waarmee hij speelt (donker of licht). Samen met het titelscherm vormen deze een state machine, met meerdere lagen om de geselecteerde opties bij te houden.

Het ontwerpen van assets was relatief eenvoudig. Ik gebruikte vooral Gemini (Nano Banana 2) om de illustraties te maken, laadde ze in GIMP om ze wat op te kuisen en er echte 2-bitgraphics van te maken. Daarna werden ze met `png2asset` omgezet naar assets voor het spel. Dat één voor één doen was echter een vergissing; één grote afbeelding aan `png2asset` doorgeven en dan de juiste tiles laden is efficiënter. Voor de assets die hier worden gebruikt, leverde dat geen problemen op, maar in de volgende fase zou ik minder geluk hebben.

<div class="gallery-3-col" markdown="1">
![The Royal Game of Ur als Game Boy-spel in BGB, je tegenstander kiezen](/assets/posts/2026-03-15-gameboy-royal-game-of-ur/opponent_select.png)
![The Royal Game of Ur als Game Boy-spel in BGB, de moeilijkheidsgraad kiezen](/assets/posts/2026-03-15-gameboy-royal-game-of-ur/difficulty_select.png)
![The Royal Game of Ur als Game Boy-spel in BGB, de kant kiezen](/assets/posts/2026-03-15-gameboy-royal-game-of-ur/side_select.png)
</div>

### De eigenlijke gameloop maken

Ik hield de stap-voor-stapaanpak aan: ik tekende een bord, liet Claude dat aan het spel toevoegen en daarna werden de tekst en het profiel van de tegenstander toegevoegd. Maar toen het tijd was om de stukken op het bord te tekenen, liepen we vast. Omdat ik een PNG van het volledige spelbord gebruikte, bleek het voor Claude onmogelijk om tiles met de speelstukken erop toe te voegen, die vervolgens naar assets moesten worden omgezet en op de juiste positie getoond. Uiteindelijk sloeg ik een compleet andere weg in: ik maakte een bestand met alle bordvakjes, elk in een lege versie, met een zwart stuk en met een wit stuk, en converteerde die. Daarna koppelde ik die (manueel) aan de schermposities waar ze getekend moesten worden. Zo kon een bezet vakje op het bord met veel eenvoudigere logica worden getekend, door simpelweg de tiles van een andere positie in die referentie te nemen (zie hieronder).

<div class="gallery-2-col" markdown="1">
![tiles van de bordvakjes](/assets/posts/2026-03-15-gameboy-royal-game-of-ur/board_tiles.png){:style="width:auto; max-width:none; image-rendering:pixelated;"}
![profielen van de tegenstanders](/assets/posts/2026-03-15-gameboy-royal-game-of-ur/profiles_merged.png){:style="width:auto; max-width:none; image-rendering:pixelated;"}
</div>

De debugfunctie van BGB, en dan vooral die om het VRAM te bekijken, kwam heel goed van pas om sommige van deze problemen te ontrafelen.

![De VRAM-viewer in BGB](/assets/posts/2026-03-15-gameboy-royal-game-of-ur/bgb_vram_debug.png){:.small-image}

Toen dat opgelost was, moesten de sprites gemaakt worden. Ook dat bezorgde me wat kopzorgen, want sprites gebruiken slechts 3 van de 4 kleuren, waarbij er één transparant wordt. Omdat ik de sprites één voor één maakte, was die transparante kleur voor elke sprite anders en werden nieuwe sprites niet correct weergegeven. Zodra ik doorhad dat het aan het palet voor sprites lag, maakte ik alle sprites voor een bepaald scherm samen, met dezelfde transparante kleur, en stelde ik de paletconfiguratie voor elk scherm correct in.

![The Royal Game of Ur als Game Boy-spel in BGB, het eigenlijke spel](/assets/posts/2026-03-15-gameboy-royal-game-of-ur/game_board.png){:.small-image}

De rest kreeg Claude toegevoegd met slechts kleine hobbels onderweg. Ook hier nam ik mijn tijd, met vrij kleine incrementele wijzigingen die ik telkens opnieuw testte.

Aanvankelijk deed de computer gewoon steeds willekeurige zetten. De AI toevoegen bleek echter verrassend eenvoudig: ik kopieerde de code van de Python-agents waarmee ik verschillende AI-strategieën had getest en geoptimaliseerd, en Claude zette die om naar C, met de nodige aanpassingen om aan te sluiten bij de implementatie van het spel. Heel indrukwekkend! Ik moest enkel aangeven welke AI ik aan welk profiel gekoppeld wilde zien.

{:.compact-table}
| Tegenstander | Strategie | Beschrijving |
|----------|----------|-------------|
| **De Geleerde** | Adaptive | Wisselt tussen een defensieve, evenwichtige en agressieve modus naargelang de AI voorstaat, gelijk staat of achterstaat |
| **De Koopman** | Greedy | Beoordeelt bordposities op basis van voortgang, rozetten en vangsten |
| **De Muzikant** | Turn Economy | Minimaliseert het aantal beurten om te winnen en hecht veel waarde aan extra beurten via rozetten |
| **De Priesteres** | Phase-based | Past de weging van de evaluatie aan op basis van de spelfase (opening/middenspel/eindspel) |

Elke strategie heeft ook moeilijkheidsinstellingen (Easy/Medium/Hard) die bepalen hoe vaak de AI zijn strategie gebruikt in plaats van willekeurige zetten te doen:

- **Easy**: 40% kans dat de strategie gevolgd wordt, 60% willekeurig
- **Medium**: 65% kans dat de strategie gevolgd wordt, 35% willekeurig
- **Hard**: volgt de gekozen strategie 100%


### Winnen en verliezen

Het laatste scherm toont wie het spel gewonnen heeft. Aanvankelijk was dat een statische afbeelding, maar later kwam er een animatie bij het profiel (ook hier moest de manier waarop profielen naar assets werden omgezet worden herzien).

## Multiplayer: ondersteuning voor de linkkabel toevoegen

Rond het moment dat ik een werkende versie had, dacht ik eraan om af te ronden en het hierbij te laten. Met ondersteuning voor de linkkabel zou dit echter een spel voor twee spelers kunnen worden. Aangezien het linkkabelsysteem van de Game Boy in wezen een low-level seriële verbinding tussen de twee consoles is, is dat makkelijker gezegd dan gedaan; je zou echt het volledige communicatieprotocol moeten implementeren. Maar Anthropic bracht Opus 4.6 uit en schonk gebruikers $50 aan API-credits om met het nieuwe model te experimenteren. Met een sterker model en die extra credits besloot ik het te proberen!

Dit was met voorsprong het lastigste onderdeel van dit spel! Meer dan eens moesten grote stukken code worden geherstructureerd, de manier waarop de twee toestellen met elkaar moesten communiceren was niet vanzelfsprekend en testen kostte veel tijd. De wijzigingen van Claude moesten vaak worden teruggedraaid, want zelfs het Opus 4.6-model met high effort kon niet altijd de juiste implementatie vinden. Hoewel ik af en toe een stap of twee terug moest zetten, kreeg ik het uiteindelijk werkend door de code te testen, de implementatie te controleren en het model in de juiste richting te duwen.

Om dit te testen gebruik je best de emulator [Emulicious](https://emulicious.net/). Op mijn systeem kon BGB geen twee instanties verbinden ...

![Twee instanties van Emulicious die het spel draaien om de linkkabelmodus te testen](/assets/posts/2026-03-15-gameboy-royal-game-of-ur/emulicious_link_cable.png)

Voor wie het zich afvraagt: hiervoor waren de volledige $50 aan API-credits nodig, en zonder die credits zou het één à twee weken van het Pro-abonnement van Claude Code hebben gekost. Die credits kwamen dus op het juiste moment, want zonder die extra ruimte was deze functie er niet gekomen.

## Geluid en muziek

Dit is het onderdeel waar nog heel wat verbetering mogelijk is. Sommige GB-spellen hebben ongelooflijk iconische en sfeervolle soundtracks en uitstekende geluidseffecten. Het systeem kan dus echt veel meer dan wat ik eruit heb kunnen persen. Aangezien ik geen componist ben, koos ik een toonladder die Midden-Oosters aanvoelde, de Frygische toonladder, en voegde ik een paar variaties toe samen met hier en daar wat noten in het tweede kanaal. Zo bleven het wave- en het noise-kanaal vrij voor geluidseffecten.

Het was vooral een kwestie van proberen en mislukken om iets aanvaardbaars te laten klinken, maar er is hier zeker nog veel ruimte voor verbetering. De muziek wordt ondanks de variaties toch wat repetitief, dus besloot ik de optie toe te voegen om ze uit te schakelen. Vind je de SFX ook niets, dan kun je het volume van je console lager zetten.

Voor ik aan een ander project begin, ga ik nog wat tijd in hUGETracker steken om uit te zoeken hoe ik de geluidseffecten en muziek die ik wil op een doordachtere en voorspelbaardere manier kan maken.

Er waren wel wat problemen doordat ik de achtergrondmuziek pas zo laat in de ontwikkeling toevoegde. Op sommige schermen was er niet veel ruimte over om de muziek af te spelen en begonnen noten te laat of werden ze helemaal overgeslagen. Daardoor moest ik enkele functies schrappen (aanvankelijk had ik een animatie in het titelscherm) en wat code herstructureren zodat ze efficiënter en regelmatiger uitgevoerd werd.

## Wat ik leerde

De [techniek achter de Game Boy](https://www.youtube.com/watch?v=BKm45Az02YE) is ongelooflijk; het toestel zit vol slimme functies waarmee programmeurs veel kunnen doen op energiezuinige hardware. Dat vergt wel een degelijk begrip van het systeem, en enigszins verrassend slaagde Claude Code erin functies te implementeren met die trucs. Door Plan Mode te gebruiken en te vragen om ontwerpkeuzes uit te leggen, kun je veel over het systeem bijleren!


### Een nieuwe waardering voor Game Boy-spellen

Terwijl ik aan dit spel werkte en de beperkingen van het systeem begon te begrijpen, raakte ik steeds meer onder de indruk van sommige spellen uit mijn kindertijd. In Jurassic Park kan de speler bijvoorbeeld achter elementen (muren en bomen) lopen, wat onmogelijk lijkt gezien de manier waarop de achtergrondlaag, de sprites en de windowlaag op elkaar inwerken, en toch kregen ze dat voor elkaar. De graphics van Donkey Kong Land waren de concurrentie altijd al voor, maar met wat ik nu weet lijkt het nog onmogelijker wat die ontwikkelaars hebben gepresteerd! Ook de pure omvang van Pokémon Gold/Silver/Crystal verbaast me: die spellen zijn enorm en gebruiken meerdere geheugenbanken.

<div class="gallery-2-col" markdown="1">
![In Jurassic Park kan de speler achter het gebladerte lopen](/assets/posts/2026-03-15-gameboy-royal-game-of-ur/jurassic_park.png){:.small-image}
![Donkey Kong Land op de Game Boy had ongelooflijke graphics](/assets/posts/2026-03-15-gameboy-royal-game-of-ur/donkey_kong_land.png){:.small-image}
</div>

### Over The Royal Game of Ur zelf

De meeste racebordspellen zijn behoorlijk willekeurig; geluk bepaalt het hele spel en de spelers hebben weinig invloed op de uitkomst. Hier heb je een verrassende mate van controle. Doordat er vier binaire dobbelstenen gebruikt worden, is een worp van twee het waarschijnlijkst, zijn 1 en 3 iets minder waarschijnlijk en zijn de extremen 0 en 4 vrij zeldzaam. Dat vermindert de frustratie die je met één D6 zou hebben. Doordat je meerdere stukken op het bord hebt en beslist welk stuk je verzet, is er meer ruimte voor strategie en planning dan je zou denken.


## Wat nu?

Er zijn nog een paar zaken op dit systeem die ik niet heb verkend. Dit spel past op de eenvoudigste cartridges van 32K; wil je meer assets en code kwijt, dan moet je die over verschillende geheugenbanken spreiden en ertussen wisselen naargelang de assets die je nodig hebt. Werken met andere typen cartridges met meerdere banken zou een logische volgende stap zijn, want dat maakt complexere en grotere spellen mogelijk. Voor deze ROM was een opslagfunctie niet nodig, maar naarmate spellen complexer en langer worden, wordt dat wel een vereiste. Nu ik dit spel heb afgewerkt, is iets uitgebreiders mogelijk geworden.

Er zijn ook trucs die je met graphics kunt uithalen. Je kunt niet alleen coole dingen doen met de achtergrondlaag; ik heb hier ook enkel statische sprites gebruikt en de windowlaag maar heel even aangeraakt (voor het pauzescherm). Die mogelijkheden verkennen om interessantere overgangen tussen schermen te maken, zou een mooie volgende stap zijn.

De ROM op echte hardware draaien zou ook geweldig zijn, maar dat wordt prijzig. (Update: er is bevestigd dat de ROM werkt op echte hardware, inclusief de linkkabel.) Ik zou moeten uitzoeken hoe je de cartridges maakt — op zijn minst zou ik een toestel moeten kopen om de ROM naar een cartridge te schrijven — en ook geschikte handhelds moeten aanschaffen om de linkkabelmodus te testen. Echte toestellen worden hier steeds duurder, te duur om dit te verantwoorden (ik heb handhelds genoeg die GB-spellen prima via emulatie kunnen spelen), maar er zijn misschien opties zoals de Funny Playing Game Boy Color (FPGBC), een systeem op basis van FPGA dat de Game Boy Color op hardwareniveau emuleert en cartridges en de linkkabel ondersteunt. Verleidelijk is het wel ...


## Verder lezen

### Tools en software
  * [GBDK-2020](https://gbdk.org/) -- Game Boy Development Kit, de toolchain waarmee deze ROM gebouwd is
  * [hUGETracker](https://github.com/SuperDisk/hUGETracker) -- Muziektracker voor Game Boy-homebrew
  * [Claude Code](https://claude.ai/) -- De agentic AI-codeertool die tijdens de hele ontwikkeling gebruikt werd
  * [GIMP](https://www.gimp.org/) -- Beeldbewerkingsprogramma om de assets van het spel op te kuisen
  * [Gemini](https://gemini.google.com/app) -- Gebruikt om de illustraties voor het spel te genereren

### Emulators
  * [SameBoy](https://sameboy.github.io/) -- Accurate Game Boy-emulator
  * [BGB](https://bgb.bircd.org/) -- Game Boy-emulator met uitstekende debugtools
  * [Emulicious](https://emulicious.net/) -- Multi-systeememulator met ondersteuning voor de linkkabel tussen instanties

### The Royal Game of Ur
  * [Regels van The Royal Game of Ur](https://royalur.net/rules) -- Helder overzicht van de regels, en je kunt er ook online spelen
  * [Tom Scott vs Irving Finkel: The Royal Game of Ur](https://www.youtube.com/watch?v=WZskjLq040I) -- De video van het British Museum die dit hele project op gang bracht
  * [Irving Finkel over The Royal Game of Ur](https://www.youtube.com/watch?v=_bBRVNkAfkQ) -- De podcast die het idee weer deed opflakkeren
  * [The Royal Game of Ur op Wikipedia](https://en.wikipedia.org/wiki/Royal_Game_of_Ur) -- Geschiedenis, regels en archeologische context
  * [British Museum: The Royal Game of Ur](https://www.britishmuseum.org/collection/object/W_1928-1009-378) -- Het originele bord in de collectie van het museum

### Bronnen over Game Boy-ontwikkeling
  * [GBDK-2020-documentatie](https://gbdk-2020.github.io/gbdk-2020/docs/api/) -- Officiële GBDK-documentatie en API-referentie
  * [Pan Docs](https://gbdev.io/pandocs/) -- Uitgebreide technische referentie voor de hardware van de Game Boy
  * [Awesome Game Boy Development](https://github.com/gbdev/awesome-gbdev) -- Samengestelde lijst met bronnen over Game Boy-ontwikkeling
  * [The Ultimate Game Boy Talk](https://www.youtube.com/watch?v=HyzD8pNlpwI) -- Uitstekende technische verdieping in de hardware

### Hardware
  * [FunnyPlaying FPGBC](https://funnyplaying.com/products/fpgbc-kit) -- Op FPGA gebaseerd systeem dat compatibel is met de Game Boy Color

### Verwante artikels op deze blog
  * [Python to Rust: Porting My Genetic Art Algorithm]({% post_url nl/2025/2025-12-20-rust-experiment %}) -- Een gelijkaardig experiment met Claude Code in een onbekend ecosysteem
  * [An Agent Based Model to look at Gwent Pro Ladder]({% post_url 2020/2020-11-11-Gwent-Pro-Rank-ABM %}) -- De agent-gebaseerde modelleringsaanpak waarnaar verwezen wordt voor de AI-tegenstanders
  * [Can ChatGPT write a Python GUI app for me?]({% post_url 2023/2023-02-02-chatgpt-python-gui-app %}) -- Een eerder experiment met AI-ondersteunde ontwikkeling
  * [GameBoy Zero Builds]({% post_url 2021/2021-01-31-Gameboy-Zero %}) -- Een eerder Game Boy-project op deze blog

## Dankwoord

De headerafbeelding werd gegenereerd met [Gemini](https://gemini.google.com/app), vertrekkend van een [afbeelding uit het publieke domein](https://commons.wikimedia.org/wiki/File:British_Museum_Royal_Game_of_Ur.jpg).


