---
layout: post
title:  "Een slimme bewegingssensor gebruiken met Home Assistant"
byline: ""
description: "Een slimme ZigBee-bewegingssensor via MQTT en ZigBee2MQTT toevoegen aan Home Assistant om een eenvoudig alarmsysteem te bouwen of verlichting in te schakelen wanneer er beweging wordt gedetecteerd."
date:   2023-03-12 08:00:00
author: Sebastian Proost
post_id: smart-motion-sensor
categories: diy
tags:	home-assistant MQTT Zigbee yaml security
cover:  "/assets/posts/2023-03-12-smart-motion-sensor/header.jpg"
thumbnail: "/assets/images/thumbnails/motion_sensor.jpg"
---

Ben je op zoek naar een eenvoudige maar doeltreffende manier om je huis of kantoor te beveiligen, dan is een slimme bewegingssensor
die met [Home Assistant] verbonden is misschien wel de perfecte oplossing. Zo kun je een eenvoudig alarm-
systeem opzetten dat onverwachte bewegingen in de buurt herkent en je daarvan op de hoogte brengt. Of je nu
thuis bent of niet, je kunt gerust zijn in de wetenschap dat je eigendom dag en nacht in de gaten wordt gehouden. In dit artikel lees je
hoe je zo'n opstelling maakt. Ook wie de sensor wil gebruiken om een lamp in of uit te schakelen,
kan met dit artikel aan de slag.

![Foto van de bewegingssensor die we aan Home Assistant toevoegen](/assets/posts/2023-03-12-smart-motion-sensor/sensor_front.jpg)

## Aan de slag

Voor je erin vliegt, kun je het best eerst ons vorige artikel over het [installeren van Home Assistant met MQTT en ZigBee] lezen. Zodra dat in orde is, kun je deze handleiding volgen met een werkende installatie van
[Home Assistant] waarop [MQTT] en [ZigBee2MQTT] al actief zijn. Om te beginnen heb je enkel enkele
ZigBee-compatibele bewegingssensoren nodig. Ik koos voor een exemplaar van SilverCrest dat ik met korting in de
lokale supermarkt vond, maar andere modellen zouden net zo goed moeten werken.

Volg eerst de instructies bij je sensor om hem [met HA te koppelen]. Zodra de verbinding gemaakt is,
geef je de sensor een geschikte naam (ik koos voor ```Motion Sensor Test```). Ga vervolgens naar
```Settings``` > ```Devices & Services``` en klik op ```Configure``` in het paneel ```Mosquitto broker```. Hier kun je
naar MQTT-berichten luisteren om na te gaan of je toestel correct werkt. Om te beginnen luisteren,
voer je gewoon de naam van je toestel in (```zigbee2mqtt/<your sensor name>```) en klik je op ```Start Listening```. Probeer nu
de sensor te activeren door ervoor te bewegen. Verschijnt er een bericht op het scherm, dan weet je dat je sensor correct
met Home Assistant verbonden is en kun je je woning beginnen te automatiseren.

![De bewegingssensor werkt correct: het bericht wordt met succes naar de MQTT-broker doorgestuurd](/assets/posts/2023-03-12-smart-motion-sensor/001_sensor_working.png){:.small-image}


## MQTT-berichten die de sensoren versturen

Hieronder zie je een voorbeeld van een bericht dat een bewegingssensor naar MQTT stuurt. Hou er wel rekening mee dat er verschillende
situaties zijn waarin de sensor een bericht kan uitsturen:

  * Wanneer de sensor beweging heeft gedetecteerd, stuurt hij een MQTT-bericht met ```"occupancy": true```. Daardoor wordt de sensor ook
gedurende een bepaalde tijd uitgeschakeld (drie minuten bij het model dat ik gebruik).
  * Wanneer de sensor na een detectie opnieuw actief wordt, stuurt hij nog een MQTT-bericht met ```"occupancy": false```.
  * Als iemand met de sensor knoeit door hem uit zijn houder te halen, stuurt hij een bericht met
```"tamper": true``` zodra de sabotageknop aan de achterkant van de sensor wordt losgelaten. (Zie hieronder de sabotageknop aan de
achterkant van de sensor; die wordt geactiveerd zodra hij niet langer ingedrukt is.)
  * Zolang de sabotageknop niet ingedrukt blijft, herhaalt de sensor elk halfuur het bericht met ```"tamper": true```.

![Achterkant van de sensor met de sabotageknop. Zolang die ingedrukt is, zit de sensor in zijn houder en is alles in orde. Zodra de knop niet meer ingedrukt is, begint de sensor berichten te versturen](/assets/posts/2023-03-12-smart-motion-sensor/sensor_back.jpg)

Om automatiseringen te activeren wanneer er beweging wordt gedetecteerd, hebben we een filter nodig dat alleen reageert op berichten met
"occupancy": true. Zo weten we zeker dat onze automatiseringen alleen worden uitgevoerd wanneer de bewegings-
sensor daadwerkelijk beweging detecteert, en niet door een sabotagebericht of een bericht dat meldt dat de sensor opnieuw actief is.

```json
{
    "battery": 100,
    "battery_low": false,
    "linkquality": 63,
    "occupancy": true,
    "tamper": false,
    "voltage": 3000
}
```

## Automatiseringen maken

Nu we weten welke informatie de sensor(en) zullen versturen en wanneer dat gebeurt, kunnen we een
automatisering maken. Voor we dit als alarm instellen, raad ik wel aan om eerst wat extra te testen door gewoon te tellen
hoe vaak de sensor elke dag wordt geactiveerd. Daarvoor stellen we in het bestand `configuration.yaml` van Home Assistant een teller in
door de volgende code toe te voegen:

```
counter:
  motion_triggers:
    initial: 0
    step: 1

```

Zodra het bestand opgeslagen is en HA opnieuw werd opgestart, is de teller actief. Vervolgens voegen we twee automatiseringen toe:
één die telkens wordt geactiveerd wanneer er een MQTT-bericht van de sensor verschijnt met `"occupancy": true` en onze teller verhoogt,
en een timer die de teller elke dag om middernacht opnieuw op nul zet. In recente versies van HA kan dat eenvoudig via de
interface. Ga naar `Settings` > `Automations & Scenes` en klik op `Create Automation`.


![Schermafbeelding van de Home Assistant-interface om de automatisering te maken](/assets/posts/2023-03-12-smart-motion-sensor/002_sensor_automation.png)

Stel de trigger in op **When an MQTT message has been received** en het onderwerp op
`zigbee2mqtt/<your sensor name>`. Om te voorkomen dat elk bericht de automatisering activeert, hebben we onder de
voorwaarden een **Template condition** nodig, met `{% raw %}{{ trigger.payload_json.occupancy }}{% endraw %}` als **Value template**. Zo worden de berichten
van de sensor gefilterd en worden de acties alleen voor relevante berichten uitgevoerd. Tot slot voegen we een actie met de service
**Counter:Increment** toe, die verwijst naar de teller die we in de vorige stap hebben gemaakt.

Om de teller opnieuw op nul te zetten, moet je een tweede automatisering instellen, zoals hieronder:

![Automatisering om de teller opnieuw op nul te zetten](/assets/posts/2023-03-12-smart-motion-sensor/003_reset_counter.png)

Laat dit enkele dagen draaien om na te gaan hoe goed het werkt en of er valse positieven zijn. Een vals positief resultaat kan
onnodige ongerustheid of acties veroorzaken wanneer je niet thuis bent. Na het testen waren er echter geen onverwachte detecties
op momenten dat er niemand thuis was of wanneer we sliepen.

## HA als alarmsysteem instellen

Nu we weten hoe we een teller kunnen verhogen, kunnen we ook een melding sturen naar een mobiel toestel waarop de
Home Assistant-app staat. De trigger en voorwaarde voor deze automatisering zijn dezelfde als voordien, maar we veranderen de actie
zodat er een melding naar mijn telefoon wordt gestuurd. Als je een toestel met audio-uitvoer hebt dat geluid kan afspelen,
kun je dat samen met de melding activeren.

![Automatisering die een melding naar een mobiele telefoon stuurt wanneer de sensor wordt geactiveerd](/assets/posts/2023-03-12-smart-motion-sensor/004_notification.png)

Ik wil natuurlijk niet telkens een melding krijgen wanneer ik zelf langs de sensor loop. Daarom heb ik enkele
onderdelen aan het dashboard toegevoegd, zodat ik de meldingen eenvoudig kan in- en uitschakelen en de teller in de gaten kan houden.

![HA-interface met een grafiek voor de teller en een knop om het alarm in te schakelen](/assets/posts/2023-03-12-smart-motion-sensor/005_dashboard.png)


## Conclusie

Bewegingssensoren zijn dus een betaalbare en doeltreffende manier om met Home Assistant een beveiligingssysteem na te bootsen. We
kunnen deze sensoren eenvoudig in ons systeem integreren en ze gebruiken om allerlei automatiseringen te activeren, zoals
meldingen naar onze mobiele toestellen sturen, alarmen inschakelen en aanwezigheid bijhouden. Zo geeft het wat
gemoedsrust dat er tijdens je vakantie geen onverwachte bezoekers zijn langsgekomen, zonder dat het je handenvol geld kost.

Naast de bovenstaande voordelen hebben bewegingssensoren nog andere praktische toepassingen binnen domotica. Ze kunnen bijvoorbeeld
worden gebruikt om verlichting in te schakelen wanneer iemand een kamer binnenkomt en die na een bepaalde tijd zonder
beweging weer uit te schakelen, wat energie en geld kan besparen. Ze kunnen ook de thermostaat bijstellen naargelang een kamer
al dan niet bezet is, wat nog meer energie kan besparen.

Kortom, bewegingssensoren zijn een veelzijdig en betaalbaar hulpmiddel dat je domotica-
systeem functioneler maakt en tegelijk voor extra beveiliging en gemoedsrust zorgt. Of je nu een doe-het-zelver bent of al
heel wat ervaring met domotica hebt, het is zeker het overwegen waard om bewegingssensoren in je systeem te integreren.

## Disclaimer

Hoewel een slimme bewegingssensor die met Home Assistant verbonden is een eenvoudige en doeltreffende manier kan zijn om de beveiliging van je huis of
kantoor te verbeteren, is het belangrijk om te beseffen dat zulke systemen hun beperkingen hebben. Ze kunnen je waarschuwen voor
onverwachte bewegingen, maar voldoen mogelijk niet aan dezelfde normen als professioneel geïnstalleerde, gespecialiseerde alarmsystemen.
Daarom is het altijd verstandig om je beveiligingsbehoeften te beoordelen en eventueel een beveiligingsexpert te raadplegen om de
beste oplossing voor jouw specifieke situatie te bepalen.

[installeren van Home Assistant met MQTT en ZigBee]: {% post_url nl/2020/2020-09-10-MQTT %}
[Home Assistant]: https://www.home-assistant.io/
[MQTT]: https://www.home-assistant.io/integrations/mqtt/
[ZigBee2MQTT]: https://www.zigbee2mqtt.io/guide/usage/integrations/home_assistant.html
[met HA te koppelen]: {% post_url nl/2021/2021-04-28-MQTT-Ikea-Tradfri %}
