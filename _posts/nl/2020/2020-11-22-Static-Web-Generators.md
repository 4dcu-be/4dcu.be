---
layout: post
title:  "Statische-sitegeneratoren: Jekyll versus Pelican versus Gatsby"
byline: "welke kies je het best?"
description: "De statische-sitegeneratoren Jekyll, Pelican en Gatsby vergelijken op basis van echte projectervaring, met de sterke en zwakke punten van elk om je te helpen kiezen."
date:   2020-11-22 13:00:00
author: Sebastian Proost
post_id: static-web-generators
categories: programming
tags:	python ruby javascript pelican jekyll gatsby
cover:  "/assets/posts/2020-11-22-Static-Web-Generators/generator_header.jpg"
thumbnail: "/assets/images/thumbnails/generator_header.png"
---

Er bestaan heel wat statische-sitegeneratoren! De juiste kiezen is allesbehalve vanzelfsprekend. In dit artikel vergelijk ik drie generatoren
die ik in enkele projecten gebruikte, zodat je de juiste voor je volgende project kunt kiezen!

Op [JamStack] staat een lange lijst generatoren waaruit je kunt kiezen, waardoor er één selecteren voor
je volgende project een onmogelijke opgave lijkt. Als je het gevoel hebt dat kiezen onmogelijk is, is dit artikel voor jou! Hier bespreek ik drie sterk
verschillende tools die ik dit jaar in enkele projecten gebruikte, met hun sterke en zwakke punten.

Dit is gebaseerd op, en dus gekleurd door, mijn ervaring ermee. Deel gerust je mening in de
reacties hieronder.

## Jekyll

![Jekyll-logo](/assets/posts/2020-11-22-Static-Web-Generators/jekyll-logo-2x.png){:.small-image}

[Jekyll], uitgebracht in 2008, is een van de eerste statische-sitegeneratoren en werd populairder dankzij de 
integratie in GitHub. Hoewel je met Jekyll allerlei websites kunt bouwen, is het in de kern bedoeld
voor blogs. Het legt vrij sterk zijn eigen keuzes op voor bestandsstructuur, artikelmetadata, extensies, ... maar zodra je die 
patronen aanvaardt, kun je het webontwikkelingsaspect echt vergeten en je op de inhoud richten.

### Voordelen

Jekyll bestaat intussen ruim 12 jaar en er zijn heel wat thema's en sjablonen beschikbaar (bijvoorbeeld [JekyllThemes]). 
Er bestaan verschillende plugins om Jekyll uit te breiden en nuttige functies aan je website toe te voegen, zoals
een artikelarchief, bibliografie (voor wetenschappelijke artikels met referenties), galerijen, ...

Elke statische website kan gratis op GitHub worden gehost, maar een site die met Jekyll is gemaakt kan GitHub ook zelf bouwen.
Voeg je sjabloon en inhoud aan een nieuwe repository toe, stel in de instellingen de root van de repository in als bron voor de projectpagina 
(zie hieronder) en je bent vertrokken. Je hoeft Jekyll zelfs niet meer lokaal te installeren: je kunt
de repository wijzigen (lokaal en de wijzigingen committen/pushen, of rechtstreeks op GitHub via de online-interface). Zodra
de nieuwe gegevens de servers van GitHub bereiken, wordt de website opnieuw gebouwd en verschijnen de wijzigingen enkele seconden later online. Zo 
kun je onderweg vrij eenvoudig inhoud toevoegen vanaf elk apparaat met een browser en internetverbinding.

![Instellingenpagina van GitHub, waar je GitHub kunt configureren om je site te bouwen](/assets/posts/2020-11-22-Static-Web-Generators/github_settings.png)

Een uitgesproken systeem als Jekyll kan een zegen zijn: doorgaans bestaat er maar één manier om iets te doen. Voor sommigen
voelt dat als een beperking, voor anderen maakt het mogelijk om gewoon de gewenste inhoud te maken zonder veel 
over webontwikkeling te moeten leren.

Van de drie platformen die hier aan bod komen, is Jekyll het vriendelijkst voor beginners! Elk framework heeft wel een 
leercurve (als je dat niet ziet zitten, ga dan naar [wordpress.com]), maar volgens mij was Jekyll het snelst 
gebruiksklaar.

### Nadelen

Jekyll is gebaseerd op Ruby, tegenwoordig geen bijzonder populaire programmeertaal. Als je het wilt of moet uitbreiden, 
zul je die taal dus moeten leren. Voor kleine wijzigingen, zoals die uit [dit artikel]({% post_url nl/2020/2020-03-13-Jekyll-Blog %}), is dat maar een beperkte hindernis,
maar voor grotere functies (bijvoorbeeld ondersteuning voor nieuwe bestandstypes) 
moet je je in deze programmeertaal verdiepen (waar ik persoonlijk verder niets mee doe). Hoewel er
uitstekende plugins beschikbaar zijn, is hun aantal wat beperkt in vergelijking met andere platformen.

Je website op GitHub bouwen beperkt het aantal bruikbare plugins nog verder (GitHub ondersteunt slechts een handvol 
plugins op een toelatingslijst; al de rest is uitgesloten). Het kan handig zijn dat GitHub de pagina voor
je bouwt, maar zonder toegang tot alle plugins (bijvoorbeeld een plugin die een artikelarchief voor je blog maakt) kun je mogelijk
niet alle gewenste functies opnemen. Je kunt dit omzeilen door de website lokaal in de map 
```/docs``` te bouwen of de gebouwde versie naar de branch ```gh-pages``` te pushen. Daardoor verlies je wel wat 
flexibiliteit om rechtstreeks via GitHub snel wijzigingen aan te brengen.

Met het juiste sjabloon kan een Jekyll-website er modern en strak uitzien, maar dat is wat moeilijker dan met
bijvoorbeeld [Gatsby], dat standaard door JavaScript en React wordt aangedreven.

### Waar gebruik je het?

Ik zou zonder aarzelen Jekyll kiezen om een project te documenteren. Omdat de code op GitHub staat, is het erg handig om enkele 
Markdown-bestanden aan de map ```/docs``` toe te voegen en met een sjabloon eenvoudige maar duidelijke documentatie te maken.
Die kan via het systeem van GitHub ook gemakkelijk worden gewijzigd en uitgebreid. Iedereen die een functie aan de code toevoegt,
kan zo de bijbehorende documentatie toevoegen zonder extra tools op het eigen systeem te installeren.

Ook voor eenvoudige websites met weinig variabele onderdelen die af en toe moeten worden bijgewerkt, valt er 
veel voor Jekyll te zeggen. Alle werk kan naar het webdesign gaan en de weinige variabele delen kunnen uit
een YAML-bestand worden gehaald. Die waarden bijwerken is dan even eenvoudig als ze in dat YAML-bestand aanpassen; GitHub regelt
al de rest. Ik zie heel wat toepassingen, van kleine ondernemingen tot sportclubs, ... waarvoor dit
een efficiënte manier is om een website op te zetten en te onderhouden. Mijn vorige cv was zo opgebouwd, maar vorige week stapte ik over op
een versie met [Gatsby]. Je vindt de vorige versie nog steeds [hier](https://github.com/sepro/resume-pre2020).

Beide blogs die ik heb opgezet ([Beyond the Known] en deze) draaien ook op Jekyll, maar gebruiken allebei plugins en
aanpassingen die GitHub niet ondersteunt. Daarom worden ze lokaal in de map ```/docs``` gebouwd en naar 
GitHub gecommit. Dat is wat omslachtiger, maar alle andere statische-sitegeneratoren vereisen een vergelijkbare stap.

## Pelican

![Pelican-logo](/assets/posts/2020-11-22-Static-Web-Generators/pelly.png){:.small-image}

Omdat ik Python het best beheers, klinkt een statische-sitegenerator op basis van Python erg aantrekkelijk. 
Er bestaan enkele opties, maar Pelican was het populairste platform. Daarom koos ik het om mee te experimenteren
en bouwde ik uiteindelijk [DeckLock], een website om mijn decks voor verschillende verzamelkaartspellen bij te houden.   

### Voordelen

Pelican draait op Python, waardoor je gemakkelijk alle bibliotheken uit het Python-ecosysteem kunt benutten. In 
[DeckLock] wordt de requests-bibliotheek bijvoorbeeld gebruikt om gegevens van het web te downloaden, die daarna met 
de JSON-bibliotheek of BeautifulSoup worden verwerkt. Telkens wanneer de site wordt gebouwd, haalt die automatisch ontbrekende gegevens op
en plaatst ze op de juiste pagina's. Dat biedt enorm veel mogelijkheden voor dashboards. Je kunt nieuwe gegevens ophalen,
een lokale SQLite-databank bijwerken, statistiek uitvoeren met pandas en numpy (of zelfs een *machine-learningmodel* draaien) en
de uitvoer in enkele JSON-objecten stoppen die het sjabloon visualiseert (bijvoorbeeld met Charts.js).

De geavanceerde documentatie focust sterk op de interne werking van Pelican en hoe je die uitbreidt. Dat is precies wat je nodig hebt
om iets te maken dat verder gaat dan blogs, nieuwssites, ...

### Nadelen

Voor Pelican zijn maar een honderdtal thema's beschikbaar (bijvoorbeeld [Pelican Themes]) en die zijn vaak van mindere kwaliteit dan
de thema's voor [Jekyll]. Mogelijk vind je dus niets dat meteen geschikt is en moet je meer tijd besteden
aan het aanpassen van het sjabloon.

Hoewel iemand met Python-ervaring gemakkelijk met Pelican aan de slag kan, is de leercurve 
iets steiler dan bij Jekyll. 

### Waar gebruik je het?

Pelican is een uitstekende keuze als je de invoer grondig moet verwerken voordat die in
een pagina kan worden omgezet. [DeckLock] begint met heel beperkte informatie (bijvoorbeeld de identificatiecode van een KeyForge-deck), haalt alle
benodigde informatie op (zoals de decklijst, kaartillustraties, kaartdetails, ...), voert extra statistiek uit en zet dat 
vervolgens met een sjabloon om in een pagina. Ik beweer niet dat dit onmogelijk is met [Jekyll] of [Gatsby], maar het wordt 
een stuk ingewikkelder. De uitstekende pakketten uit het Python-ecosysteem kunnen benutten geeft Pelican hier
een voorsprong. 

Als dat geen vereiste is, zijn [Jekyll] of [Gatsby] waarschijnlijk betere alternatieven. Beide voelen als rijpere 
platformen waarvoor meer hulpmiddelen beschikbaar zijn.

## Gatsby

![Gatsbyjs-logo](/assets/posts/2020-11-22-Static-Web-Generators/Gatsby.jpg){:.small-image}

Het recentste framework dat ik bekeek en gebruikte om de huidige versie van mijn cv te bouwen: [http://sebastian.proost.science/](http://sebastian.proost.science/).
[Gatsby] draait op JavaScript en heeft daardoor een duidelijk voordeel tegenover [Jekyll] en [Pelican]. Het combineert
niet alleen inhoud met een sjabloon ... het kan ook moderne webtechnologie (zoals React) gebruiken om dat sjabloon te bouwen. Als
de *front-end* belangrijk is, biedt Gatsby dus een manier om de nieuwste JavaScript-tools in je statische website te verwerken.

## Voordelen

Net als Jekyll en Pelican zet Gatsby een sjabloon om in een statische website, maar het soort sjabloon vormt het
grote verschil. De andere frameworks gebruiken Jinja om inhoud in een HTML-sjabloon te plaatsen; met Gatsby kun je
sjablonen bouwen met React, GraphQL, React-router en webpack. Met deze moderne webtechnologieën kun je leuke
functies in je website opnemen die met de andere frameworks moeilijk te realiseren zijn.

Samen met Gatsby krijg je het React-ecosysteem. Dat biedt heel wat uitstekende opties voor de lay-out die
met andere frameworks veel meer tijd kosten om toe te voegen. 

### Nadelen

Van de frameworks die hier worden besproken, heeft Gatsby de steilste leercurve. Naast kennis van frameworks en wat HTML + CSS om
het sjabloon te bouwen, vereist Gatsby enige kennis van React, modern JavaScript (ES6 is de huidige variant), npm, ...
Niet iedereen zal dat kunnen of willen leren.

### Waar gebruik je het?

Zodra je de basis beheerst, kun je Gatsby gebruiken voor vrijwel alles waarvoor je Jekyll gebruikt. 
Het enige probleem is dat GitHub je site niet kan bouwen, maar met [Netlify] kun je dat oplossen. Zolang
je bereid bent extra tijd te investeren om JavaScript, React, npm, ... te leren, is er weinig reden om
voor [Jekyll] te kiezen.

Voor een nicheproject als [DeckLock], waar allerlei voorverwerking nodig is om een pagina te bouwen, biedt Python mogelijk betere
opties. [Pelican] kan hier dus een voordeel hebben, al kun je dit met wat extra moeite ook in JS en dus
met Gatsby realiseren.

## Conclusie

Ik geef toe dat ik enkele jaren geleden geen hoge pet op had van statisch gegenereerde sites. Dat kwam vooral doordat mijn eerste
ervaring ermee rampzalig was. Het was simpelweg niet het juiste hulpmiddel voor die taak, maar een misplaatste 
poging om een degelijke databank te vermijden. Met daarbovenop een vreselijke implementatie was het onderhoud van die code 
een ware nachtmerrie...

Tijdens het werk aan enkele blogs, [DeckLock] en [mijn cv] ben ik echter helemaal van mening veranderd. Waar
het past, is dit een uitstekende manier om snel ladende websites te maken die goedkoop (of zelfs gratis) te hosten en eenvoudig te 
onderhouden zijn.

Mijn persoonlijke keuze voor toekomstige projecten wordt waarschijnlijk [Gatsby]. Ik ken de basis al en het biedt de beste 
mogelijkheden om moderne webtechnologie in de *front-end* te gebruiken. [Jekyll] zal ik vermoedelijk geleidelijk door Gatsby vervangen, al 
blijft het de efficiëntste optie om snel keurige documentatie op GitHub te maken. Ik verwacht dus niet dat ik het
binnenkort volledig opgeef. [Pelican] bleek een uitstekende keuze voor [DeckLock], maar dat is
een vrij specifiek geval; voor gangbaardere toepassingen bestaan betere opties.

## Dankwoord

Headerafbeelding door [Jayphen Simpson] op [Unsplash]

[JamStack]: https://jamstack.org/generators/
[Jekyll]: https://jekyllrb.com/
[Gatsby]: https://www.gatsbyjs.com/
[Pelican]: https://docs.getpelican.com/en/latest/
[JekyllThemes]: http://jekyllthemes.org/
[Beyond the Known]: https://www.beyond-the-known.eu/
[DeckLock]: {% post_url nl/2020/2020-04-05-DeckLock %}
[Pelican Themes]: http://www.pelicanthemes.com/
[wordpress.com]: https://wordpress.com/
[Netlify]: https://www.netlify.com/
[mijn cv]: http://sebastian.proost.science/
[Jayphen Simpson]: https://unsplash.com/@jayphen
[Unsplash]: https://unsplash.com/s/photos/generator
