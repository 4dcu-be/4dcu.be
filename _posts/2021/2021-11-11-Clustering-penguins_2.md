---
layout: post
title:  "Faster Mixture Models in PyMC3"
byline: "ft. more penguins"
date:   2021-11-11 08:00:00
author: Sebastian Proost
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

In a [previous post] about clustering the [palmer penguins] using [PyMC3], the mixture model was implemented in the model itself. 
Though this is great for understanding what is going on, it isn't very efficient when sampling the model. Furthermore, 
observations (here penguins) were assigned to groups (here the species of penguin) using only one of the samples taken 
from the model, since we sample the model thousands of times it is a shame not to take all that data into account. 

When acquiring more observations, you typically don't want to re-run the entire sampling step (here it takes minutes
but this could be hours or days for more complex mixtures or larger datasets). Ideally you can fit the model on some 
initial data and then predict the group using new, previously unseen, data. With the code in the previous post this 
was not possible, in the code below we'll explore how this can be done using PyMC3.

So while we had a great model already, a few trick can still be used to further improve upon it. 
[This GitHub repository] contains all the code, which is based on the code discussed on the PyMC3 forums 
[here](https://discourse.pymc.io/t/properly-sampling-mixture-models/986/7) and 
[here](https://discourse.pymc.io/t/get-probability-of-parameter-given-new-data/2511/2). Both threads are interesting
and worth checking out !

## The new model

The data is all identical to the [previous post], as is the code to prepare it (applying a ```StandardScaler```). Here
the explicit categories for each observation are replaced by ```pm.Mixture``` which handles this far more efficiently.
Using Theano's ```stack``` function different distributions are combined into a larger tensor. 

Also note that the sampling is done on a single core, this is because there is a bug in the sampling of Mixtures on 
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

Sampling here is considerably faster than before, that already is a clear advantage (especially if you need to run
the inference multiple times with different cluster sizes to determine how many there are). Though,
there are still a few things to implement, as this model doesn't provide a category/group to each observation.

## Assigning groups to observations

From this model it is far less obvious how to get cluster assignments for all observations. The previous model 
explicitly assigned a category to each observation, which is not the case here. We'll have to check with each of 
the ```MvNormals``` in the Mixture which fits best with each observation. The code below does this for all sampled data
and returns the mean probability for each observation and each cluster.

Note that here we tackle multiple issues in one go as also new data can be passed in that was not used for 
sampling. After scaling new data (look at ```.fit()``` and ```.transform()``` from ```StandardScaler```) it can simply
be passed in here and done! 


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

This will give us an *n_observations* by *n_clusters* large matrix, with for each observation the probabilities it belongs
to each cluster. With a few lines below we can get the best cluster for each observation.

```python
weights_df = pd.DataFrame(
    weights, columns=[f"Group {d+1}" for d in range(weights.shape[1])]
)
weights_df["Predicted Group"] = weights_df.apply(lambda x: x.idxmax(), axis=1)

weights_df
```

{:.large-table}
|     |      Group 1 |      Group 2 |      Group 3 | Predicted Group |
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

## Final results

The clustering is on par, or even slightly better than before. By taking all samples from one chain into account we
get a much more robust result. Only four observations are assigned in the wrong group here, which given how minor the 
differences are between some species (at least from these measurements, visually it is rather easy telling them apart) 
in this dataset is a rather nice result.

[![Final model, samples faster and can be used to assign groups to unseen data](/assets/posts/2021-11-11-Clustering-penguins_2/clustering_results.svg)](/assets/posts/2021-11-11-Clustering-penguins_2/clustering_results.json)

## Conclusion

While the model itself isn't much more complicated than in the [previous post], not explicitly including categories
(or groups or species) which can be extracted, makes the downstream analysis more involved. Though the advantages of
this approach are clear; the model **samples much faster** in under two minutes (vs. 15+ minutes for the previous one), 
**new observations can be assigned to a group** without re-running the sampling and the final **results are more robust**
as more data from the sampling is included.


## References

  * **[palmerpenguins](https://allisonhorst.github.io/palmerpenguins/): Palmer Archipelago (Antarctica) penguin data.** Allison Marie Horst and Alison Presmanes Hill and Kristen 
B Gorman (2020).

## Acknowledgements

Header photo by [Cornelius Ventures](https://unsplash.com/@corneliusventures) on [Unsplash](https://unsplash.com/s/photos/penguin)
  

[PyMC3]: https://docs.pymc.io/
[this GitHub repository]: https://github.com/4dcu-be/ClassifyingPenguins
[GitHub repo]: https://github.com/4dcu-be/ClassifyingPenguins
[palmer penguins]: https://allisonhorst.github.io/palmerpenguins/
[previous post]: {% post_url 2021/2021-08-01-Clustering-penguins %}
