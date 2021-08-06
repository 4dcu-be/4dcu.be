---
layout: post
title:  "Gwent: Pro Ladder Analysis and National Rankings"
byline: ""
date:   2020-09-01 12:00:00
author: Sebastian Proost
categories: programming games
tags:	python jupyter pandas gwent data-science
cover:  "/assets/posts/2020-09-01-GwentProRankAnalysis/gwent_pro_rank.jpg"
thumbnail: "/assets/images/thumbnails/gwent_pro_rank.jpg"
github: "https://github.com/4dcu-be/GwentRank"
---

Data for on players in Pro Ladder is released on [playgwent.com](https://masters.playgwent.com/en/), but it is limited.
You get the rank, the score, the country of origin and the number of matches played. Using some fairly basic data
analysis tricks there must be more we can do with these data! Using python we'll scrape data for the top 
[Gwent players on pro-ladder](https://masters.playgwent.com/en/rankings/masters-2/season-of-the-draconid/1/1) 
and calculate additional statistics about the current season, popularity of the game in different countries, players' 
efficiency, players national rank, ...

A jupyter notebook with all code can be found on [GitHub](https://github.com/4dcu-be/GwentRank) which you can explore
through [Binder](https://mybinder.org/v2/gh/4dcu-be/GwentRank/master?filepath=Gwent%20Stats.ipynb) without installing
anything. For those that want to check their own national rank or ladder efficiency index (and don't care about the 
code). Download links for the full tables discussed here (in Excel-format) are available here:

  * [Player Statistics](/assets/pages/gwent/player_stats.xlsx) : Player data for each season, with ladder efficiency and national rank added.
  * [Player Summaries](/assets/pages/gwent/player_summaries.xlsx) : Summary data for each player that made an appearance in pro rank. Includes number of appearances on
  the leaderboards, min and max MMR, best rank, best national rank, ...
  * [Seasonal summary](/assets/pages/gwent/seasonal_stats.xlsx) : Number of games played each season in Masters 2, minimum and maximum MMR as well as top 500,200 and 64 cutoffs.
  * [National Statistics](/assets/pages/gwent/national_stats.xlsx) : Data per country, number of pro players per million inhabitants, ...

**Update 04/08/2021:** Downloads are now linked to the [Gwent Pro Rank Data]({% link _pages/gwent_stats.md %}) page which will be updated more frequently.

**Update 12/03/2021:** All files were updated and now contain Season of the Wolf and Season of Love from Masters 3 (2021). 

**Update 03/09/2020:** Credit where credit is due! After putting this blog post up I found two articles by Lerio2 that
predate mine where he did the same analysis to check the popularity and rank countries (based on teams of 4 players). 
Though I did my analysis independently, he had the idea several months earlier and deserves full credit for that! 
You can read his articles, called Nations of Gwent, [here](https://teamlegacy.org/gwent-for-geeks-nations-of-gwent/) and [here](https://teamlegacy.org/gwent-for-geeks-nations-of-gwent-vol-2/)

## Getting the Data

Python has two powerful packages to scrape data from the web: the requests library to download data and BeautifulSoup
to parse the HTML that comes back and extract information. The tabular data from [playgwent.com](https://masters.playgwent.com/en/)
is pretty straightforward to parse. There is the rank, the player's handle, the number of matches played and their score
(which is called the Matchmaking Rating or MMR).

Furthermore, there is a flag icon indicating the country the player is
from. These icons have a class that contains the two letter code, which follows the official [ISO 3166 international
standard](https://www.iso.org/iso-3166-country-codes.html). 

```html
<i class="flag-icon flag-icon-pl"></i>
```

The two letter code can be easily extracted from the the html tag, while converting it to a human readable name can be
done in a few lines of code using the python library [pycountry](https://pypi.org/project/pycountry/). As shown in the
stub below, you can provide it with a two letter code (*pl* in the example below) and it will return all other names, including the
common name (*Poland* here). So after scraping the data, the pycountry library was used to get proper names for all
countries.

```python
import pycountry
pycountry.countries.get(alpha_2='pl')

# Output: 
# Country(alpha_2='PL', alpha_3='POL', name='Poland', numeric='616', official_name='Republic of Poland')
```
While reading the data we'll also keep track of which players were in the top 500 the season before (note that this
does require all seasons to be loaded and in orde). So we end up with a table (called full_df in the code), that looks 
like this:

{:.large-table .narrow-rows }
| rank |     name | country | matches |   mmr |          season | previous_top500 |
|-----:|---------:|--------:|--------:|------:|----------------:|----------------:|
|    1 | kolemoen | Germany |     431 | 10484 | M2_01 Wolf 2020 |              no |
|    2 |  kams134 |  Poland |     923 | 10477 | M2_01 Wolf 2020 |              no |
|    3 |  TailBot |  Poland |     538 | 10472 | M2_01 Wolf 2020 |              no |
|    4 |  Pajabol |  Poland |     820 | 10471 | M2_01 Wolf 2020 |              no |
|    5 |  Adzikov |  Poland |    1105 | 10442 | M2_01 Wolf 2020 |              no |


## Adding National Rank and Efficiency Statistics

The rank on playgwent.com is the global rank, adding a national rank can be done in a single line of code. The
`groupby` function in combination with the `rank` function does exactly what we want here.

```python
full_df['national_rank'] = full_df.groupby(['country','season'])["mmr"].rank("first", ascending=False)
```

In Gwent you need to play at least 25 games with four out of six factions. 
This will give you a base score, MMR, of 9600. Winning a game increases the MMR, depending on the current rank of your
opponent (usually about 7 points are gained) and losing costs you MMR points. The highest reached MMR per faction is 
summed up to get the final score. So with a higher win-rate, better scores can be obtained with fewer games. To find out
which players are more efficient in climbing (and arguably better at the game than others at the same MMR) we we take 
the MMR, subtract the base value (9600) and divide by the number of matches. However, as 
increasing the MMR score becomes progressively more difficult as players will face better opponents as they climb the
ladder, Lerio2 from Team Legacy proposed to divide by the square root of the number of matches. Their metric, the
[Ladder Efficiency Index](https://teamlegacy.org/2020/08/05/gwent-players-scores-and-efficiency-index/) or *LEI* is 
calculated here as well.

```python
full_df['efficiency'] = ((full_df['mmr']-9600))/full_df['matches']
full_df['lei'] = ((full_df['mmr']-9600))/np.sqrt(full_df['matches'])
```

Now our full dataframe has two additional columns one with the simple linear efficiency and one with Team Legacy's 
Ladder Efficiency Index.

{:.large-table .narrow-rows }
| rank |     name | country | matches |   mmr |          season | previous_top500 | national_rank | efficiency |       lei |
|-----:|---------:|--------:|--------:|------:|----------------:|----------------:|--------------:|-----------:|----------:|
|    1 | kolemoen | Germany |     431 | 10484 | M2_01 Wolf 2020 |              no |           1.0 |   2.051044 | 42.580782 |
|    2 |  kams134 |  Poland |     923 | 10477 | M2_01 Wolf 2020 |              no |           1.0 |   0.950163 | 28.866807 |
|    3 |  TailBot |  Poland |     538 | 10472 | M2_01 Wolf 2020 |              no |           2.0 |   1.620818 | 37.594590 |
|    4 |  Pajabol |  Poland |     820 | 10471 | M2_01 Wolf 2020 |              no |           3.0 |   1.062195 | 30.416639 |
|    5 |  Adzikov |  Poland |    1105 | 10442 | M2_01 Wolf 2020 |              no |           4.0 |   0.761991 | 25.329753 |

You can download the full table [here](/assets/posts/2020-09-01-GwentProRankAnalysis/player_stats.xlsx).

## Season Summary

About every month or so there is a new season in Gwent. Using the `groupby` function we can very quickly create a summary
how many games were played by the pro-ranked players (do note that only the 2860 best players are listed on the website).
We'll also add the cutoff values for rank 500, 200 and 64 as these are important thresholds for competitive players. 
Here the aggregate function `agg` is used in combination with NamedAgg to calculate all statistics in one go.

```python
per_season_df = full_df.groupby(['season']).agg(
    min_mmr     = pd.NamedAgg('mmr', 'min'),
    max_mmr     = pd.NamedAgg('mmr', 'max'),
    num_matches = pd.NamedAgg('matches', 'sum')
).reset_index()

top500_cutoffs = full_df[full_df['rank'] == 500][['season', 'mmr']].rename(columns={'mmr': 'top500_cutoff'})
top200_cutoffs = full_df[full_df['rank'] == 200][['season', 'mmr']].rename(columns={'mmr': 'top200_cutoff'})
top64_cutoffs  = full_df[full_df['rank'] == 64][['season', 'mmr']].rename(columns={'mmr': 'top64_cutoff'})

per_season_df = pd.merge(per_season_df, top500_cutoffs, on='season')
per_season_df = pd.merge(per_season_df, top200_cutoffs, on='season')
per_season_df = pd.merge(per_season_df, top64_cutoffs, on='season')
per_season_df
``` 
The full output from this you can see below:

{:.large-table .narrow-rows }
|              season | min_mmr | max_mmr | num_matches | top500_cutoff | top200_cutoff | top64_cutoff |
|--------------------:|--------:|--------:|------------:|--------------:|--------------:|-------------:|
|     M2_01 Wolf 2020 |    2407 |   10484 |      699496 |          9749 |          9872 |        10061 |
|     M2_02 Love 2020 |    7776 |   10537 |      769358 |          9832 |          9952 |        10117 |
|     M2_03 Bear 2020 |    9427 |   10669 |      862678 |          9867 |          9995 |        10204 |
|      M2_04 Elf 2020 |    9666 |   10751 |     1004830 |          9952 |         10087 |        10293 |
|    M2_05 Viper 2020 |    9635 |   10622 |      859640 |          9910 |         10028 |        10255 |
|    M2_06 Magic 2020 |    9624 |   10597 |      793401 |          9896 |         10002 |        10191 |
|  M2_07 Griffin 2020 |    9698 |   10667 |      996742 |          9978 |         10100 |        10289 |
| M2_08 Draconid 2020 |    9666 |   10546 |      838212 |          9946 |         10061 |        10246 |

The number of matches played by the top players is an indication how many people are playing the game, as more
active players would require more games to be played to climb pro ladder. You can see that the popularity peaked during
the Season of the Elves. During this season also some new leader abilities
were introduced, so the fresh content could also to players return to the game. A similar increase in matches can be 
seen in the Season of the Griffin with the release of new cards through the Master Mirror expansion. So it seems that 
new content is a good incentive for players to play more, and spark a fiercer competition.

You can download the full table [here](/assets/posts/2020-09-01-GwentProRankAnalysis/seasonal_stats.xlsx).

## Where is Gwent Being Played

So using the `groupby` function in combination with the `agg` we can very quickly count how many pro players there are
per country. We can then combine this with the population size of each country (and somewhat up-to-date list can be found
[here](https://www.kaggle.com/erikbruin/countries-of-the-world-iso-codes-and-population/data#)). By dividing the number
of players in pro-ladder by the number of inhabitants (in millions) we can get the number of pro players per capita.

{:.large-table .narrow-rows }
|              season |            country | total_matches | num_players | pro_players_per_million | matches_per_player |
|--------------------:|-------------------:|--------------:|------------:|------------------------:|-------------------:|
| M2_08 Draconid 2020 |             Poland |         72225 |         267 |                7.047129 |         270.505618 |
| M2_08 Draconid 2020 |            Estonia |          1726 |           7 |                5.280436 |         246.571429 |
| M2_08 Draconid 2020 | Russian Federation |        195905 |         673 |                4.613626 |         291.092125 |
| M2_08 Draconid 2020 |            Belarus |         10260 |          39 |                4.125931 |         263.076923 |
| M2_08 Draconid 2020 |            Ukraine |         52333 |         162 |                3.682351 |         323.043210 |

The top 5 countries is comprised out of Eastern European Countries, which is no surprise as the company that created
Gwent is based in Poland and The Witcher lore has been created based on Slavic myths and legends. Iceland, Finland, 
Hong Kong, Malta and Croatia complete the top 10. These are all relatively small countries, so a single player 
making it up to Pro Rank boosts them up in the ranking. 

You can download the full table, which includes data for all seasons and countries [here](/assets/posts/2020-09-01-GwentProRankAnalysis/national_stats.xlsx).

## Which Country has the best Gwent Team

Now we know where the most pro players are per capita, but what if countries were able to send a team of three 
e-athletes to a world championship? Which countries would do best with their team of three pro players. To this end
all countries with three or more players were selected, and the top 3 players for each of those countries picked.
Next, the average MMR and total MMR for those players, was calculated as well as the efficiency to climb and the rank
for each country. The code is up on GitHub for those interested, but also here it is a simple matter of filtering and
grouping data using built-in pandas functions.

The results for Season of the Draconid are shown below. It seems that China has the best team of three this season
followed by Russia and Poland.

{:.large-table .narrow-rows }
|              season |            country |     mean_mmr | total_mmr | mean_matches_per_player | total_matches | nation_rank | efficiency |       lei |
|--------------------:|-------------------:|-------------:|----------:|------------------------:|--------------:|------------:|-----------:|----------:|
| M2_08 Draconid 2020 |              China | 10489.333333 |     31468 |                     409 |          1227 |           1 |   2.174409 | 43.974703 |
| M2_08 Draconid 2020 | Russian Federation | 10479.666667 |     31439 |                     636 |          1908 |           2 |   1.383124 | 34.881052 |
| M2_08 Draconid 2020 |             Poland | 10439.333333 |     31318 |                     657 |          1971 |           3 |   1.277524 | 32.745512 |

## Player Summaries

For players that made it up to Pro Rank during multiple seasons we'll quickly generate a summary. Again the *groupby* and
*agg* function are being leveraged again to group things and get the summary statistics. We'll count the number of 
appearnaces on pro ladder, the min, mean, max MMR score. Average number of matches and total number of matches as well as
the best global and national ranks.

This can give you a quick impression of all the data available on a player. Here you can see the output from myself (handle *sepro*).

{:.large-table .narrow-rows }
|  name | country | appearances | min_mmr | mean_mmr | max_mmr | mean_matches | num_matches | best_rank | best_national_rank |
|------:|--------:|------------:|--------:|---------:|--------:|-------------:|------------:|----------:|-------------------:|
| sepro | Belgium |           3 |    9746 |     9782 |    9820 |          243 |         728 |      1138 |                2.0 |

You can download the full table [here](/assets/posts/2020-09-01-GwentProRankAnalysis/player_summaries.xlsx) to find your
own or your favorite players stats.

## Conclusion

Initially, I set out to get players national ranks. When you are from a small country, just making it to 
Pro Rank will likely give you bragging rights about being in the top 3 of your country. Though with some fairly basic
data science you can very quickly get a lot more details on various aspects of the game.

This type of project I would really recommend for people starting out with programming. Find a topic you like and write
some code to get some data about it, do some analysis and generate a few plots.
