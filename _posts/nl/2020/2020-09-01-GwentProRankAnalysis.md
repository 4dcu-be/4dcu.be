---
layout: post
title:  "Gwent: analyse van de Pro Ladder en nationale ranglijsten"
byline: ""
description: "Gegevens van de Gwent Pro Ladder scrapen met Python en pandas om nationale ranglijsten, efficiëntie op de ladder, populariteit per land en seizoensstatistieken te berekenen."
date:   2020-09-01 12:00:00
author: Sebastian Proost
post_id: gwent-pro-rank-analysis
categories: programming games
tags:	python jupyter pandas gwent data-science
cover:  "/assets/posts/2020-09-01-GwentProRankAnalysis/gwent_pro_rank.jpg"
thumbnail: "/assets/images/thumbnails/gwent_pro_rank.jpg"
github: "https://github.com/4dcu-be/GwentRank"
---

Op [playgwent.com](https://masters.playgwent.com/en/) worden gegevens over spelers in de Pro Ladder gepubliceerd, maar die zijn beperkt.
Je krijgt de rang, de score, het land van herkomst en het aantal gespeelde wedstrijden. Met enkele vrij eenvoudige technieken voor
gegevensanalyse moet er meer uit deze gegevens te halen zijn! Met Python scrapen we gegevens voor de beste 
[Gwent-spelers op de Pro Ladder](https://masters.playgwent.com/en/rankings/masters-2/season-of-the-draconid/1/1) 
en berekenen we bijkomende statistieken over het huidige seizoen, de populariteit van het spel in verschillende landen, de 
efficiëntie en nationale rang van spelers, ...

Een Jupyter-notebook met alle code staat op [GitHub](https://github.com/4dcu-be/GwentRank). Via
[Binder](https://mybinder.org/v2/gh/4dcu-be/GwentRank/master?filepath=Gwent%20Stats.ipynb) kun je het verkennen zonder iets te installeren.
Wie alleen zijn eigen nationale rang of ladder-efficiëntie-index wil controleren en niet in de code geïnteresseerd is, vindt hier downloadlinks
voor de volledige tabellen uit deze post (in Excel-formaat):

  * [Spelerstatistieken](/assets/pages/gwent/player_stats.xlsx): gegevens per speler en seizoen, aangevuld met ladder-efficiëntie en nationale rang.
  * [Spelersoverzichten](/assets/pages/gwent/player_summaries.xlsx): samenvattende gegevens voor elke speler die in Pro Rank verscheen. Bevat het aantal vermeldingen op
  de ranglijsten, minimale en maximale MMR, beste rang, beste nationale rang, ...
  * [Seizoensoverzicht](/assets/pages/gwent/seasonal_stats.xlsx): aantal gespeelde wedstrijden per seizoen in Masters 2, minimale en maximale MMR en de drempels voor de top 500, 200 en 64.
  * [Nationale statistieken](/assets/pages/gwent/national_stats.xlsx): gegevens per land, aantal profspelers per miljoen inwoners, ...

**Update 04/08/2021:** Downloads verwijzen nu naar de pagina [Gwent Pro Rank Data]({% link _pages/gwent_stats.md %}), die vaker wordt bijgewerkt.

**Update 12/03/2021:** Alle bestanden werden bijgewerkt en bevatten nu Season of the Wolf en Season of Love uit Masters 3 (2021). 

**Update 03/09/2020:** Ere wie ere toekomt! Nadat ik deze blogpost online zette, vond ik twee artikels van Lerio2 die
ouder waren dan het mijne en waarin hij dezelfde analyse uitvoerde om de populariteit te onderzoeken en landen te rangschikken (op basis van teams van vier spelers). 
Hoewel ik mijn analyse onafhankelijk uitvoerde, had hij het idee enkele maanden eerder en verdient hij daarvoor alle erkenning! 
Je kunt zijn artikels, Nations of Gwent, [hier](https://web.archive.org/web/20210415222805/https://teamlegacy.org/gwent-for-geeks-nations-of-gwent/) en [hier](https://web.archive.org/web/20210416003340/https://teamlegacy.org/gwent-for-geeks-nations-of-gwent-vol-2/) lezen. 
(06/08/2026 - teamlegacy.org is niet langer online; deze links verwijzen naar gearchiveerde kopieën)

## De gegevens verzamelen

Python heeft twee krachtige pakketten om gegevens van het web te scrapen: de requests-bibliotheek om gegevens te downloaden en BeautifulSoup
om de teruggestuurde HTML te verwerken en er informatie uit te halen. De tabelgegevens van [playgwent.com](https://masters.playgwent.com/en/)
zijn vrij eenvoudig te verwerken. Ze bevatten de rang, de spelersnaam, het aantal gespeelde wedstrijden en de score
(die Matchmaking Rating of MMR wordt genoemd).

Daarnaast geeft een vlagpictogram aan uit welk land de speler
komt. Deze pictogrammen hebben een klasse met de tweelettercode volgens de officiële internationale [ISO 3166-
standaard](https://www.iso.org/iso-3166-country-codes.html). 

```html
<i class="flag-icon flag-icon-pl"></i>
```

De tweelettercode kan eenvoudig uit de HTML-tag worden gehaald. Met de Python-bibliotheek [pycountry](https://pypi.org/project/pycountry/) zet je die in enkele regels code om naar een leesbare naam. Zoals in het
voorbeeld hieronder geef je een tweelettercode op (*pl*) en krijg je alle andere namen terug, waaronder de
gebruikelijke naam (*Poland*). Na het scrapen gebruikte ik pycountry dus om correcte namen voor alle
landen te verkrijgen.

```python
import pycountry
pycountry.countries.get(alpha_2='pl')

# Output: 
# Country(alpha_2='PL', alpha_3='POL', name='Poland', numeric='616', official_name='Republic of Poland')
```
Tijdens het inlezen houden we ook bij welke spelers het vorige seizoen in de top 500 stonden (hiervoor
moeten wel alle seizoenen in de juiste volgorde geladen zijn). Zo krijgen we een tabel, in de code full_df genoemd, die er 
als volgt uitziet:

{:.large-table .narrow-rows }
| rank |     name | country | matches |   mmr |          season | previous_top500 |
|-----:|---------:|--------:|--------:|------:|----------------:|----------------:|
|    1 | kolemoen | Germany |     431 | 10484 | M2_01 Wolf 2020 |              no |
|    2 |  kams134 |  Poland |     923 | 10477 | M2_01 Wolf 2020 |              no |
|    3 |  TailBot |  Poland |     538 | 10472 | M2_01 Wolf 2020 |              no |
|    4 |  Pajabol |  Poland |     820 | 10471 | M2_01 Wolf 2020 |              no |
|    5 |  Adzikov |  Poland |    1105 | 10442 | M2_01 Wolf 2020 |              no |


## Nationale rang en efficiëntiestatistieken toevoegen

De rang op playgwent.com is de wereldwijde rang. Een nationale rang voeg je met één regel code toe. De
functie `groupby` in combinatie met `rank` doet precies wat we nodig hebben.

```python
full_df['national_rank'] = full_df.groupby(['country','season'])["mmr"].rank("first", ascending=False)
```

In Gwent moet je minstens 25 wedstrijden spelen met vier van de zes facties. 
Dat levert een basisscore, MMR, van 9600 op. Een overwinning verhoogt de MMR afhankelijk van de huidige rang van je
tegenstander (meestal met ongeveer 7 punten), terwijl een nederlaag MMR-punten kost. De hoogste behaalde MMR per factie wordt 
opgeteld tot de eindscore. Met een hoger winstpercentage kun je dus met minder wedstrijden een betere score behalen. Om te bepalen
welke spelers efficiënter klimmen (en mogelijk beter zijn dan anderen met dezelfde MMR), nemen we 
de MMR, trekken we de basiswaarde 9600 af en delen we door het aantal wedstrijden. Omdat 
een hogere MMR steeds moeilijker wordt naarmate spelers sterkere tegenstanders treffen op de
ladder, stelde Lerio2 van Team Legacy voor om te delen door de vierkantswortel van het aantal wedstrijden. Hun maatstaf, de
[Ladder Efficiency Index](https://web.archive.org/web/20201001135246/https://teamlegacy.org/2020/08/05/gwent-players-scores-and-efficiency-index/) of *LEI*, wordt 
hier eveneens berekend.

```python
full_df['efficiency'] = ((full_df['mmr']-9600))/full_df['matches']
full_df['lei'] = ((full_df['mmr']-9600))/np.sqrt(full_df['matches'])
```

Ons volledige dataframe heeft nu twee extra kolommen: één met de eenvoudige lineaire efficiëntie en één met Team Legacy's 
Ladder Efficiency Index.

{:.large-table .narrow-rows }
| rank |     name | country | matches |   mmr |          season | previous_top500 | national_rank | efficiency |       lei |
|-----:|---------:|--------:|--------:|------:|----------------:|----------------:|--------------:|-----------:|----------:|
|    1 | kolemoen | Germany |     431 | 10484 | M2_01 Wolf 2020 |              no |           1.0 |   2.051044 | 42.580782 |
|    2 |  kams134 |  Poland |     923 | 10477 | M2_01 Wolf 2020 |              no |           1.0 |   0.950163 | 28.866807 |
|    3 |  TailBot |  Poland |     538 | 10472 | M2_01 Wolf 2020 |              no |           2.0 |   1.620818 | 37.594590 |
|    4 |  Pajabol |  Poland |     820 | 10471 | M2_01 Wolf 2020 |              no |           3.0 |   1.062195 | 30.416639 |
|    5 |  Adzikov |  Poland |    1105 | 10442 | M2_01 Wolf 2020 |              no |           4.0 |   0.761991 | 25.329753 |

Je kunt de volledige tabel [hier](/assets/posts/2020-09-01-GwentProRankAnalysis/player_stats.xlsx) downloaden.

## Seizoensoverzicht

Ongeveer elke maand begint er een nieuw seizoen in Gwent. Met `groupby` maken we snel een overzicht
van het aantal wedstrijden dat spelers in Pro Rank speelden (merk op dat alleen de beste 2860 spelers op de website staan).
We voegen ook de drempelwaarden voor rang 500, 200 en 64 toe, want die zijn belangrijk voor competitieve spelers. 
Hier gebruiken we de aggregatiefunctie `agg` samen met NamedAgg om alle statistieken in één keer te berekenen.

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
De volledige uitvoer zie je hieronder:

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

Het aantal wedstrijden van de beste spelers geeft een indicatie van hoeveel mensen het spel spelen, want meer
actieve spelers vereisen meer wedstrijden om de Pro Ladder te beklimmen. Je ziet dat de populariteit piekte tijdens
Season of the Elves. In dat seizoen werden ook enkele nieuwe leidervaardigheden
geïntroduceerd, waardoor de verse inhoud spelers mogelijk deed terugkeren. Een vergelijkbare stijging in wedstrijden is 
zichtbaar in Season of the Griffin, toen de Master Mirror-uitbreiding nieuwe kaarten uitbracht. Nieuwe inhoud lijkt dus 
een goede stimulans om meer te spelen en de competitie aan te wakkeren.

Je kunt de volledige tabel [hier](/assets/posts/2020-09-01-GwentProRankAnalysis/seasonal_stats.xlsx) downloaden.

## Waar wordt Gwent gespeeld?

Met `groupby` in combinatie met `agg` tellen we snel hoeveel profspelers er
per land zijn. Vervolgens combineren we dat met het bevolkingsaantal van elk land (een enigszins recente lijst staat
[hier](https://www.kaggle.com/erikbruin/countries-of-the-world-iso-codes-and-population/data#)). Door het aantal
spelers in Pro Rank te delen door het aantal inwoners in miljoenen, krijgen we het aantal profspelers per hoofd van de bevolking.

{:.large-table .narrow-rows }
|              season |            country | total_matches | num_players | pro_players_per_million | matches_per_player |
|--------------------:|-------------------:|--------------:|------------:|------------------------:|-------------------:|
| M2_08 Draconid 2020 |             Poland |         72225 |         267 |                7.047129 |         270.505618 |
| M2_08 Draconid 2020 |            Estonia |          1726 |           7 |                5.280436 |         246.571429 |
| M2_08 Draconid 2020 | Russian Federation |        195905 |         673 |                4.613626 |         291.092125 |
| M2_08 Draconid 2020 |            Belarus |         10260 |          39 |                4.125931 |         263.076923 |
| M2_08 Draconid 2020 |            Ukraine |         52333 |         162 |                3.682351 |         323.043210 |

De top vijf bestaat uit Oost-Europese landen. Dat verbaast niet: het bedrijf achter
Gwent is in Polen gevestigd en de wereld van The Witcher is gebaseerd op Slavische mythen en legendes. IJsland, Finland, 
Hongkong, Malta en Kroatië vervolledigen de top tien. Dit zijn allemaal relatief kleine landen, zodat één speler 
die Pro Rank bereikt hen flink hoger in de ranglijst brengt.

Je kunt de volledige tabel met gegevens voor alle seizoenen en landen [hier](/assets/posts/2020-09-01-GwentProRankAnalysis/national_stats.xlsx) downloaden.

## Welk land heeft het beste Gwent-team?

Nu weten we waar de meeste profspelers per hoofd van de bevolking wonen, maar wat als landen een team van drie 
e-sporters naar een wereldkampioenschap mochten sturen? Welke landen zouden met hun drie profspelers het beste presteren? Hiervoor
selecteerde ik alle landen met minstens drie spelers en koos ik de drie beste spelers uit elk land.
Daarna berekende ik hun gemiddelde en totale MMR, de efficiëntie waarmee ze klimmen en de rang
van elk land. De code staat voor geïnteresseerden op GitHub, maar ook hier gaat het eenvoudigweg om gegevens filteren en
groeperen met ingebouwde pandas-functies.

De resultaten voor Season of the Draconid staan hieronder. China lijkt dit seizoen het beste team van drie te hebben,
gevolgd door Rusland en Polen.

{:.large-table .narrow-rows }
|              season |            country |     mean_mmr | total_mmr | mean_matches_per_player | total_matches | nation_rank | efficiency |       lei |
|--------------------:|-------------------:|-------------:|----------:|------------------------:|--------------:|------------:|-----------:|----------:|
| M2_08 Draconid 2020 |              China | 10489.333333 |     31468 |                     409 |          1227 |           1 |   2.174409 | 43.974703 |
| M2_08 Draconid 2020 | Russian Federation | 10479.666667 |     31439 |                     636 |          1908 |           2 |   1.383124 | 34.881052 |
| M2_08 Draconid 2020 |             Poland | 10439.333333 |     31318 |                     657 |          1971 |           3 |   1.277524 | 32.745512 |

## Spelersoverzichten

Voor spelers die tijdens meerdere seizoenen Pro Rank bereikten, maken we snel een overzicht. Opnieuw gebruiken we *groupby* en
*agg* om gegevens te groeperen en samenvattende statistieken te berekenen. We tellen het aantal 
vermeldingen op de Pro Ladder, de minimale, gemiddelde en maximale MMR-score, het gemiddelde en totale aantal wedstrijden en
de beste wereldwijde en nationale rang.

Zo krijg je snel een beeld van alle beschikbare gegevens over een speler. Hier zie je mijn eigen uitvoer (spelersnaam *sepro*).

{:.large-table .narrow-rows }
|  name | country | appearances | min_mmr | mean_mmr | max_mmr | mean_matches | num_matches | best_rank | best_national_rank |
|------:|--------:|------------:|--------:|---------:|--------:|-------------:|------------:|----------:|-------------------:|
| sepro | Belgium |           3 |    9746 |     9782 |    9820 |          243 |         728 |      1138 |                2.0 |

Je kunt de volledige tabel [hier](/assets/posts/2020-09-01-GwentProRankAnalysis/player_summaries.xlsx) downloaden om de statistieken van jezelf
of je favoriete spelers op te zoeken.

## Conclusie

Aanvankelijk wilde ik de nationale rang van spelers berekenen. Kom je uit een klein land, dan geeft alleen al het bereiken van 
Pro Rank je waarschijnlijk het recht om op te scheppen dat je tot de top drie van je land behoort. Met vrij eenvoudige
datawetenschap haal je echter snel veel meer details uit verschillende aspecten van het spel.

Ik raad dit soort project echt aan voor mensen die leren programmeren. Zoek een onderwerp dat je leuk vindt, schrijf
wat code om er gegevens over te verzamelen, voer een analyse uit en maak enkele grafieken.
