---
layout: post
title:  "KeyForge: How many decks were printed ?"
byline: "... and which percentage has been registered ?"
date:   2021-09-4 06:00:00
author: Sebastian Proost
categories: programming games
tags:	python pymc3 keyforge data-analysis data-science machine-learning covid-19
cover:  "/assets/posts/2021-09-04-KeyForge_Decks_Printed/keyforge_logos.jpg"
thumbnail: "/assets/images/thumbnails/keyforge_deck_estimate.jpg"
github: "https://github.com/4dcu-be/BayesianSalesAnalysis"
---

KeyForge is often advertised as having 104 septillion possible decks per set (that is 104 followed by 24 zeros), but
how many of those decks actually exist? [Fantasy Flight Games] never released data on how many decks were printed
per run. Though with Dark Tiding having Evil Twin decks (exact copies of other decks, but with Evil versions of certain 
cards), we can actually estimate the total number of decks printed! This allows us to get a grasp of which percentage of
decks are registered.

## How to estimate the number of printed Dark Tidings decks ?

In the [previous post] a trick used in ecology, called [Capture-Mark-Recapture], to estimate the number of 
animals in a given population, without counting all of them was shown. The basis for this strategy is visiting the 
site twice, and being able to capture animals each time independently. The first time captured animals are marked and released, 
the second time around the total number of animals caught and how many of those were marked is recorded. From those 
numbers you can, using a relatively simple formula, estimate the total population size.

To apply this to KeyForge, Evil-Twin decks in Dark Tidings are key (pun intended). We can consider the Evil Twin decks as the first 
sample and they "mark" their regular counterparts. Next, we look at all non-Evil Twin decks and check how many were 
marked. From this we can apply the same formula used in ecology to estimate the number of printed non-Evil Twin decks.
With a simple correction we can turn that into an estimate of the total number of Dark Tidings decks printed.

## How many DT decks are there ?

As of writing, there were **8 454 Evil Twin decks** registered in [the master vault], while there were **96 960 non-Evil Twin
decks** from Dark Tidings scanned. In total there were **2 854 pairs registered**. These three values are all we need to
punch into the formula to get an estimate! For details check out the [GitHub repo].

This gives a mean estimate of **312 463 Dark Tidings decks printed**, with the 94% HDI between 302k and 323k decks. 
Furthermore, it also shows that somewhere between **32.6 % and 35.0 % of all those decks have been registered already**. 

## How many other decks are there ?

Dark Tidings is somewhat of an outlier due to COVID (see 
[this post]({% post_url 2021/2021-08-21-COVID_and_KeyForge %}) about the impact of COVID on KeyForge) and the print
run seems to have been adjusted accordingly. So any projections from these data to other sets should be taken with
a hefty dose of scepticism. With that disclaimer in mind, we do know that with Dark Tidings, about 3 months after 
release roughly 1 in 3 decks printed has been registered. Assuming this is true for other sets (we don't know this, but 
unless we accept this the article ends here), we get these estimates:

|  Set | Decks registered * | Decks printed (est.) |
|-----:|-------------------:|---------------------:|
| CotA |            682 800 |            2 048 400 |
| AoA  |            295 698 |              887 094 |
| WC   |            256 531 |              769 593 |
| MM   |            174 778 |              524 334 |
| DT   |            105 414 |              312 463 |
| **Total**|                |        **4 541 884** |

*\* The number of decks registered three months after the release.*

This seems to be in line with what scarce details are known, CotA received [multiple print runs], likely to keep up with 
demand. MM and DT were rumored to have received a smaller print due to COVID and supply issues (for those that speak
italian, it is mentioned in [this podcast], so for Italian cards this is confirmed).

## Conclusion

The unique presence of Evil Twin decks in Dark Tidings allows us to accurately estimate
about 312k Dark Tidings decks were printed. From this we also can show that roughly 1/3 DT decks currently has been 
registered about 16 weeks after its release. Projecting this onto other sets at this point is dubious, but it can 
give a very rough idea how many decks are out there. So it seems **there are in total 4.5M decks printed** across five sets.

Ideally, this analysis should be repeated when there are hardly any DT decks being registered anymore. 
At that point we can estimate the fraction of decks that will ever be registered, which will likely project better
to other sets. Though this will require waiting for another year or two for DT registrations to really go down.

## Acknowledgements

While all data could be scraped from [the master vault], check the [GitHub repo] for the code, this is a very slow process.
Fortunately, Saluk from [Archon Arcana] had a list of all registered Dark Tidings decks already available and was
kind enough to share these data.

This post is unofficial Fan Content. The literal and graphical information presented in this project related with 
KeyForge is copyright of Fantasy Flight Games (FFG). 4DCu.be is not produced by, endorsed by, supported by, 
or affiliated with FFG.

[Fantasy Flight Games]: https://www.fantasyflightgames.com/en/index/
[previous post]: {% post_url 2021/2021-08-30-Capture_Mark_Recapture %}
[Capture-Mark-Recapture]: https://www.bbc.co.uk/bitesize/guides/zmxbkqt/revision/3
[the master vault]: https://www.keyforgegame.com/
[GitHub repo]: https://github.com/4dcu-be/BayesianSalesAnalysis
[Archon Arcana]: https://archonarcana.com/Main_Page
[multiple print runs]: https://www.reddit.com/r/KeyforgeGame/comments/bdwmk9/guide_for_distinguishing_print_runs/
[this podcast]: https://open.spotify.com/episode/7sGXnTsNKfnBkQyDD7Yepr
