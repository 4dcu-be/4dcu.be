---
layout: post
title:  "Gwent: hoeveel Pro Players zijn er?"
byline: ""
description: "Met Python, webscraping en datawetenschap schatten hoeveel spelers op Gwents Pro Ladder staan, via drie methodes om ze te tellen."
date: 2021-01-24 12:00:00
author: Sebastian Proost
post_id: gwent-pro-players-analysis
categories: programming games
tags:	python jupyter pandas gwent 
cover:  "/assets/posts/2020-09-01-GwentProRankAnalysis/gwent_pro_rank.jpg"
thumbnail: "/assets/images/thumbnails/gwent_pro_rank.jpg"
github: "https://github.com/4dcu-be/GwentRank"
---

Ik merkte dat sommige mensen via een Google-zoekopdracht naar "gwent how many players in pro rank" op mijn blog
terechtkwamen. Ze zullen teleurgesteld zijn geweest, want tot nu toe stond het antwoord op die vraag er niet. Eens
kijken of we daar iets aan kunnen doen! In deze post proberen we met datawetenschap en webscraping exact te achterhalen
hoeveel mensen er op Gwents Pro Ladder staan.

In Gwent zelf worden voor het huidige seizoen alleen de beste 1144 spelers getoond. Dat is handig, maar lang niet de
volledige lijst. Op de website van [Gwent Masters] kun je de rangschikking van alle Pro Players tot en met plaats 2860
opvragen ... meer, maar nog altijd niet volledig ... Daarom onderzoek ik drie manieren om een beeld te krijgen van het
totale aantal Pro Players.

Ben je alleen geïnteresseerd in het aantal spelers, [klik dan hier](#methode-3-de-website-van-gwent-masters-bestoken) om
meteen naar de gezochte cijfers te springen.

## Methode 1: de laagst gerangschikte speler zijn

Een truc die je zou kunnen gebruiken, is in één seizoen bij de beste 500 eindigen, zodat je niet uit Pro Rank zakt. In
het volgende seizoen speel en verlies je één spel, en echt maar één! Zo heb je in totaal 96 MMR en zou je de laagst
gerangschikte speler in het spel moeten zijn. Kijk aan het einde van het seizoen in het spel naar je positie en je weet
hoeveel spelers er op Pro Ladder staan, want ze hebben allemaal dezelfde of een betere positie.

Probleem: ik ben niet goed genoeg om me naar de beste 500 te knokken en dit uit te proberen ... Ik moet dus een andere
aanpak zoeken, want met mijn Gwent-vaardigheden kom ik er niet.

## Methode 2: schatten op basis van een gedeeltelijke verdeling

Stel je even een jaarlijkse loopwedstrijd met ongeveer tweeduizend deelnemers op de 15 km voor. De week nadien drukt
de lokale krant de volledige deelnemerslijst met hun tijden af. Maar naarmate de wedstrijd populairder wordt, trekt ze
steeds meer deelnemers aan en wordt het onmogelijk om de volledige lijst nog te publiceren. Om inkt en papier te
besparen, publiceren ze nu dus alleen nog een lijst van de lopers die binnen het uur finishten ...

Als we nog toegang hebben tot een volledige lijst van enkele jaren eerder, kunnen we bepalen welk aandeel deelnemers
erin slaagt om 15 km binnen het uur te lopen. Die aanpak kunnen we gebruiken om te schatten hoeveel Pro Players er in
Gwent zijn.

Hierbij is het belangrijk op te merken dat er tijdens het Season of the Wolf in 2020 heel weinig spelers in Pro Rank
waren. Dat zie je aan de MMR-score van de speler op plaats 2860. Er zijn waarschijnlijk nog wat meer spelers dan die
2860, maar gezien de lage MMR die nodig is om op de website te staan, zullen het er niet veel meer zijn.

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

Op basis van de scores kunnen we voor elke score de percentielrang bepalen: het percentage spelers dat die score of
minder behaalde. Hieronder zie je enkele percentielrangen. In het eerste seizoen van M2 behaalde de helft van de spelers
(het 50e percentiel) een score boven 9051 MMR, slechts één op vier (het 75e percentiel) haalde 9685, en spelers met een
score van 9810 zitten in het 90e percentiel. Dat betekent dat alleen de beste 10% die score of meer behaalt.

{:.narrow-rows }
| Percentiel |  MMR |
|:----------:|:----:|
| 50         | 9051 |
| 75         | 9685 |
| 90         | 9810 |

Op basis hiervan kunnen we bepalen welk aandeel spelers boven 9700, 9800, 9900, 10000 en 10100 geraakt. Vervolgens
kijken we in andere seizoenen hoeveel spelers die score werkelijk overschreden. Met die twee cijfers kun je het
verwachte totale aantal spelers heel eenvoudig berekenen! Als je geïnteresseerd bent in de code, vind je alles op
[GitHub]. De resultaten staan hieronder:

{:.narrow-rows }
|        Season        | Schatting (laag) | Schatting (hoog) | Schatting (gemiddeld) |
|:--------------------:|:----------------:|:-----------------:|:---------------------:|
| M2_01 Wolf 2020      | 2900             | 3600              | 3118                  |
| M2_02 Love 2020      | 4567             | 7100              | 5620                  |
| M2_03 Bear 2020      | 6036             | 10300             | 7329                  |
| M2_04 Elf 2020       | 9927             | 18000             | 12319                 |
| M2_05 Viper 2020     | 7767             | 11400             | 9372                  |
| M2_06 Magic 2020     | 6800             | 9800              | 8320                  |
| M2_07 Griffin 2020   | 12836            | 19900             | 14683                 |
| M2_08 Draconid 2020  | 9567             | 13300             | 11186                 |
| M2_09 Dryad 2020     | 9733             | 12580             | 11219                 |
| M2_10 Cat 2020       | 12800            | 14620             | 13774                 |
| M2_11 Mahakam 2020   | 12995            | 18900             | 16042                 |
| M2_12 Wild Hunt 2020 | 13000            | 36000             | 23085                 |


## Methode 3: de website van Gwent Masters bestoken

Hoewel de website van Gwent Masters alleen de beste 2860 spelers toont, vind je de resultaten van een specifieke speler
voor dat seizoen als je naar die speler zoekt. Zelfs als die onder plaats 2860 staat! Dat zette me aan het denken ...
Als we een lijst maken met de namen van alle spelers die tijdens Masters 2 in om het even welk seizoen bij de beste 2860
stonden, kunnen we voor elke naam en elk seizoen met *brute force* de positie van die speler controleren. Met wat geluk
zijn er spelers uit de beste 500 die in Pro Rank bleven maar het volgende seizoen niet veel speelden, zodat we gegevens
over lage posities kunnen vinden ... en het werkte! Het duurde enkele dagen en meer dan 12000 HTTP-verzoeken legden wat
druk op de servers van CDPR, maar het script haalde gegevens op voor veel meer spelers dan er werden getoond ... met
inbegrip van minstens één speler met de laagst mogelijke MMR van 96 in elk seizoen! Deze cijfers zouden heel dicht bij
het exacte aantal Pro Players per seizoen moeten liggen.

{:.narrow-rows }
|        Season        | Spelers       |
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

## Werkten de schattingen?

Hoewel de laatste methode de schattingen overbodig maakt, was ik benieuwd hoe goed de methode werkte. Een eenvoudige
spreidingsgrafiek met een lineaire regressie toont dat de schattingen behoorlijk goed zijn. De methode is dus niet
perfect, maar vereist geen 6 à 7 uur per seizoen om de nodige gegevens te scrapen. Dat maakt ze waardevol om snel
cijfers te schatten voordat je voluit begint te scrapen.

![Een snelle controle van hoe goed de schattingen werkten](/assets/posts/2021-01-24-GwentProPlayersAnalysis/estimate_check.png)

## Conclusie

Voilà, het totale aantal Pro Players per seizoen! Het is ongelooflijk dat het totale aantal Pro Players in amper één
jaar bijna vertienvoudigde (merk wel op dat het laatste seizoen uitzonderlijk lang duurde, waardoor meer spelers Pro
Rank konden bereiken). Gwent kende een moeilijke start in 2021, met veel bugs die het spel braken, maar ik hoop dat het
zal blijven groeien. Dit benadrukt ook dat de moeilijk te behalen titels voor spelers die bij de beste 500 of zelfs de
beste 200 eindigen steeds lastiger te bemachtigen zijn.


[Gwent Masters]: https://masters.playgwent.com/en/
[GitHub]: https://github.com/4dcu-be/GwentRank
