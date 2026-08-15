---
layout: post
title:  "Snellere mengmodellen in PyMC3"
byline: "met nog meer pinguïns"
description: "PyMC3-mengmodellen op de Palmer-pinguïndataset versnellen met pm.Mixture en soorten voor nieuwe waarnemingen voorspellen zonder opnieuw te samplen."
date:   2021-11-11 08:00:00
author: Sebastian Proost
post_id: clustering-penguins-2
categories: programming biology
tags:	python pymc3 data-analysis data-science machine-learning altair biology
cover:  "/assets/posts/2021-11-11-Clustering-penguins_2/penguin_header.jpg"
thumbnail: "/assets/images/thumbnails/classifying_penguins_2_header.jpg"
github: "https://github.com/4dcu-be/ClassifyingPenguins"
custom_js:
  - vega.min
  - vega-lite.min
  - vega-embed.min
  - justcharts
---

In een [vorige post] over het clusteren van de [Palmer-pinguïns] met [PyMC3] werd het mengmodel in het model zelf geïmplementeerd. 
Dat is uitstekend om te begrijpen wat er gebeurt, maar niet erg efficiënt bij het samplen van het model. Bovendien werden 
waarnemingen (hier pinguïns) aan groepen (hier de pinguïnsoorten) toegewezen op basis van slechts één sample uit 
het model. Omdat we het model duizenden keren samplen, is het zonde om niet al die gegevens mee te nemen. 

Wanneer je meer waarnemingen verzamelt, wil je doorgaans niet de hele samplestap opnieuw uitvoeren (hier duurt dat enkele minuten,
maar bij complexere mengsels of grotere datasets kan het uren of dagen kosten). Idealiter fit je het model op een eerste 
reeks gegevens en voorspel je daarna de groep met nieuwe, nog niet eerder geziene gegevens. Met de code uit de vorige post kon dat 
niet; in de code hieronder onderzoeken we hoe het wel kan met PyMC3.

Hoewel we al een uitstekend model hadden, kunnen enkele trucjes het nog verder verbeteren. 
[Deze GitHub-repository] bevat alle code, gebaseerd op code die op de PyMC3-forums 
[hier](https://discourse.pymc.io/t/properly-sampling-mixture-models/986/7) en 
[hier](https://discourse.pymc.io/t/get-probability-of-parameter-given-new-data/2511/2) werd besproken. Beide discussies zijn interessant
en het bekijken waard!

## Het nieuwe model

De gegevens zijn identiek aan die uit de [vorige post], net als de code om ze voor te bereiden (met een ```StandardScaler```). Hier
worden de expliciete categorieën voor elke waarneming vervangen door ```pm.Mixture```, dat dit veel efficiënter afhandelt.
Met Theano's ```stack```-functie worden verschillende verdelingen samengevoegd tot een grotere tensor. 

Merk ook op dat het samplen op één core gebeurt. Dat komt door een bug bij het samplen van mengmodellen op 
Windows.

{:.large-code}
```python
n_clusters = 3
data = scaled_penguin_df.drop(columns=["species"]).values
n_observations, n_features = data.shape
with pm.Model() as Model:
    # Create a covariance matrix for each potential cluster which relates all features of our data
    lower = tt.stack(
        [
            pm.LKJCholeskyCov(
                "sigma_{}".format(k),
                n=n_features,
                eta=2.0,
                sd_dist=pm.HalfNormal.dist(sd=1.0),
            )
            for k in range(n_clusters)
        ]
    )
    chol = tt.stack(
        [pm.expand_packed_triangular(n_features, lower[k]) for k in range(n_clusters)]
    )

    # The center of each cluster
    mus = tt.stack(
        [
            pm.Normal("mu_{}".format(k), 0.0, 1.5, shape=n_features)
            for k in range(n_clusters)
        ]
    )

    # Create the multivariate normal distribution for each cluster
    MultivariateNormals = [
        pm.MvNormal.dist(mus[k], chol=chol[k], shape=n_features)
        for k in range(n_clusters)
    ]

    # Create the weights for each cluster which measures how much impact they have
    w = pm.Dirichlet("w", np.ones(n_clusters) / n_clusters)

    obs = pm.Mixture("obs", w=w, comp_dists=MultivariateNormals, observed=data)
    trace = pm.sample(2000, cores=1, tune=2000, chains=1)
```

Het samplen gaat hier aanzienlijk sneller dan voordien. Dat is al een duidelijk voordeel, zeker als je de inferentie
meermaals met verschillende clustergroottes moet uitvoeren om het aantal clusters te bepalen. Toch
moeten we nog enkele zaken implementeren, want dit model kent niet aan elke waarneming een categorie of groep toe.

## Groepen aan waarnemingen toewijzen

Bij dit model is het veel minder duidelijk hoe we alle waarnemingen aan een cluster toewijzen. Het vorige model 
kende expliciet een categorie aan elke waarneming toe; hier gebeurt dat niet. We moeten voor elk van 
de ```MvNormals``` in het mengmodel nagaan welke het best bij iedere waarneming past. De code hieronder doet dat voor alle gesamplede gegevens
en retourneert voor elke waarneming en elk cluster de gemiddelde kans.

Merk op dat we hier meerdere problemen tegelijk aanpakken, want er kunnen ook nieuwe gegevens worden doorgegeven die niet voor het 
samplen werden gebruikt. Nadat je nieuwe gegevens hebt geschaald (bekijk ```.fit()``` en ```.transform()``` van ```StandardScaler```), kun je ze hier gewoon
doorgeven en klaar! 


{:.large-code}
```python
def prob_weights(model_mixed, trace_mixed, ynew):
    complogp = obs.distribution._comp_logp(theano.shared(ynew))
    f_complogp = model_mixed.model.fastfn(complogp)
    weight_ynew = []
    ichain = 0  # just use the first chain, as groups can differ between chains you can't mix them

    for point_idx in range(len(trace_mixed)):
        point = trace_mixed._straces[ichain].point(point_idx)
        point = {
            k: v
            for k, v in point.items()
            if k.startswith("mu_") or "cholesky" in k or "w_stick" in k
        }  # We need to remove a number of un-necessary keys.
        prob = np.exp(f_complogp(point))
        prob /= prob.sum()
        weight_ynew.append(prob)

    weight_ynew = np.asarray(weight_ynew).squeeze()

    return weight_ynew.mean(axis=0)


with Model:
    weights = prob_weights(Model, trace, data)
```

Dit levert een matrix van *n_observations* bij *n_clusters* op, met voor elke waarneming de kans dat ze bij
elk cluster hoort. Met de enkele regels hieronder vinden we voor iedere waarneming het beste cluster.

```python
weights_df = pd.DataFrame(
    weights, columns=[f"Group {d+1}" for d in range(weights.shape[1])]
)
weights_df["Predicted Group"] = weights_df.apply(lambda x: x.idxmax(), axis=1)

weights_df
```

{:.large-table}
|     |      Groep 1 |      Groep 2 |      Groep 3 | Voorspelde groep |
|----:|-------------:|-------------:|-------------:|----------------:|
|   0 | 8.382822e-07 | 3.585496e-27 | 2.134100e-03 |         Group 3 |
|   1 | 2.719038e-05 | 8.994132e-19 | 3.469642e-03 |         Group 3 |
|   2 | 9.999582e-05 | 1.876578e-19 | 1.003150e-03 |         Group 3 |
|   3 | 3.711145e-07 | 2.739789e-26 | 1.710354e-03 |         Group 3 |
|   4 | 7.053319e-08 | 1.083051e-32 | 5.662282e-04 |         Group 3 |
| ... |          ... |          ... |          ... |             ... |
| 337 | 1.704825e-13 | 3.702778e-03 | 6.052112e-15 |         Group 2 |
| 338 | 4.878579e-12 | 1.184303e-02 | 1.632105e-13 |         Group 2 |
| 339 | 1.321670e-14 | 5.686282e-03 | 5.483161e-16 |         Group 2 |
| 340 | 6.149976e-12 | 4.603352e-03 | 9.009127e-13 |         Group 2 |
| 341 | 4.806522e-11 | 7.667016e-04 | 1.549001e-12 |         Group 2 |

## Eindresultaten

De clustering is even goed of zelfs iets beter dan voordien. Door alle samples uit één chain mee te nemen,
krijgen we een veel robuuster resultaat. Slechts vier waarnemingen worden hier aan de verkeerde groep toegewezen. Gezien hoe klein de 
verschillen tussen sommige soorten in deze dataset zijn — althans volgens deze metingen; visueel zijn ze vrij eenvoudig uit elkaar te houden — 
is dat een erg mooi resultaat.

[![Het eindmodel samplet sneller en kan groepen toewijzen aan ongeziene gegevens](/assets/posts/2021-11-11-Clustering-penguins_2/clustering_results.svg)](/assets/posts/2021-11-11-Clustering-penguins_2/clustering_results.json)

## Conclusie

Hoewel het model zelf niet veel ingewikkelder is dan in de [vorige post], maakt het ontbreken van expliciete, uitleesbare categorieën
(of groepen of soorten) de verdere analyse arbeidsintensiever. De voordelen van
deze aanpak zijn echter duidelijk: het model **samplet veel sneller**, in minder dan twee minuten (tegenover meer dan 15 minuten voor het vorige), 
**nieuwe waarnemingen kunnen aan een groep worden toegewezen** zonder opnieuw te samplen en de uiteindelijke **resultaten zijn robuuster**
omdat meer gegevens uit het samplen worden meegenomen.


## Referenties

  * **[palmerpenguins](https://allisonhorst.github.io/palmerpenguins/): Palmer Archipelago (Antarctica) penguin data.** Allison Marie Horst and Alison Presmanes Hill and Kristen 
B Gorman (2020).

## Dankwoord

Headerfoto door [Cornelius Ventures](https://unsplash.com/@corneliusventures) op [Unsplash](https://unsplash.com/s/photos/penguin)
  

[PyMC3]: https://docs.pymc.io/
[Deze GitHub-repository]: https://github.com/4dcu-be/ClassifyingPenguins
[GitHub repo]: https://github.com/4dcu-be/ClassifyingPenguins
[Palmer-pinguïns]: https://allisonhorst.github.io/palmerpenguins/
[vorige post]: {% post_url nl/2021/2021-08-01-Clustering-penguins %}
