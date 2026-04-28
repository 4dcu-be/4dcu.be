---
layout: page
title: "Gallery"
permalink: /gallery/
main_nav: true
cover:  "/assets/images/headers/gameboyzero.jpg"
cover_options: narrow
sitemap: true
---
<div class="gallery-grid" id="gallery-grid">
{% for post in site.posts -%}
  {% for item in post.gallery_items -%}
  {% assign gsize = item.gallery_size %}
  <div class="gallery-tile"{% if gsize %} data-size="{{ gsize }}"{% endif %}>
    <a href="{{ item.image | prepend: site.baseurl }}" class="lightgallery-link" data-sub-html="{{ item.description | escape }} <a href='{{ post.url }}'>Read more ...</a>">
      <img src="{{ item.gallery_image | prepend: site.baseurl }}" data-src="{{ item.image | prepend: site.baseurl }}" alt="Image from post: {{ post.title | strip_html }}" loading="lazy" />
      <div class="gallery-tile-overlay">
        <div class="gallery-tile-title">{{ post.title | strip_html }}</div>
        <div class="gallery-tile-cta">View &rarr;</div>
      </div>
    </a>
  </div>
  {%- endfor %}
{%- endfor %}
</div>

<script src="{{ '/js/gallery-packer.js' | prepend: site.baseurl }}"></script>
