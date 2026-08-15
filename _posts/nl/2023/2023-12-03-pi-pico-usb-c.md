---
layout: post
title:  "Eenvoudige USB Type-C-upgrade voor de Raspberry Pi Pico"
byline: "vandaag zelf maken — klaar voor morgen"
description: "Soldeeraanpassing voor beginners waarbij je de micro-USB-poort van de Raspberry Pi Pico vervangt door een USB Type-C-breakoutboard, met uitleg over weerstanden voor stroomvoorziening via USB-C-kabels."
date:   2023-12-03 08:00:00
author: Sebastian Proost
post_id: pi-pico-usb-c
categories: diy
tags:	python raspberry-pi soldering electronics
cover:  "/assets/posts/2023-12-03-pi-pico-usb-c/pico_close.jpg"
thumbnail: "/assets/images/thumbnails/pico_usbc_header.jpg"
---

Nu USB Type-C-poorten overal ingeburgerd zijn, kan het vervelend zijn om voor sommige toestellen nog micro-USB-kabels bij te houden. Het 
gemak van één omkeerbare kabel voor bijna al je toestellen valt niet te ontkennen. Bij sommige toestellen kun je de 
micro-USB-poort zelfs vervangen door een USB Type-C-exemplaar ... zolang je niet bang bent om wat te solderen. Voor we aan 
ingewikkeldere elektronica beginnen, houden we het eenvoudig: een kleine aanpassing aan de Raspberry Pi Pico is de perfecte manier om van start te gaan.

## Benodigdheden

Voor dit project heb je enkele essentiële soldeerbenodigdheden nodig. Een soldeerbout, sponsje en soldeertin volstaan om te beginnen. Naast dit gereedschap heb je nog enkele onderdelen nodig:

  * een Raspberry Pi Pico
  * vier stukjes elektrische draad (die van mij heb ik uit een oude USB-kabel gehaald)
  * een USB Type-C-breakoutboard met vrouwelijke connector dat de pinnen voor massa (GND), spanning (V), data plus (D+) en data min (D-) naar buiten voert (Opmerking: als je een USB-C-naar-USB-C-kabel wilt gebruiken, moet het bordje stroomvoorziening ondersteunen.)

Het juiste breakoutboard kiezen is cruciaal, want niet elk bordje is geschikt voor dit project. Zoek voor deze aanpassing een bordje dat de pinnen GND, V, D+ en D- van de vrouwelijke USB Type-C-connector naar buiten voert. Hoewel USB Type-C-connectoren veel extra pinnen hebben, heb je alleen deze vier nodig om een ouder USB-toestel aan te sluiten.

Als je een USB-A-naar-USB-C-kabel gebruikt om je toestel aan te sluiten, volstaat elk bordje dat de relevante pinnen naar buiten voert. Gebruik je echter een USB-C-naar-USB-C-kabel, dan moeten de twee aangesloten toestellen eerst een digitale "handshake" uitvoeren voor het brontoestel stroom levert aan het ontvangende toestel. In dat geval zijn er twee weerstanden op het breakoutboard nodig om het brontoestel te melden dat onze Pi Pico de standaardspanning van 5V nodig heeft.

Aanvankelijk kocht ik breakoutboards zonder de nodige weerstanden. Dat kan een probleem zijn als je een USB-C-naar-USB-C-verbinding wilt gebruiken. Gelukkig gebruik ik voor de ontwikkeling op deze Pi Pico een USB-A-naar-USB-C-kabel, waardoor de bordjes die ik heb toch volstaan. Ik raad niettemin aan een breakoutboard te kopen dat correct is ingesteld voor stroomvoorziening. Zo blijft het in de nabije toekomst compatibel met elke USB-C-kabel en elk USB-C-toestel. (Ik heb voor toekomstige projecten al nieuwe besteld)

![Een USB Type-C-breakoutboard met vrouwelijke connector dat de pinnen voor massa, spanning en data naar buiten voert. Volledig bedraad en klaar voor gebruik.](/assets/posts/2023-12-03-pi-pico-usb-c/usbc_close.jpg)

## Het USB Type-C-breakoutboard met de Raspberry Pi Pico verbinden

Bij de meeste toestellen moet je de bestaande micro-USB-connector lossolderen om het nieuwe USB Type-C-breakoutboard aan te sluiten. Gelukkig kan het bij de Raspberry Pi Pico eenvoudiger.

De Pi Pico heeft aan de onderkant handige testpads, aangeduid als TP1 tot en met TP6. Deze toegankelijke pads bieden een rechtstreekse verbinding met belangrijke lijnen: massa (TP1), data min (TP2) en data plus (TP3). De spanning kunnen we aanleveren door aan de VBUS-pin van de GPIO van de Pi Pico te solderen. Dankzij deze eenvoudige aanpak kunnen we het USB Type-C-breakoutboard moeiteloos integreren zonder de oorspronkelijke micro-USB-poort te verwijderen.

![Raspberry Pi Pico met draden die op de testpads zijn gesoldeerd en hem met het USB-C-breakoutboard verbinden](/assets/posts/2023-12-03-pi-pico-usb-c/pico_close.jpg)

| Pin op breakoutboard | Aansluiting op Raspberry Pi Pico | Kleur USB-draad |
|--------------------|------------------------------|----------------|
| GND                | TP1 (Massa)                  | Zwart          |
| V                  | VBUS (PIN 40)                | Rood           |
| D+                 | TP3 (Data Plus)              | Groen          |
| D-                 | TP2 (Data Min)               | Wit            |


En klaar! Met enkele eenvoudige verbindingen verander je de Raspberry Pi Pico in een toestel met moderne 
USB Type-C-compatibiliteit. Deze eenvoudige upgrade voegt met slechts enkele 
soldeerstappen functionaliteit en gebruiksgemak toe. Controleer voor het testen zeker al je verbindingen nog eens!

## Besluit

Een Raspberry Pi Pico uitrusten met een USB Type-C-poort toont duidelijk hoe je zelfs de eenvoudigste toestellen met 
een beetje kennis en soldeerwerk kunt moderniseren. Het is een toegankelijk project dat niet alleen de connectiviteit verbetert, maar ook een 
goede basis vormt voor wie zich verder in de wereld van doe-het-zelfelektronica wil verdiepen. Ons voorbeeld met de Pi Pico 
was relatief eenvoudig omdat de testpads makkelijk bereikbaar zijn om op te solderen, maar andere toestellen kunnen een grotere 
uitdaging vormen. Elk toestel heeft zijn eigen bijzonderheden en kan extra stappen of voorzorgsmaatregelen vereisen. Dit 
project is een perfect vertrekpunt om je zelfvertrouwen en vaardigheden op te bouwen voor je complexere 
hardware-upgrades aanpakt. Zoek alles vooraf altijd grondig uit, neem de nodige veiligheidsmaatregelen en geniet vooral van het 
proces waarmee je je technologie een persoonlijke toets geeft. Veel plezier met aanpassen!

![Beide bordjes met elkaar verbonden](/assets/posts/2023-12-03-pi-pico-usb-c/full_view.jpg)

## Disclaimer

Hoewel we ernaar streven gedetailleerde en duidelijke instructies te geven, zijn we niet verantwoordelijk voor schade die tijdens het aanpassen aan je elektronica kan ontstaan. Zulke aanpassingen vereisen dat je voorzichtig te werk gaat en enige ervaring hebt met elektronische onderdelen en solderen. Als je dit project uitvoert, doe je dat op eigen risico. Zorg er altijd voor dat je volledig geïnformeerd bent en over de juiste uitrusting beschikt om de taak veilig uit te voeren voor je eraan begint.
