---
layout: post
title:  "The KeyForge hiatus: impact on deck registrations"
byline: ""
date:   2022-04-13 08:00:00
author: Sebastian Proost
categories: programming games
tags:	python pymc3 keyforge data-analysis data-science machine-learning altair
cover:  "/assets/posts/2022-04-13-KeyForge_Hiatus/david-kegg-ffg-keyforge-cover-final-small.jpg"
thumbnail: "/assets/images/thumbnails/keyforge_hiatus.jpg"
github: "https://github.com/4dcu-be/BayesianSalesAnalysis"
custom_js:
  - vega.min
  - vega-lite.min
  - vega-embed.min
  - justcharts
---

Is has been a few months since FFG announced KeyForge would be paused, or in their words going [on hiatus]. Though as decks are 
still being registered we can get a glimpse of the effect of this announcement on the game. In a [previous post], a 
model was made that can be used to infer the impact of each set's release on deck registrations as well as provide 
a realistic estimate of registrations lost due to [COVID-19]. By including another variable in the model, the
number of weekly registrations after the announcement of FFG, the effects of this announcement can be evaluated. 

The code for this post is discussed in a [previous post] and the updated version along with fresh data can be found on 
[GitHub].

## Drop in the number of weekly registrations

Before the announcement, but well during the pandemic, there were between 5820 and 6470 decks being registered weekly. 
With new sets (Mass Mutation and Dark Tidings) being released pushing this number up for a few weeks after release. A
substantial difference with the situation before the pandemic, where 14980 to 16750 decks were scanned every week.

The model estimates the number of deck registered weekly has dropped with **3.6% to 17.5%** (compared to the situation 
during the pandemic) since the announcement the game was being put on hold. While this means every week 
5200 to	5820 decks and opened and entered in the system.

[![Probability density function of the percentage drop in registrations due to the hiatus](/assets/posts/2022-04-13-KeyForge_Hiatus/model_6_hiatus_percent_drop.svg)](/assets/posts/2022-04-13-KeyForge_Hiatus/model_6_hiatus_percent_drop.json)

The above image shows the probability density function of the percentage drop in registrations due to the hiatus. We
can confidently say it is between **3.6% to 17.5%**, with the peak just over 10%. While the game isn't exactly dead,
missing 1 or 2 out of every 10 sales isn't good for any business either.

## Model without a pandemic and no hiatus

In the previous post the model was used to check how deck registrations would have evolved in case there was no pandemic,
we'll repeat that here with more data and removing the effect of the hiatus as well.

[![Model in case there was no pandemic and no hiatus](/assets/posts/2022-04-13-KeyForge_Hiatus/model_6_no_covid_no_hiatus.svg)](/assets/posts/2022-04-13-KeyForge_Hiatus/model_6_no_covid_no_hiatus.json)

In the aftermath of the pandemic and with the hiatus announced the number of decks registered each week is rather pale
in comparison to two years ago. The difference between the actual number of registered decks (blue line) and mean 
estimate (dark gray line) is getting larger. In [August 2021] (when I created the model), the difference was roughly 
0.6 million decks, this has gone up to around **1 million** now. 

Also note that no new sets were released, which boosts deck registrations considerably for a few months once the cards become 
available. So in reality the difference could have been even greater.

## Conclusion

It is clear that the number of deck registrations has gone down since the hiatus. While this is solely due to the 
announcement or the add-on effects (e.g. stores clearing inventory and having no more KeyForge decks to sell) is
impossible to assess. We do know that new releases and competitive play drive sales (and hence registrations), as 
neither of those will happen for an undefined period, it isn't looking good in the long run. However, all things
considering, even an intermediate estimate of 10% fewer registrations weekly compared to the situation during the
pandemic means over 5500 new decks are being opened, scanned and (hopefully) played with every week.

## Acknowledgements

This post is unofficial Fan Content. The literal and graphical information presented in this project related with 
KeyForge is copyright of Fantasy Flight Games (FFG). 4DCu.be is not produced by, endorsed by, supported by, 
or affiliated with FFG.

[previous post]: {% post_url 2021/2021-07-04-Bayesian-sales-analysis %}
[COVID-19]: {% post_url 2021/2021-08-21-COVID_and_KeyForge %}
[August 2021]: {% post_url 2021/2021-08-21-COVID_and_KeyForge %}
[on hiatus]: https://www.fantasyflightgames.com/en/news/2021/9/10/down-but-not-out/
[GitHub]: https://github.com/4dcu-be/BayesianSalesAnalysis
