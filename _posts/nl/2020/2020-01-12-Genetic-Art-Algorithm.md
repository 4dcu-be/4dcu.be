---
layout: post
title:  "Genetisch kunstalgoritme"
byline: "Van Goghs De sterrennacht natekenen met een genetisch algoritme"
description: "Een genetisch algoritme in Python bouwen met de Evol-bibliotheek, dat 150 willekeurige driehoeken gedurende 5000 generaties laat evolueren om Van Goghs De sterrennacht na te tekenen."
date:   2020-01-12 12:00:00
author: Sebastian Proost
post_id: genetic-art-algorithm
categories: programming
tags:	python evolution genetic-algorithm algorithm art
cover:  "/assets/posts/2020-01-12-Genetic-Art-Algorithm/post_header.jpg"
thumbnail: "/assets/images/thumbnails/starry_night_generation_5000.jpg"
github: "https://github.com/4dcu-be/Genetic-Art-Algorithm"

gallery_items:
  - image: "/assets/posts/2020-01-12-Genetic-Art-Algorithm/post_header.jpg"
    gallery_image: "/assets/images/gallery/starry_night.jpg"
    description: "Van Goghs De sterrennacht, opgebouwd uit 150 driehoeken die door een genetisch algoritme werden geplaatst."

---

Genetische algoritmen zijn leuk, want ze vragen een andere manier van denken. Hier neem ik je mee door mijn proces om een 
algoritme te bouwen dat 150 willekeurige driehoeken laat evolueren tot een beroemd kunstwerk. Het werk dat ik koos om na te tekenen: Van Goghs 
[De sterrennacht]. Het origineel en de versie die het algoritme na 5000 generaties maakte, zie je hieronder.

<div class="gallery-2-col" markdown="1">
![Het origineel van Van Gogh, getiteld De sterrennacht](/assets/posts/2020-01-12-Genetic-Art-Algorithm/starry_night_full.jpg)
![De uitvoer van het algoritme na 5000 generaties](/assets/posts/2020-01-12-Genetic-Art-Algorithm/starry_night_generation_5000.png)
</div>

De code voor deze post vind je [hier](https://github.com/4dcu-be/Genetic-Art-Algorithm) op GitHub.

**Update 25/03/2021**: In versie 0.5.2 wijzigde de Evol-API: de functie ```apply()``` werd 
hernoemd naar ```callback()```. De code hier en in de repository werd bijgewerkt.

## Genetische algoritmen

Voor we beginnen, eerst een korte uitleg over genetische algoritmen. Op [WikiPedia] staat een vrij uitvoerige beschrijving,
maar hier houden we het kort en eenvoudig. Deze algoritmen zijn sterk gebaseerd op biologische principes zoals overerving, voortplanting en evolutie. Je hebt een aantal oplossingen, die samen de 
**populatie** vormen. Elke **individuele** oplossing heeft een lijst met onderdelen, waarden, ... die het **chromosoom** wordt genoemd. Een
**fitnessfunctie** beoordeelt hoe goed een bepaalde oplossing voor ons probleem is. Binnen deze populatie kunnen individuen
worden verwijderd (die met de slechtste fitheid), zich **voortplanten** (hun chromosomen combineren tot een nieuw individu) en 
**muteren** (willekeurige wijzigingen in het chromosoom aanbrengen).

In deze context:

  * de **populatie** is een verzameling van 200 schilderijen
  * elk **individu** is één schilderij
  * het **chromosoom** is een lijst van 150 driehoeken met een bepaalde vorm, positie en kleur (rood, groen, blauw en ondoorzichtigheid)
  * de **fitness** is de afstand tot het doelschilderij op basis van pixels (we moeten deze score minimaliseren)
  * individuen kunnen zich **voortplanten** en een nieuw schilderij maken met de helft van de driehoeken van de ene **ouder** en de helft van de andere
  * individuen kunnen **muteren**: driehoeken kunnen bewegen, van vorm of kleur veranderen, van positie in het chromosoom wisselen of opnieuw worden ingesteld
  * de populatie kan door een **flessenhals** gaan, waarbij een groot deel van de individuen (met de slechtste fitness) wordt
  weggegooid en de overlevenden vervolgens worden gebruikt om de populatie opnieuw tot de gewenste grootte te laten groeien


## Het algoritme implementeren in Python

Zelf alle stappen programmeren zou niet zo moeilijk zijn, maar [Evol]
biedt een geweldige API die alle scoring, voortplanting, ... afhandelt en ingebouwde multiprocessing heeft om
de fitness van elk individu in een populatie te berekenen.

### De klasse Triangle

Een chromosoom is hier een lijst van driehoeken. Eén driehoek heeft drie punten met x- en y-coördinaten en een kleur met 
ondoorzichtigheid. Tijdens een mutatie kunnen verschillende wijzigingen optreden: de driehoek kan bewegen (alle punten verschuiven), van vorm veranderen (punten
afzonderlijk verplaatsen) of van kleur veranderen. Er is ook een ingrijpendere gebeurtenis die de huidige driehoek vernietigt en
vervangt door een volledig willekeurige. De functie `.mutate` regelt dit allemaal. Met de waarde sigma kun je de
sterkte van een mutatie opgeven (hoe groot de verandering is), terwijl de gewichten bepalen welke soorten 
mutaties vaker optreden dan andere.

{:.large-code}
```python
import random


class Triangle:
    def __init__(self, img_width, img_height):
        x = random.randint(0, int(img_width))
        y = random.randint(0, int(img_height))

        self.points = [
            (x + random.randint(-50, 50), y + random.randint(-50, 50)),
            (x + random.randint(-50, 50), y + random.randint(-50, 50)),
            (x + random.randint(-50, 50), y + random.randint(-50, 50))]
        self.color = (
            random.randint(0, 256),
            random.randint(0, 256),
            random.randint(0, 256),
            random.randint(0, 256)
        )

        self._img_width = img_width
        self._img_height = img_height

    def __repr__(self):
        return "Trangle: %s in color %s" % (','.join([str(p) for p in self.points]), str(self.color))

    def mutate(self, sigma=1.0):
        mutations = ['shift', 'point', 'color', 'reset']
        weights = [30, 35, 30, 5]

        mutation_type = random.choices(mutations, weights=weights, k=1)[0]

        if mutation_type == 'shift':
            x_shift = int(random.randint(-50, 50)*sigma)
            y_shift = int(random.randint(-50, 50)*sigma)
            self.points = [(x + x_shift, y + y_shift) for x, y in self.points]
        elif mutation_type == 'point':
            index = random.choice(list(range(len(self.points))))

            self.points[index] = (self.points[index][0] + int(random.randint(-50, 50)*sigma),
                                  self.points[index][1] + int(random.randint(-50, 50)*sigma),)
        elif mutation_type == 'color':
            self.color = tuple(
                c + int(random.randint(-50, 50)*sigma) for c in self.color
            )

            # Ensure color is within correct range
            self.color = tuple(
                min(max(c, 0), 255) for c in self.color
            )
        else:
            new_triangle = Triangle(self._img_width, self._img_height)

            self.points = new_triangle.points
            self.color = new_triangle.color
```
 

### De klasse Painting

Het schilderij bevat een lijst met Triangles, samen met de nodige functies om de driehoeken te tekenen (met de 
[Pillow]-bibliotheek) en de afbeelding met het doel te vergelijken (met de 
[Imagecompare]-bibliotheek). Verder is er een functie om twee schilderijen te kruisen. Die is
geïnspireerd op **crossing-over** in de biologie, waarbij twee chromosomen stukken uitwisselen om twee nieuwe chromosomen te maken.

{:.large-code}
```python
from triangle import Triangle
from random import shuffle, randint
from PIL import Image, ImageDraw
from imgcompare import image_diff
import random


class Painting:
    def __init__(self, num_triangles, target_image, background_color=(0, 0, 0)):
        self._img_width, self._img_height = target_image.size
        self.triangles = [Triangle(self._img_width, self._img_height) for _ in range(num_triangles)]
        self._background_color = (*background_color, 255)
        self.target_image = target_image

    @property
    def get_background_color(self):
        return self._background_color[:3]

    @property
    def get_img_width(self):
        return self._img_width

    @property
    def get_img_height(self):
        return self._img_height

    @property
    def num_triangles(self):
        return len(self.triangles)

    def __repr__(self):
        return "Painting with %d triangles" % self.num_triangles

    def mutate_triangles(self, rate=0.04, swap=0.5, sigma=1.0):
        total_mutations = int(rate*self.num_triangles)
        random_indices = list(range(self.num_triangles))
        shuffle(random_indices)

        # mutate random triangles
        for i in range(total_mutations):
            index = random_indices[i]
            self.triangles[index].mutate(sigma=sigma)

        # Swap two triangles randomly
        if random.random() < swap:
            shuffle(random_indices)
            self.triangles[random_indices[0]], self.triangles[random_indices[1]] = self.triangles[random_indices[1]], self.triangles[random_indices[0]]

    def draw(self, scale=1) -> Image:
        image = Image.new("RGBA", (self._img_width*scale, self._img_height*scale))
        draw = ImageDraw.Draw(image)

        if not hasattr(self, '_background_color'):
            self._background_color = (0, 0, 0, 255)

        draw.polygon([(0, 0), (0, self._img_height*scale), (self._img_width*scale, self._img_height*scale), (self._img_width*scale, 0)],
                     fill=self._background_color)

        for t in self.triangles:
            new_triangle = Image.new("RGBA", (self._img_width*scale, self._img_height*scale))
            tdraw = ImageDraw.Draw(new_triangle)
            tdraw.polygon([(x*scale, y*scale) for x, y in t.points], fill=t.color)

            image = Image.alpha_composite(image, new_triangle)

        return image

    @staticmethod
    def _mate_possible(a, b) -> bool:
        return all([a.num_triangles == b.num_triangles,
                   a.get_img_width == b.get_img_width,
                   a.get_img_height == b.get_img_height])

    @staticmethod
    def mate(a, b):
        if not Painting._mate_possible(a, b):
            raise Exception("Cannot mate images with different dimensions or number of triangles")

        ab = a.get_background_color
        bb = b.get_background_color
        new_background = (int((ab[i] + bb[i])/2) for i in range(3))

        child_a = Painting(0, a.target_image, background_color=new_background)
        child_b = Painting(0, a.target_image, background_color=new_background)

        for at, bt in zip(a.triangles, b.triangles):
            if randint(0, 1) == 0:
                child_a.triangles.append(at)
                child_b.triangles.append(bt)
            else:
                child_a.triangles.append(bt)
                child_b.triangles.append(at)

        return child_a, child_b

    def image_diff(self, target: Image) -> float:
        source = self.draw()

        return image_diff(source, target)

```

### Het algoritme samenstellen

Het pakket [Evol] neemt het meeste werk voor zijn rekening, maar we moeten wel enkele functies definiëren om te 
beginnen. We hebben een scorefunctie nodig die de afstand tot de doelafbeelding controleert, een functie die bepaalt hoe individuen
een partner vinden om mee te kruisen en een definitie van hoe we de populatie willen laten evolueren. We voegen ook een functie toe die de
fitnessscores weergeeft (zodat we zien of er nog vooruitgang is), de afbeelding van het beste individu opslaat en
de populatie om de vijftig generaties bewaart (zodat we niet opnieuw hoeven te beginnen als er iets misgaat).

{:.large-code}
```python
from PIL import Image
from evol import Evolution, Population

import random
import os
from copy import deepcopy

from painting import Painting


def score(x: Painting) -> float:
    """
    Calculate the distance to the target image
    
    :param x: a Painting object to calculate the distance for
    :return: distance based on pixel differences
    """
    current_score = x.image_diff(x.target_image)
    print(".", end='', flush=True)
    return current_score


def pick_best_and_random(pop, maximize=False):
    """
    Here we select the best individual from a population and pair it with a random individual from a population
    
    :param pop: input population
    :param maximize: when true a higher fitness score is better, otherwise a lower score is considered better
    :return: a tuple with the best and a random individual
    """
    evaluated_individuals = tuple(filter(lambda x: x.fitness is not None, pop))
    if len(evaluated_individuals) > 0:
        mom = max(evaluated_individuals, key=lambda x: x.fitness if maximize else -x.fitness)
    else:
        mom = random.choice(pop)
    dad = random.choice(pop)
    return mom, dad


def mutate_painting(x: Painting, rate=0.04, swap=0.5, sigma=1) -> Painting:
    """
    This will mutate a painting by randomly applying changes to the triangles.
    
    :param x: Painting to mutate
    :param rate: the chance a triangle will be mutated
    :param swap: the chance a pair of traingles will be swapped
    :param sigma: the strenght of the mutation (how much a triangle can be changed)
    :return: New painting object with mutations
    """
    x.mutate_triangles(rate=rate, swap=swap, sigma=sigma)
    return deepcopy(x)


def mate(mom: Painting, dad: Painting):
    """
    Takes two paintings, the mom and dad, to create a new painting object made up with triangles from both parents
    
    :param mom: One parent painting
    :param dad: Other parent painting
    :return: new Painting with features from both parents
    """
    child_a, child_b = Painting.mate(mom, dad)

    return deepcopy(child_a)


def print_summary(pop, img_template="output%d.png", checkpoint_path="output") -> Population:
    """
    This will print a summary of the population fitness and store an image of the best individual of the current
    generation. Every fifty generations the entire population is stored.
    
    :param pop: Population
    :param img_template: a template for the name of the output images, should contain %d as the number of the generation is included
    :param checkpoint_path: directory to write output.
    :return: The input population
    """
    avg_fitness = sum([i.fitness for i in pop.individuals])/len(pop.individuals)

    print("\nCurrent generation %d, best score %f, pop. avg. %f " % (pop.generation,
                                                                     pop.current_best.fitness,
                                                                     avg_fitness))
    img = pop.current_best.chromosome.draw()
    img.save(img_template % pop.generation, 'PNG')

    if pop.generation % 50 == 0:
        pop.checkpoint(target=checkpoint_path, method='pickle')

    return pop


if __name__ == "__main__":
    target_image_path = "./img/starry_night_half.jpg"
    checkpoint_path = "./starry_night/"
    image_template = os.path.join(checkpoint_path, "drawing_%05d.png")
    target_image = Image.open(target_image_path).convert('RGBA')

    num_triangles = 150
    population_size = 200

    pop = Population(chromosomes=[Painting(num_triangles, target_image, background_color=(255, 255, 255)) for _ in range(population_size)],
                     eval_function=score, maximize=False, concurrent_workers=6)

    evolution = (Evolution()
                 .survive(fraction=0.05)
                 .breed(parent_picker=pick_best_and_random, combiner=mate, population_size=population_size)
                 .mutate(mutate_function=mutate_painting, rate=0.05, swap=0.25)
                 .evaluate(lazy=False)
                 .callback(print_summary,
                           img_template=image_template,
                           checkpoint_path=checkpoint_path))

    pop = pop.evolve(evolution, n=5000)
``` 

## De uitvoer

Hier zie je het beste individu uit generatie 1, 250, 500, 750, 1000, 1500, 2500, 3500 en 4500 (van links naar rechts, 
van boven naar beneden).

![Uitvoer na verschillende generaties](/assets/posts/2020-01-12-Genetic-Art-Algorithm/evolution_grid.png)


### Verschillende uitvoeringen, verschillende resultaten

Omdat zowel het begin van de evolutie als alle mutaties en voortplantingsgebeurtenissen willekeurig zijn, kan de uitvoer
tussen uitvoeringen verschillen. Hieronder zie je het resultaat van twee onafhankelijke uitvoeringen van elk 5000 generaties. Hoewel
deze afbeeldingen een vergelijkbare afstand tot de doelafbeelding hebben, verschillen ze sterk van elkaar.

<div class="gallery-2-col" markdown="1">
![De uitvoer van het algoritme na 5000 generaties](/assets/posts/2020-01-12-Genetic-Art-Algorithm/starry_night_generation_5000.png)
![De uitvoer van het algoritme na een tweede uitvoering van 5000 generaties](/assets/posts/2020-01-12-Genetic-Art-Algorithm/starry_night_generation_5000.run_2.png)
</div>

## Conclusie en vooruitblik

Deze resultaten zijn behoorlijk gaaf. Omdat er heel weinig verschil is tussen generatie 4500 en 5000, is dit waarschijnlijk
ongeveer het beste wat met slechts 150 driehoeken haalbaar is. Toch zijn er enkele mogelijke verbeteringen. Het algoritme
probeert zoveel mogelijk pixels correct te benaderen. Correcte pixels in grote egale vlakken leveren dus een veel betere score op
dan correcte details. Je zou een masker kunnen maken dat gedetailleerde gebieden markeert en correcte pixels in die
gebieden extra beloont.

De chromosomen zijn in dit geval erg statisch: ze hebben altijd dezelfde lengte (150 onderdelen) en afgezien van het occasioneel
verwisselen van onderdelen gebeurt er niets. In de natuur evolueert de grootte van chromosomen voortdurend en is duplicatie van genen vaak een 
bron van innovatie. Je zou de mutatiefunctie kunnen aanpassen om af en toe een extra driehoek toe te voegen, of
complexere manieren kunnen bedenken om schilderijen te kruisen zodat lijsten met verschillende aantallen onderdelen samen kunnen worden gebruikt. Extra
driehoeken moeten echter een kost hebben die in de fitness wordt meegerekend. In de natuur betekent een
groter genoom dat bij elke celdeling meer DNA moet worden gekopieerd, waardoor genomen niet onbeperkt groot kunnen worden. Ook hier is
een vergelijkbare straf in de fitness nodig. Deze extra parameter afstellen kan moeilijk zijn.

Tot slot kunnen andere stijlen worden gebruikt. Ik koos hier voor een beperkt aantal driehoeken omdat dit het eerste 
idee was dat bij de start van het project in me opkwam. Tijdens het werk ontstonden echter nog enkele andere (en mogelijk 
betere) ideeën. Die werk ik uit en behandel ik in een latere post!



[WikiPedia]: https://en.wikipedia.org/wiki/Genetic_algorithm
[Evol]: https://evol.readthedocs.io/en/latest/#
[Pillow]: https://pillow.readthedocs.io/en/stable/
[Imagecompare]: https://github.com/datenhahn/imgcompare
[De sterrennacht]: https://en.wikipedia.org/wiki/The_Starry_Night
