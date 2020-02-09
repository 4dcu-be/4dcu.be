---
layout: post
title:  "Minimalist Art Using a Genetic Algorithm"
byline: "a different take on Vermeer's Girl with a Pearl Earring"
date:   2020-02-10 12:00:00
author: Sebastian Proost
categories: programming
tags:	python evolution genetic-algorithm algorithm art
cover:  "/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/vermeer_header.jpg"
thumbnail: "/assets/images/thumbnails/vermeer_header.jpg"
github: "https://github.com/4dcu-be/Genetic-Art-Algorithm"

gallery_items:
  - image: "/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/vermeer_generation_05600.png"
    gallery_image: "/assets/images/gallery/vermeer_generation_5600.jpg"
    description: "Van Gogh's The Starry Night generated using 150 triangles placed by a genetic algorithm."

---

While the genetic algorithm in the [previous post]({% post_url 2020-01-12-Genetic-Art-Algorithm %})
worked very well, it didn't quite produce the style of minimalist artwork I was hoping for. Furthermore, it didn't allow
the chromosomes to evolve using duplication and deletion of existing genes in a way that is very common in biology. So
after mulling over these issues a few days, I found a solution using a [Voronoi diagram]. The final 
result (shown below) is much closer to what I was aiming for. The painting to re-drawn by the algorithm this time is
Vermeer's [Girl with a Pearl Earring].

<div class="gallery-2-col" markdown="1">
![Vermeer's Girl with a Pearl Earring](/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/girl_with_pearl_earring.jpg)
![The output of the algorithm after 5600 generations](/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/vermeer_generation_05600.png)
</div>

## Voronoi diagrams (aka partitions)

You can find a detailed explanation on what Voronoi diagrams are [here](https://youtu.be/Q804hv73L6U?t=66).
The plot below illustrates the principle as well, each blue point is an input point. Black edges are equidistant between
two points and orange points (endpoints of an edge) are equidistant between three neighbors. This creates a polygon 
around each input point that is convex and non-overlapping. These polygons can be colored and drawn as solid shapes 
which creates a cell pattern.

<div class="gallery-2-col" markdown="1">
![Voronoi plot, blue dots are the input](/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/voronoi_plot.png)
![Colored the individual polygons of the plot](/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/voronoi_polygons.png)
</div>

In Python Voronoi diagrams can easily be created and draw from a list of points using the **Voronoi** and **voronoi_plot_2d**
functions which are included in [SciPy].

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

## An individual's chromosome

Here the chromosome is a list of 2D points, each with an RGB color attached to it. These points can move, or the color
can shift in a mutation step. The order of the points doesn't matter, making a copy of a point and adding it to the end
of the chromosome doesn't have an impact on the image it produces. However it does provide additional 'genetic material'
that can evolve and can create complexity. Points can also be removed again.

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

This allows us to start with a relatively small number of points, evolve these for a while until we get close to the 
optimal. Then we can trigger a 'whole genome duplication' where a chromosome is doubled. This will initially have no
impact on the image, but as the duplicate points start to diverge can create additional complexity and a better fit
to the target image. However an excess of points will run rather slowly as it will take more time to draw the image (and
since we are drawing hundreds of images each generation this matters) and it will be harder to make a beneficial mutation.
To solve this issue we need to reduce the number of genes every so often as well.

The strategy used to generate the image in the beginning of the post was to start with 250 points and evolve them for 
~1000 generations, then double the number of points and evolve for another 1000 generations and double again. Then 
the population was left to evolve for a while and then force to shed 100 genes, this process was repeated a few times 
to end up with a final image that contains 600 points. 

![The evolution at generation 1, 250, 500, 750, 1000, 1500, 2500, 3500 and 5500](/assets/posts/2020-02-10-Genetic-Art-Algorithm-2/vermeer_evolution.png)

In the image above you can see the best individual (out of a population of 250) of generation 1, 250, 500, 750, 1000, 
1500, 2500, 3500 and 5500. The last four images have a whole genome duplication, followed by a number of evolutionary
steps, and a genome reduction (removing 100-200 points) between them. As in biology this is a great way to increase the
complexity of the output.

The code to achieve this is mostly the same as the [previous post]({% post_url 2020-01-12-Genetic-Art-Algorithm %}), 
check the repository 



[Voronoi diagram]: https://en.wikipedia.org/wiki/Voronoi_diagram
[Girl with a Pearl Earring]: https://en.wikipedia.org/wiki/Girl_with_a_Pearl_Earring
[SciPy]: https://www.scipy.org/
