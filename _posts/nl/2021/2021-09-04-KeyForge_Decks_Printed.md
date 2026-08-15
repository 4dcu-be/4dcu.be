---
layout: post
title:  "KeyForge: hoeveel decks werden er gedrukt?"
byline: "... en welk percentage werd geregistreerd?"
description: "Een schatting van het aantal gedrukte KeyForge Dark Tidings-decks op basis van Evil Twin-decks en Capture-Mark-Recapture in PyMC3: ongeveer 312.000 decks."
date:   2021-09-4 06:00:00
author: Sebastian Proost
post_id: keyforge-decks-printed
categories: programming games
tags:	python pymc3 keyforge data-analysis data-science machine-learning covid-19
cover:  "/assets/posts/2021-09-04-KeyForge_Decks_Printed/keyforge_logos.jpg"
thumbnail: "/assets/images/thumbnails/keyforge_deck_estimate.jpg"
github: "https://github.com/4dcu-be/BayesianSalesAnalysis"
---

KeyForge wordt vaak aangeprezen met 104 quadriljoen mogelijke decks per set (dat is 104 gevolgd door 24 nullen), maar
hoeveel van die decks bestaan werkelijk? [Fantasy Flight Games] maakte nooit bekend hoeveel decks er per oplage werden gedrukt.
Omdat Dark Tidings Evil Twin-decks heeft (exacte kopieën van andere decks, maar met Evil-versies van bepaalde 
kaarten), kunnen we het totale aantal gedrukte decks wel degelijk schatten! Zo krijgen we een beeld van welk percentage van de
decks geregistreerd is.

## Hoe schat je het aantal gedrukte Dark Tidings-decks?

In de [vorige post] werd een ecologische methode getoond, [Capture-Mark-Recapture] genaamd, om het aantal 
dieren in een populatie te schatten zonder ze allemaal te tellen. De basis van die strategie is dat je de 
locatie twee keer bezoekt en de dieren telkens onafhankelijk kunt vangen. De eerste keer worden de gevangen dieren gemerkt en vrijgelaten; 
de tweede keer noteer je het totale aantal gevangen dieren en hoeveel daarvan gemerkt zijn. Met die 
getallen kun je via een relatief eenvoudige formule de totale populatiegrootte schatten.

Om dit op KeyForge toe te passen, zijn de Evil Twin-decks in Dark Tidings de sleutel (woordspeling bedoeld). We kunnen de Evil Twin-decks als de eerste 
steekproef beschouwen: ze ‘merken’ hun gewone tegenhangers. Vervolgens bekijken we alle decks die geen Evil Twin zijn en tellen we hoeveel er 
gemerkt werden. Daarna kunnen we dezelfde ecologische formule gebruiken om het aantal gedrukte decks zonder Evil Twin te schatten.
Met een eenvoudige correctie maken we daarvan een schatting van het totale aantal gedrukte Dark Tidings-decks.

## Hoeveel DT-decks zijn er?

Op het moment van schrijven waren er **8.454 Evil Twin-decks** geregistreerd in [the master vault], terwijl er **96.960 Dark Tidings-decks
zonder Evil Twin** waren gescand. In totaal waren er **2.854 paren geregistreerd**. Deze drie waarden volstaan om
in de formule in te vullen en een schatting te krijgen! Bekijk voor details de [GitHub repo].

Dat geeft een gemiddelde schatting van **312.463 gedrukte Dark Tidings-decks**, met de 94%-HDI tussen 302k en 323k decks. 
Daarnaast blijkt dat ergens tussen **32,6% en 35,0% van al die decks al geregistreerd is**. 

## Hoeveel andere decks zijn er?

Dark Tidings is door COVID enigszins een buitenbeentje (zie 
[deze post]({% post_url nl/2021/2021-08-21-COVID_and_KeyForge %}) over de impact van COVID op KeyForge) en de oplage
lijkt daaraan te zijn aangepast. Projecties van deze gegevens naar andere sets moeten dus met
een flinke dosis scepsis worden bekeken. Met die waarschuwing in het achterhoofd weten we wel dat bij Dark Tidings, ongeveer drie maanden na de 
release, ruwweg één op de drie gedrukte decks geregistreerd was. Als we aannemen dat dit ook voor andere sets geldt (dat weten we niet, maar 
zonder die aanname eindigt het artikel hier), krijgen we deze schattingen:

|  Set | Geregistreerde decks * | Gedrukte decks (schatting) |
|-----:|-------------------:|---------------------:|
| CotA |            682 800 |            2 048 400 |
| AoA  |            295 698 |              887 094 |
| WC   |            256 531 |              769 593 |
| MM   |            174 778 |              524 334 |
| DT   |            105 414 |              312 463 |
| **Total**|                |        **4 541 884** |

*\* Het aantal decks dat drie maanden na de release geregistreerd was.*

Dit lijkt overeen te komen met de schaarse bekende details. CotA kreeg [meerdere oplages], waarschijnlijk om aan de 
vraag te voldoen. Volgens geruchten kregen MM en DT door COVID en leveringsproblemen een kleinere oplage (voor wie
Italiaans spreekt: het wordt vermeld in [deze podcast], dus voor Italiaanse kaarten is dit bevestigd).

## Conclusie

Dankzij de unieke aanwezigheid van Evil Twin-decks in Dark Tidings kunnen we nauwkeurig schatten
dat er ongeveer 312k Dark Tidings-decks werden gedrukt. Daaruit blijkt ook dat ongeveer zestien weken na de release ruwweg één derde van de DT-decks 
geregistreerd was. Dit nu doortrekken naar andere sets is twijfelachtig, maar het kan 
een zeer ruw beeld geven van hoeveel decks er bestaan. Het lijkt er dus op dat er over vijf sets heen **in totaal 4,5 miljoen decks werden gedrukt**.

Idealiter wordt deze analyse herhaald wanneer er nauwelijks nog DT-decks geregistreerd worden. 
Dan kunnen we schatten welk aandeel van de decks ooit geregistreerd zal worden, wat zich waarschijnlijk beter laat doortrekken
naar andere sets. Daarvoor moeten we wel nog een jaar of twee wachten tot de DT-registraties echt afnemen.

## Dankwoord

Hoewel alle gegevens uit [the master vault] kunnen worden geschraapt — bekijk de [GitHub repo] voor de code — is dat een erg traag proces.
Gelukkig had Saluk van [Archon Arcana] al een lijst met alle geregistreerde Dark Tidings-decks en was hij
zo vriendelijk die gegevens te delen.

Deze post is onofficiële fancontent. De tekstuele en grafische informatie over KeyForge die in dit project wordt getoond, 
is auteursrechtelijk beschermd door Fantasy Flight Games (FFG). 4DCu.be wordt niet geproduceerd, onderschreven of ondersteund door 
en is niet verbonden aan FFG.

[Fantasy Flight Games]: https://www.fantasyflightgames.com/en/index/
[vorige post]: {% post_url nl/2021/2021-08-30-Capture_Mark_Recapture %}
[Capture-Mark-Recapture]: https://www.bbc.co.uk/bitesize/guides/zmxbkqt/revision/3
[the master vault]: https://www.keyforgegame.com/
[GitHub repo]: https://github.com/4dcu-be/BayesianSalesAnalysis
[Archon Arcana]: https://archonarcana.com/Main_Page
[meerdere oplages]: https://www.reddit.com/r/KeyforgeGame/comments/bdwmk9/guide_for_distinguishing_print_runs/
[deze podcast]: https://open.spotify.com/episode/7sGXnTsNKfnBkQyDD7Yepr
