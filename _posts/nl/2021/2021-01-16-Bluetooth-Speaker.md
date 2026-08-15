---
layout: post
title:  "Een Bluetooth-luidspreker bouwen — deel 1"
byline: "... de elektronica"
description: "Een draagbare Bluetooth-luidspreker van nul bouwen, met aandacht voor de elektronica: luidsprekers, LiPo-batterij, een M38 Bluetooth-versterkermodule en TP4056-lader."
date:   2021-01-16 10:00:00
author: Sebastian Proost
post_id: bluetooth-speaker-part-1
categories: diy
tags:	bluetooth hardware speaker star-wars rogue-one 3d-printing
cover:  "/assets/posts/2021-01-16-Bluetooth-Speaker/modules.jpg"
thumbnail: "/assets/images/thumbnails/bluetooth_speaker_modules.jpg"
gallery_items:
  - image: "/assets/posts/2021-01-16-Bluetooth-Speaker/modules.jpg"
    gallery_image: "/assets/images/gallery/bluetooth_speaker.jpg"
    description: "De elektronica voor een draagbare Bluetooth-luidspreker, alleen de behuizing ontbreekt nog."
---

Sinds ik [The Smuggler's Room] een Bluetooth-luidspreker zag bouwen, was ik van plan er zelf een te maken. Hier bespreek
ik de elektronica. Alles in een 3D-geprinte behuizing plaatsen en schilderen is voor de
[volgende post]({% post_url nl/2021/2021-02-22-Bluetooth-Speaker %}). Mijn versie verschilt wat van de hunne, dus geef ik hier de details.

**Benodigde onderdelen**

  * 2x 5W-luidspreker (compact formaat)
  * 1x 3,7V-LiPo-batterij **met PCM-beveiligingsmodule**; alles boven 1000 mAh zou een heel behoorlijke speelduur moeten opleveren.
  * 1x schakelaar (tweerichtingsschuifschakelaar)
  * 1x Bluetooth-module met 2x5W-versterker (zowel een M38- als CT14-module werkt)
  * 1x LiPo-laadcircuit op basis van de TP4056-chip
  * Krimpkous
  * Soldeergereedschap

Er zijn dus twee belangrijke verschillen met de onderdelen van [The Smuggler's Room]: ik gebruik een M38
Bluetooth-module en een eenvoudiger laadcircuit. Aanvankelijk gebruikte ik een CT14-module, maar de modules die ik van
mijn leverancier kreeg hadden een behoorlijk irritant opstartgeluid. In plaats van een paar discrete piepjes om aan te
geven dat het apparaat klaar was om te koppelen of gekoppeld was, speelde het de stemopnames "Connecting the Bluetooth
device" en "The Bluetooth device has been connected" af ... op het hoogst mogelijke volume. De M38-module die ik als
vervanging bestelde, laat gelukkig een eenvoudig geluidssignaal op een redelijk volume horen wanneer hij verbinding
maakt. Bovendien kan de M38-chip als USB-audioapparaat werken wanneer hij via USB met een computer is verbonden (ik zal
dat niet gebruiken, maar het is een handige optie). 

Het verschil in laadmodule komt gewoon doordat ik de verkeerde module bestelde ... Ze is gebaseerd op dezelfde chip
(TP4056) om LiPo-batterijen op te laden en biedt bescherming tegen overladen, maar is niet ontworpen om bedraad te
worden en een andere module van stroom te voorzien (let op het ontbreken van contactpunten met het label Out+ en Out- op mijn
module). Ze bevat ook geen beveiliging tegen te ver ontladen en moet daarom worden gebruikt met een LiPo-batterij die
deze functie ingebouwd heeft. Door de manier waarop deze printplaatjes werken, is het bovendien niet aanbevolen om een
apparaat tegelijk op te laden en te gebruiken. Voor wat extra bescherming heb ik de modules, batterij en schakelaar zo
aangesloten dat de luidspreker, wanneer hij aanstaat, op de batterij werkt en de laadmodule niet verbonden is, en
*vice versa*. Hieronder kun je mijn aansluitschema bekijken.

![Zo sluit je alle onderdelen aan](/assets/posts/2021-01-16-Bluetooth-Speaker/circuit.png)

Alles aan elkaar solderen was heel eenvoudig. Alle contactpunten zijn duidelijk gelabeld en groot, waardoor je alles
makkelijk correct kunt aansluiten. De plus- en minpool van beide luidsprekers moeten op dezelfde manier worden
aangesloten, want de luidsprekers moeten in fase staan. Wat krimpkous over de aansluitingen van de schakelaar komt goed
van pas. De LiPo-batterij die ik hieronder heb aangesloten is een exemplaar van 3500 mAh, maar later vervang ik die door
een lichtere versie (omdat ik de 3500mAh-batterij nodig heb voor een toekomstig project).

![Luidsprekers met eraan gesoldeerde aansluitingen; sluit ze op dezelfde manier aan zodat ze in fase staan](/assets/posts/2021-01-16-Bluetooth-Speaker/speakers.jpg)

Om de batterij op te laden, moet het systeem uitgeschakeld zijn en via micro-USB op een voeding van 1 A zijn
aangesloten. Een rood lampje betekent dat de batterij opgeladen is, terwijl blauw betekent dat ze wordt opgeladen (of
dat er geen batterij aangesloten is). Wanneer je de luidspreker inschakelt, wordt de stroomverbinding tussen het
laadcircuit en de batterij onderbroken om gelijktijdig gebruiken en opladen te voorkomen. De schakelaar maakt het
onmogelijk om de batterij tegelijk op te laden en te gebruiken.

Als alles correct werkt, zou de luidspreker als een Bluetooth-luidspreker met de naam *MH-M38* moeten verschijnen (de
naam hangt af van de module die je hebt; de standaardnaam kan niet worden veranderd, maar je kunt het apparaat in
Android een andere naam geven). Maak nu gewoon verbinding en speel wat muziek af om de luidspreker te testen.

![De twee modules, schakelaar en LiPo-batterij aan elkaar gesoldeerd](/assets/posts/2021-01-16-Bluetooth-Speaker/modules.jpg)

![Na het inschakelen verschijnt hij als MH-M38 in de lijst met Bluetooth-apparaten](/assets/posts/2021-01-16-Bluetooth-Speaker/connected.png)

Hoe goed het geluid uiteindelijk zal zijn, valt nog af te wachten. Voor het best mogelijke geluid moeten deze
luidsprekers in een behuizing zitten. Dat moet dus getest worden zodra alles in elkaar zit. Maar zelfs zonder behuizing
is het geluid luider en beter dan wat mijn telefoon zonder externe luidsprekers kan produceren, dus het ziet er
veelbelovend uit ... De behuizing is 3D-geprint (zie hieronder), dus blijf zeker kijken voor meer in een volgende post!

![3D-geprinte behuizing net van het printbed, er moet nog veel geschuurd worden ...](/assets/posts/2021-01-16-Bluetooth-Speaker/case.jpg)

[The Smuggler's Room]: https://www.youtube.com/watch?v=2wUlkyUbZ-I
