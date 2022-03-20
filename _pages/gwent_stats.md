---
layout: page
title: "Gwent Pro Rank Stats"
byline: "one stop shop for up-to-date Gwent data"
permalink: /gwent/
main_nav: false
cover:  "/assets/posts/2020-09-01-GwentProRankAnalysis/gwent_pro_rank.jpg"
include_sticker: false
custom_js:
  - vega.min
  - vega-lite.min
  - vega-embed.min
  - justcharts
---

Want some up-to-date date from previous Gwent posts? Look no further, here the most important bits of data are
collected! (*last update: 20/03/2022*)

## How many Pro Rank players are there ?

<vegachart schema-url="{{ site.baseurl }}/assets/pages/gwent/pro_player_chart.json" style="width: 100%"></vegachart>

At the end of each season the website can be scraped to figure out how many Pro Ranked players there were (described in
[this post]({% post_url 2021/2021-01-24-GwentProPlayersAnalysis %}). Note that longer seasons typically have more
players reaching Pro ladder than shorter seasons.

## How many players are there on regular ladder ?

We don't know, but **at least 100 000**.

Recently I've played very little, dropping quite a bit in rank. After playing one game my position on regular ladder
was 100 001st. A few more games and this was still the case, only when hitting 300+ MMR my position started to improve.
Though this suggests the client shows position 100 001 for all players outside the top 100k. So we really don't know 
how many players there are in total, but we can say at least 100 000 people play a few games a month.

## How popular is Gwent ?

<vegachart schema-url="{{ site.baseurl }}/assets/pages/gwent/popularity_chart.json" style="width: 100%"></vegachart>

As the number of Pro Ranked players depends on the length of the season, a better metric is how many players reach 
Pro Rank on an average day. This gives an indication how many people are playing and hence how popular Gwent is.

## Downloads

  * [Player Statistics](/assets/pages/gwent/player_stats.xlsx) : Player data for each season, with ladder efficiency and national rank added.
  * [Player Summaries](/assets/pages/gwent/player_summaries.xlsx) : Summary data for each player that made an appearance in pro rank. Includes number of appearances on
  the leaderboards, min and max MMR, best rank, best national rank, ...
  * [Seasonal summary](/assets/pages/gwent/seasonal_stats.xlsx) : Number of games played each season in Masters 2, minimum and maximum MMR as well as top 500,200 and 64 cutoffs.
  * [National Statistics](/assets/pages/gwent/national_stats.xlsx) : Data per country, number of pro players per million inhabitants, ...

## Read more...

If you want more information or check how these graphs were generated, relevant posts are linked below.

  * [Gwent Popularity](https://teambanditgang.com/gwent-popularity/)
  * [Gwent: How Many Pro Players Are Out There ?]({% post_url 2021/2021-01-24-GwentProPlayersAnalysis %})
  * An Agent Based Model to look at Gwent Pro Ladder. [Part 1]({% post_url 2020/2020-11-11-Gwent-Pro-Rank-ABM %}) and [part 2]({% post_url 2020/2020-11-11-Gwent-Pro-Rank-ABM_2 %})
  * [Climbing Pro Ladder: Grind vs Skill](https://teambanditgang.com/climbing-pro-ladder-grind-vs-skill/)
  * [Gwent: Pro Ladder Analysis and National Rankings]({% post_url 2020/2020-09-01-GwentProRankAnalysis %})

There is also a ton of information in other places:

  * [GwentData](https://www.gwentdata.com/): Win rates per faction during the season (near real-time)
  * [Team Legacy](https://teamlegacy.org/tag/gwent/): Lerio2's analyses and articles
