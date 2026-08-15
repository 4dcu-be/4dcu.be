---
layout: post
title:  "Batcheffecten bestrijden met pyComBat"
byline: ""
description: "Hoe je batcheffecten in meetgegevens corrigeert met het Python-pakket pyComBat, gedemonstreerd op een synthetische dataset met verschuivings- en schaaleffecten."
date:   2021-04-21 10:00:00
author: Sebastian Proost
post_id: code-nugget-batch-effects
categories: programming
tags:	python pandas data-science seaborn code-nugget sklearn pycombat
cover:  "/assets/posts/2021-04-21-Code-Nugget-Batch_Effects/pycombat_header.jpg"
thumbnail: "/assets/images/thumbnails/pycombat_header.jpg"
github: https://github.com/4dcu-be/CodeNuggets
---

Zelfs hoogwaardig wetenschappelijk materiaal heeft al eens een slechte dag! De prestaties van een toestel kunnen
beïnvloed worden door de omgevingstemperatuur, luchtvochtigheid, ... Wanneer stalen in verschillende batches gemeten
worden, moet je daarvoor dus corrigeren. In dit artikel bekijken we het Python-pakket [pyComBat], dat dit elegant en
efficiënt doet. Merk wel op dat je *stalen correct over de batches moet randomiseren*. Stel dat je bodemstalen uit twee
verschillende omgevingen onderzoekt. Om batcheffecten te kunnen corrigeren, moet je ervoor zorgen dat de helft van de
stalen uit elke groep in batch één zit en de andere helft in batch twee. Als je alle stalen uit groep één in batch één
stopt, verwijdert de correctie net de verschillen die je probeert te vinden. Bovendien moeten er *voldoende stalen in
elke batch* zitten om dit te laten werken. Met slechts een handvol metingen per batch kun je het effect niet corrigeren.

## Een dataset maken

Om te testen wat [pyComBat] kan, kunnen we een synthetische dataset genereren met een reeks metingen en een tweede reeks
met een kleine afwijking die nabootst wat er kan gebeuren wanneer stalen op verschillende datums of met verschillende
toestellen gemeten worden. We gebruiken hier een dataset met waarden uit een normale verdeling en een uniform verdeelde
reeks waarden. Eén effect dat we invoeren is een verschuiving, waarbij alle waarden die in die batch gemeten zijn gewoon
een constante hoeveelheid afwijken, en bij een ander effect worden de waarden met een constante factor vermenigvuldigd.
Als controle voegen we voor elke verdeling ook een kenmerk zonder effect toe.

{:.large-code}
```python
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

num_samples = 200  # number of samples per batch

batches = ["Batch 1"] * num_samples + ["Batch 2"] * num_samples
df = pd.DataFrame(
    {
        "batch": batches,
        # Feature 1-3 are normal distributed, we'll shift one, multiply another and leave one untouched
        "feature_one": np.concatenate(
            [np.random.randn(num_samples), np.random.randn(num_samples) + 1]
        ),
        "feature_two": np.concatenate(
            [np.random.randn(num_samples), np.random.randn(num_samples) * 1.3]
        ),
        "feature_three": np.concatenate(
            [np.random.randn(num_samples), np.random.randn(num_samples)]
        ),
        # Feature 4-6 are uniformly distributed, we'll shift one, multiply another and leave one untouched
        "feature_four": np.concatenate(
            [np.random.rand(num_samples), np.random.rand(num_samples) + 0.2]
        ),
        "feature_five": np.concatenate(
            [np.random.rand(num_samples), np.random.rand(num_samples) * 1.3]
        ),
        "feature_six": np.concatenate(
            [np.random.rand(num_samples), np.random.rand(num_samples)]
        ),
    }
)
```

## De artificiële dataset bekijken

Met enkele regels die Seaborns ```FacetGrid``` en ```histplot``` gebruiken, kunnen we snel een grafiek van de
synthetische gegevens genereren. Daarvoor moeten de gegevens met Pandas' functie ```melt``` naar lang formaat worden
omgezet.

```python
long_df = df.melt(id_vars=["batch"])

g = sns.FacetGrid(
    long_df, col="variable", height=3, aspect=1, sharex=False, col_wrap=3,
)
g.map_dataframe(sns.histplot, x="value", hue="batch")
plt.show()
```

![Verdelingen van de dataset met artificieel ingevoerde batcheffecten](/assets/posts/2021-04-21-Code-Nugget-Batch_Effects/pycombat_synthetic_dataset.png)

## De batcheffecten corrigeren

Het dataframe hoort eruit te zien zoals hieronder: één kolom met de batch waartoe een staal behoort, en de andere met
metingen die mogelijk gecorrigeerd moeten worden.


{:.large-table}
|     |   batch | feature_one | feature_two | feature_three | feature_four | feature_five | feature_six |
|----:|--------:|------------:|------------:|--------------:|-------------:|-------------:|------------:|
|   0 | Batch 1 |   -0.560251 |   -0.329007 |     -0.391515 |     0.705579 |     0.067287 |    0.318247 |
|   1 | Batch 1 |   -0.676682 |   -1.219296 |      0.488081 |     0.940643 |     0.786043 |    0.374624 |
|   2 | Batch 1 |    0.557334 |   -0.025515 |      1.478300 |     0.851690 |     0.340614 |    0.682563 |
| ... | ... |    ... |    ... |     ... |     ... |     ... |    ... |
| 399 | Batch 2 |    0.253740 |   -0.100651 |     -0.268410 |     0.788433 |     0.740919 |    0.028127 |
| 398 | Batch 2 |   -0.345181 |   -0.420646 |     -0.876879 |     0.327634 |     0.815336 |    0.783284 |
| 397 | Batch 2 |   -0.189546 |    1.500048 |     -1.136106 |     0.536194 |     1.118575 |    0.155961 |

De batchcorrectie toepassen met pyComBat is heel eenvoudig. Je roept de functie aan met de kenmerken als eerste
argument en als tweede argument een lijst die aangeeft tot welke batch elk staal behoort. Met het bovenstaande
dataframe doe je dat gemakkelijk met de onderstaande code.

```python
from combat.pycombat import pycombat

corrected_df = pycombat(df.drop(columns=["batch"]).transpose(), df["batch"]).transpose()
```

Het resultaat is een dataframe met de gecorrigeerde kenmerken, zoals hieronder.

{:.large-table}
|   | feature_one | feature_two | feature_three | feature_four | feature_five | feature_six |
|--:|------------:|------------:|--------------:|-------------:|-------------:|------------:|
| 0 |   -0.062237 |   -0.276713 |     -0.429908 |     0.790984 |     0.089940 |    0.298606 |
| 1 |   -0.180598 |   -1.270888 |      0.458374 |     1.035210 |     0.921394 |    0.356112 |
| 2 |    1.073879 |    0.062193 |      1.458372 |     0.942790 |     0.406123 |    0.670221 |
| 3 |   -1.299430 |   -1.993188 |      1.117924 |     0.775037 |     0.635035 |    0.022828 |
| ... | ... |    ... |    ... |     ... |     ... |     ... |

## De wijzigingen visualiseren

Laten we eens kijken welke wijzigingen pyComBat aan onze gegevens heeft aangebracht en of die logisch zijn! Het
dataframe met gecorrigeerde waarden moet ook naar lang formaat worden omgezet (opnieuw met ```melt```), met de originele
gegevens worden samengevoegd via ```merge``` en daarna worden geplot. Hier gebruiken we ```scatterplot``` om de
originele waarde (x-as) met de gecorrigeerde waarde (y-as) te vergelijken voor waarden uit verschillende batches
(kleur). Als er geen correcties uitgevoerd werden, zouden alle stalen op de diagonaal liggen omdat hun x- en y-waarden
identiek zijn. Waar wel correcties toegepast worden, treedt een verschuiving op.

```python
long_corrected_df = corrected_df.melt()
merged_df = pd.merge(
    long_df,
    long_corrected_df,
    left_index=True,
    right_index=True,
    suffixes=("_raw", "_corrected"),
)
g = sns.FacetGrid(
    merged_df,
    col="variable_raw",
    height=3,
    aspect=1,
    sharex=False,
    sharey=False,
    col_wrap=3,
)
g.map_dataframe(sns.scatterplot, x="value_raw", y="value_corrected", hue="batch")
plt.show()
```

![Vergelijking van ruwe waarden en waarden na correctie voor batcheffecten met pyComBat](/assets/posts/2021-04-21-Code-Nugget-Batch_Effects/pycombat_corrections.png)


Kenmerk één en vier, die met een constante hoeveelheid verschoven werden, zijn in beide gevallen perfect gecorrigeerd.
Ook kenmerk twee en vijf (vermenigvuldigd) worden correct behandeld. Fantastisch! Merk wel op dat er ook een (kleine)
correctie werd toegepast op kenmerk zes, waar er geen effect was. Als je correcties toepast waar ze niet nodig zijn,
kun je inderdaad fouten invoeren in plaats van oplossen. Wees dus voorzichtig en pas dit niet zomaar toe als er geen
batcheffecten aanwezig zijn.

## Conclusie

[pyComBat] is een geweldige aanvulling op het Python-ecosysteem voor datawetenschap! Het is eenvoudig toe te passen en
werkt precies zoals je verwacht met Pandas-dataframes. Of het nuttig zal zijn voor jouw projecten hangt af van (a) het
aantal stalen (je kunt met de parameter ```num_samples``` in de code spelen en zien hoe de correctie mislukt zodra het
aantal stalen te klein is), (b) of ze correct over de batches gerandomiseerd werden en (c) of er batcheffecten aanwezig
zijn.

Bekijk voor meer artikels zoals dit de [Code Nuggets]! Dat zijn allemaal artikels in kookboekstijl met stukjes code om
veelvoorkomende datawetenschappelijke taken aan te pakken.


[pyCombat]: https://github.com/epigenelabs/pyComBat
[Code Nuggets]: {{site.baseurl}}/tag/code-nugget/
