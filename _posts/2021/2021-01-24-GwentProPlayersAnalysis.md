---
layout: post
title:  "Gwent: How Many Pro Players Are Out There ?"
byline: ""
date: 2021-01-24 12:00:00
author: Sebastian Proost
categories: programming games
tags:	python jupyter pandas gwent 
cover:  "/assets/posts/2020-09-01-GwentProRankAnalysis/gwent_pro_rank.jpg"
thumbnail: "/assets/images/thumbnails/gwent_pro_rank.jpg"
github: "https://github.com/4dcu-be/GwentRank"
---

I noticed that some people ended up on my blog by searching Google for "gwent how many players in pro rank". They would
have been disappointed as there is no answer to that question yet, let's see if we can change that! In this post
using data science and web scraping, we'll try to figure that out exactly how many people can be found on Gwent's Pro
Ladder.

In-game Gwent only shows the top 1144 players for the current season, which is convenient but nowhere near the complete
list. On the [Gwent Masters] website you can pull up the rankings of all Pro Players up to rank 2860, ... more but still
not complete ... so I'll explore three ways to get an idea of the total number of Pro Players out there.

If you are just interested in the number of players, [click here](#method-3-hammering-the-gwent-masters-website) to
jump right to the numbers you are looking for.

## Method 1: Being the Lowest Ranked Player

One trick you could use is ending in the top 500 one season, so you won't drop out of Pro Rank. During the next season
you play and lose one game, only one! This way you will have a grand total of 96 MMR and should be the lowest ranked player in 
the game. At the end of the season, check your rank in-game and you'll know how many players are on Pro Ladder as
all of them will have an equal or better rank.

Problem, I'm not good enough to fight my way up to the top 500 to try this... so I'll have to resort to a 
different approach as my Gwent skills won't get me there.

## Method 2: Estimating From a Partial Distribution

Imagine for a moment a yearly running competition with about two thousand participants running a 15K. The local newspaper
prints the full list of participants with their times the following week. However, as the competition grows more and more
popular, it attracts more and more participants making it not feasible to publish the full list anymore. So to save ink
and paper now they only publish those a list of those who finished in under one hour...

Now if we still have access to a full list from a few years before, we can figure out which fraction of participants
actually manages to run a 15K in under an hour. We can use this approach to estimate how many Pro Players there are in
Gwent.

Here it is important to note that during the Season of the Wolf in 2020 there were very few players in Pro Rank as you
can see by the MMR score by the player at rank 2860. While there are probably a few more out there than 2860, it won't
be much more given the low MMR required to be listed on the website.

{:.narrow-rows }
|        Season        | Min MMR (top 2860) |
|:--------------------:|:------------------:|
| **M2_01 Wolf 2020**  | **2407**           |
| M2_02 Love 2020      | 7776               |
| M2_03 Bear 2020      | 9427               |
| M2_04 Elf 2020       | 9666               |
| M2_05 Viper 2020     | 9635               |
| M2_06 Magic 2020     | 9624               |
| M2_07 Griffin 2020   | 9698               |
| M2_08 Draconid 2020  | 9666               |
| M2_09 Dryad 2020     | 9678               |
| M2_10 Cat 2020       | 9703               |
| M2_11 Mahakam 2020   | 9706               |
| M2_12 Wild Hunt 2020 | 9756               |

Based on the scores, we can determine the percentile rank for each score, that is the percentage of players that had
that score or less. A few percentile ranks are shown below, we can see that
in the first season of M2 half of the players (50th percentile) got a score above 9051 MMR, only one in four (75th
percentile) got 9685 and those with a score of 9810 are in the 90th percentile, indication only the best 10% players
get that score or above.

{:.narrow-rows }
| Percentile |  MMR |
|:----------:|:----:|
| 50         | 9051 |
| 75         | 9685 |
| 90         | 9810 |

So based on these we can determine the fraction of players that can get above 9700, 9800, 9900, 10000 and, 10100, 
next we look in other seasons how many players actually got above that score. Using these two number it is pretty
easy to calculate the total number of players you would expect! If you are interested in the code, everything is 
available on [GitHub]. The results are shown below:

{:.narrow-rows }
|        Season        | Estimate (low) | Estimate (high) | Estimate (mean) |
|:--------------------:|:--------------:|:---------------:|:---------------:|
| M2_01 Wolf 2020      | 2900           | 3600            | 3118            |
| M2_02 Love 2020      | 4567           | 7100            | 5620            |
| M2_03 Bear 2020      | 6036           | 10300           | 7329            |
| M2_04 Elf 2020       | 9927           | 18000           | 12319           |
| M2_05 Viper 2020     | 7767           | 11400           | 9372            |
| M2_06 Magic 2020     | 6800           | 9800            | 8320            |
| M2_07 Griffin 2020   | 12836          | 19900           | 14683           |
| M2_08 Draconid 2020  | 9567           | 13300           | 11186           |
| M2_09 Dryad 2020     | 9733           | 12580           | 11219           |
| M2_10 Cat 2020       | 12800          | 14620           | 13774           |
| M2_11 Mahakam 2020   | 12995          | 18900           | 16042           |
| M2_12 Wild Hunt 2020 | 13000          | 36000           | 23085           |


## Method 3: Hammering the Gwent Masters Website

While on the Gwent Masters website only the top 2860 players are listed, if you search for a specific player you'll
find their results for that season. Even if they are below rank 2860! This got me thinking ... If we get a list of 
names from all players that were in the top 2860 in any season during Masters 2, we could brute-force check for each name
and each season the rank of that player. If we are lucky there are a few top 500 players that remained in Pro Rank but
didn't play a lot of games the next season, so we can get some data on low ranks... it worked ! It did take several days
and over 12000 HTTP requests putting some strain on CDPR's servers, but the script pulled data for a lot more players 
than were listed ... including at least one player with the lowest possible MMR of 96 each season! These numbers should
be very close to the exact number of Pro Players each season.

{:.narrow-rows }
|        Season        | Players       |
|:--------------------:|:-------------:|
| M2_01 Wolf 2020      | 2997          |
| M2_02 Love 2020      | 4883          |
| M2_03 Bear 2020      | 6632          |
| M2_04 Elf 2020       | 10209         |
| M2_05 Viper 2020     | 10079         |
| M2_06 Magic 2020     | 9919          |
| M2_07 Griffin 2020   | 14791         |
| M2_08 Draconid 2020  | 13800         |
| M2_09 Dryad 2020     | 14554         |
| M2_10 Cat 2020       | 16011         |
| M2_11 Mahakam 2020   | 16752         |
| M2_12 Wild Hunt 2020 | 22464         |

## Did the estimates work ?

While the last method makes the estimates obsolete, I was curious to know how well the method worked. A quick
scatter plot with a linear regression shows the estimates are quite good. So while it is not perfect, it doesn't require
6-7 hours per season to scrape the required data. That makes it valuable to quickly estimate numbers before going all
out with the scraping.

![A quick check how well the estimates worked](/assets/posts/2021-01-24-GwentProPlayersAnalysis/estimate_check.png)

## Conclusion

There you have it, the total number of Pro Players each season! It is incredible to see that the total number of Pro
Players increased nearly 10 fold over the course of a single year (do note that the last season was exceptionally long
which allowed more players to reach Pro Rank). While Gwent had a rough start in 2021, with many
game breaking bugs creeping in the game, I hope it will continue to grow. This also highlights that if you want to
get those hard to get titles which are awarded to those that finish in the Top 500 or even the Top 200 are increasingly
difficult to obtain.


[Gwent Masters]: https://masters.playgwent.com/en/
[GitHub]: https://github.com/4dcu-be/GwentRank
