---
layout: post
title:  "De pinguïndata van Palmer Station clusteren met PyMC3"
byline: "Adelie, kinband, ezel..."
description: "Ongesuperviseerd clusteren van de Palmer Station-pinguïndataset met PyMC3, waarbij het aantal soorten wordt afgeleid uit metingen van vinnen, snavels en lichaamsgewicht."
date:   2021-08-01 08:00:00
author: Sebastian Proost
post_id: clustering-penguins
categories: programming biology
tags:	python pymc3 data-analysis data-science machine-learning altair biology
cover:  "/assets/posts/2021-08-01-Clustering-penguins/penguin_header.jpg"
thumbnail: "/assets/images/thumbnails/classifying_penguins_header.jpg"
github: "https://github.com/4dcu-be/ClassifyingPenguins"
custom_js:
  - vega.min
  - vega-lite.min
  - vega-embed.min
  - justcharts
---

Deze post draait om het afleiden van de soort waaruit verschillende waarnemingen afkomstig zijn, zonder toegang te hebben 
tot de labels. Dat klinkt misschien vergezocht, maar in de biologie komt het vaker voor dan je zou verwachten! 
Bij grote dieren vind je meestal duidelijke verschillen tussen soorten, maar bij nematoden
(kleine wormen) in een bodemmonster zijn die verschillen soms bijzonder moeilijk te zien. Er kan ook een subpopulatie zijn die
licht afwijkt van de hoofdpopulatie. Zo kunnen polyploïde planten (met extra kopieën van hun genoom) 
in hetzelfde veld groeien als planten met normale ploïdie. Ze gelden als dezelfde soort en lijken in bijna alle opzichten op elkaar,
maar zijn bijvoorbeeld wat groter, sterker of toleranter. Bij de eerste metingen vallen ze daardoor mogelijk niet op. Of denk aan 
indirecte metingen: sommige dieren zijn zeldzaam en leven op afgelegen plaatsen, waardoor biologen hun voetafdrukken gebruiken om ze te bestuderen.
Als meerdere soorten vergelijkbare afdrukken achterlaten, moeten ze misschien de grootte van de afdrukken, 
de afstand ertussen enzovoort gebruiken om te schatten van welke soort een reeks afdrukken afkomstig is. De oplossing is dus zoveel
mogelijk exemplaren te meten en het later (hopelijk) uit te zoeken.

Verschillende groepen herkennen is bijzonder lastig als je niet eens weet hoeveel groepen er zijn. Hier 
gebruiken we de [Palmer Station Penguin]-dataset om het probleem te tonen (we verbergen de soortlabels voor de modellen). Met metingen van vinnen, snavels en lichaamsgewicht 
proberen we te bepalen hoeveel soorten de dataset bevat en welke exemplaren tot dezelfde
groep behoren.

Notebooks met de gegevens en de volledige code voor deze post vind je in deze [GitHub repo]. Daar staat ook de
code toegepast op andere datasets, zoals [Iris] en [Fish Market], zij het met minder documentatie.

## De gegevens laden

De [GitHub repo] bevat de gegevens als .csv-bestand, dat rechtstreeks met pandas kan worden geladen. We hebben het
eiland waar de waarneming plaatsvond en het geslacht van het dier niet nodig, dus laten we die kolommen weg. Rijen met nog 
ontbrekende waarden worden verwijderd met ```.dropna()```. Het soortlabel behouden we wel, zodat we later kunnen controleren of 
onze clustering echt werkt, maar tijdens het clusteren wordt het niet gebruikt.

```python
%load_ext nb_black
import seaborn as sns
import pymc3 as pm
import pandas as pd
import numpy as np
import arviz as az

import altair as alt

penguin_df = (
    pd.read_csv("./data/penguins_size.csv").drop(columns=["island", "sex"]).dropna()
)
penguin_df
```

We schalen de gegevens het best zodat het gemiddelde van elk kenmerk nul is, met een standaardafwijking van één. ```StandardScaler```
 maakt dat eenvoudig. 

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
scaled_penguin_df = scaler.fit_transform(penguin_df.drop(columns=["species"]))
scaled_penguin_df = pd.DataFrame(scaled_penguin_df, columns=penguin_df.columns[1:])
scaled_penguin_df["species"] = list(penguin_df["species"])
scaled_penguin_df
```

## Het eerste model - één kenmerk gebruiken

Alle modellen in deze post hebben een ```pm.Dirichlet```-verdeling als kern, die de kans bepaalt om een
bepaalde groep — hier een soort — waar te nemen. Voorlopig stellen we het gewenste aantal clusters in met ```n_clusters```;
later werken we daar omheen, geen zorgen! Vervolgens kennen we op basis van die kansen categorieën toe aan alle waarnemingen. 
Door categorieën expliciet op te nemen met ```pm.Categorical``` kunnen we de groepen later erg eenvoudig uitlezen. Merk
wel op dat ```pm.NormalMixture``` efficiënter is als we alleen een model willen fitten.

Hier nemen we voor elke categorie een sigma en een gemiddelde op. Daarmee maken we een likelihood-functie om een normale
verdeling te fitten op de waarnemingen van het lichaamsgewicht van elke soort.

```python
n_clusters = 3
n_observations, n_features = scaled_penguin_df.shape

with pm.Model() as model:
    p = pm.Dirichlet("p", a=np.ones(n_clusters))
    category = pm.Categorical("category", p=p, shape=n_observations)
    
    bm_sigmas = pm.HalfNormal("bm_sigmas", sigma=1, shape=n_clusters)
    bm_means = pm.Normal("bm_means", np.zeros(n_clusters), sd=1, shape=n_clusters)

    y_bm = pm.Normal(
        "y_bm",
        mu=bm_means[category],
        sd=bm_sigmas[category],
        observed=scaled_penguin_df.body_mass_g,
    )

    trace = pm.sample(10000)
```

Na het samplen kunnen we de categorieën uit een van de traces halen en met de werkelijke soorten vergelijken om te zien
hoe goed het werkte. We voegen de groepen opnieuw toe aan de oorspronkelijke gegevens, herformatteren die snel om aantallen te krijgen en visualiseren ze 
met Altair.

```[2][200]``` verwijst naar de chain met index twee en de trace met index 200. Bekijk bij deze oefening
meerdere waarden om een indruk te krijgen van de algemene prestaties.

```python
groups = [
    f"Group {n+1}"
    for n in list(trace.get_values("category", burn=6000, combine=False)[2][20])
]
penguin_df["group"] = groups

plot_df = penguin_df.groupby(["species", "group"]).size().reset_index(name="counts")

alt.Chart(plot_df).mark_bar().encode(
    x=alt.X("group", title=None),
    y=alt.Y("counts", title="Count"),
    color=alt.Color("species", title="Species"),
    tooltip=["group", "counts", "species"],
).properties(width=400)
```

[![Het eerste model classificeert deze pinguïnsoorten niet bijzonder goed](/assets/posts/2021-08-01-Clustering-penguins/model_01.svg)](/assets/posts/2021-08-01-Clustering-penguins/model_01.json)

Hier zie je dat Groep 2 alle ezelspinguïns bevat — de grootste en zwaarste soort — maar ook enkele
andere pinguïns. De twee overige groepen bevatten een mix van adelie- en kinbandpinguïns, niet bepaald indrukwekkend voor
een classifier. Laten we voor we verdergaan de gegevens bekijken die we aan het model gaven.

[![Verdeling van het lichaamsgewicht](/assets/posts/2021-08-01-Clustering-penguins/body_mass_distribution.svg)](/assets/posts/2021-08-01-Clustering-penguins/body_mass_distribution.json)

Zoals je ziet, overlappen de soorten sterk. Dat is niet ideaal voor zo'n eenvoudige classifier. We moeten dus
meer metingen opnemen, zoals de lengte van de vin en de lengte en diepte van de culmen (een deel van de snavel).

## Een model met alle kenmerken

De eenvoudigste manier om dit model uit te breiden, is meer sigma's, gemiddelden en likelihoods toe te voegen die allemaal dezelfde
categorieën delen. 

{:.large-code}
```python
n_clusters = 3
n_observations, n_features = scaled_penguin_df.shape
with pm.Model() as model:
    p = pm.Dirichlet("p", a=np.ones(n_clusters))
    category = pm.Categorical("category", p=p, shape=n_observations)

    cl_sigmas = pm.HalfNormal("cl_sigmas", sigma=1, shape=n_clusters)
    cd_sigmas = pm.HalfNormal("cd_sigmas", sigma=1, shape=n_clusters)
    fl_sigmas = pm.HalfNormal("fl_sigmas", sigma=1, shape=n_clusters)
    bm_sigmas = pm.HalfNormal("bm_sigmas", sigma=1, shape=n_clusters)
    
    cl_means = pm.Normal("cl_means", np.zeros(n_clusters), sd=1, shape=n_clusters)
    cd_means = pm.Normal("cd_means", np.zeros(n_clusters), sd=1, shape=n_clusters)
    fl_means = pm.Normal("fl_means", np.zeros(n_clusters), sd=1, shape=n_clusters)
    bm_means = pm.Normal("bm_means", np.zeros(n_clusters), sd=1, shape=n_clusters)

    y_cl = pm.Normal(
        "y_cl",
        mu=cl_means[category],
        sd=cl_sigmas[category],
        observed=scaled_penguin_df.culmen_length_mm,
    )
    y_cd = pm.Normal(
        "y_cd",
        mu=cd_means[category],
        sd=cd_sigmas[category],
        observed=scaled_penguin_df.culmen_depth_mm,
    )
    y_fl = pm.Normal(
        "y_fl",
        mu=fl_means[category],
        sd=fl_sigmas[category],
        observed=scaled_penguin_df.flipper_length_mm,
    )
    y_bm = pm.Normal(
        "y_bm",
        mu=bm_means[category],
        sd=bm_sigmas[category],
        observed=scaled_penguin_df.body_mass_g,
    )

    trace = pm.sample(10000)
```

Dit werkt zeker, al zou een lus beter zijn dan code voor elk kenmerk te herhalen. Maar
is het ook beter dan het vorige model? Laten we een willekeurig geselecteerde chain en trace bekijken.

[![Het tweede model wordt beter](/assets/posts/2021-08-01-Clustering-penguins/model_02.svg)](/assets/posts/2021-08-01-Clustering-penguins/model_02.json)

Dit is duidelijk een veel betere classificatie, wat wordt bevestigd wanneer we meerdere traces bekijken. Alle ezelspinguïns zitten
samen in groep één, groep drie bevat vooral adeliepinguïns en groep twee is wat gemengd. Dit 
model heeft echter een groot nadeel: meerdere likelihoods. Daardoor is het erg moeilijk om met PyMC3 en Arviz het model met
andere modellen te vergelijken. Het is niet onmogelijk — in de [GitHub repo] staat een notebook met code daarvoor —
maar het was erg omslachtig en iets wat je waar mogelijk beter vermijdt.

## Overschakelen op multivariate normale verdelingen 

Om het probleem met meerdere likelihoods op te lossen, kunnen we ```pm.MvNormal``` gebruiken. Dat is een multivariate normale of 
Gaussische verdeling die meerdere invoerwaarden in één likelihood combineert. Ze vereist een gemiddelde 
voor elk kenmerk in de invoer en een Cholesky-decompositie van de covariantiematrix... Oei, ik ga niet beweren dat ik de 
onderliggende wiskunde begrijp — dat doe ik niet — maar gelukkig vond ik code die met ```pm.LKJCholeskyCov``` de vereiste 
matrix genereert. Kort gezegd is dit nodig om rekening te houden met correlaties tussen verschillende kenmerken.

Daarnaast maakt dit de code aanzienlijk netter en algemener dan bij het vorige model. Dat is dus 
mooi meegenomen.

{:.large-code}
```python
n_clusters = 3
data = scaled_penguin_df.drop(columns=["species"]).values
n_observations, n_features = data.shape
with pm.Model() as model:
    chol, corr, stds = pm.LKJCholeskyCov(
        "chol",
        n=n_features,
        eta=2.0,
        sd_dist=pm.Exponential.dist(1.0),
        compute_corr=True,
    )
    cov = pm.Deterministic("cov", chol.dot(chol.T))
    mu = pm.Normal(
        "mu", 0.0, 1.5, shape=(n_clusters, n_features), testval=data.mean(axis=0)
    )

    p = pm.Dirichlet("p", a=np.ones(n_clusters))
    category = pm.Categorical("category", p=p, shape=n_observations)

    y = pm.MvNormal("y", mu[category], chol=chol, observed=data)

    trace = pm.sample(8000)
```

Omdat een multivariate Gaussische verdeling kijkt naar de kans op combinaties van kenmerken, past deze methode ook beter
bij deze gegevens. We krijgen er dus ook een beter passend model voor terug. Kijk maar naar de classificatie hieronder: die is
bijna perfect!

[![[Het eindmodel herkent de soorten bijna perfect](/assets/posts/2021-08-01-Clustering-penguins/multivariate_model_check.svg)](/assets/posts/2021-08-01-Clustering-penguins/multivariate_model_check.json)

## Het aantal clusters bepalen

Tot nu toe legden we het gewenste aantal clusters vast in de code. Dat is handig als je het aantal kent, maar wat als je geen idee hebt?
Dan moet je een model bouwen met 2, 3, 4, 5... clusters en bekijken welk model het best past zonder 
te complex te worden. Eerst maken we een functie die een model met *n* clusters bouwt, het samplet en het 
model en de traces retourneert. Daarna voeren we dit uit voor meerdere clustergroottes, slaan we de resultaten op en vergelijken we ze met Arviz.

{:.large-code}
```python
def run_model(data, n_clusters, samples=4000):
    print(f"Building model with {n_clusters} cluster and {samples} samples.")

    n_observations, n_features = data.shape
    with pm.Model() as model:
        chol, corr, stds = pm.LKJCholeskyCov(
            "chol",
            n=n_features,
            eta=2.0,
            sd_dist=pm.Exponential.dist(1.0),
            compute_corr=True,
        )
        mu = pm.Normal(
            "mu", 0.0, 1.5, shape=(n_clusters, n_features), testval=data.mean(axis=0)
        )

        p = pm.Dirichlet("p", a=np.ones(n_clusters))
        category = pm.Categorical("category", p=p, shape=n_observations)

        y = pm.MvNormal("y", mu[category], chol=chol, observed=data)

        trace = pm.sample(samples)
    return model, trace
```

Dit is eigenlijk een erg algemene functie die elke dataframe of matrix aanvaardt — ze moet wel geschaald zijn — samen met een 
aantal clusters. Ze bouwt en samplet een model en retourneert het daarna. Met enkele regels code kunnen we de functie uitvoeren en
de uitvoer in een dictionary opslaan. Vervolgens vergelijken we met ```az.compare``` de modellen met verschillende aantallen
clusters.

```python
data = scaled_penguin_df.drop(columns=["species"]).values
model_traces = {
    f"model_{i}_clusters": run_model(data, i, samples=8000) for i in range(2, 6)
}
comp = az.compare({k: v[1] for k, v in model_traces.items()})
comp
```

{:.large-table}
|                  | rank |          loo |      p_loo |      d_loo |       weight |        se |       dse | warning | loo_scale |
|-----------------:|-----:|-------------:|-----------:|-----------:|-------------:|----------:|----------:|--------:|----------:|
| model_3_clusters |    0 |  -905.740656 |  68.837020 |   0.000000 | 4.808971e-01 | 29.476505 |  0.000000 |    True |       log |
| model_5_clusters |    1 |  -905.837578 | 197.606731 |   0.096921 | 5.191029e-01 | 28.926480 | 11.295538 |    True |       log |
| model_4_clusters |    2 |  -922.262126 | 175.651671 |  16.521469 | 0.000000e+00 | 29.039549 | 10.030136 |    True |       log |
| model_2_clusters |    3 | -1284.311894 | 156.435489 | 378.571238 | 2.416753e-09 | 28.624421 | 16.756834 |    True |       log |

```az.compare``` past verschillende maatstaven toe om te bepalen welk model het best bij onze gegevens past. Standaard
gebruikt dit *leave-one-out cross-validation*. ```loo```, ```p_loo``` en ```d_loo``` zijn de waarden uit 
die analyse (loo is de maatstaf die je bekijkt en lager is beter; p_loo is het geschatte aantal parameters en d_loo is 
het verschil met het beste model). Het gewicht kun je ruwweg zien als de kans dat het model correct is gegeven de 
gegevens; dichter bij 1 is hier beter. De standaardfout van de crossvalidatie, ```se``` in de tabel, is ook opgenomen, 
net als het verschil met het beste model, ```dse```. 

We zien dat het model met drie clusters hier het best presteert. Omdat dit niet het maximale geteste aantal 
clusters is, kunnen we dat aanvaarden. Vaak maken deze cijfers echter niet zo duidelijk welk model je moet 
kiezen: twee modellen kunnen erg dicht bij elkaar liggen. Een grafiek met ```az.plot_compare``` kan dan uitsluitsel geven. 

```python
az.plot_compare(comp)
```

![Vergelijkingsgrafiek van Arviz-modellen](/assets/posts/2021-08-01-Clustering-penguins/cluster_selection.png){:.small-image}

Hier zie je de scores van alle modellen; de verticale grijze lijn markeert de beste score. Alle modellen waarvan de zwarte balk
deze lijn kruist, kun je waarschijnlijk als even goed beschouwen (in dit geval de modellen met 3, 4 en 5 clusters). 
Kies dan het model met de minste clusters, zelfs als het niet bovenaan staat.

## Conclusie

Omdat ik nog maar een maand of twee met PyMC3 en Bayesiaanse statistiek werk, gaan sommige concepten hier verder dan
wat ik volledig begrijp. Neem alles dus met een flinke korrel zout! Door rustig en stap voor stap te 
werken, was het toch mogelijk een bijzonder goed presterende classifier voor deze dataset te bouwen. Het geeft me ook een 
duidelijke richting voor de theorie die ik verder moet bestuderen: multivariate Gaussische verdelingen. 


## Referenties

  * **[palmerpenguins](https://allisonhorst.github.io/palmerpenguins/): Palmer Archipelago (Antarctica) penguin data.** Allison Marie Horst and Alison Presmanes Hill and Kristen 
B Gorman (2020).

## Dankwoord

Headerfoto door [Derek Oyen](https://unsplash.com/@goosegrease?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) op [Unsplash](https://unsplash.com/s/photos/penguin?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
  

[PyMC3]: https://docs.pymc.io/
[this GitHub repository]: https://github.com/4dcu-be/ClassifyingPenguins
[GitHub repo]: https://github.com/4dcu-be/ClassifyingPenguins
[Palmer Station Penguin]: https://allisonhorst.github.io/palmerpenguins/
[Iris]: https://archive.ics.uci.edu/ml/datasets/iris
[Fish Market]: https://www.kaggle.com/aungpyaeap/fish-market
