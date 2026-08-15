---
layout: post
title:  "Altair + Vega + Justcharts = interactieve visualisaties op statische websites"
byline: ""
description: "Interactieve grafieken toevoegen aan statische sites zoals Jekyll met Altair, Vega en de justcharts-bibliotheek, door grafieken als JSON te exporteren zonder JavaScript te schrijven."
date:   2021-05-03 10:00:00
author: Sebastian Proost
post_id: interactive-visualizations
categories: programming
tags:	python pandas data-science altair vega
cover:  "/assets/images/headers/python_code.jpg"
thumbnail: "/assets/images/thumbnails/python_code.jpg"
custom_js:
  - vega.min
  - vega-lite.min
  - vega-embed.min
  - justcharts
---

Hoewel ik een groot voorstander ben van interactieve grafieken voor datavisualisaties op het web, zijn alle grafieken
op deze blog statisch. Met [Altair], [Vega] en een kleine bibliotheek, [justcharts], vielen alle puzzelstukjes eindelijk
op hun plaats om ook op deze blog te doen wat ik verkondig!

## Het probleem met statische sitegeneratoren en interactieve grafieken

Pandas, numpy, scikit-learn en [seaborn] worden vaak gebruikt om met gegevens te experimenteren en kwamen eerder al in
alle datagerelateerde posts op deze blog aan bod. Seaborn maakt met relatief weinig moeite heel mooie afbeeldingen,
maar er is geen eenvoudige manier om ze interactief te maken. Zodra je resultaten hebt die je wilt tonen, kun je extra
code schrijven om de gegevens te exporteren in een formaat dat compatibel is met een JavaScript-bibliotheek voor
grafieken (zoals [Chart.js]). Naast het extra werk levert dat nog een tweede probleem op ... Hoe voeg je ze toe aan een
blog die bijvoorbeeld met Jekyll is gegenereerd? Markdown ondersteunt afbeeldingen, maar voor grafieken zijn doorgaans
specifieke HTML-tags en enkele aangepaste regels JavaScript nodig, en die horen niet thuis in Markdown-bestanden. 

## De oplossing in een notendop

[Altair], een Python-pakket om grafieken te maken, lost het eerste probleem op. Wanneer je in een notebook werkt,
gedraagt Altair zich net zoals seaborn: de grafieken verschijnen wanneer het hoort. Achter de schermen worden ze echter
getekend met [Vega], een JavaScript-bibliotheek. Met Altair kun je de grafiekgegevens ook exporteren als een JSON-bestand
dat op elke website kan worden weergegeven, zolang je het nodige JavaScript toevoegt. 

Het nodige JavaScript rechtstreeks in een [Markdown]-bestand opnemen om die grafieken bijvoorbeeld aan een [Jekyll]-
blog toe te voegen, blijft een antipatroon. Daar komt [justcharts] van pas. Zodra die bibliotheek geladen is, kun je een
JSON-bestand met een Vega-grafiek met één regel HTML opnemen. 


## De grafiek voorbereiden met Altair

Deze post is geen volledige tutorial voor Altair of Vega en blijft dus heel eenvoudig. We laden een voorbeelddataset en
tonen hem als een spreidingsgrafiek. Door het sleutelwoord ```tooltip=``` toe te voegen, verschijnt er extra informatie
wanneer je over punten beweegt. De methode ```.interactive()``` maakt eenvoudig pannen en zoomen mogelijk. Eenvoudig,
maar voldoende als *proof of concept*. 

```python
import altair as alt
from vega_datasets import data

source = data.cars()
source.rename(columns={"Miles_per_Gallon":"Miles per Gallon"}, inplace=True)

chart = alt.Chart(source).mark_circle(size=60).encode(
    x='Horsepower',
    y='Miles per Gallon',
    color='Origin',
    tooltip=['Name', 'Origin', 'Horsepower', 'Miles per Gallon']
).interactive()
```

De API van Altair voelt wat aan als een kruising tussen seaborn en ggplot2. Als je van een andere bibliotheek komt, is
het dus even wennen. Toch hebben we met enkele regels code al een grafiek met *tooltips*, zoomen en pannen. 

Ten slotte kan de grafiek naar de schijf worden geschreven als een JSON-bestand dat compatibel is met Vega-Lite. Eerst
passen we ```.properties(width='container')``` toe (wat niet werkt in een Jupyter Notebook), zodat de grafiek de
volledige breedte van het bovenliggende element inneemt wanneer ze op de website wordt opgenomen. Zo wordt ze meteen
ook responsief. Met ```.save()``` wordt alles in het opgegeven bestand opgeslagen.

```python
chart.properties(width='container').save("cars.json")
```

## Alles in een Jekyll-sjabloon opnemen

Gelukkig ondersteunt het [Jekyll-sjabloon] van deze blog al het toevoegen van extra JS-bibliotheken aan specifieke
posts. Nadat je alle .js-bestanden naar de juiste map hebt gekopieerd, kun je ze dus voor een bepaalde post inschakelen
door de onderstaande regels aan de hoofding toe te voegen. 

```yaml
custom_js:
  - vega.min
  - vega-lite.min
  - vega-embed.min
  - justcharts
```

Wanneer deze bibliotheken geladen zijn, kun je een HTML-tag ```<vegachart>``` in een post opnemen. Het attribuut
```schema-url``` wijst daarbij naar het JSON-bestand dat met Altair werd gemaakt. De tag wordt op magische wijze in een
grafiek omgezet, zonder extra code. Merk op dat de aangepaste stijl ```style="width: 100%"``` nodig is wanneer de
breedte in het Vega-JSON-bestand op *container* is ingesteld.

{% raw %}
```xml
<vegachart schema-url="{{ site.baseurl }}/assets/posts/2021-05-03-Interactive-Visualizations/cars.json" style="width: 100%"></vegachart>
```
{% endraw %}

Het resultaat staat hieronder: een grafiek waarin je kunt pannen en zoomen, met *tooltips* die voor elk punt extra
gegevens tonen. Een kleine maar belangrijke verbetering ten opzichte van een statische afbeelding! Vega kan nog veel,
veel meer, dus dit kan nog een flink stuk verder worden uitgebreid.

[![Spreidingsgrafiek die het vermogen en brandstofverbruik van verschillende auto's vergelijkt](/assets/posts/2021-05-03-Interactive-Visualizations/cars.png)](/assets/posts/2021-05-03-Interactive-Visualizations/cars.json)

## Betere integratie met Markdown

Hoewel je enkele HTML-tags in een Markdown-document soms niet kunt vermijden, kan dit nog beter. Met een Jekyll-hook
kunnen we een aangepaste plug-in maken die zoekt naar het onderstaande patroon. Dat is geldige Markdown-syntaxis voor
een afbeelding die naar een ander bestand linkt. De hook zet dit om in de tag ```<vegachart>```. Als we het
Markdown-bestand ooit in een ander project moeten gebruiken waar Vega niet beschikbaar is, wordt de statische
afbeelding daardoor zonder problemen getoond en in een link naar de JSON-gegevens omgezet.

{% raw %}
```yaml
 [![Number of cylinders vs different stats](/assets/posts/2021-05-03-Interactive-Visualizations/cars2.png)](/assets/posts/2021-05-03-Interactive-Visualizations/cars2.json)
```
{% endraw %}

Deze aangepaste plug-in detecteert dit en zet het om in de vereiste tag ```<vegachart>```. Zonder de plug-in blijft het
perfect geldige Markdown en verschijnt de PNG-versie van de afbeelding, waarop je kunt klikken om het JSON-bestand te
downloaden.

{% raw %}
```ruby
Jekyll::Hooks.register :posts, :pre_render do |post, payload|
  post.content.gsub!(/^\[!\[(.*)\]\(([^\)]+)\)\]\(([^\)]+)\)/, "<vegachart schema-url=\"{{ site.baseurl }}\\3\" style=\"width: 100%\"></vegachart>")
end
```
{% endraw %}

Om te tonen dat dit werkt, staat hieronder de autodataset als boxplots die verschillende kenmerken vergelijken op basis
van het aantal cilinders. (Oké, ik lieg: de vorige grafiek werd ook met deze syntaxis toegevoegd.)

[![Aantal cilinders tegenover verschillende statistieken](/assets/posts/2021-05-03-Interactive-Visualizations/cars2.png)](/assets/posts/2021-05-03-Interactive-Visualizations/cars2.json)

## Conclusie

De resultaten kunnen variëren: de maker van [justcharts] beschrijft zijn eigen bibliotheek als
"[very hacky](https://twitter.com/fishnets88/status/1388753884236156931)", en door er nog een laag bovenop te leggen maak
ik het er waarschijnlijk niet beter op. Hoe *hacky* het ook is, dit biedt een bijzonder elegante manier om interactieve
grafieken in een Jekyll-sjabloon op te nemen. Ook de volledige workflow verloopt vlot. Je verkent de gegevens zoals
voorheen, alleen gebruik je Altair in plaats van seaborn, waarna je ze exporteert en met evenveel code als vroeger
toevoegt. Het zal wat werk vergen om even bedreven te worden met Altair als ik nu met seaborn ben, maar interactieve
grafieken op mijn blog zijn die extra inspanning zeker waard.

[Altair]: https://altair-viz.github.io/
[justcharts]: https://github.com/koaning/justcharts
[Vega]: https://vega.github.io/
[seaborn]: https://seaborn.pydata.org/
[Chart.js]: https://www.chartjs.org/
[Markdown]: https://en.wikipedia.org/wiki/Markdown
[Jekyll]: https://jekyllrb.com/
[Jekyll-sjabloon]: https://github.com/4dcu-be/4dcu.be
