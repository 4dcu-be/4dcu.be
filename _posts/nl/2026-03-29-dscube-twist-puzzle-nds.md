---
layout: post
title: "Een 20 jaar oud NDS-project nieuw leven inblazen met AI"
byline: "Een Nintendo DS-homebrewproject reanimeren met Claude Code en Gemini"
description: "DSCube, een 20 jaar oude Rubiks kubus-homebrew voor de Nintendo DS geschreven in C++, weer tot leven wekken met Claude Code en Gemini, en met devkitPro en Docker opnieuw aan het bouwen krijgen."
date: 2026-03-29 08:00:00
post_id: dscube-twist-puzzle-nds
categories: ai programming games
tags: cpp nintendo nds retrogaming homebrew ai claude-code gemini rubiks-cube devkitpro docker
cover: "/assets/posts/2026-03-29-dscube-twist-puzzle-nds/header.jpg"
thumbnail: "/assets/images/thumbnails/dscube.jpg"
gallery_items:
  - image: "/assets/posts/2026-03-29-dscube-twist-puzzle-nds/solved_02.jpg"
    gallery_image: "/assets/images/gallery/dscube.jpg"
    description: "Een Nintendo DS Lite waarop mijn draaipuzzelspel DSCube draait."
author: Sebastian Proost
---

Bijna twintig jaar geleden, tijdens mijn doctoraat in de bio-informatica, moest ik mijn C++ weer opfrissen. Ons
labo deed aan vergelijkende genomica en bestudeerde hoe genomen op structureel niveau evolueren, in het bijzonder
de effecten van volledige genoomduplicaties in plantengenomen. Een van de belangrijkste tools die we gebruikten,
[i-ADHoRe 2.0], had een bug waardoor ik hem niet naar meer genomen kon opschalen, en ik zou die zelf moeten
oplossen. Dus deed ik wat elke nerd met een beetje zelfrespect zou doen: ik schreef een Rubiks kubus-simulator
voor de Nintendo DS om wat C/C++ te oefenen.

![DSCube-boxart](/assets/posts/2026-03-29-dscube-twist-puzzle-nds/box_art.jpg){:.medium-image}

Dat projectje, **DSCube**, lag bijna twee decennia stil. De code compileerde nog (net), maar de tekstgebaseerde
menu's en de erg kale interface begonnen hun ouderdom te tonen. Onlangs besloot ik er opnieuw naar te kijken,
niet uit pure nostalgie, maar om te zien hoe ver AI-ondersteunde ontwikkeling een project kon brengen dat ik nooit
de tijd of de grafische vaardigheden had om af te werken tot iets waar ik echt tevreden over was. Het resultaat is
een volledig afgewerkte draaipuzzelsimulator met 3D-rendering, touchbediening, eigen illustraties en ondersteuning
voor 2x2-, 3x3- en 4x4-kubussen.

Wil je het uiteindelijke spel uitproberen, ga dan naar [itch.io](https://sebastianproost.itch.io/dscube) en download daar de ROM.

<div style="text-align: center;">
<iframe frameborder="0" src="https://itch.io/embed/4419149" width="552" height="167"  style="max-width: 100%;"><a href="https://sebastianproost.itch.io/dscube">DSCube door sebastian.proost</a></iframe>
</div>

## Het origineel: C++ oefenen op een handheld met twee schermen

De Nintendo DS was een fascinerend platform om voor te ontwikkelen. De ARM9-processor, de hardwarematig versnelde
3D-engine en het touchscreen maakten er een echte uitdaging van, geen speelgoed. De oorspronkelijke DSCube had de
kernlogica van de puzzel werkend: je kon lagen draaien op kubussen van verschillende groottes, in 3D gerenderd op
het bovenste scherm. Maar alles eromheen was ruw. De menu's waren pure tekst, er was geen enkele visuele afwerking,
en de code was het soort "het werkt, blijf eraf"-C++ dat een bio-informaticus schrijft terwijl hij de taal leert.



De oorspronkelijke NDS-toolchain was ook een andere wereld. devkitPro opzetten, libnds geconfigureerd krijgen en
de hardwareregisters begrijpen: dat betekende allemaal ploeteren door schaarse documentatie en forumberichten. Er
was zo goed als geen Stack Overflow voor NDS-homebrew. Je had een paar wiki's, wat voorbeeldcode en heel veel
vallen en opstaan.

## Twee decennia later

Spoel door naar 2026. Ik ben aan het verkennen hoe AI-ondersteund programmeren hobbyprojecten naar een niveau kan
tillen dat ik alleen niet bereik, of dat nu [een genetisch kunstalgoritme naar Rust porten] is of [een Game Boy-game vanaf nul bouwen]. Elk project leert me iets nieuws over waar AI uitblinkt en waar menselijk oordeel nog altijd
onmisbaar is.

DSCube voelde als de perfecte kandidaat. De kernlogica was solide, maar de code eromheen was rommelig. De UI had een
volledige revisie nodig. Dat is precies het soort werk waarbij AI-ondersteuning goed werkt: bestaande code
refactoren, goed afgebakende functies implementeren en de saaie stukken afhandelen, zodat ik me op de
ontwerpbeslissingen kan concentreren.

## Een moderne buildomgeving opzetten

Eerste prioriteit was het project betrouwbaar aan het bouwen krijgen. De NDS-toolchain is sinds midden jaren 2000
sterk geëvolueerd, en ik wilde een reproduceerbare opzet. Ik stelde een Dockerfile samen op basis van de officiële
devkitPro-image:

{:.large-code}
```dockerfile
# Multi-stage build: start from the official devkitPro devkitARM image
# which includes the full NDS toolchain (devkitARM, libnds, ndstool, etc.)
FROM devkitpro/devkitarm:latest AS devkitarm

# Use a modern Debian base for the final image so we get recent Python
# and can install Node.js / Claude Code without fighting old system packages
FROM debian:bookworm-slim

# Carry over the entire devkitPro toolchain from the official image
COPY --from=devkitarm /opt/devkitpro /opt/devkitpro

# devkitPro environment variables expected by all NDS Makefiles
ENV DEVKITPRO=/opt/devkitpro
ENV DEVKITARM=${DEVKITPRO}/devkitARM
ENV PATH=${DEVKITPRO}/tools/bin:${DEVKITARM}/bin:${PATH}

# Core build tools and utilities needed for NDS development and general use
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials for compiling native helper tools or asset pipelines
    build-essential \
    make \
    # Python 3.11+ ships with Bookworm
    python3 \
    python3-pip \
    python3-venv \
    # Node.js needed for Claude Code (npm method) and JS-based asset tools
    curl \
    ca-certificates \
    # Version control
    git \
    # Useful for NDS ROM inspection and data manipulation
    xxd \
    # C/C++ code formatter (equivalent to black/ruff for Python)
    clang-format \
    # Shell niceties for devcontainer use
    less \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 LTS via NodeSource for Claude Code compatibility
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code globally via npm
# The native installer requires an interactive shell, so npm is more
# straightforward inside a container build
RUN npm install -g @anthropic-ai/claude-code

# Create a non-root user for devcontainer use
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && apt-get update && apt-get install -y --no-install-recommends sudo \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && rm -rf /var/lib/apt/lists/*

USER ${USERNAME}
WORKDIR /workspace

```

Deze multi-stage build haalt de volledige NDS-toolchain uit de officiële image van devkitPro en zet die op een
moderne Debian-basis. De container bevat Python (voor scripts die assets converteren), Node.js (voor Claude Code)
en clang-format voor een consistente codestijl. Met deze opzet kan iedereen de repo klonen en de ROM bouwen met
een simpele `make`.

## Het moderniseringsproces

Mijn workflow met Claude Code volgde een patroon dat ik over verschillende projecten heen heb verfijnd. Eerst werk
ik een markdowndocument uit met de wijzigingen die ik stap voor stap wil doorvoeren en beschrijf ik in detail hoe
ik ze geïmplementeerd wil zien. Daarna wijs ik de AI op één specifieke stap, laat ik die implementeren en verwijder
ik die stap uit de lijst. Voor grotere wijzigingen doe ik een extra ronde in **plan mode**, waarbij Claude een of
meer implementatieplannen voor een stap opstelt. Dat plan bekijk ik zorgvuldig, ik pas het aan waar nodig en laat
Claude het vervolgens uitvoeren terwijl ik het resultaat controleer. Voor rechttoe rechtaan taken sla ik de
planfase over, en voor triviale fixes schakel ik terug naar het Sonnet-model om tijd en tokens te sparen.

### De fundamenten opkuisen

De eerste rondes draaiden helemaal om codekwaliteit. Claude Code voerde een grondige code review uit en spoorde
dode code, inconsistente naamgeving, overbodige logica en potentiële bugs op. Een vroege winst was het bundelen
van losse globale variabelen in echte objecten: een `GameSession`-klasse om de timer en de zettenstatus bij te
houden, en een `nds_init`-wrapperklasse voor de initialisatie van de hardware:

```cpp
class GameSession
{
  public:
    void start(int initialMoves);
    void reset();
    bool isSolved() const;
    int getMoves() const;
    int getElapsedTicks() const;
    // ...
};
```

Dat soort refactoring is vervelend om met de hand te doen, maar gaat snel met een codeerassistent. Claude spotte
consequent patronen die ik zou hebben gemist: ongebruikte declaraties, magic numbers die constanten hadden moeten
zijn, functies die eenvoudiger konden.

### De interface grondig herwerkt

Hier ging het project van "functioneel" naar "afgewerkt". De oude tekstgebaseerde menu's werden vervangen door een
volwaardig knopgebaseerd UI-systeem dat zowel touch- als D-padnavigatie ondersteunt:

![Titelscherm](/assets/posts/2026-03-29-dscube-twist-puzzle-nds/main_menu_01.jpg)

Het spel doorloopt een nette state machine: titelscherm, aftelling (met geanimeerde 3-2-1-GO-graphics), spelen,
gepauzeerd en opgelost. Een `ButtonGroup`-klasse regelt de ruimtelijke navigatie: wanneer je een richting op het
D-pad indrukt, zoekt hij de dichtstbijzijnde knop in die richting. Dat klinkt eenvoudig, maar het vergt wat zorg
om het goed te krijgen op het 256x192-scherm van de DS.

### Graphics: hier sprong Gemini bij

Dit is een domein waar mijn vaardigheden gewoon tekortschieten. Ik gebruikte [**Google Gemini**](https://gemini.google.com/app) om alle visuele assets te genereren:
knopafbeeldingen in normale en geselecteerde toestand voor elke kubusgrootte, achtergronden voor elke spelstatus,
titeltekst in streetartstijl en zelfs een fictieve boxart. De assets werden vervolgens met een Python-script
omgezet naar het RGB555-formaat van de NDS:

```python
# tools/png2bin.py - Convert images to NDS RGB555 format
r5, g5, b5 = r >> 3, g >> 3, b >> 3
pixel = (1 << 15) | (b5 << 10) | (g5 << 5) | r5
```

Elke pixel wordt in een 16-bits word gepakt met 5 bits per kanaal en een alphabit. Die `.bin`-bestanden worden dan
rechtstreeks in de ROM gecompileerd via `bin2o` van devkitARM, waardoor ze in C beschikbaar zijn als byte-arrays.
Het is een eenvoudige pipeline, maar hij werkt. Doordat een AI de bronassets genereerde, kon ik itereren op de
visuele stijl zonder geblokkeerd te worden door mijn eigen artistieke beperkingen.

![Gameplay](/assets/posts/2026-03-29-dscube-twist-puzzle-nds/countdown.jpg)

### De libfb-compatibiliteitslaag

Iets wat nauwelijks als uitdaging aanvoelde, maar twintig jaar geleden een kopzorg zou zijn geweest, was dat de
`libfb`-bibliotheek waarvan mijn oorspronkelijke code afhing op een bepaald moment uit libnds was verwijderd.
Claude Code schreef een drop-in compatibiliteitslaag (`libfb_compat`) die de framebuffer-tekstweergave en het
blitten van afbeeldingen op het onderste scherm opnieuw implementeert met `bgInitSub` en `dmaCopy`. Elk frame
wordt een softwarematige framebuffer samengesteld en via DMA naar VRAM gestuurd:

```cpp
static u16 fb_buffer[256 * 192];  // software framebuffer

void bg_swapBuffers()
{
    dmaCopy(fb_buffer, bgGetGfxPtr(bg_id), 256 * 192 * sizeof(u16));
    // Reset to background image for next frame
    dmaCopy(current_bg, fb_buffer, 256 * 192 * sizeof(u16));
}
```

Ik vermeld dit omdat het een perfect voorbeeld is van het soort probleem dat vroeger een heel weekend opslokte met
documentatie doorspitten en debuggen. Met Claude Code was het in één stap klaar. Ik beschreef de ontbrekende
bibliotheek en de API die ik nodig had, en kreeg een werkende vervanging.

## Toen versus nu: hoe ontwikkelen veranderd is

Aan dit project werken in 2026 in plaats van in 2007 is een heel andere ervaring. Dit viel me op:

**Een toolchain opzetten is nu een fluitje van een cent.** Twintig jaar geleden was devkitPro aan de praat krijgen
op zich al een project van meerdere dagen. Met Docker geven een `Dockerfile` en een `Makefile` je in enkele minuten
een reproduceerbare buildomgeving. Dat is geen AI-verhaal, maar het cumulatieve effect van twee decennia
verbeteringen in opensourcetooling.

**AI neemt het vervelende werk over.** Code reviews, refactoring, compatibiliteitslagen schrijven, goed
gespecificeerde functies implementeren ... dat zijn taken waarin Claude Code goed presteert zonder veel sturing.
Twintig jaar geleden zou al dat afwerken weken of maanden werk in mijn vrije tijd hebben gekost, met horten en
stoten, en eerlijk gezegd zou ik het waarschijnlijk hebben opgegeven.

**Graphics zijn geen struikelblok meer.** Voor een hobbyprogrammeur met weinig artistieke aanleg betekende het
maken van fatsoenlijke knopafbeeldingen en achtergronden vroeger ofwel genoegen nemen met programmer art, ofwel een
medewerker zoeken. Gemini leverde bruikbare assets op basis van tekstbeschrijvingen, en hoewel ze niet
pixel-perfect zijn, zijn ze veel beter dan wat ik met de hand zou tekenen.

**De moeilijke stukken zijn nog altijd moeilijk.** 3D-selectie via touch (met `gluPickMatrix` voor hit testing),
het algoritme om te detecteren of een 4x4 opgelost is, en de camerawiskunde: dat vergde net zoveel zorgvuldig
nadenken als vroeger. AI kan helpen bij het implementeren van een oplossing zodra je ze hebt ontworpen, maar dat
ontwerp vraagt nog steeds een mens die het probleemdomein begrijpt.

**Debuggen op embedded targets is nauwelijks veranderd.** Als er iets misgaat op de NDS, staar je nog altijd naar
een zwart scherm of vervormde pixels. De emulators (melonDS, DeSmuME) zijn beter dan vroeger, maar debuggen op
beperkte hardware zonder stdout blijft even pijnlijk. Claude Code kan fixes voorstellen, maar kan je scherm niet
zien.

## Zelf aan de slag

Wil je DSCube uitproberen, haal het dan eerst op via [itch.io](https://sebastianproost.itch.io/dscube). Om het te draaien heb je twee opties:

1. **Op echte hardware**: kopieer `dscube.nds` naar een DS-flashcart
2. **In een emulator**: laad het in [melonDS](https://melonds.kuribo64.net/) of [DeSmuME](https://desmume.org/)


![Opgelost](/assets/posts/2026-03-29-dscube-twist-puzzle-nds/solved_closeup.jpg)
![Opgelost](/assets/posts/2026-03-29-dscube-twist-puzzle-nds/solved_01.jpg)


## Wat ik leerde

**AI-ondersteunde ontwikkeling schaalt ook naar beneden.** De meeste aandacht rond AI-codeertools gaat naar grote
codebases en moderne frameworks. Maar het werkt verrassend goed op een 20 jaar oud C++-project voor een
ARM9-processor met 4 MB RAM. Claude Code begreep de NDS-API's, de OpenGL-achtige renderpipeline en de beperkingen
van het platform zonder dat ik veel context moest aanleveren.

**AI gebruik je het best om bestaande kennis te vermenigvuldigen.** Ik begreep de kubuslogica, het hardwaremodel
van de NDS en hoe ik wilde dat het eindresultaat eruitzag. Claude Code en Gemini vulden de gaten in de
implementatie op: de boilerplate, de compatibiliteitscode, de visuele assets. Was ik aan dit project vanaf nul
begonnen zonder ervaring met embedded programmeren, dan zou de AI-ondersteuning veel minder effectief zijn geweest.

**Oude projecten zijn uitstekende AI-benchmarks.** Wil je weten wat AI-codeertools echt kunnen, richt ze dan eens
op je oudste, meest verstofte zijproject. De kloof tussen "werkend maar lelijk" en "afgewerkt en compleet" is
precies het soort kloof dat deze tools het best dichten.

Het is een vreemd gevoel om dit project eindelijk af te zien geraken. Twintig jaar geleden zette ik het in de kast
omdat het leven (en een doctoraatsthesis) ertussen kwam. De kernlogica was altijd al in orde, het had gewoon meer
tijd en moeite nodig dan ik kon verantwoorden. Nu is het, met wat hulp van AI, klaar.



[i-ADHoRe 2.0]: https://academic.oup.com/bioinformatics/article/24/1/127/204920
[een genetisch kunstalgoritme naar Rust porten]: {% post_url 2025/2025-12-20-rust-experiment %}
[een Game Boy-game vanaf nul bouwen]: {% post_url 2026/2026-03-15-gameboy-royal-game-of-ur %}
