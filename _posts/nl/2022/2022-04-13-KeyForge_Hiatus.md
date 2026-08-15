---
layout: post
title:  "De pauze van KeyForge: impact op deckregistraties"
byline: ""
description: "Een Bayesiaans model in PyMC3 gebruiken om te meten hoe de aankondiging van FFG over de pauze van KeyForge en COVID-19 de wekelijkse deckregistraties beïnvloedden, gevisualiseerd met Altair."
date:   2022-04-13 08:00:00
author: Sebastian Proost
post_id: keyforge-hiatus
categories: programming games
tags:	python pymc3 keyforge data-analysis data-science machine-learning altair
cover:  "/assets/posts/2022-04-13-KeyForge_Hiatus/david-kegg-ffg-keyforge-cover-final-small.jpg"
thumbnail: "/assets/images/thumbnails/keyforge_hiatus.jpg"
github: "https://github.com/4dcu-be/BayesianSalesAnalysis"
custom_js:
  - vega.min
  - vega-lite.min
  - vega-embed.min
  - justcharts
---

Het is intussen enkele maanden geleden dat FFG aankondigde dat KeyForge tijdelijk zou worden stopgezet, of in hun woorden [een pauze zou nemen]. Omdat er nog altijd decks 
worden geregistreerd, kunnen we een glimp opvangen van het effect van die aankondiging op het spel. In een [vorige post] maakte ik een 
model waarmee we zowel de impact van de uitgave van elke set op de deckregistraties kunnen afleiden als 
een realistische schatting kunnen maken van het aantal registraties dat door [COVID-19] verloren ging. Door een extra variabele aan het model toe te voegen, namelijk het
aantal wekelijkse registraties na de aankondiging van FFG, kunnen we de effecten van die aankondiging evalueren. 

De code voor deze post wordt besproken in een [vorige post]. De bijgewerkte versie en de nieuwste gegevens vind je op 
[GitHub].

## Daling van het aantal wekelijkse registraties

Voor de aankondiging, maar wel volop tijdens de pandemie, werden er wekelijks tussen 5820 en 6470 decks geregistreerd. 
De uitgave van nieuwe sets (Mass Mutation en Dark Tidings) dreef dat aantal telkens enkele weken op. Dat is een
aanzienlijk verschil met de situatie voor de pandemie, toen er elke week 14980 tot 16750 decks werden gescand.

Het model schat dat het aantal wekelijks geregistreerde decks sinds de aankondiging dat het spel werd stopgezet met **3,6% tot 17,5%** is gedaald (tegenover de situatie 
tijdens de pandemie). Dat betekent wel dat er elke week nog altijd 
5200 tot 5820 decks worden geopend en in het systeem worden ingevoerd.

[![Kansdichtheidsfunctie van de procentuele daling van het aantal registraties door de pauze](/assets/posts/2022-04-13-KeyForge_Hiatus/model_6_hiatus_percent_drop.svg)](/assets/posts/2022-04-13-KeyForge_Hiatus/model_6_hiatus_percent_drop.json)

De afbeelding hierboven toont de kansdichtheidsfunctie van de procentuele daling van het aantal registraties door de pauze. We
kunnen met vertrouwen stellen dat die tussen **3,6% en 17,5%** ligt, met een piek net boven 10%. Hoewel het spel niet bepaald dood is,
is het voor geen enkel bedrijf goed om 1 of 2 van elke 10 verkopen mis te lopen.

## Model zonder pandemie en zonder pauze

In de vorige post gebruikte ik het model om na te gaan hoe de deckregistraties zouden zijn geëvolueerd als er geen pandemie was geweest.
Dat doen we hier opnieuw met meer gegevens, waarbij we ook het effect van de pauze weglaten.

[![Model voor een situatie zonder pandemie en zonder pauze](/assets/posts/2022-04-13-KeyForge_Hiatus/model_6_no_covid_no_hiatus.svg)](/assets/posts/2022-04-13-KeyForge_Hiatus/model_6_no_covid_no_hiatus.json)

Na de pandemie en de aankondiging van de pauze valt het aantal decks dat elke week wordt geregistreerd nogal bleek uit
in vergelijking met twee jaar geleden. Het verschil tussen het werkelijke aantal geregistreerde decks (blauwe lijn) en de gemiddelde 
schatting (donkergrijze lijn) wordt groter. In [augustus 2021] (toen ik het model maakte) bedroeg het verschil ongeveer 
0,6 miljoen decks. Intussen is dat opgelopen tot ongeveer **1 miljoen**. 

Merk ook op dat er geen nieuwe sets zijn uitgegeven. Zodra de kaarten beschikbaar worden, geven die de deckregistraties doorgaans 
enkele maanden lang een flinke boost. In werkelijkheid had het verschil dus nog groter kunnen zijn.

## Tot slot

Het is duidelijk dat het aantal deckregistraties sinds de pauze is gedaald. Of dat uitsluitend door de 
aankondiging komt, dan wel door bijkomende effecten (zoals winkels die hun voorraad opruimen en geen KeyForge-decks meer te koop hebben), valt
niet te achterhalen. We weten wel dat nieuwe uitgaven en competitief spel de verkoop (en dus de registraties) stimuleren. Omdat 
geen van beide gedurende onbepaalde tijd zal plaatsvinden, ziet het er op lange termijn niet goed uit. Alles
welbeschouwd betekent zelfs een middenschatting van 10% minder wekelijkse registraties dan tijdens de
pandemie dat er elke week nog ruim 5500 nieuwe decks worden geopend, gescand en (hopelijk) gespeeld.

## Dankwoord

Deze post is onofficiële fancontent. De letterlijke en grafische informatie over 
KeyForge die in dit project wordt voorgesteld, is auteursrechtelijk beschermd door Fantasy Flight Games (FFG). 4DCu.be wordt niet geproduceerd, goedgekeurd of ondersteund door 
en is niet verbonden aan FFG.

[vorige post]: {% post_url nl/2021/2021-07-04-Bayesian-sales-analysis %}
[COVID-19]: {% post_url nl/2021/2021-08-21-COVID_and_KeyForge %}
[augustus 2021]: {% post_url nl/2021/2021-08-21-COVID_and_KeyForge %}
[een pauze zou nemen]: https://www.fantasyflightgames.com/en/news/2021/9/10/down-but-not-out/
[GitHub]: https://github.com/4dcu-be/BayesianSalesAnalysis
