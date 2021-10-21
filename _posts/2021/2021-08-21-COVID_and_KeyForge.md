---
layout: post
title:  "COVID-19 impact on KeyForge"
byline: ""
date:   2021-08-20 08:00:00
author: Sebastian Proost
categories: programming games
tags:	python pymc3 keyforge data-analysis data-science machine-learning altair covid-19
cover:  "/assets/posts/2021-08-21-COVID_and_KeyForge/ammonia_clouds_header.jpg"
thumbnail: "/assets/images/thumbnails/keyforge_covid.jpg"
github: "https://github.com/4dcu-be/BayesianSalesAnalysis"
custom_js:
  - vega.min
  - vega-lite.min
  - vega-embed.min
  - justcharts
---

All our lives were impacted by COVID-19, but what was the impact on KeyForge sales? There was a
[very technical post]({% post_url 2021/2021-07-04-Bayesian-sales-analysis %}) last month, this one is intended for 
everyone that cares about KeyForge, but not the details of how to create models.


## 500 000 fewer decks registered during COVID

This shouldn't come as a surprise to anyone, during COVID, with the world going in lockdown there were fewer decks
registered. With local game stores closed, in person games were hard if not impossible at times and the competitive
scene died out entirely. So no decks are being purchased for sealed play and there was no need to buy a bunch of deck to 
find that one with the combo that could take you to the top of the leaderboards. With people unable to get together
and play, they play less and the decks they do purchase will last longer as the novelty doesn't wear off nearly as fast.

The graph below shows, in blue, how many decks were registered in [the master vault] since the release up until this
article was posted. The gray line indicates how many decks the model predicts would have been registered had COVID-19 never 
happened. The area between the lowest and highest prediction is shaded in gray and shows the uncertainty of the model.

[![Updated model shows how many decks would have been registered in a world without COVID-19](/assets/posts/2021-08-21-COVID_and_KeyForge/model_6_no_covid.svg)](/assets/posts/2021-08-21-COVID_and_KeyForge/model_6_no_covid.json)

So the model fits the real data like a glove before COVID-19 measurements got into effect (which is good, it would
be a very poor model if it didn't) and as it projects further into our hypothetical scenario the uncertainty grows 
(which is expected). It shows that **without COVID-19 there would have been around 3.16 million decks registered on August 15th, 2021**. 
With the worst prediction at 2.99 million and the best 3.31 million, which makes the actual number of decks registered at that
date, 2.43 million look rather pale in comparison. 

So Fantasy Flight Games sold a substantially lower number of KeyForge decks during this period. Obviously this isn't
good for the game, **without a global pandemic there would have been at least half a million more decks registered**.
Note that the number of lost sales is even higher, as not every deck sold is necessarily registered.

## The interest in KeyForge didn't diminish

Do you notice the little nicks in the graph above? Those bumps coincide with new sets being released. With every set
being preceded with additional advertisement to create a bit of hype, and simply new cards coming out gets people excited
to pick up new decks. The model includes the interest there is to buy new decks upon release, and we can compare 
this between sets. (Technical details can be found in the 
[previous post]({% post_url 2021/2021-07-04-Bayesian-sales-analysis %}), with the latest model available on [GitHub] )

[![Updated model shows how much interest there was at release in each set](/assets/posts/2021-08-21-COVID_and_KeyForge/model_6_set_interest.svg)](/assets/posts/2021-08-21-COVID_and_KeyForge/model_6_set_interest.json)

This graph is a bit harder to grok than the previous one, so let's pick it apart slowly. Each bell curve represents the
interest in the different sets, the more the curve is shifted to the left, the lower the interest was, the more to the 
right the more decks were sold due to the release of that set. The shape of the curve shows where the model thinks 
the real value is, so it is more likely to be near the top of the curve than near the bottom. Overlapping curves mean 
there is a rather large chance there was no real difference between the two sets. The technical term for these curves are
[probability density functions]. 

The interest in Call of the Archons, the very first set, is huge compared to the others. Releasing a new game, by
[Richard Garfield, Ph.D.] himself, can have that effect. It being a new game also requires people to pick up a few decks
to have a variety of games. So the fact that no-one had a collection yet also made the threshold to buy decks early on
lower than right now, where some players have already acquired dozens if not hundreds of decks.

However, we see only minor differences in the interest in other sets released before (Age of Ascension and Worlds Collide) and
sets released during the pandemic (Mass Mutation and Dark Tidings). The graphs overlap too much to make a call which ones
are worse or better than others with confidence. Which is a good thing here! **So, we can conclude that the interest in 
new KeyForge releases hasn't faded because of a viral outbreak!** 

## Conclusion

KeyForge is a game intended to be played in person. So it is not surprising that with local game stores and tournaments 
abruptly becoming unavailable the rate of decks being registered dropped considerably. This must have lead to considerable 
losses for both game stores and [Fantasy Flight Games] which produces KeyForge. With 500 000 less decks registered the 
last year and a half, it also creates the impression that interest in the game died. Though when digging deeper into the 
data that is clearly shown to be incorrect. People still pony up cash 
to buy new decks upon the release of a new set as before the pandemic. Which suggests the game is very much alive, but 
incentives to buy more product between releases (sealed and competitive play or simply the ability to go out, sit 
in front of someone at the store and play) simply weren't there. Hopefully that is about to change soon again with life
restrictions being lifted and the [World Championship] coming up in 2022 !

Note that this is all about the number of *registered* decks, if you are interested in the total number of *printed* 
decks, have a look a [this post]({% post_url 2021/2021-09-04-KeyForge_Decks_Printed %}).

## Acknowledgements

[Archon Arcana] has been tracking registered decks from the very beginning and kindly shared 
the raw data for us to play with (check out their page [here](https://archonarcana.com/Master_Vault#Registered_decks)).

This post is unofficial Fan Content. The literal and graphical information presented in this project related with 
KeyForge is copyright of Fantasy Flight Games (FFG). 4DCu.be is not produced by, endorsed by, supported by, 
or affiliated with FFG.

[the master vault]: https://www.keyforgegame.com/
[Richard Garfield, Ph.D.]: https://en.wikipedia.org/wiki/Richard_Garfield
[probability density functions]: https://en.wikipedia.org/wiki/Probability_density_function
[Fantasy Flight Games]: https://www.fantasyflightgames.com/
[World Championship]: https://www.fantasyflightgames.com/en/news/2021/2/4/forging-ahead/
[GitHub]: https://github.com/4dcu-be/BayesianSalesAnalysis
[Archon Arcana]: https://archonarcana.com/Main_Page
