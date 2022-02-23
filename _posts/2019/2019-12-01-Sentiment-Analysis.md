---
layout: post
title:  "Sentiment Analysis and the Shape of Stories"
byline: "The shape of Lord of the Rings - The Fellowship of the Ring"
date:   2019-12-01 12:00:00
author: Sebastian Proost
categories: programming
tags:	python NLP NLTK pandas matplotlib LotR data-science
cover:  "/assets/posts/2019-12-01-Sentiment-Analysis/header.png"
thumbnail: "/assets/images/thumbnails/sentiment_analysis.jpg"
github: "https://github.com/4dcu-be/ShapeOfStories-SentimentAnalysis"
---

When I accidentally stumbled upon a presentation from [Kurt Vonnegut](https://en.wikipedia.org/wiki/Kurt_Vonnegut) 
on how [stories have a shape](https://www.youtube.com/watch?v=oP3c1h8v2ZQ) I started thinking... "Would you be able 
to use natural language processing (NLP) to pick up these shapes based on sentiment analysis of the actual text?" So 
here I'll show you the approach I came up with, and the application on 
[J.R.R. Tolkien](https://en.wikipedia.org/wiki/J._R._R._Tolkien)'s 
[Lord of the Rings](https://en.wikipedia.org/wiki/The_Lord_of_the_Rings) - The Fellowship of the Ring. All code can be
found in a Jupyter notebook in [this repository](https://github.com/4dcu-be/ShapeOfStories-SentimentAnalysis).


To understand what this post is about you should really have a look at [this video](https://www.youtube.com/watch?v=oP3c1h8v2ZQ). 

## Sentiment analysis in Python

Python has the [Natural Language Toolkit](https://www.nltk.org/) which includes a very easy way to do sentiment 
analysis. Import the correct library, create a `SentimentIntsenityAnalyzer()` and apply it on a fragment of text. Done! 
Just look at the examples below how a few lines of code can pick up which fragments are positive, negative or 
neutral (reflected in the 'pos', 'neg', 'neu'). Furthermore there is a **compound score** that is positive if the overall
sentiment of the text is good and negative if it is bad, this is the metric we want to create the shape of the story.

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

## Parsing your book

You'll have to go over your book and extract the paragraphs. Titles, subtitles, ... will need to be removed. 
Specifically for Lord of the Rings - The Fellowship of the Ring dialog and songs were removed as well. Only paragraphs 
of sufficient length are stored. So in total we are only considering the 303 longest paragraphs in this book for the 
analysis. 

I stored the parsed book to a .json file like this:

```json
[
  { "paragraph" : "Paragraph one text..." },
  { "paragraph" : "Paragraph two text..." },
  ...
]
```

LotR is protected by copyright. I have both a physical as a digital copy legally, though I can't share the parsed 
book here. There is no general way to parse an ebook into paragraphs as depending on the source the way a paragraph ends
will be encoded differently.

Using the code below, this file can be loaded and the sentiment analysis applied to each paragraph. Scores are stored 
into a pandas dataframe. As sentiment analysis can be rather noisy and one paragraph can be very positive, followed by 
a rather negative one, however a few negative ones in a row are relevant. Therefore a rolling window will be applied 
to the scores to get the average score over a number of paragraphs.

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

That is all there is to it! We now have a data frame with for each paragraph the sentiment scores and applied a rolling 
window to create a smoothed result. Now we just need to visualize the shape of our book and see if this makes sense. 
While normally Seaborn can be used to quickly get a visualization of your data, here I wanted to have a curve with the
area under it colored by the sentiment, green in case it is positive blue for negative sections. To do this I had to use
matplotlib directly. 

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

![Sentiment plot of Lord of the Rings - The Fellowship of the Ring](/assets/posts/2019-12-01-Sentiment-Analysis/Fellowship.svg)

This looks pretty close to what I wanted ! However, does it make sense ... To figure this out lets add some annotations
to the plot. I pinpointed paragraphs containing key moments in the story and will add them to the plot. This will give
us a better view if the plot makes sense and if it really follows the story.

The code to do this is similar as above, with the exception dots and text will be added.

**Note that the section below the code contains SPOILERS for both the book and the movie**

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

![Annotated Sentiment plot of Lord of the Rings - The Fellowship of the Ring](/assets/posts/2019-12-01-Sentiment-Analysis/Fellowship.annotated.svg)

## Discussion

I was surprised how well the image actually reflects the story! For those that need a reminder here is a 
short outline of the story specifically focusing on the annotations added to the image.

The Fellowship of the Ring starts with a Birthday party where the Hobbits and their village in The Shire are introduced.
So the story starts very happy and cheerful, as Tolkien describes these characters in great depth this takes up a major
portion of the book. Meeting new characters, like Strider/Aragorn, is often met with positive sentiment.

The sentiment goes down considerably once Frodo makes his way to Bree and the Black Riders (later revealed as the
ringwraights or [Nazgûl](https://lotr.fandom.com/wiki/Nazg%C3%BBl)) start chasing them, leading to a confrontation at 
the Weathertop. Here Frodo is injured and needs to be rushed to Rivendell. This section in both the book and the movie
is rather dark, the Hobbits fear the Riders and start to understand their mission is far more perilous than they ever
imagined.

At Rivendell Frodo is healed and meets up with his Uncle Bilbo again. Here the Hobbits are safe and this is reflected in
the sentiment of the text. While in Rivendell Elrond also talks about Sauron, Isildur and the Ring, this flashback is
rather negative (Isildur failed to destroy the ring) and this is clearly visible in the plot as well. Once the 
Fellowship is assembled and they leave Rivendell for Mordor their spirits are good, when being forced to go through the 
Mines of Moria however things start looking grim. Gandalf ultimately defeats the Balrog yet is pulled down into the dark
depths of the mine himself. The last words he utters "Fly, you fools!" before going down the Abyss is one of the most 
negative moments in both the book and the movie. This is also the sharpest negative peak in the plot. The others 
make it out of the Mines alive and are able to find shelter with the elves of Lothlórien. 

Once they leave the forest and their host Galadriel the Lady of Lórien, things quickly take a turn
for the worst at the end of the story. Orcs are closing in on them, Boromir betrays them and tries to take the ring from
Frodo (Unlike the movie his death isn't included in this book, it is at the start of The Two Towers), the Fellowship 
breaks up and hence fails to complete their quest.

I wonder if this approach would work as well for other books ?
