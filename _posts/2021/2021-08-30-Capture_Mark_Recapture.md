---
layout: post
title:  "Capture-Mark-Recapture model in PyMC3"
byline: ""
date:   2021-08-30 06:00:00
author: Sebastian Proost
categories: programming biology
tags:	python pymc3 data-analysis data-science machine-learning ecology biology
cover:  "/assets/posts/2021-08-30-Capture_Mark_Recapture/fish_header.jpg"
thumbnail: "/assets/images/thumbnails/fish_school.jpg"
---

Imagine you wish to know how many fish are in a rather large pond... The water is murky so forget about counting them
easily... In ecology this is a common problem! The population size of a species often needs to be known, but it is
either impractical or simply impossible to count all individual members of that population. Fortunately, there is
a relatively easy solution to get an estimation!

To estimate the size of the population you would have to visit the site twice. On the first visit a number of 
animals are caught, marked and released. It is important to mark them in a way it doesn't do them any disadvantage or harm, 
equally important is to use marks that don't easily rub off. You keep count of how many members of the population were
caught and marked. Next, a day or so later, the site is visited again and a number of animals is caught. This time the number
of marked animals that were recaptured is important. As the fraction of the marked individuals captured the second day, is 
essentially the same as the fraction of the population that was marked the first day. This method goes by a few names
like *[Capture-Mark-Recapture]*, *[Mark and Recapture]* or other slight variations.

As an example imagine you catch and tag 50 individuals on day one. The next day, 100 animals are caught and 10 of those
are marked. So we know that roughly 10% of all individuals were tagged, we also know that there are in total 50 tagged
individuals, so the total population size should be about 500. 

$$
\begin{aligned}
  \frac{n\_marked}{population\_size} = \frac{n\_recaptured}{captured\_round\_2}
\end{aligned}
$$

This formula can be re-written as:

$$
\begin{aligned}
 population\_size = \frac{n\_marked * captured\_round\_2}{n\_recaptured}
\end{aligned}
$$

While the latter is really simple and similar exercises are already seen in primary school (known as the 
[rule of three]), calculating the [confidence interval] (the range in which the actual population size is with a 
certain amount, usually 95%, of confidence) on this estimate is far from trivial (check the link, it is 
a very complex formula). However, when using a Bayesian approach, we get the uncertainty on the population size 
automatically, without any extra effort. So let's implement this model in [PyMC3] and see what we get.


## Creating a PyMC3 model

The data from the observation is stored in a few variables: ```n_marked``` (the number of individuals marked on the 
first visit), ```captured_round_2``` (the total number of individuals caught the second visit) and ```n_recaptured``` 
(the number of marked individuals caught the second visit). The big unknown that we need to infer is the 
```population_size```, we don't really have any clue about this except that it is equal or higher than the total number
of individual that were caught during both visits. So we can set the number of unique animals seen as the lower limit.

The probability to capture an already marked animal the second visit ```p_marked``` is the number of marked animal within the
full population. So this is a ```pm.Deterministic``` variable as it is defined by the number of marked animals (which is known) 
and the population size (which we try to infer). Finally, a likelihood ```recapture_obs``` is required, this will be 
a ```pm.Binomial``` with the total number of animals caught the second day as the number of draws, the number of 
marked individual recaptured as the observation and a probability of ```p_marked```. 

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

After sampling the model, we get our estimate for the population size. In this case the population size is estimated
to be between 294 and 1034 individuals (hdi_3% and hdi_97%, PyMC3 by default gives you the smallest range where 94% of the
inferred values were found) with a mean value of 620. While the mean isn't crazy far off from the 
population size in our example, the uncertainty is rather large. It does show that not nearly enough animals were 
marked or re-captured in our thought experiment.

|                 |    mean |      sd |  hdi_3% |  hdi_97% |
|----------------:|--------:|--------:|--------:|---------:|
| population_size | 620.067 | 220.926 | 293.750 | 1034.423 |
|        p_marked |   0.090 |   0.028 |   0.039 |    0.142 |

### Update 30/08/2022 - HyperGeometric likelihood

As in this case draws from the population aren't independent, a HyperGeometric distribution is better for this model. The
last two parts can be switched for the lines below to implement this. While this wouldn't be a big difference in case
the number of marked individuals is large enough, here it does affect the mean estimate and 94% HDI.

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

## Can we improve without catching more animals ?

So without catching more animals overall, is it better to mark more animals, and catch fewer the next visit? Or capture more
animals on the second visit, while marking fewer the first time around? With this model we can easily test this out!

Let's mark 100 animals on day one and catch 50 on day two. Given a population size of 500 we'd expect about 10 to be
re-capture. If we feed those number in the model we get the results below.

|                 |    mean |      sd |  hdi_3% |  hdi_97% |
|----------------:|--------:|--------:|--------:|---------:|
| population_size | 610.585 | 212.195 | 310.344 | 1008.055 |
|        p_marked |   0.180 |   0.054 |   0.082 |    0.279 |

While there is still a lot of uncertainty, it does drop when catching more animals the first day and fewer the
second day. (I'll leave confirming it gets worse if you do things the other way around to the reader) However,
once you drop below a point where you are barely recapturing any animals on the second day, this is also negatively
going to affect the estimate.

## Catching twice as many animals

This model really works well if enough individuals can be tagged and recaptured. So if we increase the number of
marks to 200 and capture 100 the second day, we would expect about 40 to be tagged. Punching in those numbers in the
model, we see that now the mean is very close to what it should be in our imaginary population and the
uncertainty is far smaller.

|                 |    mean |     sd |  hdi_3% | hdi_97% |
|----------------:|--------:|-------:|--------:|--------:|
| population_size | 519.579 | 66.165 | 402.473 | 643.741 |
|        p_marked |   0.391 |  0.048 |   0.302 |   0.483 |

## Conclusion

While the formula for this model is simple, calculating the confidence interval isn't. Though here it could be instrumental to know
how much uncertainty you have. In our first example, depending on how many fish there are in the pond you might allow
fishers to capture a certain number. So if there are 293, 500, 610 or, 1034 this could influence how many people 
are allowed to catch fish in that pond.

By using a Bayesian approach, the problem is solved in a few simple lines of code, and we get the confidence interval 
in one go as well, easy! This is exactly the strength of Bayesian statistics. The advantages here are further 
highlighted as it is very easy to play with the number to see how the uncertainty can be decreased, so the efforts of 
catching and marking individuals can be done as efficient as possible.

To see what I did with this formula, check out the [next post] where this is used to estimate how many KeyForge decks
were printed.

## Acknowledgements

Header image by [Sebastian Pena Lambarri](https://unsplash.com/@sebaspenalambarri?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/s/photos/fish?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)

[rule of three]: https://en.wikipedia.org/wiki/Cross-multiplication#Rule_of_three
[Mark and Recapture]: https://en.wikipedia.org/wiki/Mark_and_recapture
[Capture-Mark-Recapture]: https://www.bbc.co.uk/bitesize/guides/zmxbkqt/revision/3
[confidence interval]: https://en.wikipedia.org/wiki/Mark_and_recapture#Confidence_interval
[PyMC3]: https://docs.pymc.io/
[next post]: {% post_url 2021/2021-09-04-KeyForge_Decks_Printed %}
