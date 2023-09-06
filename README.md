[![pages-build-deployment](https://github.com/4dcu-be/4dcu.be/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/4dcu-be/4dcu.be/actions/workflows/pages/pages-build-deployment)

# 4DCu.be

![sticker](./assets/sticker_medium.png)

Code for Sebastian Proost's blog about programming, gaming, technology, ...
 

## Features

This theme comes with a number of features, including:
* Easily customizable fonts and colors
* Cover images for your homepage and blog posts
* Pagination enabled by default
* Archiving of posts by categories and tags
* Syntax highlighting for code snippets
* Lightgallery for viewing full-screen photos and albums
* Social media integration (Twitter, Facebook, LinkedIn, GitHub, and more)
* Thumbnail generator
* Gallery generator (to highlight the best images)
* AOS integration (Animate on Scroll)

## Installation

Feel free to use this template as the base for your blog. Just 
download this project and add all the files to your project. Add your blog posts to the `posts/` directory, 
and create your pages with the proper Jekyll front matter (see `posts.html` for an example).

Installing Jekyll and the dependencies:

```bash
# cd into project directory
cd 4dcu.be
# install Bundler if you don't have it already
gem install bundler
# install jekyll, jekyll-archives, jekyll-sitemap, mini_magick and jekyll-paginate-v2
bundle install
```

You will need to install [ImageMagick](https://imagemagick.org/) on your system as well for the thumbnail generation.

__NOTE :__ This theme is not compatible with github pages as it uses a custom plugin. 
[Here is a guide](http://ixti.net/software/2013/01/28/using-jekyll-plugins-on-github-pages.html) how to host it on 
github. In a nutshell, the trick is to build the website to the `./docs` locally and commit/push this along with the 
other files. GitHub can then be set up to host the site directly from the `./docs` folder.

## Building the site

On windows you can use the batch files included. run_server.bat will start the development server and the site will
become available locally on localhost:4000. To build the site into the docs folder (requirement to host on GitHub) use
run_build.bat

```commandline
run_server.bat
run_build.bat
```

The command to start the dev server is (without using the batch file):

```commandline
bundle exec jekyll serve --config _config_dev.yml
```

The underlaying command to (re-)build the website is:

```commandline
bundle exec jekyll build --config _config.yml
```


## Configuration

All configuration options can be found in `_config.yml`.

### Site Settings

* __title:__ The title for your site. Displayed in the navigation menu, the `index.html` header, and the footer.
* __subtitle:__ The subtitle of your site. Displayed in the `index.html` header.
* __email:__ Your email address, displayed with the Contact info in the footer.
* __name:__ Your name. _Currently unused._
* __description:__ The description of your site. Used for search engine results and displayed in the footer.
* __baseurl:__ The subpath of your site (e.g. /blog/).
* __url:__ The base hostname and protocol for your site.
* __cover:__ The relative path to your site's cover image.
* __logo:__ The relative path to your site's logo. Used in the navigation menu instead of the title if provided.
* __sticker:__ The relative path to your site's sticker/mascot, can be added behind the page title.
* __thumbnail__:
  * __resize_dimensions__: e.g. '430x288^' size of the thumbnails
  * __crop_dimensions__: e.g. '430x288+0+0' how to crop the thumbnail

### Build Settings

* __markdown:__ Markdown parsing engine. Default is kramdown.
* __inter_post_navigation:__ Whether to render links to the next and previous post on each post.

### Pagination settings

See the documentation for [jekyll-paginate-v2](https://github.com/sverrirs/jekyll-paginate-v2/blob/master/README-GENERATOR.md#site-configuration) for more details.

### Archive Settings

Although this theme comes with a combined, categorized archive (see `posts.html`), you can enable further archive
creation thanks to [jekyll-archives][archives]. Support for category and tag archive pages is included, but you can also
add your own archive pages for years, months, and days.

To change archive settings, see the __jekyll-archives__ section of `_config.yml`:

```yml
jekyll-archives:
  enabled:
    - categories
    - tags
  layout: 'archive'
  permalinks:
    category: '/category/:name/'
    tag: '/tag/:name/'
```

A sitemap is also generated using [jekyll-sitemap][sitemap].


### Social Settings

Your personal social network settings are combined with the social sharing options. In the __social__ section of `_config.yml`, include an entry for each network you want to include. For example:

```yml
social:
  - name: Twitter                             # Name of the service
    icon: twitter                             # Font Awesome icon to use (minus fa- prefix)
    username: ProostSebastian                 # (User) Name to display in the footer link
    url: https://twitter.com/ProostSebastian  # URL of your profile (leave blank to not display in footer)
    desc: Follow me on Twitter                # Description to display as link title, etc
    share: true                               # Include in the "Share" section of posts
```

### Social Protocols

Using the Open Graph Protocol or Twitter Card metadata, you can automatically set the images and text used when people
share your site on Twitter or Facebook. These take a bit of setup, but are well worth it. The relevant fields are at the
end of the `_config.yml` file.

Also there is another protocol, the Open Source protocol, for saying where your site is hosted if the source is open.
This helps develops more easily see your code if they are interested, or if they have issues. For more, see
http://osprotocol.com.

### Category Descriptions

You can enhance the `posts.html` archive page with descriptions of your post categories. See the __descriptions__
section of `_config.yml`:

```yml
# Category descriptions (for archive pages)
descriptions:
  - cat: jekyll
    desc: "Posts describing Jekyll setup techniques."
```

### Custom Page-Specific Javascript

You can add page-specific javascript files by adding them to the top-level `/js` directory and including the filename in
the __custom_js__ page's configuration file:

```yml
# Custom js (for individual pages)
---
layout: post
title:  "Dummy Post"
date:   2020-02-09 12:00:00
author: Sebastian Proost
categories: Dummy
custom_js:
- Popmotion
- Vue
---
```

The `/js/` directory would contain the corresponding files:

```bash
$ ls js/
Popmotion.js Vue.js
```

## Modifying the theme

### Updating Header and Footer Links

Links in the header and footer are auto-generated. Links will be made for all files marked `category: page`, that have a
 title, and have the custom `main_nav` front-matter variable set to `true`. You can modify the rules for link generation
 in `_layouts/nav_links.html`.

### Updating Styles

If you want change the CSS of the theme, you'll probably want to check out these files in the `_sass/` directory:

* `base/_variables.scss`: Common values found throughout the project, including base font size, font families, colors, and more.
* `base/_typography.scss`: Base typography values for the site (see `typography.html` for a demonstration)
* `_layout.scss`: The primary styles for the layout and design of the theme.
* Update the images for logo, stickers ... in `assets/`

#### Important Variables

Here are the important variables from `base/_variables.scss` you can tweak to customize the theme to your liking:

* `$base-font-family`: The font-family of the body text. Make sure to `@import` any new fonts!
* `$heading-font-family`: The font-family of the headers. Make sure to `@import` any new fonts!
* `$base-font-size`: The base font-size. Defaults to $em-base from Bourbon (`bourbon/settings/_px-to-em.scss`).
* `$base-font-color`: The color for the body text.
* `$action-color`: The color for links in the body text.
* `$highlight-color`: The color for the footer and page headers (when no cover image provided).


## License

MIT. See [LICENSE.MD](https://github.com/4dcu-be/4dcu.be/blob/master/LICENSE.md).

## Acknowledgements

4DCu.be is based on a jekyll theme by [Ben Centra][Ben Centra]. 

Which includes these awesome libraries:
* [Bourbon][bourbon]
* [Neat][neat]
* [Bitters][bitters]
* [Refills][refills]
* [Font Awesome][fontawesome]
* [Lightgallery][Lightgallery]
* [AOS][AOS]

[bourbon]: http://bourbon.io/
[neat]: http://neat.bourbon.io/
[bitters]: http://bitters.bourbon.io/
[refills]: http://refills.bourbon.io/
[fontawesome]: http://fortawesome.github.io/Font-Awesome/
[Lightgallery]: https://sachinchoolur.github.io/lightgallery.js/
[AOS]: https://michalsnik.github.io/aos/
[archives]: https://github.com/jekyll/jekyll-archives
[sitemap]: https://github.com/jekyll/jekyll-sitemap
[Ben Centra]: http://bencentra.github.io/centrarium/
