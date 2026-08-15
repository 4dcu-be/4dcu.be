---
layout: post
title:  "De klank van stilte: een stil mechanisch toetsenbord bouwen"
byline: ""
description: "Een stil mechanisch toetsenbord bouwen met de ID75-printplaat, met uitleg over wat mechanische schakelaars luid maakt en welke aanpassingen het tastgevoel behouden en tegelijk het geluid beperken."
date:   2023-04-14 08:00:00
author: Sebastian Proost
post_id: silent-mechanical-keyboard
categories: diy
tags:	mechanical-keyboard soldering electronics
cover:  "/assets/posts/2023-04-14-silent-mechanical-keyboard/completed.jpg"
thumbnail: "/assets/images/thumbnails/id75_keyboard2.jpg"
gallery_items:
  - image: "/assets/posts/2023-04-14-silent-mechanical-keyboard/closeup.jpg"
    gallery_image: "/assets/images/gallery/silent_mechanical_keyboard.jpg"
    description: "Close-up van een stil mechanisch toetsenbord op basis van de ID75-printplaat."
---

Tik je nog steeds op een goedkoop toetsenbord met rubberkoepels? Dan mis je misschien de aangename en
efficiënte ervaring van een mechanisch toetsenbord. Ik gebruik mijn [zelfgemaakte mechanische toetsenbord] intussen al
jaren en kan me niet voorstellen dat ik terug zou gaan. Bovendien is het formaat van 60% perfect om mijn muis dichtbij te houden
en onnodige handbewegingen te beperken, maar het geluid kan een nadeel zijn. Daarom heb ik wat tijd besteed aan het zoeken naar
stillere opties die toch de tactiele respons geven waar ik zo van hou. Lees verder om te ontdekken hoe ik een veel
stiller mechanisch toetsenbord bouw.

![Een stil mechanisch toetsenbord op basis van de ID75-printplaat](/assets/posts/2023-04-14-silent-mechanical-keyboard/completed.jpg)

## Wat maakt mechanische toetsenborden luid?

Wat mechanische toetsenborden onderscheidt van exemplaren met rubberkoepels, is dat ze voor elke toets een afzonderlijke schakelaar gebruiken.
Die schakelaars bestaan uit een veer en een steel die bij het indrukken een elektrisch circuit sluiten en de
toetsaanslag registreren. Het resultaat is een voelbare en hoorbare respons, waardoor je weet wanneer een toets correct werd ingedrukt.
Bovendien veroorzaken de stabilisatoren onder grotere toetsen, zoals de spatiebalk en shifttoets, extra geluid. Die
stabilisatoren zijn nodig om ervoor te zorgen dat deze toetsen langs alle kanten gelijkmatig worden ingedrukt, maar ze voegen extra
onderdelen toe die kunnen rammelen.

## De juiste onderdelen kiezen om lawaai te vermijden

Stille schakelaars kunnen het geluid van toetsaanslagen aanzienlijk beperken zonder dat de tactiele feedback verloren gaat. Een andere
optie is overschakelen op een ortholineair toetsenbord. Dat gebruikt een rasterindeling waardoor er geen stabilisatoren nodig zijn,
want er zijn geen grote toetsen. Dit ontwerp maakt typen ook ergonomischer, omdat je vingers
minder ver hoeven te bewegen om verschillende toetsen te bereiken. O-ringen aan de toetskapjes of een schuimlaag in de behuizing kunnen het geluid
van de schakelaars en stabilisatoren nog verder dempen. Door deze methodes te combineren, kun je bijna geruisloos typen
zonder je collega's of huisgenoten te storen.

## De onderdelen

  * **ID75** *hot-swappable* printplaat met aluminium achterplaat
  * Outemu **Silent** Lemon tactiele **schakelaars** (je hebt er 75 nodig, plus enkele reserve-exemplaren voor de zekerheid)
  * **Schuimlaag** tussen de achterplaat en de printplaat
  * Een set toetskapjes met **XDA-profiel**
  * Rubberen **O-ringen** voor de toetskapjes (75, één voor elk toetskapje)
  * Een **behuizing** die je mooi vindt (de meeste behuizingen van 60% werken met de ID75, maar moeten mogelijk wat worden aangepast)
  * Een toetskapjestrekker en een schakelaarstrekker (doorgaans meegeleverd met respectievelijk de toetskapjes en schakelaars)

Alle onderdelen (behalve de rubberen O-ringen) zijn hierboven afgebeeld. De schuimlaag die onder de printplaat moest komen, paste echter
niet goed in de behuizing en werd uiteindelijk niet gebruikt. Bij de standaardbehuizing van 60% moesten wel enkele afstandsbusjes
worden verwijderd en moest een stukje plastic dat op de resetknop van de ID75 drukte worden bijgesneden.

![Overzicht van alle onderdelen die nodig zijn om een stil mechanisch toetsenbord te bouwen](/assets/posts/2023-04-14-silent-mechanical-keyboard/parts.jpg)

Merk op dat er bij toetskapjes met een XDA-profiel geen verschil is tussen de toetsen op de verschillende rijen van het toetsenbord. Ze hebben
allemaal dezelfde vorm. Omdat alle toetskapjes dezelfde vorm hebben, kun je wat creatiever zijn met waar je welke toets plaatst,
zonder je zorgen te maken of de toetsen wel de juiste vorm hebben.

## De bouw

Omdat deze printplaat *hot-swappable* is, kun je de schakelaars er gewoon induwen en hoef je niet te solderen. Plaats eerst enkele schakelaars in
de juiste richting in de hoeken van de achterplaat, leg het schuim op de juiste plek, klik dit geheel op de printplaat en
duw vervolgens de overige schakelaars erin. Zorg er zeker voor dat de pinnen van de schakelaars mooi recht staan! Als ze niet correct uitgelijnd zijn,
buig je ze onherstelbaar krom en kun je de schakelaar niet meer gebruiken met een *hot-swappable* printplaat. Of erger nog: je beschadigt misschien de
aansluiting op de printplaat. Wees voorzichtig en zorg dat je enkele reserveschakelaars hebt.

![De achterplaat wordt met enkele eerst geplaatste schakelaars op de printplaat vastgehouden](/assets/posts/2023-04-14-silent-mechanical-keyboard/installing_switches.jpg)

Wanneer alle schakelaars geplaatst zijn, sluit je de printplaat aan en test je of ze allemaal werken. Zo niet, gebruik dan de schakelaarstrekker
om de defecte schakelaar uit het toetsenbord te halen en een andere te installeren.

![Meer schakelaars worden aan het mechanische toetsenbord toegevoegd](/assets/posts/2023-04-14-silent-mechanical-keyboard/more_switches.jpg)

## De indeling

Dankzij de combinatie van toetskapjes met een XDA-profiel en een ortholineaire printplaat kun je elke toets om het even waar op het bord plaatsen. Zo kun je
elke mogelijke indeling maken. Hoewel de meesten een indeling gebruiken die op qwerty lijkt (wat ik zou aanraden om het typen
op een normaal toetsenbord niet af te leren en problemen met een laptop te vermijden), heb je zelfs dan meerdere opties. Zodra je
beslist hebt welke indeling je wilt proberen, kun je de toetsen met de [VIA-software](https://usevia.app/) toewijzen. Dat is een eenvoudig proces dat
weinig moeite zal kosten als je tot hier geraakt bent. Gebruik [dit JSON-bestand](/assets/posts/2023-04-14-silent-mechanical-keyboard/idobao_id75.layout2.json)
als je dezelfde indeling wilt gebruiken als degene waarop ik uiteindelijk ben uitgekomen.

![Schermafbeelding van de VIA-app met een qwerty-achtige indeling voor de ID75-printplaat](/assets/posts/2023-04-14-silent-mechanical-keyboard/layout.png)

## Hoe luid is het?

Omdat ik geen echte decibelmeter had, moest ik een app op mijn mobiele telefoon gebruiken om het
geluidsniveau objectief te meten. Hoewel ik niet verwacht dat die heel nauwkeurig is, zouden de metingen wel vergelijkbaar moeten zijn en
een indicatie moeten geven van het relatieve geluidsniveau van verschillende toetsenborden. Voor de test legde ik de telefoon met de app gewoon naast
het toetsenbord en typte ik een minuut lang aan een gematigd tempo op [keybr.com]. Zo wist ik zeker
dat ik op elk toetsenbord ongeveer even snel typte. De resultaten waren verbluffend: het verschil
in geluidsniveau tussen de toetsenborden was opmerkelijk!

| Toetsenbord                         | Gemiddelde | Piek    |
|-------------------------------------|------------|---------|
| Mijn oude mechanische toetsenbord   | 30.4 dB    | 56.9 dB |
| Goedkoop toetsenbord met rubberkoepels | 25.0 dB | 42.7 dB |
| Logitech K400                       | 21.5 dB    | 39.5 dB |
| Stil mechanisch toetsenbord         | 20.3 dB    | 32.0 dB |


Dit toetsenbord is indrukwekkend stil en produceert 10 decibel minder geluid dan het gemiddelde toetsenbord. Vergeleken met een
doorsnee mechanisch toetsenbord, dat meer dan 20 decibel produceert, is het verschil behoorlijk groot. Het is de ideale oplossing
voor wie wil typen zonder collega's of geliefden te storen, of gewoon een
stillere type-ervaring verkiest.

![Een stil mechanisch toetsenbord op basis van de ID75-printplaat](/assets/posts/2023-04-14-silent-mechanical-keyboard/top.jpg)

## Conclusie

Een stil mechanisch toetsenbord bouwen is absoluut haalbaar en de resultaten spreken voor zich. De tactiele
feedback van een mechanisch toetsenbord blijft behouden, maar het geluid wordt drastisch beperkt. Als je het goed aanpakt,
kun je zelfs een toetsenbord bouwen dat stiller is dan exemplaren met rubberkoepels en tegelijk een veel aangenamere
type-ervaring biedt.

**Update**: Ik heb de indeling wat aangepast. De backspace bedienen met mijn duim werkte niet en de RGB-bediening is nu
beter. Het [bijgewerkte JSON-bestand](/assets/posts/2023-04-14-silent-mechanical-keyboard/idobao_id75.layout3.json) kan worden gedownload.

[zelfgemaakte mechanische toetsenbord]: {% post_url 2020/2020-05-01-Mechanical-Keyboard %}
[keybr.com]: https://www.keybr.com/
