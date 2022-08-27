---
layout: post
title:  "Where are my Magic: the Gathering cards ?"
byline: "plotting where my sold cards were shipped to"
date:   2022-01-30 10:00:00
author: Sebastian Proost
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

Since a few months I've been selling some [Magic: the Gathering] cards on [CardMarket]. Last week I realized I could 
extract the address from buyers from eml files (exported emails) with orders. From those the (approximate*) location 
using Google's [Geocoding API] can be found and plotted using [Altair]. This gives a visual overview where my cards are ending up !

Hovering over the map shows summary stats for each country or location. The color coding can be changed dynamically with
the combo-box below the chart. Locations close to each other are combined and shown with a larger dot, 
numbers inside the dots indicate how many orders were shipped to that municipality (or combination of municipalities).

[![Interactive map of CardMarket sales](/assets/posts/2022-01-30-MTG_sales_map/mtg_map.png)](/assets/posts/2022-01-30-MTG_sales_map/mtg_map.json)

As there are some cool bits of code used here (some [GeoPandas], clustering on [haversine] distance, ...) there will
be a full-length blog post, outlining those tricks in the future!

(*) to ensure buyers' addresses aren't made public, the center of their municipality is used instead of the exact 
location.

[Altair]: https://altair-viz.github.io/
[justcharts]: https://github.com/koaning/justcharts
[Vega]: https://vega.github.io/
[Geocoding API]: https://developers.google.com/maps/documentation/geocoding/overview
[Magic: the Gathering]: https://magic.wizards.com/en
[CardMarket]: https://www.cardmarket.com/
[GeoPandas]: https://geopandas.org/en/stable/
[haversine]: https://en.wikipedia.org/wiki/Haversine_formula
