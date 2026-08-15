---
layout: post
title:  "Correlatieheatmaps met significantie in Python"
byline: "met pandas, scipy en seaborn"
description: "Correlatieheatmaps in Python maken die ook statistische significantie tonen, met pandas, scipy, seaborn en correctie voor meervoudig toetsen."
date:   2021-03-16 10:00:00
author: Sebastian Proost
post_id: code-nugget-correlation-heatmaps
categories: programming
tags:	python pandas data-science seaborn code-nugget
cover:  "/assets/posts/2021-03-16-Code-Nugget-Correlation-Heatmaps/clustermap_header.jpg"
thumbnail: "/assets/images/thumbnails/clustermap_header.jpg"
github: https://github.com/4dcu-be/CodeNuggets
---

Pandas en Seaborn bieden heel snelle manieren om correlaties te berekenen en in een heatmap weer te geven. Of die
correlaties statistisch significant zijn, ontbreekt echter in zulke grafieken. Door de jaren heen heb ik stukjes code
zoals dit verzameld die bijzonder nuttig blijken. Alleen is het niet zo handig dat ze verspreid staan over enkele
tientallen projecten wanneer ik ze werkelijk nodig heb. Daarom begin ik wat documentatie toe te voegen en plaats ik ze
hier met de tag [Code Nugget]({{site.baseurl}}/tag/code-nugget/), zodat ikzelf en anderen ze makkelijk kunnen terugvinden.

Normaal kun je ```corr_df = df.corr()``` gebruiken om een correlatiematrix te krijgen voor de numerieke kolommen in een
Pandas-dataframe. Die kun je vervolgens in een heatmap tonen met
```sns.clustermap(corr_df, cmap="vlag", vmin=-1, vmax=1)``` en SeaBorns ```clustermap```. Eenvoudig, maar de significantie
van die correlaties wordt niet gerapporteerd. Daarvoor kun je niet op ingebouwde functies vertrouwen en is wat meer
werk nodig.

```python
from sklearn.datasets import load_iris
from scipy.stats import spearmanr
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from statsmodels.stats.multitest import multipletests

iris_obj = load_iris()
iris_df = pd.DataFrame(iris_obj.data, columns=iris_obj.feature_names)


def get_correlations(df):
    df = df.dropna()._get_numeric_data()
    dfcols = pd.DataFrame(columns=df.columns)
    pvalues = dfcols.transpose().join(dfcols, how="outer")
    correlations = dfcols.transpose().join(dfcols, how="outer")
    for ix, r in enumerate(df.columns):
        for jx, c in enumerate(df.columns):
            sp = spearmanr(df[r], df[c])
            correlations[c][r] = sp[0]
            pvalues[c][r] = sp[1] if ix > jx else np.nan  # Only store values below the diagonal
    return correlations.astype("float"), pvalues.astype("float")


correlations, uncorrected_p_values = get_correlations(iris_df)

# Correct p-values for multiple testing and check significance (True if the corrected p-value < 0.05)
shape = uncorrected_p_values.values.shape
significant_matrix = multipletests(uncorrected_p_values.values.flatten())[0].reshape(
    shape
)

# Here we start plotting
g = sns.clustermap(correlations, cmap="vlag", vmin=-1, vmax=1)

# Here labels on the y-axis are rotated
for tick in g.ax_heatmap.get_yticklabels():
    tick.set_rotation(0)

# Here we add asterisks onto cells with signficant correlations
for i, ix in enumerate(g.dendrogram_row.reordered_ind):
    for j, jx in enumerate(g.dendrogram_row.reordered_ind):
        if i != j:
            text = g.ax_heatmap.text(
                j + 0.5,
                i + 0.5,
                "*" if significant_matrix[ix, jx] or significant_matrix[jx, ix] else "",
                ha="center",
                va="center",
                color="black",
            )
            text.set_fontsize(20)

# Save a high-res copy of the image to disk
plt.tight_layout()
plt.savefig("clustermap.png", dpi=200)
```

In dit voorbeeld laden we de Iris-dataset en zetten we die om in een Pandas-dataframe. Vervolgens definiëren we een
nieuwe functie, ```get_correlations```, die twee nieuwe dataframes teruggeeft: een met de correlaties (hier wordt de
rangcorrelatie van Spearman gebruikt, zie hieronder) en een met de p-waarden voor die correlaties. Merk op dat we geen
p-waarden opslaan voor combinaties die we niet willen toetsen (waarden op de diagonaal) of niet hoeven te toetsen
(correlaties zijn symmetrisch, dus alleen waarden onder de diagonaal worden opgeslagen). Als we die wel opnemen, wordt
de correctie voor meervoudig toetsen onnodig streng.

{:.large-table}
|                   | sepal length (cm) | sepal width (cm) | petal length (cm) | petal width (cm) |
|------------------:|------------------:|-----------------:|------------------:|-----------------:|
| sepal length (cm) |          1.000000 |        -0.166778 |          0.881898 |         0.834289 |
|  sepal width (cm) |         -0.166778 |         1.000000 |         -0.309635 |        -0.289032 |
| petal length (cm) |          0.881898 |        -0.309635 |          1.000000 |         0.937667 |
|  petal width (cm) |          0.834289 |        -0.289032 |          0.937667 |         1.000000 |

We hebben p-waarden voor al deze waarden, zoals hieronder, maar ze zijn niet gecorrigeerd voor meervoudig toetsen. De
functie ```multipletests``` uit het pakket statsmodels kan ze voor ons corrigeren en melden welke significant zijn
(standaardgrens <0.05), maar de functie verwacht een vlakke lijst met waarden. Daarom zetten we de matrix om in een
eendimensionale array, passen we de functie toe en zetten we ze met ```reshape``` terug om naar haar oorspronkelijke vorm.

{:.large-table}
|                   | sepal length (cm) | sepal width (cm) | petal length (cm) | petal width (cm) |
|------------------:|------------------:|-----------------:|------------------:|-----------------:|
| sepal length (cm) |               NaN |              NaN |               NaN |              NaN |
|  sepal width (cm) |      4.136799e-02 |              NaN |               NaN |              NaN |
| petal length (cm) |      3.443087e-50 |         0.000115 |               NaN |              NaN |
|  petal width (cm) |      4.189447e-40 |         0.000334 |      8.156597e-70 |              NaN |


Tot slot moeten de correlaties worden getekend, en daarvoor is de functie ```clustermap``` uitstekend. We hebben wel
enkele extra regels code nodig om een sterretje te plaatsen in de cellen die significant zijn. Hoe dat gebeurt is niet
bepaald raketwetenschap, maar ik moest behoorlijk diep in de code van ```clustermap``` graven om precies te vinden hoe
ik dit kon toevoegen. Er kunnen hier nog enorm veel aanpassingen worden gedaan, maar die hangen af van je persoonlijke
stijl en voorkeur. Het moeilijke werk is klaar! Bekijk hieronder het resultaat!


![Het resultaat van dit stukje code: een correlatieheatmap met sterren die significante correlaties aanduiden](/assets/posts/2021-03-16-Code-Nugget-Correlation-Heatmaps/clustermap.png)
