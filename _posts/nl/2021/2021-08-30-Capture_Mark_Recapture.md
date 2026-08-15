---
layout: post
title:  "Capture-Mark-Recapture-model in PyMC3"
byline: ""
description: "Hoe je de grootte van een dierenpopulatie schat met de ecologische Capture-Mark-Recapture-methode, geïmplementeerd als Bayesiaans model in Python met PyMC3."
date:   2021-08-30 06:00:00
author: Sebastian Proost
post_id: capture-mark-recapture
categories: programming biology
tags:	python pymc3 data-analysis data-science machine-learning ecology biology
cover:  "/assets/posts/2021-08-30-Capture_Mark_Recapture/fish_header.jpg"
thumbnail: "/assets/images/thumbnails/fish_school.jpg"
---

Stel dat je wilt weten hoeveel vissen er in een vrij grote vijver zitten... Het water is troebel, dus ze eenvoudig
tellen kun je vergeten... In de ecologie is dit een veelvoorkomend probleem! Vaak moet de populatiegrootte van een soort bekend zijn, maar het is
onpraktisch of simpelweg onmogelijk om elk afzonderlijk dier in die populatie te tellen. Gelukkig bestaat er
een relatief eenvoudige manier om tot een schatting te komen!

Om de grootte van de populatie te schatten, bezoek je de locatie twee keer. Bij het eerste bezoek worden enkele 
dieren gevangen, gemerkt en vrijgelaten. Het is belangrijk ze te merken zonder dat dit hen benadeelt of verwondt, 
en even belangrijk is een markering te gebruiken die niet gemakkelijk afslijt. Je houdt bij hoeveel dieren uit de populatie werden
gevangen en gemerkt. Een dag of wat later bezoek je de locatie opnieuw en vang je weer een aantal dieren. Dit keer is het aantal
gemerkte dieren dat opnieuw wordt gevangen van belang. Het aandeel gemerkte dieren in de vangst van de tweede dag is 
immers in wezen gelijk aan het aandeel van de populatie dat de eerste dag werd gemerkt. Deze methode heeft verschillende namen,
zoals *[Capture-Mark-Recapture]*, *[Mark and Recapture]* of kleine variaties daarop.

Stel bijvoorbeeld dat je op dag één 50 dieren vangt en merkt. De volgende dag worden 100 dieren gevangen, waarvan er 10
gemerkt zijn. We weten dus dat ongeveer 10% van alle dieren gemerkt werd, en ook dat er in totaal 50 gemerkte
dieren zijn. De totale populatiegrootte moet dan ongeveer 500 bedragen. 

$$
\begin{aligned}
  \frac{n\_marked}{population\_size} = \frac{n\_recaptured}{captured\_round\_2}
\end{aligned}
$$

Deze formule kan worden herschreven als:

$$
\begin{aligned}
 population\_size = \frac{n\_marked * captured\_round\_2}{n\_recaptured}
\end{aligned}
$$

Hoewel die laatste formule erg eenvoudig is en vergelijkbare oefeningen al in de lagere school aan bod komen (bekend als de 
[regel van drie]), is het berekenen van het [betrouwbaarheidsinterval] van deze schatting — het bereik waarbinnen de werkelijke populatiegrootte met een 
bepaalde zekerheid, meestal 95%, ligt — verre van eenvoudig (bekijk de link: het is 
een bijzonder complexe formule). Met een Bayesiaanse aanpak krijgen we de onzekerheid over de populatiegrootte 
echter automatisch, zonder extra moeite. Laten we dit model dus implementeren in [PyMC3] en kijken wat eruit komt.


## Een PyMC3-model maken

De waarnemingen worden in enkele variabelen opgeslagen: ```n_marked``` (het aantal dieren dat bij het 
eerste bezoek werd gemerkt), ```captured_round_2``` (het totale aantal dieren dat bij het tweede bezoek werd gevangen) en ```n_recaptured``` 
(het aantal gemerkte dieren dat bij het tweede bezoek werd gevangen). De grote onbekende die we moeten afleiden is de 
```population_size```. Daarover weten we eigenlijk alleen dat ze gelijk is aan of groter dan het totale aantal
unieke dieren dat tijdens beide bezoeken werd gevangen. We kunnen het aantal waargenomen unieke dieren dus als ondergrens instellen.

De kans om bij het tweede bezoek een reeds gemerkt dier te vangen, ```p_marked```, is het aandeel gemerkte dieren in de
volledige populatie. Dit is dus een ```pm.Deterministic```-variabele, want ze wordt bepaald door het aantal gemerkte dieren (dat bekend is) 
en de populatiegrootte (die we proberen af te leiden). Tot slot is er een likelihood ```recapture_obs``` nodig. Die wordt 
een ```pm.Binomial```, met het totale aantal dieren dat de tweede dag werd gevangen als het aantal trekkingen, het aantal 
opnieuw gevangen gemerkte dieren als waarneming en ```p_marked``` als kans. 

```python
%load_ext nb_black
import pymc3 as pm

n_marked = 50
captured_round_2 = 100
n_recaptured = 10

with pm.Model() as model:
    population_size = pm.Bound(
        pm.Flat, lower=n_marked + captured_round_2 - n_recaptured
    )("population_size")
    p_marked = pm.Deterministic("p_marked", n_marked / population_size)

    recapture_obs = pm.Binomial(
        "recapture_obs", captured_round_2, p_marked, observed=n_recaptured
    )

    trace = pm.sample(4000, tune=1000, return_inferencedata=False)
```

Na het samplen van het model krijgen we onze schatting van de populatiegrootte. In dit geval wordt die geschat
op 294 tot 1034 dieren (hdi_3% en hdi_97%; PyMC3 geeft standaard het kleinste bereik waarin 94% van de
afgeleide waarden valt), met een gemiddelde van 620. Hoewel dat gemiddelde niet bijzonder ver afwijkt van de 
populatiegrootte in ons voorbeeld, is de onzekerheid vrij groot. Dit toont dat er in ons gedachte-experiment lang niet genoeg dieren werden 
gemerkt of opnieuw gevangen.

|                 |    mean |      sd |  hdi_3% |  hdi_97% |
|----------------:|--------:|--------:|--------:|---------:|
| population_size | 620.067 | 220.926 | 293.750 | 1034.423 |
|        p_marked |   0.090 |   0.028 |   0.039 |    0.142 |

### Update 30/08/2022 - hypergeometrische *likelihood*

Omdat de trekkingen uit de populatie in dit geval niet onafhankelijk zijn, past een HyperGeometric-verdeling beter bij dit model. De
laatste twee onderdelen kunnen worden vervangen door de regels hieronder om die te gebruiken. Als het aantal gemerkte dieren groot genoeg is,
maakt dat weinig verschil, maar hier beïnvloedt het wel de gemiddelde schatting en de 94%-HDI.

```python
    recapture_obs = pm.HyperGeometric(
        "recapture_obs", N=population_size, k=n_marked, n=captured_round_2, observed=n_recaptured
    )

    trace = pm.sample(4000, tune=1000, return_inferencedata=False, target_accept=0.9)
```

|                 |    mean |      sd |  hdi_3% |  hdi_97% |
|----------------:|--------:|--------:|--------:|---------:|
| population_size | 748.737 | 372.363 | 273.785 | 1396.472 |
|        p_marked |   0.040 |   0.015 |   0.012 |    0.067 |

## Kunnen we verbeteren zonder meer dieren te vangen?

Als we in totaal niet meer dieren vangen, is het dan beter om meer dieren te merken en er bij het volgende bezoek minder te vangen? Of vangen we beter meer
dieren bij het tweede bezoek en merken we er de eerste keer minder? Met dit model kunnen we dat gemakkelijk testen!

Laten we op dag één 100 dieren merken en er op dag twee 50 vangen. Bij een populatie van 500 verwachten we dat er ongeveer 10
opnieuw gevangen worden. Als we die getallen in het model invoeren, krijgen we de resultaten hieronder.

|                 |    mean |      sd |  hdi_3% |  hdi_97% |
|----------------:|--------:|--------:|--------:|---------:|
| population_size | 610.585 | 212.195 | 310.344 | 1008.055 |
|        p_marked |   0.180 |   0.054 |   0.082 |    0.279 |

Hoewel er nog steeds veel onzekerheid is, neemt die af wanneer je op de eerste dag meer dieren vangt en op de
tweede dag minder. (Het bewijs dat het slechter wordt als je het omgekeerde doet, laat ik aan de lezer over.) Zodra
je echter zo weinig dieren vangt dat je op de tweede dag nauwelijks gemerkte dieren terugvangt, heeft ook dat een negatieve
invloed op de schatting.

## Dubbel zoveel dieren vangen

Dit model werkt echt goed als er genoeg dieren kunnen worden gemerkt en opnieuw gevangen. Als we het aantal
markeringen dus verhogen naar 200 en de tweede dag 100 dieren vangen, verwachten we dat er ongeveer 40 gemerkt zijn. Wanneer we die getallen in het
model invoeren, zien we dat het gemiddelde nu heel dicht ligt bij de waarde voor onze denkbeeldige populatie en dat de
onzekerheid veel kleiner is.

|                 |    mean |     sd |  hdi_3% | hdi_97% |
|----------------:|--------:|-------:|--------:|--------:|
| population_size | 519.579 | 66.165 | 402.473 | 643.741 |
|        p_marked |   0.391 |  0.048 |   0.302 |   0.483 |

## Conclusie

Hoewel de formule voor dit model eenvoudig is, geldt dat niet voor de berekening van het betrouwbaarheidsinterval. Toch kan het hier cruciaal zijn om te weten
hoe groot de onzekerheid is. In ons eerste voorbeeld zou je, afhankelijk van hoeveel vissen er in de vijver zitten,
vissers een bepaald aantal kunnen laten vangen. Of het er 293, 500, 610 of 1034 zijn, kan dus bepalen hoeveel mensen 
in die vijver mogen vissen.

Met een Bayesiaanse aanpak lossen we het probleem op in enkele eenvoudige regels code en krijgen we meteen ook het betrouwbaarheidsinterval: 
gemakkelijk! Dat is precies de kracht van Bayesiaanse statistiek. De voordelen worden hier nog duidelijker 
omdat het erg eenvoudig is met de aantallen te spelen en te zien hoe de onzekerheid kan worden verkleind. Zo kunnen 
dieren zo efficiënt mogelijk worden gevangen en gemerkt.

Wil je zien wat ik met deze formule deed, lees dan de [volgende post], waarin ze wordt gebruikt om te schatten hoeveel KeyForge-decks
er werden gedrukt.

## Dankwoord

Headerafbeelding door [Sebastian Pena Lambarri](https://unsplash.com/@sebaspenalambarri?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) op [Unsplash](https://unsplash.com/s/photos/fish?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)

[regel van drie]: https://en.wikipedia.org/wiki/Cross-multiplication#Rule_of_three
[Mark and Recapture]: https://en.wikipedia.org/wiki/Mark_and_recapture
[Capture-Mark-Recapture]: https://www.bbc.co.uk/bitesize/guides/zmxbkqt/revision/3
[betrouwbaarheidsinterval]: https://en.wikipedia.org/wiki/Mark_and_recapture#Confidence_interval
[PyMC3]: https://docs.pymc.io/
[volgende post]: {% post_url nl/2021/2021-09-04-KeyForge_Decks_Printed %}
