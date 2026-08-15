---
layout: post
title:  "Een mechanisch toetsenbord bouwen"
byline: ""
description: "Hoe ik zelf een compact mechanisch toetsenbord van 60% bouwde, met schakelaars en soldeerwerk, en waarom mechanische schakelaars beter zijn dan rubberen membranen."
date:   2020-05-01 12:00:00
author: Sebastian Proost
post_id: mechanical-keyboard
categories: diy
tags:	mechanical-keyboard soldering electronics
cover:  "/assets/posts/2020-05-01-Mechanical-Keyboard/all-switches-in-place.jpg"
thumbnail: "/assets/images/thumbnails/mech_keyboard_header.jpg"
gallery_items:
  - image: "/assets/posts/2020-05-01-Mechanical-Keyboard/keyboard-final2.jpg"
    gallery_image: "/assets/images/gallery/mechanical_keyboard.jpg"
    description: "Een mechanisch toetsenbord van 60% dat ik zelf maakte."
---

Ik wist vaag dat er vreemde, dure, kleine toetsenborden bestonden, maar had nooit de moeite genomen om uit te zoeken
waarom. Tot een collega er eentje meenam naar het werk. Nadat ik er wat met haar over had gepraat en meer informatie
had verzameld, leek het me een leuk project om er zelf een te bouwen. Het resultaat zie je hieronder.

![Volledig gemonteerd mechanisch toetsenbord](/assets/posts/2020-05-01-Mechanical-Keyboard/keyboard-final2.jpg)

## Wat is een mechanisch toetsenbord?

Als je geen idee hebt wat een mechanisch toetsenbord is, volgt hier de korte uitleg. In massaal geproduceerde
toetsenborden zitten rubberen koepeltjes onder de toetsen om toetsaanslagen te registreren. Dat is goedkoop om te
produceren, maar de typervaring wordt gezien als een stap achteruit tegenover toetsenborden uit de jaren tachtig, zoals
de [IBM Model M]. Die had mechanische schakelaars (zie de afbeelding hieronder) onder elke toets. Bovendien verslijten
rubberen koepeltjes doorgaans veel sneller dan de metalen veren in mechanische schakelaars. Een mechanisch toetsenbord
gaat dus aanzienlijk langer mee dan een membraantoetsenbord.

![Enkele schakelaars voor een mechanisch toetsenbord](/assets/posts/2020-05-01-Mechanical-Keyboard/switches.jpg)

Een volledig toetsenbord heeft echter ongeveer 100 toetsen die elk hun eigen schakelaar nodig hebben. Daardoor worden
mechanische toetsenborden duur. Al die schakelaars zijn bovendien aanzienlijk zwaarder dan een rubberen membraan. De
Model M woog ruim 2 kilogram. Dat maakt hem bijzonder stabiel en stevig, maar het extra gewicht kan vervelend zijn als
je je toetsenbord vaak moet meenemen.

Daarom hebben veel mechanische toetsenborden minder toetsen. Dat verlaagt zowel de kostprijs (omdat er minder
onderdelen nodig zijn) als het gewicht. Vaak ontbreken de rij functietoetsen, het numerieke toetsenblok, de pijltjes en
andere toetsen uit het middelste deel (Delete, Page Up, Page Down ...). Moderne mechanische toetsenborden kun je zo
instellen dat die functies op een tweede of derde (of vierde ...) laag beschikbaar zijn. Met één toets wissel je tussen
de lagen. Net zoals Shift kleine letters in hoofdletters omzet, kun je een toetsenbord zo instellen dat de Menu-toets
de cijfertoetsen in functietoetsen (F1, F2 ...) verandert.

## Een mechanisch toetsenbord bouwen

Er bestaan volledig gemonteerde toetsenborden, maar als je er zelf eentje bouwt, kun je onderdelen en een uiterlijk
kiezen die bij je voorkeuren passen. Dat kan ook overweldigend zijn, want voor alle onderdelen zijn er bijzonder veel
mogelijkheden in sterk uiteenlopende prijsklassen.

![De onderdelen die ik voor mijn mechanische toetsenbord koos](/assets/posts/2020-05-01-Mechanical-Keyboard/all-components.jpg)

Hier zie je de onderdelen die ik voor mijn toetsenbord kocht:

  * Een set **toetsdoppen**
  * Een aluminium **achterplaat** (oranje, optioneel)
  * Een **printplaat**: de DZ60 v3.0 met USB-C
  * Een aluminium **behuizing** (grijs)
  * Twee zakjes witte leds van 1,8 mm (2x 50, optioneel)
  * Een set **stabilisatoren**
  * Een standaard gevlochten **USB-C-kabel**
  * Een set **schakelaars**: Kailh Box Burnt Orange (71)

Welke printplaat je kiest, hangt af van de indeling van je toetsenbord. Die bepaalt welke toetsdoppen, behuizing,
achterplaat enzovoort je nodig hebt. Ik koos een exemplaar van 60%, omdat dat vrij standaard is en er dus ruim
voldoende andere onderdelen voor bestaan. Het is ook ongeveer het kleinste formaat voordat je bij vrij exotische of
vreemde toetsenbordindelingen uitkomt. De Kailh Box Burnt Orange-schakelaars leken me een goed compromis voor algemeen
gebruik: typen, programmeren en wat gamen. Ze zijn iets zwaarder, want ik hou van een toetsenbord dat wat tegendruk
geeft. Afhankelijk van de gekozen printplaat kun je ledverlichting onder de toetsen toevoegen; welke leds je nodig hebt,
hangt opnieuw van de printplaat af. Merk ook op dat niet alle schakelaars plaats hebben voor een led. Voor grotere
toetsen, zoals de spatiebalk en Shift, heb je stabilisatoren nodig. Voor toetsenborden van 60% bestaan heel wat
behuizingen in allerlei kleuren en materialen. Kies er eentje die je mooi vindt. Voor toetsdoppen zijn er nog meer
mogelijkheden. Ik koos hier een vrij goedkope set; die kan later altijd worden vervangen.

Je hebt ook wat gereedschap nodig voor deze bouw:

  * Soldeerbout
  * Soldeer
  * Soldeerzuiger
  * Zijkniptang
  * Klein stukje geleidende draad of pincet
  * Schroevendraaier
  * Multimeter

### Stap 0: test de printplaat

Test de printplaat voordat je er iets op soldeert. Verbind ze met een computer, ga naar een website om toetsenborden te
testen ([zoals deze](https://config.qmk.fm/#/test)) en maak met een kort stukje draad of een pincet verbinding tussen de
contactpunten waar een schakelaar zou komen. Controleer met de multimeter of er spanning op de aansluitingen voor de
leds staat. Hou er wel rekening mee dat je mogelijk een toets moet indrukken om ze in te schakelen.

### Stap 1: soldeer de leds

Wanneer je onderdelen op een printplaat soldeert, begin je doorgaans best met de kleinste. Hier heb je zelfs geen keuze,
want de schakelaars komen over de leds. Om de led zo dicht mogelijk tegen de printplaat te krijgen, kan het helpen om
eerst een van de pootjes te solderen. Smelt die verbinding vervolgens opnieuw terwijl je aan het andere pootje trekt om
de led optimaal te plaatsen. Daarna kun je het tweede pootje solderen en de eerste verbinding indien nodig met wat
extra soldeer verbeteren. Zorg dat de leds correct geïnstalleerd zijn. Als ze scheef staan, wordt het moeilijk om de
schakelaars te plaatsen.

![Leds van 1,8 mm die in de Kailh-schakelaars passen](/assets/posts/2020-05-01-Mechanical-Keyboard/led-lights.jpg)

De DZ60 ondersteunt meerdere indelingen en de plaatsen waar schakelaars en leds moeten komen, verschillen. Soms zijn
de verschillen klein en subtiel. Controleer bij twijfel nogmaals met schakelaars waarop toetsdoppen zitten. Als je toch
een fout maakt, verwijder je de led met de soldeerzuiger. Verwarm het contactpunt niet te lang, want je kunt het en dus
ook je printplaat beschadigen.

Test alle leds voordat je verdergaat. Merk op dat de led onder Caps Lock op de DZ60 alleen aangaat wanneer Caps Lock
actief is. Raak dus niet in paniek als die niet meteen oplicht. Schakel Caps Lock in met de draad of het pincet en kijk
of de led aangaat.

### Stap 2: installeer de stabilisatoren

Zoek uit waar de stabilisatoren voor jouw indeling moeten komen en installeer ze. Er staan heel wat video's op YouTube
die tonen hoe je dat correct doet. Je kunt eventueel wat smeermiddel aanbrengen.

### Stap 3: monteer de achterplaat en soldeer de schakelaars

Belangrijk: de achterplaat wordt samen met de schakelaars vastgesoldeerd en kan achteraf niet meer worden geplaatst.
Duw enkele schakelaars in posities waar maar één plaats mogelijk is (het grootste deel van de bovenste rij en de meeste
letters) en plaats de achterplaat met die schakelaars op de printplaat. (Ik had een probleem met de stabilisator van de
spatiebalk. Om erbij te kunnen, moest ik twee kleine insnijdingen in de achterplaat maken, zodat ik de stabilisator kon
vervangen zonder alle (!) schakelaars los te solderen.)

Het is heel belangrijk dat je de schakelaars stevig tegen de printplaat soldeert. Soldeer daarvoor één pin vast, smelt
die verbinding opnieuw terwijl je de schakelaar stevig op zijn plaats duwt en soldeer vervolgens de andere pin. Werk
de eerste verbinding indien nodig af met wat extra soldeer. Herhaal dat voor de andere schakelaars en voeg geleidelijk
schakelaars toe. Het kan wat lastig zijn om ze in de achterplaat te laten vastklikken en er was enige kracht nodig. Let
erop dat je de printplaat niet beschadigt.

![De schakelaars solderen](/assets/posts/2020-05-01-Mechanical-Keyboard/half-way-though.jpg)

Dit kost veel tijd. Neem rustig de tijd en test regelmatig of alle gesoldeerde schakelaars werken. Controleer op
plaatsen waar meerdere posities mogelijk zijn met schakelaars waarop toetsdoppen zitten waar de schakelaar precies moet
komen.

### Stap 4: plaats enkele toetsdoppen

Je kunt nu de toetsdoppen beginnen te plaatsen. Dat spreekt voor zich: plaats de dop op de schakelaar en duw hem stevig
naar beneden. Zorg er alleen voor dat je de schroefgaten nog niet bedekt. Je moet erbij kunnen om de printplaat in de
behuizing te plaatsen. Test nog een laatste keer of alles werkt.

![De toetsdoppen plaatsen](/assets/posts/2020-05-01-Mechanical-Keyboard/installing-keycaps.jpg)

### Stap 5: plaats de printplaat in de behuizing

Plaats de printplaat in de behuizing, schroef ze vast en plaats de laatste toetsdoppen. De hardware is klaar!

![Volledig gemonteerd mechanisch toetsenbord](/assets/posts/2020-05-01-Mechanical-Keyboard/keyboard-final.jpg)

### Stap 6: configuratie

De standaardconfiguratie van de DZ60 is behoorlijk goed, al wil je ze misschien wat aanpassen. De pijltjestoetsen zijn
bijvoorbeeld niet toegewezen in de standaardconfiguratie. Daarvoor moet je aangepaste firmware flashen, maar met de
QMK-configuratietools is dat verrassend eenvoudig.

Ga naar [https://config.qmk.fm/](https://config.qmk.fm/) en klik rechtsboven op de tovenaarshoed om de handleiding te
openen. Kort samengevat maak je op de website een indeling en bouw je er ook de firmware. Download de gecompileerde
firmware en flash ze naar het toetsenbord met [qmk_toolbox](https://github.com/qmk/qmk_toolbox). (Mogelijk heb je een
stuurprogramma nodig om de firmware te kunnen flashen. Dat vind je op
[https://github.com/qmk/qmk_driver_installer/releases](https://github.com/qmk/qmk_driver_installer/releases).)

Hieronder zie je de indeling die ik momenteel gebruik. Laag nul is vrij standaard, behalve dat ik de rechter OS-toets
gebruik om laag twee te activeren. In laag één maakte ik van ESDF pijltjestoetsen. Ik gebruik niet de typische WASD-
toetsen, omdat ik daarvoor mijn hand één kolom zou moeten verschuiven. Nu kan ik de laag met mijn rechterpink activeren
en de pijltjestoetsen met mijn linkerhand bedienen. Het vroeg wat gewenning, maar intussen werk ik er zeer efficiënt mee.
Alle bediening voor de verlichting van de DZ60 verplaatste ik naar laag twee. Daar stelde ik ook enkele mediaknoppen en
een manier om mijn computer in slaapstand te zetten in.

![De indeling die ik momenteel gebruik](/assets/posts/2020-05-01-Mechanical-Keyboard/current_layout.png)

## Conclusie

Dingen bouwen is leuk, zeker als je ze elke dag kunt gebruiken. Het toetsenbord voelt bijzonder stevig aan en typt
uiterst aangenaam. Het maakt wel aanzienlijk meer lawaai dan een membraantoetsenbord, maar het klikken en klakken
wanneer ik snel typ vind ik motiverend. Hou daar wel rekening mee als je een mechanisch toetsenbord naar kantoor wilt
meenemen. Het ontbreken van enkele toetsen, vooral de pijltjestoetsen, was aanvankelijk lastig. Nadat ik ze op een voor
mij logische manier aan extra lagen had toegevoegd, was ik er echter snel aan gewend.

De achterplaat bezorgde me problemen toen ik bij de stabilisator van de spatiebalk moest komen (de staaf was uit het
scharnier gesprongen). Uiteindelijk moest ik de achterplaat strategisch met een boutenschaar bijknippen en de sneden
vijlen om de stabilisator te kunnen vervangen. Omdat deze toetsenborden bedoeld zijn om lang mee te gaan, moeten ze
herstelbaar zijn. Als je een achterplaat koopt, kies er dan dus eentje waarmee je zonder aanpassingen bij de andere
onderdelen kunt. Bij deze printplaat zit de led niet recht onder de letter en dat valt niet te veranderen. Daardoor
lichten de letters op de toetsen minder fel op dan ik hoopte. Misschien vervang ik de toetsdoppen later door een
mooiere, ondoorzichtige set die geen achtergrondverlichting nodig heeft.

Omdat hardwareprojecten best leuk zijn, zul je er later waarschijnlijk nog meer op mijn blog zien!


[IBM Model M]: https://en.wikipedia.org/wiki/Model_M_keyboard
