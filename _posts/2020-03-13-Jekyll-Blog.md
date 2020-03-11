---
layout: post
title:  "Jekyll Plugins"
byline: "lift your blog to a higher level"
date:   2020-03-13 12:00:00
author: Sebastian Proost
categories: programming
tags:	ruby jekyll blog
cover:  "/assets/posts/2020-03-13-Jekyll-Blog/map_extension.png"
thumbnail: "/assets/images/thumbnails/jekyll_map.jpg"

gallery_items:
  - image: "/assets/posts/2020-03-13-Jekyll-Blog/map_extension.png"
    gallery_image: "/assets/images/gallery/map_extension.jpg"
    description: "Jekyll plugin to mark where a blog post was written, great for a travel blog."

---

This blog is build using [Jekyll], which can be used to generate a static website based on a set of templates (for the
layout) and markdown files (for the content). The main advantage is that GitHub pages can be leveraged to host those
static pages for free. However, while there are plenty of great [themes] available, some feature I really wanted were
missing. Fortunately, [Jekyll] supports plugins to fill those gaps, here you'll read about some plugins I made for this
blog and [Beyond the Known] (a travel blog).

## Getting started

For both blogs I'm involved in, the [Centrarium] theme was used as a starting point. This them already included many 
features I wanted. There really isn't any need to re-invent the wheel for every project. I did make a number of changes
to the theme, for instance I removed support for [HighlightJS] in favor for default code highlighter present in Jekyll.
I also prefer [LightGallery] over [Lightbox], so I swapped that out as well. 

These changes are pure html and css, you just need to pinpoint where the relevant code in the **\_includes** or 
**\_layouts** folder and make the change. Including other options did prove to be more challenging. 

## Automatic LightGallery links for all images

In markdown you have a rather simple way to include an image.

```markdown
 ![image_description](path/to/the/image.jpg)
```

Technically, you should add the website's baseurl to the path. This way the site will work also when hosted in a 
sub-directory. This can be done by adding **{%raw%}{{ site.baseurl }}{%endraw%}** before the path. However if you ever want to 
use the markdown files with another framework this will come back to haunt you... To include the image, with all the 
required features for LightGallery, you need to add everything in pure html.

{% raw %}
```html
<a href="{{ site.baseurl }}/path/to/the/image.jpg" class="lightgallery-link" data-sub-html="image_description">
<img alt="image_description" data-src="{{ site.baseurl }}/path/to/the/image.jpg" src="{{ site.baseurl }}/path/to/the/image.jpg" />
</a>"
```
{% endraw %}

This is extremely verbose so adding a few images to a post will decrease the readability of the markdown. Furthermore,
the url needs to be repeated three times, the description twice. This irked me ... a lot! I would like to use the basic
syntax in my markdown files, but convert this to the html when building the page. This can be done using a 
**Jekyll Hook**. 

To do this a folder **\_plugins** needs to be created in your project, and a file **lightgallery_links.rb** with the 
code below needs to be added.

{% raw %}
```ruby
Jekyll::Hooks.register :posts, :pre_render do |post, payload|
  docExt = post.extname.tr('.', '')
  post.content.gsub!(/^!\[(.*)\]\(([^\)]+)\)((?:{:[^}]+})*)/, "<a href=\"{{ site.baseurl }}\\2\" class=\"lightgallery-link\" data-sub-html=\"\\1\">\n![\\1]({{ site.baseurl }}\\2)\\3{:data-src=\"{{ site.baseurl }}\\2\"}\n</a>")
end
```
{% endraw %}

The cryptic line is a regular expression that will detect image tags in standard markdown syntax, wrap them with the html
link tags and add a section to set the data-src of the image correctly. This will only be applied to images that are
defined at the start of the line, so it can still be disabled by simply putting a space in front of the image 
declaration.

## Thumbnail generator



## An image gallery



[Jekyll]: https://jekyllrb.com/
[themes]: http://jekyllthemes.org/
[Beyond the Known]: http://beyond-the-known.eu/
[Centrarium]: https://github.com/bencentra/centrarium
[LightGallery]: http://sachinchoolur.github.io/lightGallery/
[Lightbox]: https://lokeshdhakar.com/projects/lightbox2/
[HighlightJS]: https://highlightjs.org/
