---
layout: post
title:  "Machine Learning: the Gathering"
byline: "het deck van je tegenstander voorspellen aan de hand van de eerste gespeelde kaarten"
description: "Een Python-classificatiemodel met scikit-learn bouwen dat het Magic: The Gathering-deck van een tegenstander voorspelt op basis van de eerste kaarten die die speelt, met pandas en machine learning."
date:   2019-12-29 12:00:00
author: Sebastian Proost
post_id: magic-the-gathering
categories: programming games
tags:	python sklearn machine-learning pandas mtg magic-the-gathering data-science
cover:  "/assets/images/headers/machine_learning.jpg"
thumbnail: "/assets/images/thumbnails/machine_learning.jpg"
github: "https://github.com/4dcu-be/Machine-Learning-the-Gathering"
---

In [Magic: the Gathering](https://magic.wizards.com/en), een verzamelkaartspel, kiezen competitieve spelers meestal
enkele tientallen van de beste decks, opgebouwd uit een deel van alle beschikbare kaarten. In het Legacy-formaat
mogen bijvoorbeeld bijna alle 18.000 kaarten worden gespeeld, maar op toernooien zie je er slechts zo'n 500 opduiken.
Sommige kaarten, zoals Brainstorm en Force of Will, zitten in meer dan 50% van alle hoog geklasseerde decks.

Wanneer je aan zo'n evenement deelneemt, is het cruciaal om snel te herkennen welk deck je tegenstander speelt en je
eigen spelplan daaraan aan te passen. Topspelers kunnen dat bijzonder snel, slechte spelers zoals ik hebben enkele
beurten meer nodig. Hier bekijken we of we een model kunnen trainen dat enkele bekende kaarten als invoer krijgt en
voorspelt welk deck er wordt gespeeld.

In deze blogpost toon ik hoe ik een classificatiemodel maakte dat een lijst van bekende kaarten in het deck van je
tegenstander als invoer neemt en een lijst teruggeeft van mogelijke decks die die speelt. Maar laten we eerst twee
voorbeelden bekijken van wat het kan.

Stel je dit scenario voor: in de eerste beurt begint je tegenstander met **Wasteland**, in de tweede speelt hij een
**Plains** en gebruikt die om **Mother of Runes** te spelen.

<div class="gallery-3-col" markdown="1">

![Wasteland](/assets/posts/2019-12-29-Magic-the-Gathering/cards/wasteland.jpg)
![Plains](/assets/posts/2019-12-29-Magic-the-Gathering/cards/plains.jpg)
![Mother of Runes](/assets/posts/2019-12-29-Magic-the-Gathering/cards/mother-of-runes.jpg)

</div>

We kunnen deze informatie als volgt aan een functie doorgeven:

```python
predict_deck(["Plains", "Mother of Runes", "Wasteland"]).head(3)
```

Het resultaat is een lijst met waarschijnlijke decks op basis van die combinatie van kaarten.

| Deck          | Waarschijnlijkheid |
|---------------|------------:|
| Death & Taxes | 0.62        |
| Pikula        | 0.34        |
| Other - Aggro | 0.04        |

Dat werkte behoorlijk goed! Het waarschijnlijkste deck is hier het monowitte Death & Taxes, met het zwart-witte
Pikula (ook bekend als Deadguy Ale) op de tweede plaats. Death & Taxes zou ik zelf ook meteen als waarschijnlijkste
deck hebben gekozen, maar Pikula was ik nog nooit tegengekomen en had ik hier dus niet als mogelijkheid overwogen.

<div class="gallery-3-col" markdown="1">

![Arcum's Astrolabe](/assets/posts/2019-12-29-Magic-the-Gathering/cards/arcum-s-astrolabe.jpg)
![Noble Hierarch](/assets/posts/2019-12-29-Magic-the-Gathering/cards/noble-hierarch.jpg)
![Brainstorm](/assets/posts/2019-12-29-Magic-the-Gathering/cards/brainstorm.jpg)

</div>

```python
predict_deck(["Arcum's Astrolabe", "Noble Hierarch", "Brainstorm", "Snow-Covered Forest"]).head(3)
```

| Deck          | Waarschijnlijkheid |
|---------------|------------:|
| BUG Midrange  | 0.56        |
| Bant Aggro    | 0.32        |
| UWx Control   | 0.06        |

Als je tegenstander in de eerste beurt dus met een **Snow-Covered Forest** en **Noble Hierarch** begon en in de tweede
een **Arcum's Astrolabe** en **Brainstorm** speelde, zijn er twee vrij waarschijnlijke decks: een zwart-blauw-groen
Midrange-deck of een blauw-groen-wit Aggro-deck. Op dit moment valt dat nog niet met zekerheid te zeggen.

Zoals je ziet, kan dit classificatiemodel hetzelfde als topspelers: op basis van heel beperkte informatie een
gefundeerde gok doen over het deck waartegen ze spelen. Je vindt [de volledige code om dat te doen in deze repository
op GitHub](https://github.com/4dcu-be/Machine-Learning-the-Gathering); de interessante delen bespreek ik hier.

## Decklijsten verzamelen

Om te beginnen hebben we voorbeelddecks nodig voor elk type deck, ook archetypes genoemd. Verschillende websites
bewaren decklijsten; ik gebruikte [MTG Top 8](http://www.mtgtop8.com/). Met de *requests*-bibliotheek om de
websitegegevens te downloaden en Beautiful Soup om de HTML te verwerken, verzamelde ik alle Legacy-decklijsten van de
voorbije twee weken (gedownload op 29/12/2019). Alle code daarvoor staat in de repository, al is gegevens verzamelen
en verwerken niet het spannendste werk.

## De trainingsgegevens opbouwen

Uit elk deck nemen we steekproeven met enkele willekeurige kaarten. Die zetten we vervolgens om in een
aanwezigheids-afwezigheidsmatrix. In zo'n matrix stelt elke kolom een kaart voor en elke rij een steekproef. Als een
kaart in de steekproef zit, is de overeenkomstige cel 1; anders is ze 0. Daarnaast moeten we voor elke rij het archetype
in een andere lijst bijhouden. In de praktijk genereren we per deck, voor een aantal verschillende groottes van de
deelverzameling, **1500** willekeurige steekproeven.

Het resultaat ziet er zo uit:

### De kaartmatrix met steekproeven

Dit worden de X_train-gegevens.

{:.large-table}
| Steekproef | Abrupt Decay | Ad Nauseam | Aether Vial | Altar of Dementia | Ancient Tomb | Ancient Ziggurat | Angrath's Rampage | Animate Dead | ... | Watcher for Tomorrow | Waterlogged Grove | Wayward Servant | Whirlpool Rider | Wildborn Preserver | Windswept Heath | Wirewood Symbiote | Wishclaw Talisman | Wooded Foothills | Young Pyromancer |
|--------|--------------|------------|-------------|-------------------|--------------|------------------|-------------------|--------------|-----|----------------------|-------------------|-----------------|-----------------|--------------------|-----------------|-------------------|-------------------|------------------|------------------|
| 1      | 0            | 0          | 0           | 0                 | 1            | 0                | 0                 | 0            | ... | 0                    | 0                 | 0               | 0               | 0                  | 0               | 0                 | 0                 | 0                | 0                |
| 2      | 1            | 0          | 0           | 0                 | 0            | 0                | 0                 | 0            | ... | 0                    | 0                 | 0               | 0               | 0                  | 0               | 0                 | 0                 | 0                | 0                |
| 3      | 0            | 0          | 0           | 0                 | 0            | 0                | 0                 | 0            | ... | 0                    | 0                 | 0               | 0               | 0                  | 1               | 0                 | 0                 | 1                | 0                |
| 4      | 0            | 0          | 0           | 0                 | 0            | 0                | 0                 | 0            | ... | 0                    | 0                 | 0               | 0               | 0                  | 0               | 0                 | 0                 | 0                | 0                |
| ...    | ...          | ...        | ...         | ...               | ...          | ...              | ...               | ...          | ... | ...                  | ...               | ...             | ...             | ...                | ...             | ...               | ...               | ...              | ...              |


### De klassen

De archetypes zijn de y_train-gegevens, in essentie een lijst met categorieën voor de *fit*-functie.

| Steekproef | archetype      |
|--------|----------------|
| 1      | Artifacts Blue |
| 2      | BUG Midrange   |
| 3      | Bant Aggro     |
| 4      | Bant Control   |
| ...    | ...            |

## Een classificatiemodel bouwen

Zodra de gegevens het juiste formaat hebben, is een classificatiemodel bouwen eenvoudig. Ik koos een
RandomForestClassifier en experimenteerde met de instellingen tot ik hierop uitkwam.

```python
from sklearn.ensemble import RandomForestClassifier
rfc = RandomForestClassifier(max_depth=None, 
                             criterion= 'gini', 
                             max_features= 5, 
                             n_estimators= 50)
# Build the classifier
rfc.fit(X_train, y_train)
```

Dit classificatiemodel werkt, maar er is een probleem! Omdat we meermaals willekeurige kaarten uit elk deck trekken,
zullen populaire decks oververtegenwoordigd zijn in onze gegevensset. Die onevenwichtige invoergegevens hebben een
negatieve invloed op het model. We hebben een trainingsset nodig met evenveel steekproeven voor elk archetype. Dat kan
met zuivere Python, maar de bibliotheek *imbalanced-learn* maakt het eenvoudig. Ze maakt helaas geen deel uit van
sklearn, dus je moet ze installeren.

```bash
conda install -c conda-forge imbalanced-learn
```

Zodra de bibliotheek geïnstalleerd is, kunnen we onze gegevensset in evenwicht brengen door willekeurig een deel van de
steekproeven uit oververtegenwoordigde decklijsten te kiezen. Dat proces heet willekeurige ondersampling.

```python
from imblearn.under_sampling import RandomUnderSampler
from sklearn.ensemble import RandomForestClassifier

rus = RandomUnderSampler()
X_rus, y_rus = rus.fit_sample(X_train, y_train)

# Build a new classifier on the under sampled dataset
rfc = RandomForestClassifier(max_depth=None, 
                             criterion= 'gini', 
                             max_features= 5, 
                             n_estimators= 50,
                             n_jobs=3)
rfc.fit(X_rus, y_rus)
```

## Het classificatiemodel gebruiken

Wat nog ontbreekt, is een functie die een lijst van bekende kaarten in het deck van de tegenstander inleest, die naar
het juiste formaat omzet, het classificatiemodel uitvoert en een lijst met waarschijnlijke decks teruggeeft. Daarvoor
hebben we een lijst nodig van alle kaarten in de aanwezigheids-afwezigheidsmatrix (de kolomnamen), die we in de variabele
**all_cards** opslaan.

```python
import pandas as pd

def predict_deck(cards_known):
    """
    This will take a list of known cards and convert it in a matrix compatible with the classifier.
    Next, this classifier will be used to predict which deck the known cards are coming from and 
    return the results as a sorted pandas dataframe.
    """
    cards_array = [[1 if c in cards_known else 0 for c in all_cards]]

    cards_not_in_model = [c for c in cards_known if c not in all_cards]
    
    if len(cards_not_in_model) > 0:
        print("Some cards were not included when trainig the model, these will be ignored: %s" % ','.join(cards_not_in_model))
    
    decks_proba = rfc.predict_proba(cards_array)[0]

    decks = pd.DataFrame(list(zip(rfc.classes_, decks_proba)), columns=["Deck", "Score"])\
              .sort_values("Score", axis=0, ascending=False)

    return decks
```   

Dat is de functie van helemaal aan het begin van deze post. Op deze pagina licht ik opnieuw maar enkele stukken code
uit; het notebook op GitHub bevat een [volledig werkend voorbeeld](https://github.com/4dcu-be/Machine-Learning-the-Gathering).
Dit is een mooi voorbeeld van hoe we van een reeks decklijsten naar een gegevensset gaan waarmee we een werkend
classificatiemodel kunnen trainen.

Persoonlijk vind ik het fantastisch dat je in enkele minuten alle decklijsten kunt ophalen en een classificatiemodel
kunt trainen voor eender welk formaat. Ik heb behoorlijk wat Legacy gespeeld en speel momenteel Standard, maar heb geen
ervaring met Modern en Pioneer. Met dit model zou ik heel snel kunnen *(in)schatten* wat een tegenstander speelt zonder
elk competitief deck in het formaat te moeten kennen.

**Update 21/02/2020: Imblearn heeft de parameter return_indices verouderd verklaard. De code is bijgewerkt.**

**Update 01/11/2022: De code is bijgewerkt om aan te sluiten bij de gewijzigde lay-out van mtgtop8.**

## Juridisch

Delen van deze post zijn onofficiële faninhoud die is toegestaan volgens het Fan Content Policy van Wizards of the
Coast. De tekstuele en grafische informatie op deze site over Magic: The Gathering, waaronder kaartafbeeldingen,
manasymbolen en Oracle-tekst, is auteursrechtelijk beschermd door Wizards of the Coast, LLC, een dochteronderneming van
Hasbro, Inc. 4DCu.be wordt niet geproduceerd, goedgekeurd of ondersteund door Wizards of the Coast en is er niet mee
verbonden.
