---
layout: page
title: "Gallery"
permalink: /gallery/
main_nav: true
cover:  "/assets/images/headers/gameboyzero.jpg"
cover_options: narrow
sitemap: true
---
<div class="gallery-items">
{% for post in site.posts -%}
  {% for item in post.gallery_items -%}
  <div class="gallery-item">
    <a href="{{ item.image | prepend: site.baseurl }}" class="lightgallery-link" data-sub-html="{{ item.description }} <a href='{{ post.url }}'>Read more ...</a>"><img src="{{ item.gallery_image | prepend: site.baseurl }}" data-src="{{ item.image | prepend: site.baseurl }}" alt="Image from post: {{ post.title|strip_html}}" /></a>
  </div>
  {%- endfor %}
{%- endfor %}
</div>

<br />
![Box with things](/assets/box_medium.png){:.small}
