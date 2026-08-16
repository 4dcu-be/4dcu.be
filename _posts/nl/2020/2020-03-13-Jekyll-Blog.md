---
layout: post
title:  "Blogs verbeteren met zelfgemaakte Jekyll-plugins"
byline: "til je blog naar een hoger niveau"
description: "Zelf Jekyll-plugins in Ruby schrijven voor functies zoals automatische LightGallery-links en een kaart die voor een reisblog aangeeft waar elk artikel werd geschreven."
date:   2020-03-13 12:00:00
author: Sebastian Proost
post_id: jekyll-blog
categories: programming
tags:	ruby jekyll blog
cover:  "/assets/posts/2020-03-13-Jekyll-Blog/map_extension.png"
thumbnail: "/assets/images/thumbnails/jekyll_map.jpg"

gallery_items:
  - image: "/assets/posts/2020-03-13-Jekyll-Blog/map_extension.png"
    gallery_image: "/assets/images/gallery/map_extension.jpg"
    description: "Jekyll-plugin die aangeeft waar een blogartikel werd geschreven, ideaal voor een reisblog."

---

Deze blog is gebouwd met [Jekyll], waarmee je een statische website kunt genereren op basis van een reeks sjablonen (voor de
lay-out) en Markdown-bestanden (voor de inhoud). Het grote voordeel is dat je GitHub Pages kunt gebruiken om die
statische pagina's gratis te hosten. Hoewel er heel wat uitstekende [thema's] beschikbaar zijn, ontbreken bepaalde functies die ik echt wilde
doorgaans. Gelukkig ondersteunt [Jekyll] plugins om die leemtes op te vullen. Hier lees je over enkele plugins 
die ik maakte voor deze blog en [Beyond the Known] (een reisblog).

## Aan de slag

Voor beide blogs waarbij ik betrokken ben, diende het [Centrarium]-thema als vertrekpunt. Dat thema bevatte al heel wat 
onderdelen die ik wilde. Het is echt niet nodig om voor elk project het wiel opnieuw uit te vinden. Ik bracht wel een aantal wijzigingen aan
het thema aan. Zo verwijderde ik de ondersteuning voor [HighlightJS] ten gunste van de standaard code-highlighter van Jekyll.
Ik verkies ook [LightGallery] boven [Lightbox], dus die heb ik eveneens vervangen. 

Deze wijzigingen bestaan louter uit HTML, JS en CSS. Je moet alleen de relevante code in de map `_sass`, `_includes` of 
`_layouts` vinden en aanpassen. Ik wilde echter nog enkele dingen toevoegen die wat meer moeite
kostten.

## Automatische LightGallery-links voor alle afbeeldingen

In Markdown kun je heel eenvoudig een afbeelding invoegen.

```markdown
 ![image_description](path/to/the/image.jpg)
```

Technisch gezien moet je de *base URL* van de website aan het pad toevoegen. Zo blijft de site ook werken wanneer die in een 
submap wordt gehost. Dat kan door `{%raw%}{{ site.baseurl }}/{%endraw%}` vóór het pad te plaatsen. Dit is echter specifiek voor het thema waarmee ik begon en als je de 
Markdown-bestanden ooit met een ander thema of framework wilt gebruiken, zal dat je parten spelen... Om de afbeelding met alle 
vereiste LightGallery-functies op te nemen, moet je pure HTML in je Markdown-bestand plaatsen.

{% raw %}
```html
<a href="{{ site.baseurl }}/path/to/the/image.jpg" class="lightgallery-link" data-sub-html="image_description">
<img alt="image_description" data-src="{{ site.baseurl }}/path/to/the/image.jpg" src="{{ site.baseurl }}/path/to/the/image.jpg" />
</a>"
```
{% endraw %}

Dit is bijzonder omslachtig, waardoor enkele afbeeldingen toevoegen de leesbaarheid van de Markdown sterk vermindert. Bovendien
moet de URL drie keer worden herhaald en de beschrijving twee keer. Dat ergerde me ... enorm! Ik wil de eenvoudige
syntaxis in mijn Markdown-bestanden gebruiken, maar die bij het bouwen van de pagina naar HTML omzetten. Dat kan met een 
**Jekyll Hook**. Hooks worden uitgevoerd voordat het bestand wordt verwerkt en bieden een plaats om de Markdown-bestanden te bewerken voordat
Jekyll ze verwerkt. Hier voegen we een hook toe die alles automatisch omzet.

Daarvoor moet je in je project een map `_plugins` maken en een bestand `lightgallery_links.rb` toevoegen met de 
onderstaande code.

{% raw %}
```ruby
Jekyll::Hooks.register :posts, :pre_render do |post, payload|
  post.content.gsub!(/^!\[(.*)\]\(([^\)]+)\)((?:{:[^}]+})*)/, "<a href=\"{{ site.baseurl }}\\2\" class=\"lightgallery-link\" data-sub-html=\"\\1\">\n![\\1]({{ site.baseurl }}\\2)\\3{:data-src=\"{{ site.baseurl }}\\2\"}\n</a>")
end
```
{% endraw %}

De cryptische regel is een reguliere expressie die afbeeldingstags in de standaard Markdown-syntaxis detecteert, ze in HTML-
linktags plaatst en een deel toevoegt om de data-src van de afbeelding correct in te stellen. Dit wordt alleen toegepast op afbeeldingen die
aan het begin van een regel staan. Je kunt het dus uitschakelen door simpelweg een spatie vóór de afbeeldingsdeclaratie 
te plaatsen.

## Thumbnailgenerator

Zonder afbeeldingen zien overzichtspagina's er nogal saai uit, dus is een thumbnail die de aandacht trekt een must.
Omdat ik voor elk artikel een headerafbeelding gebruik, kan dezelfde afbeelding als thumbnail dienen. De headerafbeelding
is echter veel groter dan nodig, dus wilde ik die automatisch verkleinen. Met een generator kun je via Ruby-code nieuwe
bestanden maken. Zo kan voor elke header automatisch een thumbnail met lage resolutie worden aangemaakt.

Eerst voegen we de gewenste afmetingen van de thumbnails toe aan `_config.yml` van de website, zoals hieronder. Deze
parameters worden aan ImageMagick doorgegeven.

```yaml
plugins:
  # Add Mini magick to the plugins
  - mini_magick

thumbnail:
    resize_dimensions: '430x288^'
    crop_dimensions: '430x288+0+0'
```

We moeten mini_magick ook aan het `Gemfile` toevoegen. Dat ziet er als volgt uit:

```bash
source 'https://rubygems.org'
gem 'jekyll', '<4'
gem 'jekyll-archives'
gem 'jekyll-sitemap'
gem 'jekyll-paginate-v2'
gem 'mini_magick'
```

In de header van elk artikel moeten we een pad toevoegen waar de verkleinde afbeelding wordt opgeslagen. Bekijk de header van dit artikel in het
voorbeeld hieronder: de cover moet worden ingesteld als invoer voor de thumbnailgenerator en het thumbnailpad is
de plaats waar de verkleinde afbeelding wordt weggeschreven.

```yaml
layout: post
title:  "Jekyll Plugins"
byline: "lift your blog to a higher level"
date:   2020-03-13 12:00:00
author: Sebastian Proost
categories: programming
tags: ruby jekyll blog
cover:  "/assets/posts/2020-03-13-Jekyll-Blog/map_extension.png"
thumbnail: "/assets/images/thumbnails/jekyll_map.jpg"
```

Plaats ten slotte een bestand `thumbnail_generator.rb` met de onderstaande code in de map `_plugins`.

```ruby
require "mini_magick"
include MiniMagick

module Jekyll
  class ThumbnailGenerator < Generator
    safe true

    def generate(site)
       posts = site.posts.docs.select { |post| post.data['thumbnail'] }
       resize_dimensions = Jekyll.configuration({})['thumbnail']['resize_dimensions']
       crop_dimensions = Jekyll.configuration({})['thumbnail']['crop_dimensions']
       posts.each do |post|
         input_path = ".#{post['cover']}"
         output_path = ".#{post['thumbnail']}"
         if !File.exists?(output_path) || File.mtime(output_path) <= File.mtime(input_path)
            puts("Generating thumbnail", input_path, output_path)
            image = MiniMagick::Image.open(input_path)
            image.strip
            image.compress "JPEG2000"
            image.resize resize_dimensions
            image.gravity "center"
            image.crop crop_dimensions
            image.write output_path
         end
      end
    end
  end
end
```

Dit selecteert alle artikels waarvoor een thumbnailpad is ingesteld en laadt de afmetingen uit de configuratie. Vervolgens
worden de geselecteerde artikels doorlopen, wordt de header tot de gewenste afmetingen verkleind en wordt het resultaat naar het thumbnailpad geschreven. 
Om te vermijden dat afbeeldingen telkens opnieuw onnodig worden verkleind, wordt gecontroleerd of de thumbnail bestaat en of het invoerbestand niet 
nieuwer is dan de thumbnail.

Ten slotte moet de afbeelding in het artikeloverzicht worden opgenomen, maar dat is even eenvoudig als de titel van het artikel ophalen!

Met dezelfde aanpak bouwde ik ook de [galerij].

## Artikels op een wereldkaart

Voor [Beyond the Known] wilden we echt een wereldkaart met een speld voor elke locatie waarover een artikel werd geschreven.
Daarvoor moeten de gps-coördinaten van elk artikel in de YAML-header worden opgenomen. Je kunt ze gemakkelijk via
Google Maps verkrijgen en zoals hieronder in de header van het artikel opnemen:

```yaml
coords:
  lat: 51.151706
  lng: 3.8708973
```

Je moet een Google Maps API-sleutel aanvragen via de [Google Developer Console] en die in het bestand `_config.yml` instellen. 
Zorg ervoor dat je de juiste beperkingen op je sleutel instelt!

```yaml
# Google maps API key
google_maps_api_key: "your key here"
```

Vervolgens hebben we een JSON-bestand nodig dat voor elk artikel de coördinaten, titel, link en
beschrijving bevat. Dat bestand halen we later op wanneer de eigenlijke kaart wordt gegenereerd. Maak daarvoor een bestand `map_data.json` in de
hoofdmap van de website met deze code:

{%raw%}
```js
---
layout: null
---

[
{% for post in site.posts %}
  {
    "title": {{ post.title | jsonify }},
    "url": {{ post.url | prepend: site.baseurl | jsonify }},
    "date": {{ post.date | date: "%B %d, %Y" | jsonify }},
    "content": {{ post.content | strip_html | smartify | truncatewords: 50 | jsonify }}{% if post.coords %},
    "coords": {
      "lat": {{ post.coords.lat | jsonify }},
      "lng": {{ post.coords.lng | jsonify }}
    }{% endif %}
  }{% unless forloop.last %},{% endunless %}
{% endfor %}
]
``` 
{%endraw%}

Nu kunnen we met de onderstaande code een kaart aan een pagina toevoegen. JQuery laadt de gegevens uit `map_data.json` 
(dat wordt opgebouwd uit de coördinaten in de
headers van de artikels). Die worden omgezet in markeringen op de kaart (met een pop-upmenu) en samen met de kaart
toegevoegd aan de div met `id="map"`. 

```html
<div id="map"></div>
<div id="map_spacer"></div>

<script src="https://code.jquery.com/jquery-3.4.1.js"></script>
<script>
	var map;
	function initMap() {
		map = new google.maps.Map(document.getElementById('map'), {
			center: {lat: 50.8798, lng: 4.7005},
			zoom: 2
		});

		function addMarker(props) {
			var marker = new google.maps.Marker({
				position: props.coords,
				map: map
			});

			var infoWindow = new google.maps.InfoWindow({
				content: '<h2><a href="' + props.url + '">' + props.title + '</a></h2><p class="map_info_window">' + props.content + '</p>'
			});

			marker.addListener('click', function() {
				infoWindow.open(map, marker);
			});

		}

		$.getJSON( "{{ "/map_data.json" | prepend: site.base }}", function( data ) {
			data.forEach(function(el){
			  if (typeof el.coords !== 'undefined') {
			    console.log(el);
				  addMarker(el);
				}
			})
		});

	}
</script>
<script src="https://maps.googleapis.com/maps/api/js?key={{ site.google_maps_api_key }}&callback=initMap" async defer></script>
```

Om de kaart weer te geven, is een beetje CSS nodig. Dit werkt voor onze toepassing, maar moet waarschijnlijk worden aangepast 
aan het ontwerp van je eigen site. Het is belangrijk om een hoogte en breedte in te stellen, anders verschijnt de kaart niet.

```css
#map {
    height: 90vh;
    min-height: 250px;
    margin: 0;
    position: absolute;
    width: 100%;
    left: 0;
}

#map_spacer {
    height: 90vh;
    min-height: 250px;
    margin: 0;
}

p.map_info_window {
	width: 350px;
}
```


![Kaartpagina van Beyond the Known, met aanklikbare spelden die naar het relevante artikel leiden](/assets/posts/2020-03-13-Jekyll-Blog/map_extension.png)

Het eindresultaat op [Beyond the Known]. Merk op dat ik ook een aangepaste stijl heb toegevoegd (bekijk de documentatie van de Google Maps JavaScript API
voor details over hoe je dat doet). Met dit overzicht vind je snel een relevant artikel over een regio die je misschien 
wilt bezoeken! Een erg nuttige functie voor een reisblog.

## Conclusie

Met deze plugins kon ik alle functies toevoegen die ik nodig had voor deze blog en [Beyond the Known]. Een
statische website genereren brengt bepaalde beperkingen mee en werken met een uitgesproken framework als [Jekyll] vergde 
wat aanpassing. Nu alles op zijn plaats staat, is er echter één consistente manier om alles te doen. Daardoor wordt
het onderhoud van beide blogs in de toekomst een stuk eenvoudiger. Statische sites zijn bovendien goedkoop te hosten: GitHub biedt gratis hosting en de
enige kost is de domeinnaam, die met minder dan $10 per jaar verwaarloosbaar is. Zo komen er tijd en geld vrij
om inhoud te maken!

Als je zelf een blog hebt, mag je de code hier gerust gebruiken om deze functies aan je website toe te voegen.


[Jekyll]: https://jekyllrb.com/
[thema's]: http://jekyllthemes.org/
[Beyond the Known]: http://beyond-the-known.eu/
[Centrarium]: https://github.com/bencentra/centrarium
[LightGallery]: http://sachinchoolur.github.io/lightGallery/
[Lightbox]: https://lokeshdhakar.com/projects/lightbox2/
[HighlightJS]: https://highlightjs.org/
[Google Developer Console]: https://console.developers.google.com/
[galerij]: {{site.baseurl}}/gallery/
