---
layout: post
title:  "Waar zijn mijn Magic: the Gathering-kaarten?"
byline: "in kaart brengen waar mijn verkochte kaarten naartoe zijn verstuurd"
description: "Adressen van kopers uit CardMarket-bestelmails halen, ze geocoderen met Googles API en met Python en Altair in kaart brengen waar mijn Magic: the Gathering-kaarten naartoe zijn verstuurd."
date:   2022-01-30 10:00:00
author: Sebastian Proost
post_id: mtg-sales-map
categories: programming games
tags:	python pandas data-science altair vega mtg magic-the-gathering geopandas sklearn
cover:  "/assets/posts/2022-01-30-MTG_sales_map/mtg_map.png"
thumbnail: "/assets/images/thumbnails/mtg_map.jpg"
custom_js:
  - vega.min
  - vega-lite.min
  - vega-embed.min
  - justcharts
---

<style>
select {
  display: inline;
}
</style>

Sinds enkele maanden verkoop ik een aantal [Magic: the Gathering]-kaarten op [CardMarket]. Vorige week besefte ik dat ik 
de adressen van kopers kon halen uit eml-bestanden (geëxporteerde e-mails) met bestellingen. Daaruit kan de (geschatte*) locatie 
worden bepaald met Googles [Geocoding API] en in kaart worden gebracht met [Altair]. Zo krijg ik een visueel overzicht van waar mijn kaarten terechtkomen!

Als je met de muis over de kaart beweegt, verschijnen samenvattende statistieken voor elk land of elke locatie. De kleurcodering kan dynamisch worden aangepast met
de keuzelijst onder de grafiek. Locaties die dicht bij elkaar liggen, worden samengevoegd en met een grotere stip weergegeven. 
De cijfers in de stippen geven aan hoeveel bestellingen naar die gemeente (of combinatie van gemeenten) zijn verstuurd.

[![Interactieve kaart van CardMarket-verkopen](/assets/posts/2022-01-30-MTG_sales_map/mtg_map.png)](/assets/posts/2022-01-30-MTG_sales_map/mtg_map.json)

Omdat hier enkele leuke stukken code worden gebruikt (onder andere [GeoPandas] en clustering op basis van de [haversine]-afstand), volgt er
later nog een uitgebreide blogpost waarin ik die trucs uit de doeken doe!

(*) Om te voorkomen dat de adressen van kopers openbaar worden gemaakt, wordt het centrum van hun gemeente gebruikt in plaats van hun exacte 
locatie.

[Altair]: https://altair-viz.github.io/
[justcharts]: https://github.com/koaning/justcharts
[Vega]: https://vega.github.io/
[Geocoding API]: https://developers.google.com/maps/documentation/geocoding/overview
[Magic: the Gathering]: https://magic.wizards.com/en
[CardMarket]: https://www.cardmarket.com/
[GeoPandas]: https://geopandas.org/en/stable/
[haversine]: https://en.wikipedia.org/wiki/Haversine_formula
