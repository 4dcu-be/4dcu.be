---
layout: post
title:  "De wet van Benford op de proef gesteld"
byline: "getallen zijn misschien minder willekeurig dan je denkt"
description: "De wet van Benford testen met Python, pandas en seaborn en onderzoeken waarom het eerste cijfer in echte datasets zo vaak 1 is, geïnspireerd door de Netflix-reeks Connected."
date:   2020-09-05 12:00:00
author: Sebastian Proost
post_id: testing-benfords-law
categories: programming
tags:	python jupyter pandas data-science
cover:  "/assets/posts/2020-09-05-Testing-Benfords-Law/log_table.jpg"
thumbnail: "/assets/images/thumbnails/benfordslaw.jpg"
github: "https://github.com/4dcu-be/BenfordsLaw"
gallery_items:
  - image: "/assets/posts/2020-09-05-Testing-Benfords-Law/big_graph.png"
    gallery_image: "/assets/images/gallery/benfords_law.jpg"
    description: "Na de aflevering van Connected over de wet van Benford moest ik nagaan of die ook gold voor enkele datasets die ik zelf koos."
---

Nadat ik in [Connected](https://www.imdb.com/title/tt12753692/?ref_=fn_al_tt_2) van [Latif Nasser](https://twitter.com/latifnasser) 
(momenteel op Netflix) de aflevering over de [wet van Benford](https://en.wikipedia.org/wiki/Benford%27s_law) had gezien, moest ik testen of die echt klopt en of
ik enkele datasets kon vinden waarop ze van toepassing is. En ... dat lukte! Maar voor we in de details duiken, leggen we eerst 
uit wat de wet van Benford inhoudt.

De wet van Benford stelt dat het begincijfer (het eerste cijfer van een getal, ook het meest significante cijfer genoemd)
in veel verzamelingen getallen niet willekeurig verdeeld is. Het eerste cijfer is het vaakst 1 (bij ongeveer 30% van de getallen, tegenover
11% bij een werkelijk willekeurige verdeling), daarna komt 2 het vaakst voor, ... en 9 het minst vaak
(als begincijfer veel minder vaak dan je zou verwachten). De kans voor de tussenliggende cijfers neemt af
volgens een logaritmische schaal.

De kansen die hij voor elk cijfer voorstelde, volgen de formule *P(n)=log10(1+1/n)*. Met een beetje Python-code kunnen we
die snel berekenen en visualiseren.

```python
import pandas as pd
import numpy as np
import seaborn as sns

palette = sns.color_palette("GnBu_r", 9)

benford_proba = ({'digit': i, 'prob': np.log10(1+1/i)} for i in range(1,10,1))
ideal_df = pd.DataFrame(benford_proba)
sns.barplot(x='digit', y='prob', data=ideal_df, palette=palette).set_title('Benford\'s Law: hypothetical distribution')
plt.show()
```

Hier wordt een *generator comprehension* gebruikt die alle kansen voor de cijfers 1 tot en met 9 oplevert. Die worden in een
Pandas-dataframe omgezet en met Seaborn gevisualiseerd. Dit is de hypothetische verdeling:

![De hypothetische verdeling van de meest significante cijfers volgens de wet van Benford](/assets/posts/2020-09-05-Testing-Benfords-Law/hypothetical_distribution.png){:.small-image}

Laten we nu enkele datasets nemen en controleren of ze overeenkomen!

## De hoogtes van hoofdsteden

Op [Wikipedia](https://en.wikipedia.org/wiki/List_of_capital_cities_by_elevation) vind je een lijst van alle landen van de Verenigde 
Naties, met hun hoofdstad en de hoogte van die stad in meter boven de zeespiegel. Die lijst werd
omgezet in een Excel-spreadsheet en in een Pandas-dataframe geladen. Daarna was slechts wat code nodig om steden 
op of onder zeeniveau uit te sluiten, het meest significante cijfer te bepalen en die cijfers te tellen.

```python
df = pd.read_excel('./data/capitals_altitude.xlsx')
df = df[df['Elevation (m)'] > 0]

df['first_digit_m'] = [str(n)[0] for n in df['Elevation (m)']]
                        
counts_altitude_df = df.groupby('first_digit_m').agg(
    count = pd.NamedAgg('Country', 'count'),
).reset_index()
```
Dat leverde een dataframe op dat er als volgt uitzag:

{:.narrow-rows}
| first_digit_m | count |
|--------------:|------:|
|             1 |    56 |
|             2 |    27 |
|             3 |    17 |
|             4 |     9 |
|             5 |    13 |
|             6 |    16 |
|             7 |    14 |
|             8 |     5 |
|             9 |    10 |

Het cijfer één komt inderdaad veel vaker voor dan de andere cijfers. Om dat tastbaarder te maken, zetten we de 
frequenties uit naast de hypothetische frequentie volgens de wet van Benford en gebruiken we een test om te controleren of ze al dan niet significant
verschillen. Omdat we meerdere datasets willen testen en visualiseren, stoppen we alles in één functie:

```python
import scipy.stats as stats

def plot_benford(x, y, data, title, ax=None):
    data = data.sort_values(x)
    benford_proba = (np.log10(1+1/i) for i in range(1,10,1))
    
    observed = list(data[y])
    expected = [round(prob*np.sum(data[y])) for prob in benford_proba]
    stat, p_value = stats.chisquare(f_obs=observed, f_exp=expected)
    
    if p_value > 0.05:
        palette = sns.color_palette("GnBu_r", 9)
    else:
        palette = sns.color_palette("OrRd_r", 9)
    
    frequencies = data[y]/np.sum(data[y])

    if ax is None:
        fig, ax = plt.subplots()
    
    sns.barplot(x=data[x], y=frequencies, palette=palette, ax=ax, zorder=0).set_title(title)
    sns.pointplot(x='digit', y='prob', data=ideal_df, ax=ax, zorder=1, join=False, color='gray')
    ax.set(xlabel='First Digit', ylabel='Frequency')
```

De parameters *x* en *y* zijn respectievelijk de kolomnamen van de kolom met de cijfers en die met de aantallen. *Data* is
het dataframe met de telgegevens en *ax* is optioneel en kan worden gebruikt om figuren met meerdere panelen te maken. De gegevens worden eerst
gesorteerd om zeker te zijn dat de cijfers correct van 1 tot 9 staan, waarna we de kansen opnieuw berekenen.
Vervolgens worden de waargenomen aantallen in een aparte variabele opgeslagen en wordt het verwachte aantal berekend: de kans
voor elk cijfer vermenigvuldigd met het totale aantal waarnemingen. Met een chi-kwadraattoets controleren we of de verdelingen
gelijk zijn (p-waarde > 0,05) en stellen we de kleuren van de grafiek daarop af. Ten slotte worden de aantallen 
omgezet in frequenties en wordt alles gevisualiseerd: gekleurde balken voor de waargenomen gegevens en grijze stippen die aangeven waar
de wet van Benford ze voorspelt.

 
![Verdeling van de meest significante cijfers van de hoogtes in meter van hoofdsteden overal ter wereld](/assets/posts/2020-09-05-Testing-Benfords-Law/altitudes.png){:.small-image}

## Meer datasets: COVID-19-besmettingen, bacteriën in de menselijke darm en Gwent-scores

De hoogtes van hoofdsteden lijken de wet van Benford dus inderdaad te volgen. Tijd om enkele andere datasets te nemen en te kijken of 
de wet ook daar geldt. Ik koos Gwent-MMR-scores uit het [vorige artikel]({% post_url nl/2020/2020-09-01-GwentProRankAnalysis %}),
het dagelijkse aantal COVID-19-besmettingen in Belgische provincies van [Sciensano](https://www.sciensano.be/en/covid-19-data) en
de aantallen bacteriën in de menselijke darm uit het [Human Microbiome Project](https://www.hmpdacc.org/). 

Deze datasets en de code om ze te laden en te verwerken vind je [hier](https://github.com/4dcu-be/BenfordsLaw) op GitHub, in de repository die bij 
dit artikel hoort.

![Verdelingen van alle geteste datasets](/assets/posts/2020-09-05-Testing-Benfords-Law/big_graph.png)

De hoogtes en COVID-19-besmettingen volgen de wet van Benford dus statistisch significant (of beter: ze verschillen niet 
significant van Benfords ideale verdeling) en worden daarom in blauwtinten weergegeven. Ook voor Gwent Pro Rank-
scores en de (relatieve) aantallen bacteriën in de menselijke darm zijn de meest significante cijfers duidelijk niet 
uniform verdeeld, maar de waargenomen verdelingen verschillen wel van Benfords hypothetische ideaal (daarom worden deze datasets
in roodtinten weergegeven). Zelfs wanneer ze afwijken van het geïdealiseerde geval, passen de verdelingen
nog steeds erg goed bij een logaritmische afname!

## Conclusie

Dat de eerste cijfers van schijnbaar willekeurige getallen helemaal niet willekeurig lijken, voelt aanvankelijk erg
contra-intuïtief aan. Numberphile legt uitstekend uit waarom Benford van toepassing is op verzamelingen getallen met een 
exponentiële groei. Bekijk hun YouTube-video [hier](https://www.youtube.com/watch?v=XXjlR2OK1kM). Hoewel niet alle datasets
een exponentiële curve volgen, is van 1 naar 2 gaan in veel gevallen gemakkelijker dan van 2 naar 3, ... Dat geldt
bijvoorbeeld voor Gwent-scores (na aftrek van de basisscore van 9600). Omdat je bij een hogere MMR-score aan 
steeds betere tegenstanders wordt gekoppeld, kunnen minder mensen 200 punten klimmen dan
100 punten. Daardoor klimmen meer spelers uiteindelijk 100 dan 200 punten en zien we een verschuiving in de frequenties
van de eerste cijfers van de scores. 

Ook het dagelijkse aantal COVID-19-besmettingen zou zonder ingrijpen exponentieel stijgen (en de wet van Benford zou gelden). Door
uitgebreide maatregelen om de besmettingsgraad af te remmen (lockdown, sociale en fysieke afstand, mondmaskers, ...) wordt het 
echter moeilijker voor het virus om zich te verspreiden en daalt de curve. Dat is een traag proces en de curve heeft een erg lange staart: het dagelijkse aantal besmettingen
daalt sneller van 30 naar 20 dan van 20 naar 10. Ook dat veroorzaakt een niet-uniforme verdeling van de eerste cijfers.

Deze aflevering van Connected zette me stevig aan het denken. Ik geloof niet dat ik ooit zoveel tijd over één
documentaire heb nagedacht (en dat is positief). Hopelijk krijgt Latif Nasser de kans om nog enkele seizoenen te maken!
