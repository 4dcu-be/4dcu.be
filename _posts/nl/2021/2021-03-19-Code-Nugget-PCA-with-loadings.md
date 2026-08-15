---
layout: post
title:  "PCA-grafieken met loadings in Python"
byline: "met pandas, sklearn en seaborn"
description: "PCA-biplots in Python maken met loadings en verklaarde variantie, met pandas, scikit-learn en seaborn op de Iris-dataset."
date:   2021-03-19 10:00:00
author: Sebastian Proost
post_id: code-nugget-pca-with-loadings
categories: programming
tags:	python pandas data-science seaborn code-nugget sklearn
cover:  "/assets/posts/2021-03-19-Code-Nugget-PCA-with-loadings/PCA_header.jpg"
thumbnail: "/assets/images/thumbnails/pca_header.jpg"
github: https://github.com/4dcu-be/CodeNuggets
---

Net als de vorige [Code Nugget]({{site.baseurl}}/tag/code-nugget/) voegt dit stukje code enkele vaak benodigde functies
toe aan PCA-grafieken die met Python zijn gemaakt. Hier worden de *loadings* en verklaarde variantie aan de grafiek
toegevoegd. In R zit dat standaard in ```biplot()```, maar in Python komt er meer bij kijken. Net als bij de vorige
grafiek is de code niet moeilijk, maar om ze werkend te krijgen moet je behoorlijk wat documentatie doorzoeken om te
vinden hoe je dit kunt toevoegen.

Eerst wordt de Iris-dataset geladen. Voor deze stukjes code hebben we wat voorbeeldgegevens nodig en omdat deze dataset
meteen beschikbaar is, is hij een heel goede keuze. Met enkele regels code zetten we de dataset om in een Pandas-dataframe.

```python
from sklearn.datasets import load_iris
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


iris_obj = load_iris()
iris_df = pd.DataFrame(iris_obj.data, columns=iris_obj.feature_names)

iris_df["species"] = [iris_obj.target_names[s] for s in iris_obj.target]
iris_df.head()
```

{:.large-table}
|   | sepal length (cm) | sepal width (cm) | petal length (cm) | petal width (cm) | species |
|--:|------------------:|-----------------:|------------------:|-----------------:|--------:|
| 0 |               5.1 |              3.5 |               1.4 |              0.2 |  setosa |
| 1 |               4.9 |              3.0 |               1.4 |              0.2 |  setosa |
| 2 |               4.7 |              3.2 |               1.3 |              0.2 |  setosa |
| 3 |               4.6 |              3.1 |               1.5 |              0.2 |  setosa |
| 4 |               5.0 |              3.6 |               1.4 |              0.2 |  setosa |

Vervolgens gebruiken we scikit-learn om een PCA uit te voeren op alle afmetingen van de bladeren (de kolom met de
soort wordt dus weggelaten). Omdat het aanbevolen is om gegevens te schalen voordat je een PCA uitvoert, gebruiken we
een *pipeline* die eerst de ```StandardScaler``` en daarna de PCA toepast. De *pipeline* is hier niet strikt
noodzakelijk, maar kan bij complexere analyses veel tijd en mogelijke fouten besparen. Daarom raad ik aan ze ook in
eenvoudige gevallen zoals dit te gebruiken. 

```python
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline

pipeline = Pipeline([("scaler", StandardScaler()), ("pca", PCA(n_components=2)),])

pca_data = pd.DataFrame(
    pipeline.fit_transform(iris_df.drop(columns=["species"])),
    columns=["PC1", "PC2"],
    index=iris_df.index,
)
pca_data["species"] = iris_df["species"]

pca_step = pipeline.steps[1][1]
loadings = pd.DataFrame(
    pca_step.components_.T,
    columns=["PC1", "PC2"],
    index=iris_df.drop(columns=["species"]).columns,
)
```

De laatste paar regels zijn hier belangrijk. Ze halen de *loadings* voor de verschillende kenmerken op en zetten ze
om in het dataframe hieronder. Door die aan een grafiek toe te voegen, kun je uitleggen welke kenmerken de variatie
tussen groepen stalen bepalen. Het is dus wat vreemd dat er, voor zover ik weet, geen kant-en-klare oplossingen zijn om
ze in Python te tekenen. Laat het in de reacties weten als je pakketten kent die dat wel doen! De onderstaande code is
gebaseerd op een eenvoudig voorbeeld dat ik [hier](https://github.com/scentellegher/code_snippets/blob/master/pca_loadings/pca_loadings.ipynb) vond.

|                   |       PC1 |      PC2 |
|------------------:|----------:|---------:|
| sepal length (cm) |  0.521066 | 0.377418 |
|  sepal width (cm) | -0.269347 | 0.923296 |
| petal length (cm) |  0.580413 | 0.024492 |
|  petal width (cm) |  0.564857 | 0.066942 |

Het laatste stukje code tekent een spreidingsgrafiek met de stalen, voegt pijlen voor de *loadings* toe en vermeldt op
de labels van de assen ook welk percentage van de variantie door elke component wordt verklaard. Dat laatste wordt vaak
opgenomen in grafieken in wetenschappelijke artikels en is dus onmisbaar wanneer je PCA-gegevens presenteert.

```python
def loading_plot(
    coeff, labels, scale=1, colors=None, visible=None, ax=plt, arrow_size=0.5
):
    for i, label in enumerate(labels):
        if visible is None or visible[i]:
            ax.arrow(
                0,
                0,
                coeff[i, 0] * scale,
                coeff[i, 1] * scale,
                head_width=arrow_size * scale,
                head_length=arrow_size * scale,
                color="#000" if colors is None else colors[i],
            )
            ax.text(
                coeff[i, 0] * 1.15 * scale,
                coeff[i, 1] * 1.15 * scale,
                label,
                color="#000" if colors is None else colors[i],
                ha="center",
                va="center",
            )


g = sns.scatterplot(data=pca_data, x="PC1", y="PC2", hue="species")

# Add loadings
loading_plot(loadings[["PC1", "PC2"]].values, loadings.index, scale=2, arrow_size=0.08)


# Add variance explained by the
g.set_xlabel(f"PC1 ({pca_step.explained_variance_ratio_[0]*100:.2f} %)")
g.set_ylabel(f"PC2 ({pca_step.explained_variance_ratio_[1]*100:.2f} %)")

plt.savefig("PCA_with_loadings.png", dpi=200)
plt.show()
```

In dit laatste stukje wordt een functie, ```loading_plot()```, toegevoegd om de *loadings* over een andere grafiek
(waarschijnlijk een spreidingsgrafiek) te tekenen. Ze is flexibel genoeg om ook grafieken tussen hoofdcomponenten van
een hogere orde te maken, specifieke kleuren toe te voegen en de lijnen en pijlen naar wens te schalen. Het resultaat
staat hieronder: een PCA-grafiek met alle elementen die je verwacht!

![PCA-grafiek met loadings en verklaarde variantie, zoals gebruikelijk voor PCA-grafieken in wetenschappelijke literatuur](/assets/posts/2021-03-19-Code-Nugget-PCA-with-loadings/PCA_with_loadings.png)

Net als bij de [vorige post]({% post_url nl/2021/2021-03-16-Code-Nugget-Correlation-Heatmaps %}) worden de grafieken met wat
extra moeite aanzienlijk beter om gegevens te interpreteren. Ik zal deze stukjes ongetwijfeld vaak kopiëren en plakken
voor allerlei analyses. Hopelijk hebben anderen er ook iets aan!
