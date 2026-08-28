---
layout: post
title:  "Hnefatafl, een Vikingschaakspel voor de Game Boy"
byline: "Hnefatafl, Brandubh en Tablut bouwen voor de originele Game Boy"
description: "Hnefatafl, het Vikingschaakspel, samen met Brandubh en Tablut bouwen voor de originele Game Boy, en daarbij achtergrondscrolling, opslagsystemen en ondersteuning voor de Super Game Boy verkennen."
date:   2026-06-30 08:00:00
author: Sebastian Proost
post_id: gameboy-hnefatafl
categories: ai programming games
tags:	python c nintendo gameboy retrogaming homebrew ai claude-code agent-based-modeling
cover:  "/assets/posts/2026-06-30-gameboy-hnefatafl/hnefatafl_pieces.jpg"
thumbnail: "/assets/images/thumbnails/hnefatafl_pieces.jpg"
---

Bij [The Royal Game of Ur]({% post_url nl/2026/2026-03-15-gameboy-royal-game-of-ur %}) bleek het best lastig om twee Game Boys via de linkkabel met elkaar te laten praten. Ik kreeg $50 aan tokens en verstookte ze allemaal aan die ene functie. Ook fatsoenlijke muziek krijgen was een hele klus, en ik ben nog steeds niet helemaal tevreden met het resultaat. Toen ik dus begon aan een port van de familie van [Tafl-spellen](https://en.wikipedia.org/wiki/Tafl_games) naar de originele Game Boy, verwachtte ik half opnieuw tegen diezelfde muren aan te lopen. Met wat meer ervaring en een beter begrip van zowel het systeem als agentic coding zou het deze keer echter weleens anders kunnen lopen...

![Een spel Tablut aan de gang op de Game Boy](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/game_playing.jpg){:.small-image}

... en dat klopte! Met betere tools en meer kennis om ze te gebruiken, bleek het implementeren van deze spellen een fluitje van een cent. In deze post vertel ik hoe ik [Hnefatafl](https://en.wikipedia.org/wiki/Tafl_games#Hnefatafl), het Vikingschaakspel, en zijn verwanten [Brandubh](https://en.wikipedia.org/wiki/Tafl_games#Brandubh) (Iers) en [Tablut](https://en.wikipedia.org/wiki/Tafl_games#Tablut) (Samisch) nu allemaal aan de praat kreeg op de originele Game Boy. Dat gaf me meteen ook de kans om een paar hoekjes van DMG-ontwikkeling te verkennen die ik voordien nog niet had aangeraakt: achtergrondscrolling, effecten op basis van scanlines, een opslagsysteem, ondersteuning voor de Super Game Boy en meerdere geheugenbanken.

![Het titelscherm van Hnefatafl op een Game Boy](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/title_screen.jpg){:.small-image}

Wil je het spel uitproberen? [Download Hnefatafl gratis op itch.io](https://sebastianproost.itch.io/hnefatafl-viking-chess)!

<div style="text-align: center;">
<iframe frameborder="0" src="https://itch.io/embed/4667078?link_color=5ba9fa" width="552" height="167"  style="max-width: 100%;"><a href="https://sebastianproost.itch.io/hnefatafl-viking-chess">Hnefatafl - Vikingschaakspel door sebastian.proost</a></iframe>
</div>


## De Tafl-familie: Hnefatafl, Brandubh en Tablut

Deze Tafl-spellen waren ongeveer duizend jaar lang, van ruwweg de 4e tot de 12e eeuw, *de* bordspellen bij uitstek. "Tafl" betekent gewoon "bord" of "tafel" in het Oudnoords. Terwijl de Vikingen reisden en handel dreven, reisde het spel met hen mee en kreeg het onderweg een lokale toets: Hnefatafl ("de tafel van de koning") in Scandinavië, Brandubh ("zwarte raaf") in Ierland en Tablut bij de Sámi in het hoge noorden van Scandinavië. Geen van deze spellen overleefde, dus wat we over de regels weten, komt uit een lappendeken van oude manuscripten, fragmenten van spelborden en één beroemde, enigszins dubbelzinnige beschrijving die [Carl Linnaeus](https://en.wikipedia.org/wiki/Carl_Linnaeus) tijdens zijn reis door Lapland in 1732 neerschreef. De regels van de moderne spellen zijn dus in feite een goed onderbouwde gok, maar wellicht niet ver verwijderd van het origineel.

Wat de Tafl-spellen zo anders maakt dan schaken, is de asymmetrie. In plaats van twee identieke legers die tegenover elkaar staan, speelt elke speler een andere rol. De ene krijgt een koning en een kleine groep verdedigers die zich in het midden van het bord verschansen, aan alle kanten omsingeld door de aanvallers van de andere speler. De aanvallers winnen door de koning zo in te sluiten dat hij niet meer kan bewegen, terwijl de verdedigers winnen door hem veilig naar een van de randen of hoeken van het bord te brengen. Je vangt een stuk van je tegenstander door het langs een rij of kolom tussen twee van je eigen stukken in te klemmen. Dat is eenvoudig genoeg om uit te leggen, maar door de ongelijke startopstelling hebben aanvallers en verdedigers bijna volledig andere strategieën nodig, wat voor verrassend diepgaand spelplezier zorgt.

De varianten verschillen vooral in bordgrootte, en dat bleek behoorlijk belangrijk voor een Game Boy-port. Brandubh wordt gespeeld op een compact bord van 7×7, Tablut op 9×9 en Hnefatafl, in de meest gangbare moderne reconstructie, op 11×11. Het scherm van de Game Boy meet 160×144 pixels, wat neerkomt op een raster van 20×18 tiles van 8×8 pixels. Zelfs het Hnefatafl-bord van 11×11 past dus, maar alleen als elk vakje overeenkomt met precies één tile, zonder iets groters. Omdat ik alle spellen met dezelfde tileset wilde ondersteunen, koos ik ervoor om elk vakje van het bord als één tile te behandelen. Alle illustraties moesten dus leesbaar blijven op die 8×8 pixels.

## Eén engine, drie regelsets

![Boxart voor het homebrew Game Boy-spel Hnefatafl](/assets/posts/2026-06-30-gameboy-hnefatafl/hnefatafl_boxart.jpg){:.medium-image}

Voor ik ook maar één regel GBDK-code schreef, bouwde ik de game-engine in Python: bordstatus, validatie van zetten, regels om stukken te vangen en overwinningsvoorwaarden voor alle drie de varianten, geparametriseerd op basis van bordgrootte en startopstelling. Zo kreeg ik een snelle omgeving waarin ik AI-agents kon schrijven en tegen elkaar laten spelen, terwijl ik de strategieën voor de selectie van zetten voor Hnefatafl, Brandubh en Tablut verfijnde. Deze Python-implementatie werd vervolgens het vertrekpunt voor de C-port: dezelfde regels en structuur, vertaald naar de beperkingen van de hardware. Ik [schreef al eerder over hoe goed Claude Code van Python naar andere talen kan porten]({% post_url nl/2025/2025-12-20-rust-experiment %}), en dit is een aanpak die goed werkt bij agentic coding: zet eerst een prototype op poten in een omgeving die je goed kent, werk de details uit en haal de kinken eruit, en port het geheel pas daarna naar een beter geschikt framework.

Unit tests kunnen enorm waardevol zijn, al had ik er bij het vorige spel niet aan gedacht. Deze keer liet ik Claude unit tests toevoegen voor de C-implementatie, en de aanpak die daaruit kwam was slim: de Python-engine, die al grondig was getest tijdens de duels tussen agents, genereert testfixtures (bordstatussen, zetten en verwachte resultaten). Die worden samen met de C-code gecompileerd tot een kleine zelfstandige binary. Wanneer die binary wordt uitgevoerd, doorloopt hij dezelfde scenario's met de C-logica en vergelijkt hij de resultaten met de uitkomst die Python genereerde. Eerlijk gezegd is dit een strategie waar ik zelf nooit op zou zijn gekomen, maar ze is voor dit gebruik bijzonder zinvol.



<div class="gallery-3-col" markdown="1">
![Menu met de optie Brandubh](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_brandubh.jpg)
![Menu met de optie Tablut](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_tablut.jpg)
![Menu met de optie Hnefatafl](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_hnefatafl.jpg)
</div>

## Planning maakte een enorm verschil

Als er nog iets is dat dit project van het vorige onderscheidt, dan is het wel hoeveel voorbereidend werk ik deed voor er ook maar enige gamecode bestond! Bij The Royal Game of Ur leerde ik heel wat via vallen en opstaan: ik koos vaak voor suboptimale strategieën, wat later voor onverwachte problemen zorgde. Ook hoe ik de assets voor het bord aanleverde, was nogal kortzichtig en kwam me later duur te staan. Deze keer plande ik veel grondiger vooraf, en heel wat functies die deze keer "gewoon werkten", zijn daaraan te danken.

In de praktijk begon ik gewoon met een gesprek met Claude, ik dook niet meteen in de code. Op basis van dat gesprek werden de functieset, de specificaties, welke assets ik moest aanleveren en meer uitgewerkt. Dat mondde uiteindelijk uit in een HTML-overdrachtsdocument met gedetailleerde beschrijvingen die voor mij makkelijk leesbaar zijn, maar tegelijk ook als leidraad dienen voor agents om te implementeren. Daarna maakte ik die assets volgens de specificaties, in plaats van onderweg te improviseren. Dat maakte het veel eenvoudiger om tiles te hergebruiken (belangrijk om geheugen te sparen op deze oude systemen), de borden correct te tekenen en ze aan de spelstatus te koppelen. Ik werd ook een stuk beter in het voorbereiden van de illustraties zelf: ik zette afbeeldingen om naar nette geïndexeerde 2-bit-PNG's die `png2asset` zonder problemen kon verwerken.

Het andere waar ik deze keer op kon terugvallen, was de broncode van The Royal Game of Ur. De linkkabelmodus daarvan vergde eindeloos heen-en-weerwerk voor hij goed werkte. Deze keer wees ik Claude gewoon op die eerdere implementatie en vroeg ik om de beste delen ervan te hergebruiken en aan te passen. Na drie à vier iteraties in één enkele sessie werkte het perfect, terwijl diezelfde functie de vorige keer meer dan een week en $50 aan extra tokens had gekost (die ik gratis had gekregen). Dus als je een LLM naar een werkend voorbeeld kunt verwijzen, doe dat vooral — de winst was hier aanzienlijk (en eerlijk gezegd zou ik als mens ook liever met een werkend voorbeeld aan de slag gaan).

## Visuele effecten: achtergrondscrolling en scanlines

Hoewel ik nog niet heb beslist welk type spel ik uiteindelijk wil maken, weet ik dat één statisch scherm niet volstaat. Ik wil dat de speler een wereld zonder al te veel onderbrekingen kan verkennen (denk aan Pokémon). Dat betekent dat ik een grote kaart in de achtergrondlaag moet bouwen en die moet verplaatsen. Voor een bordspel is dat tijdens het spelen niet nodig, maar er is geen reden waarom het menu niet wat mooier kan, met afbeeldingen die verschuiven wanneer de speler een andere optie kiest.

<video style="display:block; margin:0 auto; width:100%; max-width:464px; max-height:464px;" controls>Je browser ondersteunt de &lt;video&gt;-tag niet.
    <source src="{{site.baseurl}}/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_animation.mp4"/>
</video>


Ik experimenteerde ook met scanline-effecten, waarbij je de achtergrond op een specifiek punt verschuift terwijl het scherm opnieuw wordt getekend. Oude racegames gebruikten deze truc om bochtige circuits te tekenen. Je ziet hem ook wanneer water onderaan het scherm golft terwijl de lucht statisch blijft, en sommige aanvallen in Pokémon worden eveneens zo geanimeerd. Ik kreeg het werkend, maar het effect paste niet echt bij een bordspel en haalde de uiteindelijke versie dus niet. Toch is het precies het soort truc dat ik in mijn gereedschapskist wil houden voor toekomstige projecten.

## Statistieken opslaan en geheugenbanken

Omdat een ronde Tafl niet lang duurt, had het weinig zin om een spel halverwege op te slaan. Om toch met SRAM met batterijback-up te werken, besloot ik de totale winst- en verliescijfers bij te houden. Omdat het opslaan van gegevens op een cartridge nogal verschilt van een bestandssysteem, verwachtte ik dat het een worsteling zou worden. Hier was het bijna anticlimactisch: Claude handelde de lees- en schrijfbewerkingen zonder enig probleem af.

![Het statistiekenscherm](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/stats_screen.jpg){:.small-image}

De meest eenvoudige Game Boy-cartridges hebben maar 32kB geheugen, dat de CPU rechtstreeks kan uitlezen. [The Royal Game of Ur]({% post_url nl/2026/2026-03-15-gameboy-royal-game-of-ur %}) gebruikt zo'n cartridge. Cartridges met SRAM om op te slaan hebben doorgaans meerdere ROM-banken van 16kB; die extra ruimte maakt uitgebreidere illustraties mogelijk voor de schermen voor kantselectie en winst/verlies dan ik er anders in had gekregen. Daar staat wel een nadeel tegenover: de CPU kan niet zomaar alle gegevens op elk moment uitlezen. Om gegevens uit een specifieke bank te lezen, moet die bank eerst geactiveerd worden, en de ene bank kan ook niet zomaar bij de gegevens van een andere. Het verbaasde me vooral hoe goed Claude de bank switching zelf beheerde. Om problemen vroeg op te sporen, bouwde het een kleine geheugenbank-agent die bij elke build wordt uitgevoerd. Die controleert of alles correct is ingedeeld en signaleert overlappingen of overschrijdingen voordat ze op de hardware een moeilijk te debuggen crash veroorzaken.

De schermen voor kantselectie waren een van de toepassingen waarbij die extra ruimte loonde: elke kant kreeg zijn eigen personage-illustratie in plaats van een eenvoudige tekstprompt.

<div class="gallery-2-col" markdown="1">
![Het scherm om de kant van de aanvallers te kiezen](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_side_attacker.jpg)
![Het scherm om de kant van de verdedigers te kiezen](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_side_defender.jpg)
</div>

De schermen voor winst en verlies kregen dezelfde behandeling: een specifieke bordstatus voor het einde van het spel naast een resultatenscherm met de eindstand.

<div class="gallery-2-col" markdown="1">
![Het eindscherm wanneer de verdediger wint](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/game_lost.jpg)
![Het resultatenscherm met de eindstand](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/result_lost.jpg)
</div>


## Ondersteuning voor de Super Game Boy

De vorige keer probeerde ik een rand toe te voegen die rond het spelscherm verschijnt wanneer een Super Game Boy wordt gebruikt (of, waarschijnlijker, geëmuleerd), maar ik liep tegen een muur. Die ROM was bedoeld voor de eenvoudigste cartridge, en in combinatie met mijn toen nog vrij zwakke assetbeheer bleef er niet genoeg geheugen over voor de extra gegevens die de rand nodig had.

![Hnefatafl in een emulator met de SGB-rand zichtbaar](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/sbg_support.jpg){:.medium-image}

Deze keer mikte ik op een geavanceerdere cartridge met meerdere banken, die ruim voldoende plaats biedt voor SGB-ondersteuning, vooral omdat de rand grotendeels tiles kon hergebruiken die ik al voor het bord had opgesteld. Hier maakte het nieuwste Opus-model (4.8) echt indruk op me. Ik beschreef wat ik wilde: een Hnefatafl-bord dat diagonaal is gesplitst, met één helft linksboven en de andere rechtsonder. Op basis van alleen die beschrijving maakte het een PNG, converteerde het de asset, herkende het dat die tiles al beschikbaar waren en implementeerde het de rand met de bestaande tiles. Toen ik daarna om een vleugje kleur vroeg, werd ook dat zonder problemen toegevoegd.


## Geluid en muziek

Muziek was de andere functie waar ik na de vorige keer tegenop zag. Toen kreeg Claude mijn nummers niet in een formaat dat [hUGETracker](https://github.com/SuperDisk/hUGETracker) kon laden. Een voordeel hier is dat er bekende Scandinavische melodieën zijn die ik rechtenvrij kon gebruiken. Daar begon ik dus mee, en ik vond een paar kandidaten: [*Drömde mig en dröm i nat*](https://en.wikipedia.org/wiki/Dr%C3%B8mde_mik_en_dr%C3%B8m_i_nat) (een middeleeuwse Noordse ballade, het oudste bekende wereldlijke lied in Scandinavië), [*Vem kan segla förutan vind*](https://en.wikipedia.org/wiki/Who_Can_Sail_Without_the_Wind%3F) (een Zweeds volkslied) en [*Herr Mannelig*](https://en.wikipedia.org/wiki/Herr_Mannelig) (een Zweedse middeleeuwse ballade).

De melodieën die voor mij vikingachtig klinken, hebben meestal een strijkinstrument dat lange tijd lage noten kan aanhouden. Dat geluid komt van een bastagelharpa, die wat groter en lager is dan de historisch correctere versies. Percussie is nog een moderne toevoeging. Ik wilde wat ritme, hoewel dat niet gebruikelijk lijkt te zijn geweest in traditionele Noordse muziek. De melodie zelf wordt vaak door schelle fluiten gespeeld.

Het verschil met de vorige keer was dat ik wist wat ik wilde voor ik erom vroeg. Ik beschreef welke instrumenten nagebootst moesten worden en hoe ze aan de kanalen van de Game Boy moesten worden toegewezen: aanhoudende strijkers op het wave-kanaal, de fluitmelodie op een pulse-kanaal en het noise-kanaal voor percussie, zodat CH1 vrijbleef voor SFX in het spel. Met die prompt, en na een paar pogingen, kreeg ik werkende `.uge`-bestanden terug. Na nog enkele aanpassingen in hUGETracker waren ze klaar om in het spel te gebruiken.

## Wat ik leerde

Bij agentic coding bleek planning moeilijke problemen makkelijker te maken. Door volledige tile- en spritesheets op te stellen voor ik aan de gamelogica begon, kon Claude Code met vertrouwen tiles hergebruiken in plaats van telkens te moeten uitzoeken of iets al herbruikbaar was. Vooraf weten welke instrumenten ik wilde en hoe ik ze aan de kanalen wilde toewijzen, is uiteindelijk wat de muziek liet werken en goed liet klinken.

De andere helft is ervaring: na een volledig project met GBDK ken ik het jargon gewoon beter — SCX/SCY, STAT-interrupts, VRAM-banken — waardoor ik met de juiste, specifieke termen kan vragen wat ik nodig heb. Ook kan het nieuwere Opus-model (4.8) dit soort low-levelwerk duidelijk beter aan. De code voor de linkkabel is het duidelijkste voorbeeld van hoe alles samenkwam. Bij The Royal Game of Ur was dit met voorsprong de meest tijdrovende functie. Deze keer wees ik Claude Code op de eerdere implementatie, doorliep ik een handvol iteraties en kreeg ik een betrouwbare versie terug. De grootste kopzorg van het vorige project werd een van de vlotste functies van dit project. Ook de muziek, doorgaans de zwakste schakel in mijn spellen, ging een stuk vlotter.

Samen geven deze successen me veel meer vertrouwen dat grotere, ambitieuzere projecten voor handheldconsoles ruimschoots binnen bereik liggen. Ik weet nog niet zeker wat het volgende wordt, maar ik ben er steeds meer van overtuigd dat de Game Boy nog heel wat in zijn mars heeft.


## Disclaimer

De speelstukken in de header en thumbnail van deze post werden met AI gegenereerd. Daarna werden ze verder verwerkt tot de uiteindelijke boxart en de illustraties in het spel.
