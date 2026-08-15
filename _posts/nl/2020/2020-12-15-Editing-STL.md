---
layout: post
title:  "De beste tools om STL-bestanden te bewerken"
byline: "MeshMixer, Fusion360 en Blender vergeleken"
description: "MeshMixer, Fusion360 en Blender vergelijken voor het bewerken van STL-bestanden, aan de hand van een Kyber Crystal Crate-Bluetooth-luidsprekerproject."
date:   2020-12-15 13:00:00
author: Sebastian Proost
post_id: editing-stl
categories: diy
tags:	3d-printing creality CR10S Fusion360 MeshMixer Blender
cover:  "/assets/posts/2020-12-15-Editing-STL/blender_header.png"
thumbnail: "/assets/images/thumbnails/blender_grill.jpg"
---

Geïnspireerd door [The Smuggler's Room] besloot ik zelf een Kyber Crystal
Crate-Bluetooth-luidspreker te bouwen. De 3D-printbare modellen die zij aanbieden, moeten na het
printen echter nog worden bewerkt ... met gereedschap dat ik niet heb ... Daarom besloot ik de nodige wijzigingen digitaal aan de modellen aan te brengen vóór het
printen. Hiervoor experimenteerde ik met drie tools om STL-bestanden te bewerken: [MeshMixer], [Fusion360] en [Blender]. Ze zijn allemaal
gratis te downloaden, maar hebben elk hun eigen sterke en zwakke punten. Laten we bekijken hoe ze zich tot elkaar verhouden.

De Kyber Crystal Crate-STL's die de mensen van [The Smuggler's Room] gebruiken, vind je op [Thingiverse]. Als
je hun project bekijkt, zijn er behoorlijk wat aanpassingen aan de prints nodig voor je ze kunt gebruiken. Er moeten gaten
voor aansluitingen en schakelaars bijkomen, een opening voor de luidspreker, ... Daarvoor heb je gereedschap nodig waarover ik niet beschik,
of het zou met handgereedschap eindeloos duren. Daarom leek het me beter de modellen digitaal aan te passen vóór het 
printen. Geen extra gereedschap nodig ... behalve schuurpapier, want bij 3D-geprinte projecten moet er altijd véél geschuurd worden ...

## Fusion360

Fusion360 is mijn vaste programma wanneer ik zelf iets moet modelleren. Met een onderwijslicentie kun je het gratis gebruiken 
(wat ideaal is om de tool te leren kennen en persoonlijke projecten te maken; let er wel op dat je met zo'n licentie geen modellen
of prints commercieel, professioneel of met winstoogmerk mag verkopen). 
Dankzij parametrisch modelleren kun je op elk moment teruggaan, een afmeting of positie wijzigen, ... waarna het volledige model 
automatisch wordt bijgewerkt. Dat is bijzonder krachtig bij het ontwerpen van prototypes om te printen. STL-bestanden
bevatten modellen echter als een *mesh*, een verzameling driehoekige vlakken, en niet als parametrisch model. Dat is een probleem: er
bestaan manieren om een *mesh* om te zetten naar de oppervlaktevoorstelling die Fusion360 nodig heeft, maar dat werkt alleen voor relatief eenvoudige
modellen. Ik slaagde er wel in de gewenste uitsparing in het zijpaneel te maken waar de luidsprekers moeten passen. Complexere objecten,
zoals de hoofdkist, waren moeilijk te laden en nog moeilijker te bewerken.

Voor de eerste wijziging die ik wilde uitvoeren, een eenvoudige uitsparing in het zijpaneel voor de luidspreker, werkte Fusion360 dus 
prima. Klik meteen na het
laden van het model op "do not capture design history" (door met rechts op de projectnaam te klikken). Selecteer vervolgens het object en ga in het menu naar Modify > Mesh > Mesh to BRep ... Daarmee
zet je de *mesh* om in oppervlakken waarmee je in Fusion kunt werken zoals je gewend bent. Eventueel kun je vlakke 
oppervlakken samenvoegen voor een nettere voorstelling.

![De eerste, eenvoudigste wijziging in Fusion360. Een uitstekende ontwerptool, maar niet geschikt om complexe meshes te bewerken](/assets/posts/2020-12-15-Editing-STL/fusion360.png)

Hoewel het een uitstekende tool is, werd Fusion360 dus niet ontworpen om STL-bestanden te bewerken. Voor sommige modellen werkt het misschien, maar
jouw ervaring kan verschillen! Ik gebruikte Fusion360 alleen omdat ik de tool al kende. Begin je helemaal
van nul, bekijk dan eerst de andere opties!

## MeshMixer

AutoDesks MeshMixer is een gebruiksvriendelijke tool waarmee je, zoals de naam doet vermoeden, *meshes* kunt combineren (zoals objecten in een
STL-bestand). Er zijn ook enkele basisvormen ingebouwd, zoals kubussen, bollen en cilinders. Met MeshMixer kon ik
zelfs de meest complexe STL eenvoudig laden en enkele kubussen aan de binnenkant van de kist toevoegen om de elektronica te bevestigen.

Op dezelfde manier maakte ik een kubus en cilinder op de plaatsen waar openingen voor luidsprekers, USB-poort en aan-uitschakelaar nodig waren.
Vervolgens trok ik die vormen van het hoofdmodel af om echte gaten te maken. Hoewel dat uiteindelijk lukte, duurde het lang om een 
eenvoudige basisvorm van de complexe geometrie af te trekken en was de resulterende *mesh* niet perfect (op de 
afbeelding hieronder zie je dat de naden niet volledig recht zijn en de randen niet meer scherp). Ik vond het ook moeilijk om heel nauwkeurig
te werken. Een object op een exacte afstand van een ander plaatsen, ... wordt niet door de software ondersteund.

![MeshMixer kan complexere modellen aan, maar de geometrie na het combineren van objecten is niet optimaal](/assets/posts/2020-12-15-Editing-STL/meshmixer.png)

Met MeshMixer kon ik wel STL-bestanden aanpassen die Fusion360 niet kon bewerken, en het is erg gebruiksvriendelijk. Daarom wordt deze
tool vaak als eerste optie aangeraden. Bovendien zijn enkele functies die je vaak nodig hebt voor 3D-printen meteen beschikbaar, 
zoals recht door een model snijden om een groot model op te delen in stukken die op het printbed passen. 
De resulterende geometrie na het uitsnijden van gaten was echter niet ideaal. Als er problemen ontstaan, ontbreken bovendien de tools om
die rechtstreeks te corrigeren door de hoekpunten van de *mesh* te bewerken.


## Blender

Blender bestaat het langst en kan worden gebruikt voor uiterst geavanceerde 3D-modellering en animatie. Niet verrassend
heeft deze tool een steile leercurve. Heb je echter meer precisie nodig dan MeshMixer biedt, of werk je
met complexe geometrie waarbij MeshMixer in de problemen komt, dan is dit je beste keuze!

Om enkele gaten voor het geluid van de luidsprekers aan de zijkanten van de kist toe te voegen, moest ik Blender gebruiken. Alle
cilinders correct uitlijnen in MeshMixer was lastig. Zelfs als dat was gelukt, kon MeshMixer de
cilinders niet correct van het rooster aftrekken. 

![Deze nog steeds relatief eenvoudige wijzigingen waren alleen mogelijk met Blender](/assets/posts/2020-12-15-Editing-STL/blender.png)

Het is de krachtigste tool die ik gebruikte, maar ook de moeilijkste. Met MeshMixer was ik na enkele minuten vertrokken;
Blender vergde aanzienlijk meer tijd. 

## Conclusie

Achteraf gezien had ik meteen Blender voor alle onderdelen moeten gebruiken. Omdat ik al ervaring had met Fusion360,
was het logisch om dat eerst te proberen, ook al wist ik dat het niet de beste tool voor deze klus was. MeshMixer vond ik, ondanks
de vele aanbevelingen, behoorlijk beperkt en het leverde geen goede resultaten op. Het is erg gebruiksvriendelijk
en kan werken voor wie snel enkele STL-bestanden wil samenvoegen. Maar bij het aftrekken van heel eenvoudige
geometrie van complexe vormen leverde het geen netjes resultaat op, en ook het gebrek aan precisie bleek doorslaggevend. 
Enkele uren investeren om Blender en de basisprincipes te leren kennen, was de moeite meer dan waard. Ik kon 
de wijzigingen aan het rooster aanbrengen, wat noch Fusion360 noch MeshMixer kon zonder de *mesh* te beschadigen. Bovendien 
had ik de andere wijzigingen beter ook in Blender uitgevoerd: dat zou nauwkeuriger zijn geweest en 
betere resultaten hebben opgeleverd.

Voortaan is Blender dus de eerste tool die ik opstart wanneer ik STL-bestanden moet bewerken!

De prints, STL-bestanden en bouwhandleiding voor mijn eigen Kyber Crystal Crate-Bluetooth-luidsprekers volgen in een toekomstige post. 
Wordt vervolgd!

[The Smuggler's Room]: https://www.youtube.com/watch?v=2wUlkyUbZ-I
[MeshMixer]: https://www.meshmixer.com/
[Fusion360]: https://www.autodesk.com/products/fusion-360/personal
[Blender]: https://www.blender.org/
[Thingiverse]: https://www.thingiverse.com/thing:4329491
