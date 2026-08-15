---
layout: post
title:  "Post-hoctests plotten met Python"
byline: "scikit-posthocs combineren met statannotations"
description: "Hoe je post-hoctests in Python plot door scikit-posthocs met statannotations te combineren en boxplots van Kruskal-Wallis- of ANOVA-resultaten te annoteren."
date:   2021-12-30 06:00:00
author: Sebastian Proost
post_id: posthoc-statannotations
categories: programming
tags:	python pandas data-science seaborn code-nugget sklearn scikit-posthocs statannotations
cover:  "/assets/posts/2021-12-30-Posthoc-Statannotations/posthoc_statannotations_header.png"
thumbnail: "/assets/images/thumbnails/posthoc_statannotations_header.jpg"
github: https://github.com/4dcu-be/CodeNuggets
---

Wanneer drie of meer groepen stalen worden vergeleken (bijvoorbeeld met ANOVA/Tukey HSD of
Kruskal-Wallis/Dunn), zie je de resultaten vaak als een boxplot met lijnen die aangeven welke groepen significant van
elkaar verschillen. In Python bestaat er geen enkel pakket waarmee je dit snel doet. Door [scikit-posthocs] met
[statannotations] te combineren, kun je zulke grafieken toch vrij eenvoudig genereren. Hier nemen we de benodigde code
stap voor stap door.

![Resultaten van Kruskal-Wallis met een post-hoc-Dunntest; dit artikel toont hoe je deze grafiek maakt](/assets/posts/2021-12-30-Posthoc-Statannotations/kruskal-wallis-posthoc.png)

Statistische tests die drie of meer groepen vergelijken, worden doorgaans in twee stappen uitgevoerd. De eerste test
controleert of er *enig* statistisch verschil tussen de groepen bestaat. De tweede vertelt vervolgens *welke* groepen
verschillen. Die tweede test noemen we een post-hoctest. Er bestaan veel testcombinaties, maar veelgebruikte combinaties
zijn [Kruskal-Wallis] gevolgd door een post-hoc-[Dunntest] (niet-parametrisch) en [ANOVA] met [Tukey's Honest
Significant Differences] (parametrisch). De onderstaande code kan wel gemakkelijk voor andere tests worden aangepast.

Alle code uit dit artikel vind je op [GitHub] en [Binder].

## De gegevens

De iris-dataset, met metingen van kroon- en kelkbladeren van drie bloemsoorten, is een mooie manier om enkele van deze
tests uit te proberen. De onderstaande code laadt alle vereiste bibliotheken en de iris-gegevens die bij scikit-learn
meegeleverd worden.

```python
%load_ext nb_black
from sklearn.datasets import load_iris
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

iris_obj = load_iris()
iris_df = pd.DataFrame(iris_obj.data, columns=iris_obj.feature_names)

iris_df["species"] = [iris_obj.target_names[s] for s in iris_obj.target]
iris_df.head()
```

|   | sepal length (cm) | sepal width (cm) | petal length (cm) | petal width (cm) | species |
|--:|------------------:|-----------------:|------------------:|-----------------:|--------:|
| 0 |               5.1 |              3.5 |               1.4 |              0.2 |  setosa |
| 1 |               4.9 |              3.0 |               1.4 |              0.2 |  setosa |
| 2 |               4.7 |              3.2 |               1.3 |              0.2 |  setosa |
| 3 |               4.6 |              3.1 |               1.5 |              0.2 |  setosa |
| 4 |               5.0 |              3.6 |               1.4 |              0.2 |  setosa |

Voor de eerste test (Kruskal-Wallis en ANOVA) gebruiken we de implementaties uit [SciPy]. Die verwachten voor elke
groep een lijst met waarden als functieparameter. De eenvoudigste manier om die te maken is met de onderstaande code:
er wordt een lijst met lijsten aangemaakt die voor elke soort de lengtes van de kelkbladeren bevat. Die kunnen
vervolgens met het sterretje (*) tot parameters worden uitgepakt.

```python
species = np.unique(iris_df.species)

data = []

for s in species:
    data.append(iris_df[iris_df.species == s]["sepal length (cm)"])
```

## Kruskal-Wallis met Dunn

De Kruskal-Wallistest zit in [SciPy] en kan gemakkelijk op onze gegevens worden toegepast nadat we ze in de vorige stap
correct gestructureerd hebben.

```python
from scipy import stats

stats.kruskal(*data)
```

Dit geeft een statistiek (96.04) en een p-waarde (8.9e-22) terug, dus er is een significant verschil tussen deze
soorten. Deze test toont echter niet *tussen welke* soorten er verschillen zijn. Daarvoor moeten we een post-hoc-
Dunntest uitvoeren, die vaak met Kruskal-Wallis wordt gecombineerd. We kunnen de functie ```posthoc_dunn()``` uit
[scikit-posthocs] gebruiken. (Merk het verschil in syntaxis met de SciPy-test op.)

```python
from scikit_posthocs import posthoc_dunn

# posthoc dunn test, with correction for multiple testing
dunn_df = posthoc_dunn(
    iris_df, val_col="sepal length (cm)", group_col="species", p_adjust="fdr_bh"
)
dunn_df
```

Dit geeft een matrix terug met alle paarsgewijze combinaties van soorten en de p-waarde van de test (met een correctie
als ```p_adjust``` op een geldige methode is ingesteld).

|            |       setosa |   versicolor |    virginica |
|-----------:|-------------:|-------------:|-------------:|
|     setosa | 1.000000e+00 | 1.529257e-09 | 6.000296e-22 |
| versicolor | 1.529257e-09 | 1.000000e+00 | 2.774866e-04 |
|  virginica | 6.000296e-22 | 2.774866e-04 | 1.000000e+00 |

In dit geval verschilt iedere soort dus significant van de twee andere. Voor we in detail bekijken hoe we deze
resultaten beter kunnen visualiseren, kijken we eerst naar ANOVA en Tukey HSD.

## ANOVA met Tukey HSD

Net zoals in het vorige voorbeeld kunnen we een ANOVA uitvoeren. Eerst voeren we ```f_oneway()``` uit, de functie in
[SciPy] voor een ANOVA, en we sluiten af met ```posthoc_tukey()``` uit [scikit-posthocs].

De eerste test geeft een significante p-waarde (1.67e-31), dus kunnen we doorgaan met de Tukey-test.

```python
from scikit_posthocs import posthoc_tukey

# First we do a oneway ANOVA as implemented in SciPy
print(stats.f_oneway(*data))

tukey_df = posthoc_tukey(iris_df, val_col="sepal length (cm)", group_col="species")
tukey_df
```
Dit levert de uiteindelijke tabel met alle vergelijkingen en de p-waarden van die tests op.

|            | setosa | versicolor | virginica |
|-----------:|-------:|-----------:|----------:|
|     setosa |  1.000 |      0.001 |     0.001 |
| versicolor |  0.001 |      1.000 |     0.001 |
|  virginica |  0.001 |      0.001 |     1.000 |

## De resultaten visualiseren

Deze matrices zijn moeilijk te interpreteren en de meesten verkiezen een eenvoudige visualisatie die significante
verschillen benadrukt. De eigenlijke gegevens tonen met [seaborn] is eenvoudig, maar geannoteerde lijnen met de
p-waarden toevoegen is dat niet. Daar komt [statannotations] van pas: met dit pakket voeg je ze met enkele regels code
toe. Het pakket bevat zijn eigen reeks statistische tests, maar post-hoctests zijn er momenteel helaas niet bij. Zo los
je dat op.

Eerst moeten we de matrix omzetten naar een niet-redundante lijst met vergelijkingen en de bijbehorende p-waarde. Dat
doen we door de onderste helft en de diagonaal uit de matrix te verwijderen en de matrix met ```melt()``` naar een lang
dataframe om te zetten. De code en het resulterende dataframe staan hieronder.

```python
remove = np.tril(np.ones(tukey_df.shape), k=0).astype("bool")
tukey_df[remove] = np.nan

molten_df = tukey_df.melt(ignore_index=False).reset_index().dropna()
molten_df
```

|   |      index |   variable | value |
|--:|-----------:|-----------:|------:|
| 3 |     setosa | versicolor | 0.001 |
| 6 |     setosa |  virginica | 0.001 |
| 7 | versicolor |  virginica | 0.001 |

Vervolgens tekenen we de hoofdgrafiek met de functie ```boxplot()``` van [seaborn] en zetten we ons dataframe om in
een lijst met paren en een lijst met bijbehorende p-waarden voor [statannotations]. De onderstaande code is wat cryptisch
door het gebruik van *list comprehensions* en ```iterrows()```, maar in wezen doorloopt ze iedere rij en maakt ze een
tuple met de soorten die worden vergeleken. Daarna worden de p-waarden met dezelfde functies naar een lijst omgezet.

De lijst met paren wordt samen met de gegevens aan een ```Annotator```-object doorgegeven. Met ```configure()``` stellen
we de grafiek naar wens in. Tot slot worden de p-waarden met ```set_pvalues_and_annotate()``` toegevoegd, wat ook de
annotaties op de grafiek zet.


```python
import seaborn as sns
from statannotations.Annotator import Annotator

ax = sns.boxplot(data=iris_df, x="species", y="sepal length (cm)", order=species)

pairs = [(i[1]["index"], i[1]["variable"]) for i in molten_df.iterrows()]
p_values = [i[1]["value"] for i in molten_df.iterrows()]

annotator = Annotator(
    ax, pairs, data=iris_df, x="species", y="sepal length (cm)", order=species
)
annotator.configure(text_format="star", loc="inside")
annotator.set_pvalues_and_annotate(p_values)

plt.tight_layout()
```

![Resultaten van ANOVA met Tukey HSD op de iris-dataset](/assets/posts/2021-12-30-Posthoc-Statannotations/ANOVA-posthoc.png)


## Conclusie

Het is jammer dat er (nog) geen pakket bestaat dat deze statistiek en visualisatie in één regel regelt, zoals het
R-pakket [ggpubr], maar met deze stukjes code kunnen we het eenvoudig genoeg zelf doen.

[scikit-posthocs]: https://scikit-posthocs.readthedocs.io/en/latest/
[statannotations]: https://github.com/trevismd/statannotations
[Kruskal-Wallis]: https://en.wikipedia.org/wiki/Kruskal%E2%80%93Wallis_one-way_analysis_of_variance
[Dunntest]: https://www.statisticshowto.com/dunns-test/
[ANOVA]: https://en.wikipedia.org/wiki/One-way_analysis_of_variance
[Tukey's Honest Significant Differences]: https://en.wikipedia.org/wiki/Tukey%27s_range_test
[GitHub]: https://github.com/4dcu-be/CodeNuggets/blob/main/Post%20hoc%20tests%20with%20statannotations.ipynb
[Binder]: https://mybinder.org/v2/gh/4dcu-be/CodeNuggets/HEAD
[SciPy]: https://scipy.org/
[seaborn]: https://seaborn.pydata.org/
[ggpubr]: https://rpkgs.datanovia.com/ggpubr/
