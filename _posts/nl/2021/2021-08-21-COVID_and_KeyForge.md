---
layout: post
title:  "De impact van COVID-19 op KeyForge"
byline: ""
description: "Een niet-technische blik op de impact van COVID-19 op de verkoop van KeyForge, met een PyMC3-model dat schat dat er tijdens de pandemie ongeveer 500.000 decks minder werden geregistreerd."
date:   2021-08-20 08:00:00
author: Sebastian Proost
post_id: covid-and-keyforge
categories: programming games
tags:	python pymc3 keyforge data-analysis data-science machine-learning altair covid-19
cover:  "/assets/posts/2021-08-21-COVID_and_KeyForge/ammonia_clouds_header.jpg"
thumbnail: "/assets/images/thumbnails/keyforge_covid.jpg"
github: "https://github.com/4dcu-be/BayesianSalesAnalysis"
custom_js:
  - vega.min
  - vega-lite.min
  - vega-embed.min
  - justcharts
---

COVID-19 had een impact op ons leven, maar wat was het effect op de verkoop van KeyForge? Vorige maand verscheen er een
[erg technische post]({% post_url nl/2021/2021-07-04-Bayesian-sales-analysis %}); deze is bedoeld voor iedereen die om 
KeyForge geeft, maar niet om de details van hoe je modellen bouwt.


## 500.000 minder decks geregistreerd tijdens COVID

Dit zal niemand verbazen: tijdens COVID, toen de wereld in lockdown ging, werden er minder decks
geregistreerd. Omdat lokale spellenwinkels dicht waren, waren fysieke wedstrijden soms moeilijk of onmogelijk en viel de competitieve
scène volledig stil. Er werden dus geen decks gekocht voor *sealed play* en er was geen reden om een heleboel decks te kopen om 
dat ene deck te vinden met de combo die je naar de top van het klassement kon brengen. Omdat mensen niet konden samenkomen
om te spelen, speelden ze minder en gingen de decks die ze wel kochten langer mee doordat het nieuwe er minder snel afging.

De grafiek hieronder toont in het blauw hoeveel decks sinds de release tot aan de publicatie van dit artikel in [the master vault]
werden geregistreerd. De grijze lijn geeft aan hoeveel decks er volgens het model geregistreerd zouden zijn als COVID-19 nooit 
was gebeurd. Het grijs ingekleurde gebied tussen de laagste en hoogste voorspelling toont de onzekerheid van het model.

[![Het bijgewerkte model toont hoeveel decks er in een wereld zonder COVID-19 geregistreerd zouden zijn](/assets/posts/2021-08-21-COVID_and_KeyForge/model_6_no_covid.svg)](/assets/posts/2021-08-21-COVID_and_KeyForge/model_6_no_covid.json)

Het model sluit dus als een handschoen aan bij de echte gegevens voordat de COVID-19-maatregelen van kracht werden (wat goed is, want anders
zou het een erg slecht model zijn). Naarmate het verder in ons hypothetische scenario voorspelt, neemt de onzekerheid toe 
(zoals verwacht). Het toont dat **er zonder COVID-19 op 15 augustus 2021 ongeveer 3,16 miljoen decks geregistreerd zouden zijn**. 
De slechtste voorspelling bedraagt 2,99 miljoen en de beste 3,31 miljoen. Daarmee steekt het werkelijke aantal geregistreerde decks op die
datum, 2,43 miljoen, nogal bleek af. 

Fantasy Flight Games verkocht in deze periode dus aanzienlijk minder KeyForge-decks. Dat is uiteraard niet
goed voor het spel: **zonder een wereldwijde pandemie zouden er minstens een half miljoen meer decks geregistreerd zijn**.
Merk op dat het aantal misgelopen verkopen nog hoger ligt, want niet elk verkocht deck wordt noodzakelijk geregistreerd.

## De interesse in KeyForge nam niet af

Zie je de kleine knikjes in de grafiek hierboven? Die bultjes vallen samen met de release van nieuwe sets. Elke set
wordt voorafgegaan door extra reclame om wat hype te creëren, en alleen al nieuwe kaarten doen mensen zin krijgen
om nieuwe decks te kopen. Het model bevat de interesse om bij een release nieuwe decks te kopen, zodat we die 
tussen sets kunnen vergelijken. (Technische details vind je in de 
[vorige post]({% post_url nl/2021/2021-07-04-Bayesian-sales-analysis %}); het nieuwste model staat op [GitHub].)

[![Het bijgewerkte model toont hoeveel interesse er bij de release van elke set was](/assets/posts/2021-08-21-COVID_and_KeyForge/model_6_set_interest.svg)](/assets/posts/2021-08-21-COVID_and_KeyForge/model_6_set_interest.json)

Deze grafiek is iets moeilijker te doorgronden dan de vorige, dus laten we hem rustig ontleden. Elke klokcurve stelt de
interesse in een andere set voor. Hoe verder de curve naar links ligt, hoe kleiner de interesse; hoe verder naar 
rechts, hoe meer decks er door de release van die set werden verkocht. De vorm van de curve toont waar het model denkt 
dat de werkelijke waarde ligt: die bevindt zich waarschijnlijker bij de top dan bij de voet van de curve. Overlappende curves betekenen 
dat de kans vrij groot is dat er geen echt verschil tussen beide sets was. De technische term voor deze curves is
[*probability density functions*][probability density functions]. 

De interesse in Call of the Archons, de allereerste set, is enorm vergeleken met de andere. Een nieuw spel uitbrengen van
[Richard Garfield, Ph.D.] zelf kan dat effect hebben. Omdat het een nieuw spel was, moesten mensen bovendien enkele decks kopen
om voldoende afwisseling te hebben. Dat nog niemand een verzameling had, maakte de drempel om in het begin decks te kopen dus
lager dan nu, wanneer sommige spelers al tientallen of zelfs honderden decks hebben verzameld.

Toch zien we slechts kleine verschillen tussen de interesse in andere sets die voordien uitkwamen (Age of Ascension en Worlds Collide) en
sets die tijdens de pandemie verschenen (Mass Mutation en Dark Tidings). De grafieken overlappen te sterk om met vertrouwen te zeggen welke
slechter of beter presteerden. Dat is hier goed nieuws! **We kunnen dus besluiten dat de interesse in 
nieuwe KeyForge-releases niet is afgenomen door een virusuitbraak!** 

## Conclusie

KeyForge is een spel dat bedoeld is om fysiek te spelen. Het is dus niet verrassend dat het aantal geregistreerde decks sterk daalde 
toen lokale spellenwinkels en toernooien plots wegvielen. Dat moet aanzienlijke 
verliezen hebben veroorzaakt voor zowel spellenwinkels als [Fantasy Flight Games], de producent van KeyForge. Met 500.000 minder geregistreerde decks in 
het voorbije anderhalf jaar ontstaat ook de indruk dat de interesse in het spel verdwenen is. Wie dieper in de 
gegevens duikt, ziet duidelijk dat dit niet klopt. Mensen leggen nog altijd geld neer 
om bij de release van een nieuwe set decks te kopen, net als vóór de pandemie. Dat suggereert dat het spel springlevend is, maar de 
redenen om tussen releases door meer producten te kopen (*sealed* en competitief spelen, of gewoon naar buiten kunnen gaan, tegenover 
iemand in de winkel gaan zitten en spelen) waren er gewoon niet. Hopelijk verandert dat binnenkort weer nu de
beperkingen worden opgeheven en het [World Championship] er in 2022 aankomt!

Merk op dat dit uitsluitend over het aantal *geregistreerde* decks gaat. Ben je geïnteresseerd in het totale aantal *gedrukte* 
decks, lees dan [deze post]({% post_url nl/2021/2021-09-04-KeyForge_Decks_Printed %}).

## Dankwoord

[Archon Arcana] houdt de geregistreerde decks al vanaf het prille begin bij en deelde zo vriendelijk 
de ruwe gegevens waarmee we konden spelen (bekijk hun pagina [hier](https://archonarcana.com/Master_Vault#Registered_decks)).

Deze post is onofficiële fancontent. De tekstuele en grafische informatie over KeyForge die in dit project wordt getoond, 
is auteursrechtelijk beschermd door Fantasy Flight Games (FFG). 4DCu.be wordt niet geproduceerd, onderschreven of ondersteund door 
en is niet verbonden aan FFG.

[the master vault]: https://www.keyforgegame.com/
[Richard Garfield, Ph.D.]: https://en.wikipedia.org/wiki/Richard_Garfield
[probability density functions]: https://en.wikipedia.org/wiki/Probability_density_function
[Fantasy Flight Games]: https://www.fantasyflightgames.com/
[World Championship]: https://www.fantasyflightgames.com/en/news/2021/2/4/forging-ahead/
[GitHub]: https://github.com/4dcu-be/BayesianSalesAnalysis
[Archon Arcana]: https://archonarcana.com/Main_Page
