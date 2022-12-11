---
layout: post
title:  "Machine Learning: the Gathering"
byline: "predicting your opponent's deck from the first few cards played"
date:   2019-12-29 12:00:00
author: Sebastian Proost
categories: programming games
tags:	python sklearn machine-learning pandas mtg magic-the-gathering data-science
cover:  "/assets/images/headers/machine_learning.jpg"
thumbnail: "/assets/images/thumbnails/machine_learning.jpg"
github: "https://github.com/4dcu-be/Machine-Learning-the-Gathering"
---

In [Magic: the Gathering](https://magic.wizards.com/en), a collectible card game, competitive players tend to gravitate towards a few dozen of the best 
decks made up out of a subset of all available cards. For instance in the Legacy format nearly all 18000 cards can be 
played, yet you'll only see about 500 show up in tournaments with some cards (e.g. Brainstorm and Force of Will) showing up 
in > 50% of all high-ranking decks.

When playing in such an event it is key to quickly identify your opponent's deck and adapt your own game plan 
accordingly. Top players are able to very quickly do this, bad ones like myself need a few more turns. Here we'll see 
if we can train a model that takes in a few known cards and outputs a prediction which deck is being played.

In this blog-post I'll show you how I made a classifier that can take a list of known cards in your opponent's deck and
return a list of possible decks they are playing. But let's start with two examples of what it can do first.

Imagine this scenario, on the first turn your opponent leads with **Wasteland**, on his second turn he plays a
**Plains** and uses it to cast **Mother of Runes**.

<div class="gallery-3-col" markdown="1">

![Wasteland](/assets/posts/2019-12-29-Magic-the-Gathering/cards/wasteland.jpg)
![Plains](/assets/posts/2019-12-29-Magic-the-Gathering/cards/plains.jpg)
![Mother of Runes](/assets/posts/2019-12-29-Magic-the-Gathering/cards/mother-of-runes.jpg)

</div>

We can feed this information in a function like this:

```python
predict_deck(["Plains", "Mother of Runes", "Wasteland"]).head(3)
```

And the result is a list of likely decks based on that combination of cards.

| Deck          | Probability |
|---------------|------------:|
| Death & Taxes | 0.62        |
| Pikula        | 0.34        |
| Other - Aggro | 0.04        |

That worked rather well! The most likely deck here is the mono-white Death & Taxes deck, with the Black-White Pikula
(also known as Deadguy Ale) in second position. Death & Taxes I would have immediately picked as the likely deck as 
well, however Pikula is something I never encountered and wouldn't have considered an option here. 

<div class="gallery-3-col" markdown="1">

![Arcum's Astrolabe](/assets/posts/2019-12-29-Magic-the-Gathering/cards/arcum-s-astrolabe.jpg)
![Noble Hierarch](/assets/posts/2019-12-29-Magic-the-Gathering/cards/noble-hierarch.jpg)
![Brainstorm](/assets/posts/2019-12-29-Magic-the-Gathering/cards/brainstorm.jpg)

</div>

```python
predict_deck(["Arcum's Astrolabe", "Noble Hierarch", "Brainstorm", "Snow-Covered Forest"]).head(3)
```

| Deck          | Probability |
|---------------|------------:|
| BUG Midrange  | 0.56        |
| Bant Aggro    | 0.32        |
| UWx Control   | 0.06        |

So in case your opponent started with a **Snow-Covered Forest** and **Noble Hierarch** on turn one with an 
**Arcum's Astrolabe** and **Brainstorm** on turn two, there are two rather likely decks they might be playing. A 
Black-Blue-Green Midrange deck or a Blue-Green-White Aggro deck. At this point there is no way to know for sure, yet.

As you can see, this classifier can do what top players can do as well. Based on very limited information make an 
educated guess what deck they are facing. You can [find the full code how to do this on GitHub in 
this repository](https://github.com/4dcu-be/Machine-Learning-the-Gathering), the
interesting parts I'll discuss here.

## Getting decklists

To start we'll need a example decks for all types of decks, also called archetypes. There are several websites that
store decklists, the one I've used is [MTG Top 8](http://www.mtgtop8.com/). Using the requests library to download the
site data, and Beautiful Soup to parse the html, I got all Legacy decklists from the last two weeks 
(downloaded 29/12/2019). You can find all code how to do this in the repo, collecting data and parsing it isn't the
most exciting thing to do though.

## Building the training dataset

From each deck we'll take samples with a few random cards, these are then turned into a presence-absence matrix. In such
a matrix each column represents a card and each row a sample, if a card is present in the sample the corresponding cell
is 1, if it is absent it is 0. Furthermore for each row we need to keep track of the archetype in another list. In 
practise we'll generate for each deck, for a number of different subset sizes, **1500** random samples.

The result looks like this:

### The card matrix with samples

This will be the X_train data.

{:.large-table}
| Sample | Abrupt Decay | Ad Nauseam | Aether Vial | Altar of Dementia | Ancient Tomb | Ancient Ziggurat | Angrath's Rampage | Animate Dead | ... | Watcher for Tomorrow | Waterlogged Grove | Wayward Servant | Whirlpool Rider | Wildborn Preserver | Windswept Heath | Wirewood Symbiote | Wishclaw Talisman | Wooded Foothills | Young Pyromancer |
|--------|--------------|------------|-------------|-------------------|--------------|------------------|-------------------|--------------|-----|----------------------|-------------------|-----------------|-----------------|--------------------|-----------------|-------------------|-------------------|------------------|------------------|
| 1      | 0            | 0          | 0           | 0                 | 1            | 0                | 0                 | 0            | ... | 0                    | 0                 | 0               | 0               | 0                  | 0               | 0                 | 0                 | 0                | 0                |
| 2      | 1            | 0          | 0           | 0                 | 0            | 0                | 0                 | 0            | ... | 0                    | 0                 | 0               | 0               | 0                  | 0               | 0                 | 0                 | 0                | 0                |
| 3      | 0            | 0          | 0           | 0                 | 0            | 0                | 0                 | 0            | ... | 0                    | 0                 | 0               | 0               | 0                  | 1               | 0                 | 0                 | 1                | 0                |
| 4      | 0            | 0          | 0           | 0                 | 0            | 0                | 0                 | 0            | ... | 0                    | 0                 | 0               | 0               | 0                  | 0               | 0                 | 0                 | 0                | 0                |
| ...    | ...          | ...        | ...         | ...               | ...          | ...              | ...               | ...          | ... | ...                  | ...               | ...             | ...             | ...                | ...             | ...               | ...               | ...              | ...              |


### The classes

The archetypes are the y_train data, essentially a list of categories for the fit function.

| Sample | archetype      |
|--------|----------------|
| 1      | Artifacts Blue |
| 2      | BUG Midrange   |
| 3      | Bant Aggro     |
| 4      | Bant Control   |
| ...    | ...            |

## Building a classifier

Once the data is in the right format building a classifier is easy. Here I selected a RandomForestClassifier and played
around with the settings to end up with this. 

```python
from sklearn.ensemble import RandomForestClassifier
rfc = RandomForestClassifier(max_depth=None, 
                             criterion= 'gini', 
                             max_features= 5, 
                             n_estimators= 50)
# Build the classifier
rfc.fit(X_train, y_train)
```

While this classifier will work, there is an issue! Since we are drawing a number of times random cards from each deck,
decks that are popular will be over-represented in our dataset. This imbalance in the input data will negatively 
influence the classifier. We need to provide a training set with the same number of samples for each archetype. This can
be done using pure python, but the library imbalanced-learn makes this easy. It is unfortunately not part of sklearn
so you have to install it.

```bash
conda install -c conda-forge imbalanced-learn
```

Once the library is installed we can balance our dataset by randomly selecting a subset of samples from over-represented
decklists. This process is called random undersampling.

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

## Using the classifier

The final part we lack is a function that can take a list of known cards in the opponent's deck, convert that to the 
right format, run the classifier and return us with a list of probable decks. To do this we need to have a list of all
cards in the presence-absence matrix (the column names), which we'll store in a variable **all_cards**. 

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

That's the function from the very beginning of this post. Again, on this page there are only bits and pieces of code 
highlighted, the notebook on GitHub contains a [fully working example](https://github.com/4dcu-be/Machine-Learning-the-Gathering).
This is a rather nice example how we could go from a set of decklists to a dataset to train the classifier to a working
classifier.

Personally, I think it is awesome how you can, in a matter of minutes, pull a set of all decklists and train a 
classifier on any format you want. While I played a fair bit of Legacy, and currently play Standard, I have no 
experience with Modern and Pioneer. This classifier would very quickly give me a way to *(gu)estimate* what an 
opponent is playing without having to know each competitive deck in the format.

**Update 21/02/2020: Imblearn deprecated the return_indices parameter. The code has been updated**

**Update 01/11/2022: The code has been updated to match mtgtop8's change in layout**

## Legal

Parts of this post are unofficial Fan Content permitted under the Wizards of the Coast Fan Content Policy. The literal 
and graphical information presented on this site about Magic: The Gathering, including card images, the mana symbols, 
and Oracle text, is copyright Wizards of the Coast, LLC, a subsidiary of Hasbro, Inc. 4DCu.be is not produced by, 
endorsed by, supported by, or affiliated with Wizards of the Coast.
