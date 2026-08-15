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

Bij [The Royal Game of Ur]({% post_url nl/2026/2026-03-15-gameboy-royal-game-of-ur %}) kreeg de linkkabel me bijna klein. Het was met voorsprong de moeilijkste functie van dat project en slokte het grootste deel van $50 aan API-credits op voor hij eindelijk werkte. Muziek kwam op een goede tweede plaats en was het onderdeel waarover ik het minst tevreden was. Toen ik dus begon aan een port van de familie van [Tafl-spellen](https://en.wikipedia.org/wiki/Tafl_games) naar de originele Game Boy, verwachtte ik min of meer tegen dezelfde muren aan te lopen.

![Een spel Tablut aan de gang op de Game Boy](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/game_playing.jpg){:.small-image}

Maar deze keer was het een stuk eenvoudiger. De functies die de vorige keer het pijnlijkst waren, bleken nu net zonder problemen te gaan. Hoe dat kwam, is het verhaal van dit project. Deels lag het aan een sterker model, deels aan het feit dat ik het systeem beter ken, maar de grootste factor was de planning: de basis leggen voor ik ook maar één regel gamelogica schreef. Daarover verderop meer, maar eerst het spel.

[Hnefatafl](https://en.wikipedia.org/wiki/Tafl_games#Hnefatafl), het Vikingschaakspel, en zijn verwanten [Brandubh](https://en.wikipedia.org/wiki/Tafl_games#Brandubh) (Iers) en [Tablut](https://en.wikipedia.org/wiki/Tafl_games#Tablut) (Samisch) draaien nu allemaal op de originele Game Boy. Naast de linkkabel en muziek waren er nog enkele aspecten van DMG-ontwikkeling die ik niet had verkend: achtergrondscrolling, effecten op basis van scanlines, een opslagsysteem, ondersteuning voor de Super Game Boy en meerdere geheugenbanken. Deze familie van historische spellen porten was het perfecte excuus om me in al die zaken te verdiepen.

![Het titelscherm van Hnefatafl op een Game Boy](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/title_screen.jpg){:.small-image}

Wil je het spel uitproberen? [Download Hnefatafl gratis op itch.io](https://sebastianproost.itch.io/hnefatafl-viking-chess)!

<div style="text-align: center;">
<iframe frameborder="0" src="https://itch.io/embed/4667078?link_color=5ba9fa" width="552" height="167"  style="max-width: 100%;"><a href="https://sebastianproost.itch.io/hnefatafl-viking-chess">Hnefatafl - Vikingschaakspel door sebastian.proost</a></iframe>
</div>


## De Tafl-familie: Hnefatafl, Brandubh en Tablut

Lang voordat het schaakspel Noord-Europa bereikte, waren de Tafl-spellen ongeveer duizend jaar lang, van ruwweg de 4e tot de 12e eeuw, *de* bordspellen bij uitstek. "Tafl" betekent gewoon "bord" of "tafel" in het Oudnoords. Terwijl de Vikingen reisden en handel dreven, reisde het spel met hen mee en kreeg het onderweg een lokale toets: Hnefatafl ("de tafel van de koning") in Scandinavië, Brandubh ("zwarte raaf") in Ierland en Tablut bij de Sámi in het hoge noorden van Scandinavië. Geen van deze spellen overleefde als levende traditie. Wat we over de regels weten, komt uit een lappendeken van oude manuscripten, fragmenten van spelborden en één beroemde, enigszins dubbelzinnige beschrijving die [Carl Linnaeus](https://en.wikipedia.org/wiki/Carl_Linnaeus) tijdens zijn reis door Lapland in 1732 neerschreef.

Wat de Tafl-spellen zo anders maakt dan schaken, is de asymmetrie. In plaats van twee gespiegelde legers heb je een koning en een kleine groep verdedigers die zich in het midden van het bord verschansen, aan alle kanten omsingeld door een veel grotere overmacht aan aanvallers. De aanvallers winnen door de koning zo in te sluiten dat hij niet meer kan bewegen, terwijl de verdedigers winnen door hem veilig naar een van de randen of hoeken van het bord te brengen, afhankelijk van de variant. Je vangt een stuk door het langs een rij of kolom tussen twee stukken van je tegenstander in te klemmen. Dat is eenvoudig genoeg om uit te leggen, maar door de ongelijke startopstelling hebben aanvallers en verdedigers bijna volledig andere strategieën nodig. Daardoor is het een verrassend diepgaand spelletje voor iets met zo weinig regels.

De varianten verschillen vooral in bordgrootte, en dat bleek behoorlijk belangrijk voor een Game Boy-port. Brandubh wordt gespeeld op een compact bord van 7×7, Tablut op 9×9 en Hnefatafl, in de meest gangbare moderne reconstructie, op 11×11. Het scherm van de Game Boy meet 160×144 pixels, wat neerkomt op een raster van 20×18 tiles. Zelfs het Hnefatafl-bord van 11×11 past dus, maar alleen als elk vakje overeenkomt met exact één tile van 8×8 pixels. Daardoor kon ik niet elk vakje een grotere, gedetailleerdere tile geven, een aanpak die prima zou hebben gewerkt voor het bord van 7×7 van Brandubh of dat van 9×9 van Tablut. De illustraties van het bord en de stukken moesten dus allemaal leesbaar blijven op 8×8 pixels.

## Eén engine, drie regelsets

![Boxart voor het homebrew Game Boy-spel Hnefatafl](/assets/posts/2026-06-30-gameboy-hnefatafl/hnefatafl_boxart.jpg){:.medium-image}

Voor ik ook maar één regel GBDK-code schreef, bouwde ik de game-engine in Python: bordstatus, validatie van zetten, regels om stukken te vangen en overwinningsvoorwaarden voor alle drie de varianten, geparametriseerd op basis van bordgrootte en startopstelling. Zo kreeg ik een snelle omgeving waarin ik AI-agents kon schrijven en tegen elkaar laten spelen, terwijl ik de strategieën voor de selectie van zetten voor Hnefatafl, Brandubh en Tablut verfijnde. Deze Python-implementatie werd vervolgens het vertrekpunt voor de C-port: dezelfde regels en structuur, vertaald naar de beperkingen van de hardware. Dit is dezelfde aanpak die ik eerder gebruikte en hij werkt ontzettend goed. Ik [schreef al eerder over hoe goed Claude Code van Python naar andere talen kan porten]({% post_url nl/2025/2025-12-20-rust-experiment %}).

Kernlogica naar C porten is precies het soort werk waarbij kleine fouten, zoals een off-by-one-fout bij de controle om een stuk te vangen of een tekenfout in een richtingsvector, een spel ongemerkt stukmaken. Daarom liet ik Claude deze keer unit tests toevoegen voor de C-implementatie. Claude kwam met een slimme aanpak: de Python-engine, die al grondig was getest tijdens de duels tussen agents, genereert testfixtures (bordstatussen, zetten en verwachte resultaten). Die worden samen met de C-code gecompileerd tot een kleine zelfstandige binary. Wanneer die binary wordt uitgevoerd, doorloopt hij dezelfde scenario's met de C-logica en vergelijkt hij de resultaten met de verwachtingen die Python genereerde. Zo worden afwijkingen gedetecteerd voordat ze ooit op de echte hardware verschijnen. Een handige truc, en precies het soort vangnet dat ik bij het vorige project graag had gehad.



<div class="gallery-3-col" markdown="1">
![Menu met de optie Brandubh](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_brandubh.jpg)
![Menu met de optie Tablut](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_tablut.jpg)
![Menu met de optie Hnefatafl](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_hnefatafl.jpg)
</div>

## Planning maakte het verschil

Als er één ding is dat dit project van het vorige onderscheidt, dan is het wel hoeveel voorbereidend werk ik deed voor er ook maar enige gamecode bestond. Bij The Royal Game of Ur leerde ik op de harde manier dat het alleen maar ellende oplevert als je een agent telkens één asset geeft. Deze keer deed ik de planning vooraf, en bijna elk moment waarop iets later in het project "gewoon werkte", was daaraan te danken.

Ik pakte het op twee concrete manieren beter aan. Ten eerste plande ik vooraf veel meer met Claude: ik maakte een HTML-overdrachtsdocument met gedetailleerde beschrijvingen van hoe ik alles geïmplementeerd wilde zien, welke assets ik zou aanleveren en precies hoe elke asset gebruikt moest worden. Daarna maakte ik die assets volgens de specificaties, in plaats van onderweg te improviseren. Door vooraf volledige tile- en spritesheets op te stellen, kon Claude Code met vertrouwen bestaande tiles hergebruiken in plaats van nieuwe te genereren. Dat wierp vruchten af op manieren die ik niet volledig had voorzien; de Super Game Boy-rand hieronder is het duidelijkste voorbeeld.

Ten tweede werd ik veel beter in het voorbereiden van de illustraties zelf. Ik zette afbeeldingen om naar nette geïndexeerde 2-bit-PNG's die `png2asset` zonder problemen kon verwerken. Die ene verandering nam veel wrijving weg uit de assetpipeline, die het vorige project voortdurend parten had gespeeld.

Het andere waar ik deze keer op kon terugvallen, was de broncode van The Royal Game of Ur. De linkkabelmodus daarvan vergde eindeloos heen-en-weerwerk voor hij goed werkte. Deze keer wees ik Claude gewoon op die eerdere implementatie en vroeg ik om de beste delen ervan te hergebruiken en aan te passen. Na drie à vier iteraties werkte het, terwijl dezelfde functie de vorige keer weken en het grootste deel van die API-credits had gekost. Dat contrast, waarbij de grootste kopzorg van het vorige project een van de vlotste functies van dit project werd, zette de toon voor alles wat volgde.

## Visuele effecten: achtergrondscrolling en scanlines

Hoewel ik nog niet heb beslist welk type spel ik uiteindelijk wil maken, weet ik dat één statisch scherm niet volstaat. Ik wil dat de speler een wereld zonder al te veel onderbrekingen kan verkennen. Dat betekent dat ik een grote kaart in de achtergrondlaag moet bouwen en die moet verplaatsen. Voor een bordspel is dat tijdens het spelen niet nodig, maar er is geen reden waarom het menu niet wat mooier kan, met afbeeldingen die verschuiven wanneer de speler een andere optie kiest.

<video style="display:block; margin:0 auto; width:100%; max-width:464px; max-height:464px;" controls>Je browser ondersteunt de &lt;video&gt;-tag niet.
    <source src="{{site.baseurl}}/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/menu_animation.mp4"/>
</video>


Ik experimenteerde ook met scanline-effecten, waarbij je de achtergrond op een specifiek punt verschuift terwijl het scherm opnieuw wordt getekend. Oude racegames gebruikten deze truc om bochtige circuits te tekenen. Je ziet hem ook wanneer water onderaan het scherm golft terwijl de lucht statisch blijft, en sommige aanvallen in Pokémon worden eveneens zo geanimeerd. Ik kreeg het werkend, maar het effect paste niet echt bij een bordspel en haalde de uiteindelijke versie dus niet. Toch is het precies het soort truc dat ik in mijn gereedschapskist wil voor dat grotere toekomstige spel.

## Statistieken opslaan en geheugenbanken

Omdat een ronde Tafl niet lang duurt, had het weinig zin om een spel halverwege op te slaan. Om toch met SRAM met batterijback-up te werken, besloot ik de totale winst- en verliescijfers bij te houden. Bij het vorige project had ik een opslagsysteem aangemerkt als iets voor "de volgende keer" en verwachtte ik dat het een worsteling zou worden. Hier was het bijna anticlimactisch: Claude handelde de lees- en schrijflogica zonder veel gedoe af.

![Het statistiekenscherm](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/stats_screen.jpg){:.small-image}

Cartridges met SRAM hebben meestal ook meerdere ROM-banken (en ik wil op een dag fysieke exemplaren van deze spellen maken). Die extra ruimte maakte uitgebreidere illustraties mogelijk voor de schermen voor kantselectie en winst/verlies dan ik er anders in had gekregen. Het verbaasde me vooral hoe goed Claude de bank switching zelf beheerde. De geheugenindeling over verschillende banken is precies het soort administratief werk waarbij je makkelijk subtiele fouten maakt. Om problemen vroeg op te sporen, bouwde het een kleine geheugenbank-agent die bij elke build wordt uitgevoerd. Die controleert of alles correct is ingedeeld en signaleert overlappingen of overschrijdingen voordat ze op de hardware een moeilijk te debuggen crash veroorzaken.

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

Bij deze functie kwam de waarde van de planning echt tot uiting. De vorige keer probeerde ik een rand toe te voegen die rond het spelscherm verschijnt wanneer een Super Game Boy wordt gebruikt (of, waarschijnlijker, geëmuleerd), maar ik liep tegen een muur. Die ROM was bedoeld voor de eenvoudigste cartridge en er was gewoon niet genoeg geheugen over voor de extra gegevens die de rand nodig had.

![Hnefatafl in een emulator met de SGB-rand zichtbaar](/assets/posts/2026-06-30-gameboy-hnefatafl/screenshots/sbg_support.jpg){:.medium-image}

Deze keer mikte ik op een geavanceerdere cartridge met meerdere banken, die ruim voldoende plaats biedt voor SGB-ondersteuning, vooral omdat de rand grotendeels tiles kon hergebruiken die ik al voor het bord had opgesteld. Hier maakte het nieuwste Opus-model (4.8) echt indruk op me. Ik beschreef wat ik wilde: een Hnefatafl-bord dat diagonaal is gesplitst, met één helft linksboven en de andere rechtsonder. Op basis van alleen die beschrijving maakte het een PNG, converteerde het de asset, herkende het dat die tiles al beschikbaar waren en implementeerde het de rand. Toen ik daarna om een vleugje kleur vroeg, werd ook dat zonder problemen toegevoegd. Dat werkte alleen omdat de tiles klaarstonden om te worden hergebruikt, precies het rendement waarop ik hoopte na al die planning vooraf.


## Geluid en muziek

Muziek was de andere functie waar ik na de vorige keer tegenop zag. Toen kreeg Claude mijn nummers niet in een formaat dat [hUGETracker](https://github.com/SuperDisk/hUGETracker) kon laden. Een voordeel hier is dat er bekende Scandinavische melodieën zijn die ik rechtenvrij kon gebruiken. Daar begon ik dus mee, en ik vond een paar kandidaten: [*Drömde mig en dröm i nat*](https://en.wikipedia.org/wiki/Dr%C3%B8mde_mik_en_dr%C3%B8m_i_nat) (een middeleeuwse Noordse ballade, het oudste bekende wereldlijke lied in Scandinavië), [*Vem kan segla förutan vind*](https://en.wikipedia.org/wiki/Who_Can_Sail_Without_the_Wind%3F) (een Zweeds volkslied) en [*Herr Mannelig*](https://en.wikipedia.org/wiki/Herr_Mannelig) (een Zweedse middeleeuwse ballade).

De melodieën die voor mij vikingachtig klinken, hebben meestal een strijkinstrument dat lange tijd lage noten kan aanhouden. Dat geluid komt van een bastagelharpa, die wat groter en lager is dan de historisch correctere versies. Percussie is nog een moderne toevoeging. Ik wilde wat ritme, hoewel dat niet gebruikelijk lijkt te zijn geweest in traditionele Noordse muziek. De melodie zelf wordt vaak door schelle fluiten gespeeld.

Het verschil met de vorige keer was dat ik wist wat ik wilde voor ik erom vroeg. Ik beschreef welke instrumenten nagebootst moesten worden en hoe ze aan de kanalen van de Game Boy moesten worden toegewezen: aanhoudende strijkers op het wave-kanaal, de fluitmelodie op een pulse-kanaal en het noise-kanaal voor percussie, zodat CH1 vrijbleef voor SFX in het spel. Met die prompt, en na een paar pogingen, kreeg ik werkende `.uge`-bestanden terug. Na nog enkele aanpassingen in hUGETracker waren ze klaar om in het spel te gebruiken.

## Wat ik leerde

De rode draad door dit hele project is dat planning moeilijke problemen makkelijker maakt. Door volledige tile- en spritesheets op te stellen voor ik aan de gamelogica begon, kon Claude Code met vertrouwen tiles hergebruiken in plaats van nieuwe te genereren. Dat is precies wat ervoor zorgde dat de Super Game Boy-rand zo snel tot stand kwam. Vooraf weten welke instrumenten ik wilde en hoe ik ze aan de kanalen wilde toewijzen, zorgde ervoor dat de muziek direct werkte. En door assets in een gedetailleerd overdrachtsdocument te beschrijven voor ik ze bouwde, liep de hele assetpipeline niet vast zoals bij het vorige project.

De andere helft is ervaring, aan beide kanten. Na een volledig project met GBDK ken ik het jargon gewoon beter: SCX/SCY, STAT-interrupts, VRAM-banken. Daardoor kan ik om de juiste dingen vragen. Ook kan het nieuwere Opus-model (4.8) dit soort low-levelwerk duidelijk beter aan. De code voor de linkkabel is het duidelijkste voorbeeld van hoe alles samenkwam. Bij The Royal Game of Ur was dit met voorsprong de pijnlijkste functie en slokte hij het grootste deel van die $50 aan API-credits op voor hij werkte. Deze keer wees ik Claude Code op de eerdere implementatie, doorliep ik een handvol iteraties en kreeg ik een betrouwbare versie terug. De grootste kopzorg van het vorige project werd een van de vlotste functies van dit project. Ook de muziek, doorgaans de zwakste schakel in mijn spellen, ging een stuk vlotter.

Samen geven deze successen me veel meer vertrouwen dat grotere, ambitieuzere projecten voor handheldconsoles ruimschoots binnen bereik liggen. Ik weet nog niet zeker wat het volgende wordt, maar ik ben er steeds meer van overtuigd dat de Game Boy nog heel wat in zijn mars heeft.


## Disclaimer

De speelstukken in de header en thumbnail van deze post werden met AI gegenereerd. Daarna werden ze verder verwerkt tot de uiteindelijke boxart en de illustraties in het spel.
