---
layout: post
title:  "Sentimentanalyse en de vorm van verhalen"
byline: "De vorm van Lord of the Rings - The Fellowship of the Ring"
description: "Met Python en NLTK-sentimentanalyse de emotionele vorm van een verhaal plotten, toegepast op Tolkiens Lord of the Rings en geïnspireerd door Kurt Vonnegut."
date:   2019-12-01 12:00:00
author: Sebastian Proost
post_id: sentiment-analysis
categories: programming
tags:	python NLP NLTK pandas matplotlib LotR data-science
cover:  "/assets/posts/2019-12-01-Sentiment-Analysis/header.png"
thumbnail: "/assets/images/thumbnails/sentiment_analysis.jpg"
github: "https://github.com/4dcu-be/ShapeOfStories-SentimentAnalysis"
---

Toen ik toevallig op een presentatie van [Kurt Vonnegut](https://en.wikipedia.org/wiki/Kurt_Vonnegut) 
stuitte over hoe [verhalen een vorm hebben](https://www.youtube.com/watch?v=oP3c1h8v2ZQ), begon ik na te denken ... "Kun je 
natuurlijke taalverwerking (NLP) gebruiken om die vormen te herkennen via een sentimentanalyse van de eigenlijke tekst?" 
Hier toon ik de aanpak die ik bedacht en pas ik die toe op 
[J.R.R. Tolkiens](https://en.wikipedia.org/wiki/J._R._R._Tolkien) 
[Lord of the Rings](https://en.wikipedia.org/wiki/The_Lord_of_the_Rings) - The Fellowship of the Ring. Alle code vind je
in een Jupyter-notebook in [deze repository](https://github.com/4dcu-be/ShapeOfStories-SentimentAnalysis).


Om te begrijpen waar deze post over gaat, moet je echt [deze video](https://www.youtube.com/watch?v=oP3c1h8v2ZQ) bekijken. 

## Sentimentanalyse in Python

Python beschikt over de [Natural Language Toolkit](https://www.nltk.org/), die een heel eenvoudige manier bevat om een sentimentanalyse 
uit te voeren. Importeer de juiste bibliotheek, maak een `SentimentIntensityAnalyzer()` aan en pas die toe op een tekstfragment. Klaar! 
In de voorbeelden hieronder zie je hoe enkele regels code herkennen welke fragmenten positief, negatief of 
neutraal zijn (weergegeven in 'pos', 'neg' en 'neu'). Daarnaast is er een **samengestelde score** die positief is als het algemene
sentiment van de tekst goed is en negatief als het slecht is. Dat is de maatstaf waarmee we de vorm van het verhaal willen maken.

```python
from nltk.sentiment.vader import SentimentIntensityAnalyzer
sid = SentimentIntensityAnalyzer()

print(sid.polarity_scores("He smiled, he was happy. It had been an amazing day!"))
# {'neg': 0.0, 'neu': 0.415, 'pos': 0.585, 'compound': 0.906}
print(sid.polarity_scores("They feared the others. When they show up, bad things happen."))
# {'neg': 0.427, 'neu': 0.573, 'pos': 0.0, 'compound': -0.7717}
print(sid.polarity_scores("While driving to their destination, nothing happened."))
# {'neg': 0.0, 'neu': 1.0, 'pos': 0.0, 'compound': 0.0}
```

## Je boek verwerken

Je moet je boek doorlopen en de alinea's eruit halen. Titels, ondertitels, ... moeten worden verwijderd. 
Specifiek voor Lord of the Rings - The Fellowship of the Ring werden ook dialogen en liederen verwijderd. Alleen alinea's 
die lang genoeg zijn, worden bewaard. Voor deze analyse nemen we dus enkel de 303 langste alinea's van het boek mee. 

Ik bewaarde het verwerkte boek als volgt in een .json-bestand:

```json
[
  { "paragraph" : "Paragraph one text..." },
  { "paragraph" : "Paragraph two text..." },
  ...
]
```

LotR is auteursrechtelijk beschermd. Ik bezit legaal zowel een fysiek als digitaal exemplaar, maar kan het verwerkte 
boek hier niet delen. Er bestaat geen algemene manier om een e-book in alinea's op te delen, want afhankelijk van de bron wordt het einde van een alinea
anders gecodeerd.

Met de code hieronder kan dit bestand worden geladen en kan op elke alinea een sentimentanalyse worden toegepast. De scores worden 
in een pandas-dataframe bewaard. Sentimentanalyse kan behoorlijk ruisachtig zijn: op een erg positieve alinea kan 
een vrij negatieve volgen. Enkele negatieve alinea's na elkaar zijn echter wel relevant. Daarom passen we een voortschrijdend venster 
op de scores toe om de gemiddelde score over een aantal alinea's te berekenen.

```python
import json
import pandas as pd
from nltk.sentiment.vader import SentimentIntensityAnalyzer
sid = SentimentIntensityAnalyzer()

data = []
with open('./output/The_Fellowship_Of_The_Ring.paragraphs.json', 'r') as fin:
    data = json.load(fin)

# create a data frame with the sentiment scores
df = pd.DataFrame([sid.polarity_scores(p['paragraph']) for p in data])

# Create a column with paragraph numbers (starting with 1)
df['paragraph_num'] = df.index + 1

# Apply a rolling window on the compound score to smooth out noise
# Downside is that the first and last elements will be NA
df['smooth_compound'] = df['compound'].rolling(window=20, center=True, win_type='triang').mean()
```

Dat is alles! We hebben nu een dataframe met de sentimentscores voor elke alinea en een voortschrijdend 
venster dat een afgevlakt resultaat oplevert. Nu moeten we alleen nog de vorm van ons boek visualiseren en kijken of die steek houdt. 
Normaal kun je Seaborn gebruiken om snel je gegevens te visualiseren, maar hier wilde ik een curve waarbij het
gebied eronder volgens het sentiment wordt ingekleurd: groen voor positieve en blauw voor negatieve stukken. Daarvoor moest ik
matplotlib rechtstreeks gebruiken. 

```python
import seaborn as sns
import matplotlib.pyplot as plt

plt.rcParams['figure.figsize'] = [15, 6]

blue = (0.2980392156862745, 0.4470588235294118, 0.6901960784313725)
green = (0.3333333333333333, 0.6588235294117647, 0.40784313725490196)

sns.set_style("white")
plt.title('Lord of the Rings - The Fellowship of the Ring')
plt.xlabel('Paragraph')
plt.ylabel('Sentiment')
plt.xticks([])
plt.yticks([])

plt.fill_between(df.paragraph_num, 0, df.smooth_compound, alpha=0.5, where=df.smooth_compound >= 0, facecolor=green, interpolate=True)
plt.fill_between(df.paragraph_num, 0, df.smooth_compound, alpha=0.5, where=df.smooth_compound < 0, facecolor=blue, interpolate=True)

plt.axhline(linewidth=1.5, c='gray', alpha=0.3)

plt.show()
```

![Sentimentgrafiek van Lord of the Rings - The Fellowship of the Ring](/assets/posts/2019-12-01-Sentiment-Analysis/Fellowship.svg)

Dit komt behoorlijk dicht in de buurt van wat ik wilde! Maar klopt het ook ... Om dat uit te zoeken voegen we enkele annotaties
aan de grafiek toe. Ik zocht de alinea's met belangrijke momenten uit het verhaal en voeg die aan de grafiek toe. Zo zien
we beter of de grafiek steek houdt en het verhaal echt volgt.

De code hiervoor lijkt op die hierboven, behalve dat er punten en tekst worden toegevoegd.

**Let op: het gedeelte onder de code bevat SPOILERS voor zowel het boek als de film**

```python
annotations = [
    ('Frodo meets Aragorn', (105, df.iloc[104]['smooth_compound'])),
    ('Black Riders arrive in Bree', (116, df.iloc[115]['smooth_compound'])),
    ('Black Riders assembling near Weathertop', (129, df.iloc[128]['smooth_compound'])),
    ('Frodo meets up with Bilbo in Rivendell', (152, df.iloc[151]['smooth_compound'])),
    ('"Fly, you fools"', (241, df.iloc[240]['smooth_compound']))
]

sns.set_style("white")
plt.title('Lord of the Rings - The Fellowship of the Ring')
plt.xlabel('Paragraph')
plt.ylabel('Sentiment')
plt.xticks([])
plt.yticks([])

plt.fill_between(df.paragraph_num, 0, df.smooth_compound, alpha=0.5, where=df.smooth_compound >= 0, facecolor=green, interpolate=True)
plt.fill_between(df.paragraph_num, 0, df.smooth_compound, alpha=0.5, where=df.smooth_compound < 0, facecolor=blue, interpolate=True)

plt.axhline(linewidth=1.5, c='gray', alpha=0.3)

for a, (x,y) in annotations:
    plt.scatter(x, y, c='black', alpha=0.3)
    plt.annotate(a, (x,y+0.05))
  
with open('Fellowship.annotated.svg','wb') as svg_out:
    plt.savefig(svg_out, format="svg")
    
plt.show()
```

![Geannoteerde sentimentgrafiek van Lord of the Rings - The Fellowship of the Ring](/assets/posts/2019-12-01-Sentiment-Analysis/Fellowship.annotated.svg)

## Bespreking

Ik was verbaasd over hoe goed de afbeelding het verhaal weerspiegelt! Voor wie een opfrissing nodig heeft, volgt hier een 
korte samenvatting van het verhaal, met de nadruk op de annotaties die aan de afbeelding werden toegevoegd.

The Fellowship of the Ring begint met een verjaardagsfeest waarop de Hobbits en hun dorp in The Shire worden voorgesteld.
Het verhaal begint dus erg vrolijk en opgewekt. Omdat Tolkien deze personages uitvoerig beschrijft, neemt dit een groot
deel van het boek in beslag. Ontmoetingen met nieuwe personages, zoals Strider/Aragorn, gaan vaak gepaard met een positief sentiment.

Het sentiment daalt aanzienlijk zodra Frodo naar Bree trekt en de Black Riders (later onthuld als de
Ringwraiths of [Nazgûl](https://lotr.fandom.com/wiki/Nazg%C3%BBl)) hen beginnen te achtervolgen, met een confrontatie op 
Weathertop tot gevolg. Frodo raakt daar gewond en moet met spoed naar Rivendell worden gebracht. Dit gedeelte is zowel in het boek als in de film
vrij duister. De Hobbits vrezen de Riders en beginnen te beseffen dat hun missie veel gevaarlijker is dan ze ooit
hadden gedacht.

In Rivendell wordt Frodo genezen en ziet hij zijn oom Bilbo terug. De Hobbits zijn er veilig en dat zie je terug in
het sentiment van de tekst. Elrond vertelt in Rivendell ook over Sauron, Isildur en de Ring. Deze flashback is
vrij negatief (Isildur slaagde er niet in de Ring te vernietigen) en dat is eveneens duidelijk zichtbaar in de grafiek. Zodra de 
Fellowship is gevormd en ze Rivendell verlaten richting Mordor, is de stemming goed. Wanneer ze echter gedwongen worden door de 
Mines of Moria te trekken, wordt het grimmig. Gandalf verslaat uiteindelijk de Balrog, maar wordt zelf meegetrokken in de duistere
diepten van de mijn. Zijn laatste woorden, "Fly, you fools!", voordat hij in de afgrond verdwijnt, vormen een van de meest 
negatieve momenten in zowel het boek als de film. Dit is ook de scherpste negatieve piek in de grafiek. De anderen 
ontsnappen levend uit de Mines en vinden onderdak bij de elfen van Lothlórien. 

Zodra ze het bos en hun gastvrouw Galadriel, de Lady of Lórien, verlaten, neemt het verhaal aan het einde snel een wending
ten kwade. Orks komen dichterbij, Boromir verraadt hen en probeert de Ring van
Frodo af te nemen (anders dan in de film staat zijn dood niet in dit boek, maar aan het begin van The Two Towers). De Fellowship 
valt uiteen en slaagt er dus niet in haar queeste te voltooien.

Ik vraag me af of deze aanpak ook voor andere boeken zou werken?
