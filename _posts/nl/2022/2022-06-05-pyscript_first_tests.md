---
layout: post
title:  "PyScript: Python in de browser!"
byline: "Kan het JavaScript echt vervangen?"
description: "Eerste tests met PyScript, dat Python in de browser uitvoert, vergeleken met JavaScript voor veelvoorkomende webtaken aan de hand van een praktisch voorbeeld met HTML, CSS en Python."
date:   2022-06-05 10:00:00
author: Sebastian Proost
post_id: pyscript-first-tests
categories: programming
tags:	python web-development pyscript javascript
cover:  "/assets/images/headers/python_code.jpg"
thumbnail: "/assets/images/thumbnails/python_code.jpg"
github: "https://github.com/4dcu-be/PyScript-Basics"
---

Op PyCon 2022 werd [PyScript] aangekondigd als een manier om Python in de browser uit te voeren. Sindsdien heeft het heel wat losgemaakt. 
Hoewel het project enkele bijzonder knappe demo's bevat, bevindt het zich nog in een vroege ontwikkelingsfase 
en loopt de documentatie wat achter. Laten we daarom enkele veelvoorkomende toepassingen van JavaScript bekijken
en nagaan hoe je die met PyScript realiseert.

Alle code uit deze post vind je op [GitHub]. Wil je de code in actie zien, ga dan naar [http://4dcu.be/PyScript-Basics/](http://4dcu.be/PyScript-Basics/).

## Aan de slag

We maken drie bestanden: ```index.html```, ```style.css``` en ```main.py```. De eerste twee vormen de HTML-pagina 
en het CSS-bestand voor de opmaak, terwijl het laatste onze eigen code bevat die via PyScript wordt uitgevoerd.

We beginnen met ```index.html```. Hier definiëren we het absolute minimum om PyScript, onze CSS en Python-code te laden.

```html
<html>
    <head>
        <title>PyScript Test</title>

        <link rel="stylesheet" href="./style.css">

        <link rel="stylesheet" href="https://pyscript.net/alpha/pyscript.css" />
        <script defer src="https://pyscript.net/alpha/pyscript.js"></script>

    </head>
    <body>
        <p>PyScript status: <span id="pyscript_status">Not Loaded</span></p>

        <button id="clicks" pys-onClick="increase_counter" class="btn">Count 0</button>
        <button id="toggle" pys-onClick="toggle_text" class="btn">Show Text</button>

        <p id="toggle_text" class="hidden">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus cursus 
          mauris mauris, vel fermentum risus hendrerit tincidunt. Aliquam pulvinar tellus et iaculis vestibulum. In 
          pharetra diam eu lectus dignissim tristique. Phasellus laoreet vulputate urna. Fusce vitae elit sodales, 
          tempus dui in, scelerisque magna.</p>
        
        <br />
        <button id="clicks_class" pys-onClick="test_class.inc" class="btn">Count <strong>0</strong></button>

        <py-script src='./main.py'></py-script>
    </body>
</html>
```

En een beetje CSS om het tekstveld te kunnen verbergen, plus wat code die ik van [w3schools] haalde om de knoppen 
er als echte knoppen te laten uitzien.

```css
body {
    padding: 15px;
}


.hidden {
    display: none;
}

.btn {
    background-color: #4CAF50;
    border: none;
    color: white;
    padding: 15px 32px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;
  }
```

## Met Python verbinden

De code bevat twee aanknopingspunten die PyScript gebruikt om de code in ```main.py``` uit te voeren. Onderaan de body staat
de tag ```<py-script src='./main.py'></py-script>```, die aangeeft dat er een extern bestand is dat moet worden
uitgevoerd zodra de pagina geladen is. Dit concept is identiek aan de manier waarop je een stukje JavaScript-code met 
```<script>```-tags invoegt.

In de code van een knop kun je aangeven welke functie moet worden uitgevoerd wanneer erop wordt geklikt. Voeg daarvoor het attribuut 
```pys-onClick="increase_counter"``` toe aan het element dat aanklikbaar moet zijn. In de bovenstaande code voert de ene knop bij elke klik de functie 
```increase_counter``` uit (die in ```main.py``` staat), en de andere ```toggle_text```.

Daarnaast is het belangrijk dat de elementen waarmee de Python-code moet werken een identificatiecode hebben. 
Dat zou trouwens ook nodig zijn als je JavaScript zonder framework aan een webpagina toevoegt. 

## De Python-code

```python
counter = 0

pyscript.write('pyscript_status', 'PyScript Loaded Successfully')

def increase_counter(*ags, **kws):
    global counter
    counter += 1
    button = Element('clicks')
    button.element.innerHTML = f"Count {counter}"

def toggle_text(*ags, **kws):
    text = Element('toggle_text')
    button = Element('toggle')

    if "hidden" in text.element.classList:
        text.remove_class("hidden")
        button.element.innerHTML = "Hide Text"
    else:
        text.add_class("hidden")
        button.element.innerHTML = "Show Text"

class Test():
    def __init__(self) -> None:
        self.counter = 0
        self.text_element = Element('clicks_class')

    def inc(self, *ags, **kws):
        self.counter += 1
        self.text_element.element.innerHTML = f"Count <strong>{self.counter}</strong>"

test_class = Test()
```

Zodra onze HTML-pagina is geladen, wordt het bovenstaande script uitgevoerd. De eerste manier om met de elementen op de
webpagina te werken is ```pyscript.write()```. Het eerste argument bepaalt in welk element (aan de hand van de ID) je een stukje
tekst wilt schrijven; die tekst wordt in het tweede argument opgegeven. In dit geval werken we het element pyscript_status bij, zodat er 
"PyScript Loaded Successfully" komt te staan. Dit is niet alleen een goed voorbeeld van de eenvoudigste manier om met de DOM te werken,
maar geeft ook een visuele bevestiging dat onze code wordt uitgevoerd.

Het volgende stukje bepaalt wat er gebeurt wanneer de telknop wordt ingedrukt. Twee zaken zijn hier belangrijk: het gebruik van een 
```global```-variabele om de teller bij te houden en de manier waarop de tekst wordt ingesteld. Omdat we de teller moeten bijhouden
in een variabele buiten de functie, maakt de globale variabele ```button = Element('clicks')```
een Python-object aan dat gekoppeld is aan het DOM-element met de ID "clicks". Nu kunnen we de innerHTML van dat element
naar wens aanpassen. Dit heeft één voordeel ten opzichte van ```pyscript.write()```: op deze manier kun je HTML in een element opnemen.
Als we bijvoorbeeld het getal vet wilden maken, konden we gewoon de onderstaande regel gebruiken:

```python
button.element.innerHTML = f"Count <strong>{counter}</strong>"
```

## Met klasseattributen werken

De laatste functie in het voorbeeld toont hoe je kunt werken met de klassen die aan een element zijn toegewezen. Dat is
handig om het uiterlijk van elementen onmiddellijk te veranderen door over te schakelen naar een klasse met een andere stijl in het 
CSS-bestand, of gewoon om een element te verbergen of te tonen zoals hier.

Met ```Element()``` worden de knop en het tekstveld geselecteerd. Vervolgens openen we de 
```classList``` van de tekst om te controleren of die al dan niet verborgen is. Deze lijst bevat alle klassen die momenteel aan het DOM-element zijn gekoppeld. Om
na te gaan of het element een bepaalde klasse heeft, volstaat het om te controleren of die klasse in de lijst voorkomt. Hier gaan we na of
het element verborgen is. Is dat zo, dan verwijderen we die klasse met ```text.remove_class("hidden")```. Anders voegen we 
de klasse hidden toe met ```text.add_class("hidden")```. In beide gevallen wordt de tekst van de knop overeenkomstig aangepast.

## Een Python-klasse gebruiken

De globale variabele uit het eerste voorbeeld is niet erg elegant. Hetzelfde geldt voor het uitvoeren van de functie ```Element()``` bij elke
klik op de knop. Met een klasse kunnen we dit vermijden! Met een testklasse kun je een eigenschap maken voor de huidige teller en
de elementen waarmee je wilt werken. Vervolgens voegen we een functie ```inc``` toe om de teller te verhogen. Kijk goed naar de
structuur van de argumenten: eerst self, daarna de args en kwargs die PyScript nodig heeft. Aan het einde van ```main.py``` maken we
een instantie van deze klasse met de naam ```test_class```. In de HTML-code kunnen we de functie inc binnen die instantie koppelen 
met ```pys-onClick="test_class.inc"```.

Hoewel dat in een klein voorbeeld niet eenvoudiger lijkt (het is eigenlijk één regel code meer), is dit voor
complexere apps een veel betere manier om de toestand van de app te beheren. 

# Tot slot

Uit de voorbeelden blijkt duidelijk dat ook veelvoorkomende taken waarvoor JavaScript zonder framework vaak wordt gebruikt met 
PyScript kunnen worden uitgevoerd. Door de gebrekkige documentatie vergt het wat zoekwerk, maar vaak
volstond een snelle blik op de broncode om het uit te pluizen. Het ophalen van de Python-runtime zorgt echter voor een aanzienlijke extra laadtijd
van een webpagina. In sommige gevallen kan dat een breekpunt zijn.

Als je daarentegen al logica in Python hebt geïmplementeerd, kan dit de omzetting van die code in een app
aanzienlijk versnellen. [WinstonCubeSim], een project dat ik vaak gebruik om nieuwe pakketten, tools enzovoort te testen, kon ik in één of twee avonden ombouwen tot een werkende
webapp, inclusief enkele knappe extra functies (zoals gegevens ophalen uit een externe API).
Alles naar JavaScript overzetten zou me meer tijd hebben gekost, en nu hoef ik maar één codebasis voor de CLI- en
webversie te onderhouden. De app is nogal niche, maar bekijk [WinstonCubeSimPyScript] als je het resultaat wilt zien.

# Het nadeel van PyScript

Hoewel dit vrij eenvoudige voorbeelden zijn, moest ik een of twee keer in de broncode duiken om iets uit te pluizen, omdat PyScript nog altijd weinig documentatie heeft.
Dat valt in deze fase te verwachten en zal mettertijd verbeteren. Aangezien dit project zich in de alfafase bevindt,
zullen er waarschijnlijk sowieso nog zaken veranderen. Documentatie schrijven die later opnieuw moet worden geschreven, is dus niet
erg productief voor het team. Dat neem ik hen niet kwalijk, maar wees voorbereid op wat extra werk als je erin wilt duiken.

Het PyScript-pakket bevat enkele mooie voorbeelden, al zijn die wat meer op datawetenschap gericht. Hoewel
ik niet kan wachten om dat verder te testen, vinden mensen die JavaScript zonder framework door Python willen vervangen misschien moeilijk wat ze nodig hebben.

De laadtijd is aanzienlijk. Efficiënte caching van een website zou dit probleem kunnen verzachten, maar bij de eerste laadbeurt moet
de volledige Python-runtime in WASM worden opgehaald. Helaas kan dat alleen worden vermeden als PyScript net als JavaScript
in de browser zou worden ingebouwd. Het is nog wat vroeg, maar ooit misschien ... 

# Meer lezen

  * [WinstonCubeSimPyScript] : Webapp die PyScript gebruikt en deze stukjes code toepast om een gebruikersinterface voor een bestaande bibliotheek te maken
  * [PyScript] : Officiële website
  * [Python + pyscript + WebAssembly: Python Web Apps, Running Locally with pyscript](https://www.youtube.com/watch?v=lC2jUeDKv-s) : Tutorial om met PyScript aan de slag te gaan en je code om te zetten in een Progressive Web App

[w3schools]: https://www.w3schools.com/css/css3_buttons.asp
[WinstonCubeSimPyScript]: https://github.com/4dcu-be/WinstonCubeSimPyScript
[WinstonCubeSim]: https://github.com/4dcu-be/WinstonCubeSim
[PyScript]: https://pyscript.net/
[GitHub]: https://github.com/4dcu-be/PyScript-Basics
