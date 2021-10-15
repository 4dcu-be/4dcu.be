---
layout: post
title:  "Static Site Generators: Jekyll vs Pelican vs Gatsby"
byline: "which one should you use?"
date:   2020-11-22 13:00:00
author: Sebastian Proost
categories: programming
tags:	python ruby javascript pelican jekyll gatsby
cover:  "/assets/posts/2020-11-22-Static-Web-Generators/generator_header.jpg"
thumbnail: "/assets/images/thumbnails/generator_header.png"
---

There are many static site generators out there! Which one to pick is far from trivial. In this post three generators
used in some of my projects are being compared, helping you pick the right one for your next project!

On [JamStack] there is a long list of generators to choose from, making it seem like an impossible task to pick one for
your next project. If you feel like it is impossible to make a choice, this blog post is for you! Here three widely
different tools, that I used in a few projects this year, are discussed with their strengths and weaknesses.

This is based on (and therefore biased by) my experience with these, feel free to share your opinion in the comment
section below.

## Jekyll

![Jekyll logo](/assets/posts/2020-11-22-Static-Web-Generators/jekyll-logo-2x.png){:.small-image}

[Jekyll], released in 2008, is one of the first static site generators and has grown in popularity as it has 
integrated in GitHub. While it is possible to build a wide variety of sites using Jekyll, at the core it is intended
for blogs. It is rather opinionated about file structure, post metadata, extensions, ... but once you accept these 
patterns it really allows you to forget the web development aspect and focus on the content.

### Pros

Jekyll has been around for over 12 years now and there are plenty of themes and templates available (e.g. [JekyllThemes]). 
There are a number of plugins to extend Jekyll available, which can add useful functionality to your website like
a post-archive, bibliography (for scientific posts which include references), galleries, ...

Any static website can be hosted on GitHub for free, though one that is made using Jekyll can also be built by GitHub.
Add your template and content to a fresh repository, make the repository root the origin for the project page in the 
settings (see below) and you are good to go. Now you actually don't need Jekyll installed locally anymore, you can make
changes to the repository (either locally and commit/push them or directly on GitHub through the online interface), once
the new data hits GitHub's servers they will rebuild the website and changes will appear seconds later online. This 
allows you to add content relatively easy on the road from any device that has a browser and an internet connection.

![GitHub settings page, here you can configure GitHub to build your site](/assets/posts/2020-11-22-Static-Web-Generators/github_settings.png)

A very opinionated system like Jekyll can be a boon, there usually is one, and only one, way to do things. For some this
might feel like a restriction, for others it allows them to just create the content they want without the hassle of 
learning much about web development.

From the three platforms discussed here, Jekyll is the most beginner-friendly! Though all frameworks have some learning 
curve (if you don't like that head over to [wordpress.com]) but my impression is that Jekyll was the quickest to get up 
and running.

### Cons

Jekyll is based on Ruby, not a particularly popular programming language these days, so if you do want/need to extend it, 
you'll have to learn that language. While this is just a small hurdle for minor changes, like the ones I describe in
[this post]({% post_url 2020/2020-03-13-Jekyll-Blog %}), adding in larger features (e.g. adding support for new filetypes) 
would require you to study up on this programming language (which I personally don't have other use for). While there
are great plugins available, the number of plugins is somewhat limited compared to other platforms.

Building your website on GitHub further limits the number of plugins you can use (they only support a handful of 
whitelisted plugins, everything else is off limits). While having GitHub build the page for
your can be convenient, not having access to all plugins (e.g. one to create a post archive for your blog) can make it
impossible to include all features you want. While you can work around this by building the website locally in the 
```/docs``` folder or pushing the build version into the ```gh-pages``` branch. It does take away some of the 
flexibility you have making quick changes through GitHub directly.

While with the right template a Jekyll website can look modern and sleek, it will be somewhat harder to do than with
for instance [Gatsby] which is powered by JavaScript and React out-of-the-box.

### Where to use it ?

I would pick Jekyll in a heartbeat to document a project. As the code will be in GitHub, adding a few 
markdown files in the ```/docs``` folder and picking a template to create simple, but to the point documentation is a
boon. This can also be easily changed and extended though GitHub's system. So anyone that adds a feature to the code
can add the corresponding documentation without having to install any additional tools on their system.

For simple websites, where there are few variable elements that need to updated from time to time, there is also a case 
to be made for Jekyll. Here all work can go into creating the web design and the few variable pieces can be pulled from
a YAML file. Now updating those values is as simple as changing the values in that YAML file and GitHub can take care
of everything else. I can think of plenty of cases, ranging from small businesses, sports clubs, ... where this would be
an efficient way to set up and maintain a website. My previous resume was set up like this, and while I have switched to
one powered by [Gatsby] last week. You can still find the previous version [here](https://sebastian.proost.science/resume-pre2020/).

Both blogs I've set up ([Beyond the Known] and this one), are also powered by Jekyll, though they both use plugins and
customizations that GitHub doesn't support. So these are build locally into the ```/docs``` folder and committed to 
GitHub. A bit more involved, but a similar step is required for all other static site generators.

## Pelican

![Pelican logo](/assets/posts/2020-11-22-Static-Web-Generators/pelly.png){:.small-image}

Given that I'm most proficient with Python, a static site generator which is based on Python sounds very attractive. 
There are a few option available, though Pelican was the most popular of those platforms, so I picked this to play around
with and ultimately created [DeckLock], a website to keep track of decks I have for various collectible card games.   

### Pros

Pelican is powered by Python, which means you can easily leverage all libraries in the Python ecosystem. For instance, 
in [DeckLock] the requests library is used to download data from the web, which is then parsed 
using the JSON library or BeautifulSoup. Each time the site is built, it will get data that is missing automatically
and put it in the corresponding pages. This opens up a ton of avenues for dashboards. You can pull in new data,
update a local SQLite database, do some statistics with pandas and numpy (or even run a machine learning model) and
push the output into a few JSON objects which the template will visualize (e.g. using Charts.js).

The advanced documentation really focuses on Pelican's internals and how to extend them. This is exactly what you need
if you want to create something that goes beyond the scope of blogs, news websites, ...

### Cons

Only a hundred or so themes are available for Pelican (e.g. [Pelican Themes]), and they are often of lower quality than
those for [Jekyll]. So you might not find something that will work for you as is, and will have to spend more time
adjusting the template to your liking.

While getting started with Pelican was easy for someone that has worked with Python before, the learning curve however 
is a little steeper than with Jekyll. 

### Where to use it ?

Pelican is a great option if you need to do some significant processing of your input before it can be turned into
a page. [DeckLock] starts with very limited information (e.g. a decks identifier for a KeyForge deck), pulls in all
information it needs (like the decklist, card art, card details, ... ), does some additional statistics and then turns 
that into a page using a template. While I won't say this is impossible using [Jekyll] or [Gatsby], it will be 
quite a bit more complicated. Being able to leverage amazing packages from the Python ecosystem really gives Pelican a
step up here. 

Where this is not a requirement, [Jekyll] or [Gatsby] are probably better alternatives. Both feel like more mature 
platforms that have more resources available.

## Gatsby

![Gatsbyjs logo](/assets/posts/2020-11-22-Static-Web-Generators/Gatsby.jpg){:.small-image}

The most recent framework I checked and used to build the current version of my resume [http://sebastian.proost.science/](http://sebastian.proost.science/).
[Gatsby] is powered by JavaScript which gives it a distinct advantage over [Jekyll] and [Pelican], it won't just combine
the content with a template... it can also use modern web technology (like react) to build that template. So
if the front-end matters, Gatsby provides a way to incorporate the latest JavaScript tools into your static website.

## Pros

Gatsby will turn a template into a static website, just like Jekyll and Pelican, though the type of template is the
main difference. While the other frameworks will use Jinja to put the content in an HTML template, Gatsby allows you
to build templates using React, GraphQL, React-router and webpack. These modern web technologies allow for some cool
features to be included in your website that would be hard to achieve with the other frameworks.

Along with Gatsby, you get the React ecosystem. This provides you with many great options to include in the layout that
are far more time consuming to include using other frameworks. 

### Cons

Steepest learning curve of the frameworks discussed here. Apart from knowing the frameworks and some HTML + CSS to pull
of the template, Gatsby will require some knowledge of React, modern JavaScript (ES6 is the current flavor), npm, ...
Not something everybody will be able or willing to do.

### Where to use it ?

If you picked up the basics, you can use Gatsby for just about everything you can use Jekyll for. 
The only thing is that you can't get GitHub to build your site, though using [Netlify] that issue can be resolved. So
as long as you are willing to put in the extra time to learn JavaScript, React, npm, ... there is little reason to go
for [Jekyll]

For a niche project like [DeckLock] where all sorts of pre-processing is necessary to build a page Python might have better
options. So here [Pelican] could be an advantage, though with some extra effort this can be pulled of in JS and hence
Gatsby as well.

## Conclusion

I must admit I didn't think highly about statically generated sites a few year ago. Mostly because my first
encounter with a statically generated site was abysmal. It simply wasn't the right tool for that job, but a misguided 
attempt at avoiding the use of a proper database. With a terrible implementation on top, having to maintain that code 
was a major pain...

However, while working on a few blogs, [DeckLock] and [my resume] I have come around completely on this. Where
appropriate this can be a great option to create fast-loading websites that are cheap (or even free) to host and easy to 
maintain.

My personal pick for future projects will likely be [Gatsby], I've already learned the basics and this gives the best 
options to include modern web technology in the front end. [Jekyll] I'll probably phase out in favor of Gatsby, though 
for quickly creating neat documentation on GitHub it is still the most efficient option. So I don't expect to abandon it
completely in the near future. [Pelican] turned out to be a great option for [DeckLock] though this is
a rather niche case, for more mainstream applications there are better options.

## Acknowledgements

Header image by [Jayphen Simpson] on [Unsplash]

[JamStack]: https://jamstack.org/generators/
[Jekyll]: https://jekyllrb.com/
[Gatsby]: https://www.gatsbyjs.com/
[Pelican]: https://docs.getpelican.com/en/latest/
[JekyllThemes]: http://jekyllthemes.org/
[Beyond the Known]: https://www.beyond-the-known.eu/
[DeckLock]: {% post_url 2020/2020-04-05-DeckLock %}
[Pelican Themes]: http://www.pelicanthemes.com/
[wordpress.com]: https://wordpress.com/
[Netlify]: https://www.netlify.com/
[my resume]: http://sebastian.proost.science/
[Jayphen Simpson]: https://unsplash.com/@jayphen
[Unsplash]: https://unsplash.com/s/photos/generator
