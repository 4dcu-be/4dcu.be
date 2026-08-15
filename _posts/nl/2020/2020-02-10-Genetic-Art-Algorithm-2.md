---
layout: post
title:  "Minimalistische kunst met een genetisch algoritme"
byline: "een andere kijk op Vermeers Meisje met de parel"
description: "Een genetisch algoritme in Python met Voronoi-diagrammen en genduplicatie gebruiken om Vermeers Meisje met de parel opnieuw te tekenen in een minimalistische stijl."
date:   2020-02-10 12:00:00
author: Sebastian Proost
post_id: genetic-art-algorithm-2
categories: programming
tags:	python evolution genetic-algorithm algorithm art
cover:  "/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/vermeer_header.jpg"
thumbnail: "/assets/images/thumbnails/vermeer_header.jpg"
github: "https://github.com/4dcu-be/Genetic-Art-Algorithm-part-2"

gallery_items:
  - image: "/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/vermeer_generation_05600.png"
    gallery_image: "/assets/images/gallery/vermeer_generation_5600.jpg"
    description: "Vermeers Meisje met de parel, opnieuw getekend in een minimalistische stijl met een genetisch algoritme en een Voronoi-diagram."
    gallery_size: tall

---

Hoewel het genetische algoritme uit het [vorige artikel]({% post_url nl/2020/2020-01-12-Genetic-Art-Algorithm %})
erg goed werkte, leverde het niet helemaal de minimalistische kunststijl op die ik probeerde te bereiken. Bovendien konden
de chromosomen niet evolueren door bestaande genen te dupliceren en te verwijderen (iets wat in de biologie heel vaak voorkomt). Nadat
ik een paar dagen over die problemen had nagedacht, vond ik een oplossing met een [Voronoi-diagram]. Het uiteindelijke 
resultaat (hieronder te zien) ligt veel dichter bij wat ik voor ogen had. Het schilderij dat het algoritme deze keer opnieuw tekent, is
Vermeers [Meisje met de parel].

<div class="gallery-2-col" markdown="1">
![Vermeers Meisje met de parel](/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/girl_with_pearl_earring.jpg)
![Het resultaat van het algoritme na 5600 generaties](/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/vermeer_generation_05600.png)
</div>

## Voronoi-diagrammen (ook wel partities of cellen)

De grafiek hieronder illustreert Voronoi-diagrammen: elke blauwe stip is een invoerpunt; de zwarte randen en oranje hoekpunten worden 
berekend. Zwarte randen liggen op gelijke afstand van twee naburige punten en oranje punten (de eindpunten van een rand) liggen op gelijke afstand 
van drie buren. Zo ontstaat rond elk invoerpunt een convexe veelhoek die niet met andere veelhoeken overlapt. Die 
veelhoeken kunnen worden ingekleurd en als volle vormen getekend, wat een celpatroon oplevert. (Je vindt [hier](https://youtu.be/Q804hv73L6U?t=66) een onderhoudende 
uitleg met meer details.)

<div class="gallery-2-col" markdown="1">
![Voronoi-grafiek: de blauwe stippen zijn de invoer. De zwarte randen en oranje punten worden op basis van de invoer berekend](/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/voronoi_plot.png)
![De afzonderlijke veelhoeken van de grafiek zijn ingekleurd](/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/voronoi_polygons.png)
</div>

In Python kun je met de klasse `Voronoi` en de functie `voronoi_plot_2d`
uit [SciPy] eenvoudig Voronoi-diagrammen maken en tekenen op basis van een lijst punten. Zonder de imports heb je maar vier regels code nodig!

```python
from scipy.spatial import Voronoi, voronoi_plot_2d
import matplotlib.pyplot as plt
from random import randint

# Generate 200 random points between 0-500, 0-500
points = [(randint(0, 500), randint(0, 500)) for _ in range(200)]

vor = Voronoi(points)
voronoi_plot_2d(vor)
plt.show()
```

## De nieuwe genen en chromosomen

Het chromosoom is hier een lijst van 2D-punten waaraan telkens een RGB-kleur is gekoppeld (de genen). Die punten kunnen zich verplaatsen 
of hun kleur kan tijdens een mutatiestap verschuiven. De volgorde van de punten maakt niet uit en een kopie van een gen maken heeft 
geen invloed op de afbeelding die het oplevert. Het zorgt wel voor extra 'genetisch materiaal' dat kan evolueren en 
voor meer complexiteit kan zorgen wanneer gedupliceerde punten uit elkaar beginnen te groeien. Punten kunnen ook weer uit het chromosoom worden verwijderd. Omdat 
Voronoi-partities worden gebruikt, wordt het gat automatisch door de omliggende genen opgevuld. 

Hieronder staat de code voor één punt, oftewel het gen. De code voor het chromosoom is vrijwel identiek aan die uit het
vorige artikel, op enkele eenvoudige functies na om genen te dupliceren en een willekeurig gen te verwijderen.

```python
from random import shuffle, randint, choices, choice

class ColoredPoint:
    def __init__(self, img_width, img_height):
        self.coordinates = (randint(0, int(img_width)), randint(0, int(img_height)))
        self.color = (randint(0, 256),  # Random value for the Red channel
                      randint(0, 256),  # Random value for the Green channel
                      randint(0, 256),  # Random value for the Blue channel
                      255)              # The Alpha channel is fixed

    def mutate(self, sigma=1.0):
        mutations = ['shift', 'color']
        weights = [50, 50]

        mutation_type = choices(mutations, weights=weights, k=1)[0]

        if mutation_type == 'shift':
            self.coordinates = (self.coordinates[0] + int(randint(-10, 10)*sigma), self.coordinates[1] + int(randint(-10, 10)*sigma))
        elif mutation_type == 'color':
            red = self.color[0] + int(randint(-25, 25)*sigma)
            green = self.color[1] + int(randint(-25, 25)*sigma)
            blue = self.color[2] + int(randint(-25, 25)*sigma)

            self.color = (red, green, blue, 255)

            # Ensure color is within correct range
            self.color = tuple(
                min(max(c, 0), 255) for c in self.color
            )
```

## Evolutie door duplicatie

Omdat punten gedupliceerd kunnen worden (en dat aanvankelijk geen invloed heeft op de afbeelding), kunnen we met een relatief 
klein aantal punten beginnen en die een tijd laten evolueren tot we dicht bij het 
optimum komen. Daarna kunnen we een *volledige genoomduplicatie* uitvoeren waarbij een chromosoom wordt verdubbeld. Aanvankelijk heeft dat
geen invloed op de afbeelding, maar zodra de gedupliceerde punten uit elkaar beginnen te groeien, kan dat extra complexiteit en een betere overeenkomst
met de doelafbeelding opleveren. Een teveel aan punten werkt echter vrij traag, omdat het tekenen van de afbeelding meer tijd kost (en
aangezien we per generatie honderden afbeeldingen tekenen, speelt dat een rol) en het moeilijker wordt om toevallig een gunstige mutatie te maken.
Om dat op te lossen, moeten we het aantal genen af en toe ook verminderen. (Hoewel ik dit niet heb kunnen testen, 
zou klein beginnen, naar een optimum evolueren, het genoom dupliceren en verder evolueren minder generaties moeten vergen dan 
beginnen met een grotere verzameling willekeurig geïnitialiseerde punten.)

Dit lijkt sterk op gebeurtenissen uit de evolutionaire geschiedenis van heel wat planten en dieren, 
waaronder de mens! 

De strategie waarmee de afbeelding aan het begin van het artikel werd gemaakt, was starten met 250 punten en die gedurende 
ongeveer 1000 generaties laten evolueren. Daarna werd het aantal punten verdubbeld en volgden nog eens 1000 generaties, waarna het genoom werd verkleind door 
100 punten te verwijderen en opnieuw te verdubbelen. Vervolgens mocht de populatie een tijd evolueren en werd ze gedwongen 100 
genen af te stoten. Dat proces werd enkele keren herhaald, met als eindresultaat een afbeelding met 600 punten. 

![De evolutie bij generatie 1, 250, 500, 750, 1000, 1500, 2500, 3500 en 5500](/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/vermeer_evolution.png)

In de afbeelding hierboven zie je het beste individu (uit een populatie van 250) van generatie 1, 250, 500, 750, 1000, 
1500, 2500, 3500 en 5500. Tussen generatie 1000-1500 en 2500-3500 vonden duplicaties plaats, gevolgd door een aantal 
normale evolutionaire stappen en enkele reductiestappen. De complexiteit en het detail van de afbeelding nemen bij die
stappen duidelijk toe.


## Vergelijking met het vorige algoritme

Ik paste deze aanpak ook toe op Van Goghs De sterrennacht, om de visuele stijl van dit algoritme met die van het vorige
te vergelijken. Beide afbeeldingen hebben een vergelijkbare *fitness* (afstand tot het doelschilderij).

<div class="gallery-2-col" markdown="1">
![Van Goghs De sterrennacht met het op Voronoi gebaseerde algoritme](/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/starry_night_voronoi.png)
![Van Goghs De sterrennacht met het op driehoeken gebaseerde algoritme](/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/starry_night_generation_5000.png)
</div>

## Conclusie

Deze aanpak levert de minimalistische stijl op die ik oorspronkelijk voor ogen had en laat tegelijk duplicatie- en verliesgebeurtenissen toe
die de biologie nabootsen. Missie geslaagd! 

De code die hier wordt gebruikt, is grotendeels dezelfde als in het [vorige artikel]({% post_url nl/2020/2020-01-12-Genetic-Art-Algorithm %}), dus ik 
ben er niet erg diep op ingegaan. Alles staat wel op GitHub! Bekijk de
[repository](https://github.com/4dcu-be/Genetic-Art-Algorithm-part-2) voor de volledige werkende code.

[Voronoi-diagram]: https://en.wikipedia.org/wiki/Voronoi_diagram
[Meisje met de parel]: https://en.wikipedia.org/wiki/Girl_with_a_Pearl_Earring
[SciPy]: https://www.scipy.org/
