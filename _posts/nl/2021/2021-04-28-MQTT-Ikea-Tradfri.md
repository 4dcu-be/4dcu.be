---
layout: post
title:  "Zigbee-bereik uitbreiden met Ikea Tradfri-repeaters"
byline: "willekeurige verbindingsproblemen oplossen"
description: "Goedkope Ikea Tradfri-repeaters gebruiken om het Zigbee-bereik uit te breiden en willekeurige verbindingsproblemen met Aqara-sensoren in Home Assistant op te lossen, en daarbij overschakelen op Home Assistant OS."
date:   2021-04-28 08:00:00
author: Sebastian Proost
post_id: mqtt-ikea-tradfri
categories: diy
tags:	home-assistant MQTT Zigbee Aqara yaml Ikea
cover:  "/assets/posts/2021-04-28-MQTT-Ikea-Tradfri/ikea_tradfri.jpg"
thumbnail: "/assets/images/thumbnails/ikea_tradfri.jpg"
---

Mijn gloednieuwe [Aqara-sensoren] bevonden zich helemaal aan de rand van mijn Zigbee-bereik, met ongewenste
verbindingsonderbrekingen om de paar dagen als gevolg. Gelukkig heeft de grootste hedendaagse ontwerper van Zweden een
goedkope oplossing ... al was het een kleine uitdaging om die met [Home Assistant] aan de praat te krijgen.

De temperatuur-, luchtvochtigheids- en druksensoren die ik in een [vorig artikel] met Home Assistant verbond, werkten
prima ... tot ze ermee ophielden en opnieuw ingesteld moesten worden. Dat loste het probleem één of twee dagen op,
waarna het terugkwam ... Deze sensoren bevonden zich te ver van de Raspberry Pi met de Zigbee-ontvanger voor een
stabiele verbinding, dus was er een repeater nodig om het bereik uit te breiden. Ik merkte dat Ikea enkele
Zigbee-apparaten heeft, waaronder misschien de repeater die ik nodig had ... Het was niet duidelijk of die met mijn
Aqara-sensoren en Home Assistant zou werken, maar voor amper 10 euro nam ik er eentje mee en begon ik te experimenteren ...

![Eenvoudige maar mooie verpakking, eens kijken of hij met Aqara-sensoren en Home Assistant werkt](/assets/posts/2021-04-28-MQTT-Ikea-Tradfri/ikea_tradfri.jpg)

## Overschakelen op Home Assistant OS

Aanvankelijk draaide ik Home Assistant Core vanuit een virtuele Python-omgeving en gebruikte ik Supervisor om ervoor
te zorgen dat het bij het opstarten gestart en na een fout opnieuw gestart werd. Zo kon ik nog enkele andere
toepassingen op dezelfde Raspberry Pi draaien. Naarmate Home Assistant geavanceerder werd, werd het echter steeds
moeilijker om add-ons te installeren. De nieuwere add-ons worden als Docker-containers aangeboden en die kunnen niet
in Home Assistant Core worden opgenomen. Daarom installeerde ik het [Home Assistant Operating System] op de SD-kaart
van de Pi en ging ik aan de slag met de officiële documentatie. Zodra HA opnieuw draaide, weliswaar nog zonder
apparaten, konden we de Zigbee-apparaten beginnen instellen.

Eerst moeten er enkele add-ons worden geïnstalleerd. In de nieuwe versie kan dit allemaal via de
beheerinterface (**Supervisor** --> **Add-ons Store**) en hoef je niet aan de slag met de opdrachtregel.

  * [Mosquitto-MQTT] : De *broker* die berichten van apparaten naar Home Assistant en terug doorstuurt
  * [Zigbee2MQTT] : Nodig om de Zigbee-antenne te laten werken en apparaten te koppelen.
  * [File Editor] en/of [Samba share] : Om configuratiebestanden te bewerken

De belangrijkste reden om op Home Assistant OS over te schakelen is dat de [Zigbee2MQTT]-add-on enkele voordelen heeft
ten opzichte van de service handmatig op de achtergrond te installeren (zoals ik eerder deed). Om apparaten correct
met de repeater te koppelen en de Zigbee-netwerkkaart te bekijken, zijn die functies erg handig. Tijd dus om apparaten
toe te voegen!

## Zigbee-apparaten koppelen

Hoewel Zigbee-apparaten blijkbaar zelf de beste route naar de hoofdcontroller kunnen vinden, kan het even duren voordat
ze dat pad ontdekken. De sensoren maakten aanvankelijk geen verbinding via de repeater en verloren hun verbinding toen
ze naar hun definitieve locatie werden verplaatst. Gelukkig is het via de Zigbee2MQTT-interface vrij eenvoudig om
apparaten met een specifieke ontvanger te verbinden. Ga eerst naar **Zigbee2mqtt** (in de zijbalk) en klik op **Permit
join (All)**. Daardoor krijg je vier minuten om apparaten te koppelen. Ik koppelde een [Aqara Cube] (open het
batterijdeksel, houd de knop 5 seconden ingedrukt tot de blauwe led knippert en blijf de kubus bewegen of schudden
terwijl je wacht tot hij gekoppeld is; anders gaat hij in slaapstand en mislukt het koppelen) en de [Ikea Tradfri
repeater] (druk met een speld de knop in het gaatje 5-10 seconden in; tijdens het koppelen zal het lampje langzaam
aan- en uitgaan). Dit kan één of twee minuten duren, dus wees geduldig. Zodra de apparaten in de lijst verschijnen,
kun je op de bewerkknop klikken en ze een gepaste naam geven.

<div class="gallery-2-col" markdown="1">
![Voeg eerst de repeater en apparaten toe die rechtstreeks met het toegangspunt verbonden moeten zijn](/assets/posts/2021-04-28-MQTT-Ikea-Tradfri/zigbee_devices_added.png)
![Laat daarna apparaten alleen via de repeater koppelen om de sensoren toe te voegen](/assets/posts/2021-04-28-MQTT-Ikea-Tradfri/zigbee_all_added.png)
</div>

Om vervolgens de Aqara-sensoren te koppelen, klik je op het driehoekje naast **Permit join (All)** en selecteer je de
repeater waarmee je de sensor wilt verbinden (ik noemde de mijne Tradfri Repeater). Klik daarna op **Permit join (name
repeater)**. Begin de apparaten te koppelen. Deze sensoren hebben bovenaan een knop. Houd die 5 seconden ingedrukt tot
de blauwe led knippert; 2-3 snelle flitsen geven aan dat het apparaat gekoppeld is. Wees opnieuw geduldig tot de
apparaten in de lijst verschijnen en geef ze logische namen door op de blauwe knop **Rename device** te klikken. Je kunt
de topologie van je Zigbee-netwerk controleren en nagaan of de apparaten correct gekoppeld zijn via **Map** --> **Load
Map**.

![Alle Zigbee-apparaten zijn correct verbonden](/assets/posts/2021-04-28-MQTT-Ikea-Tradfri/zigbee_map.png)

## Apparaten configureren

Hoewel je steeds meer instellingen via de beheerinterface kunt aanpassen, deed ik het grootste deel van de
configuratie voorlopig door YAML-bestanden te bewerken op basis van mijn vorige configuratie. Met de [File Editor] kun
je ```configuration.yaml```, ```automations.yaml```, ... beginnen aanpassen. Voor de Aqara-kubus werkte dezelfde
configuratie als in [dit artikel]({% post_url nl/2020/2020-09-10-MQTT %}) nog steeds. Als alternatief kun je de add-on
[Samba share] installeren en de Raspberry Pi in Windows als netwerkstation koppelen. Vanuit dat pad kun je alle
configuratiebestanden rechtstreeks met je favoriete teksteditor bewerken.

Om deze wijzigingen toe te passen, moet je Home Assistant opnieuw starten. Dat kan via **Configuration** --> **Server
Controls**. Gebruik zeker **Check Configuration** om je wijzigingen te valideren voordat je opnieuw opstart en ze in
productie neemt.

De sensoren hebben niet veel configuratie nodig, al moest ik wel opnieuw kaarten aan de interface toevoegen. Ook hier
werd code uit een [vorig artikel] hergebruikt. Nu kon de gebruiksvriendelijke naam van het apparaat gebruikt worden,
wat veel eenvoudiger is.


```yaml
type: vertical-stack
title: Bedroom
cards:
  - type: glance
    entities:
      - entity: sensor.aqara_sensor_001_temperature
      - entity: sensor.aqara_sensor_001_humidity
      - entity: sensor.aqara_sensor_001_pressure
      - entity: sensor.aqara_sensor_001_battery
    show_name: false
  - type: horizontal-stack
    cards:
      - type: sensor
        entity: sensor.aqara_sensor_001_temperature
        graph: line
        name: ' Temperature (48 h)'
        hours_to_show: 48
      - type: sensor
        entity: sensor.aqara_sensor_001_humidity
        graph: line
        name: ' Humidity (48 h)'
        hours_to_show: 48
```

## Conclusie

De [Ikea Tradfri repeater] doet het uitstekend voor zijn prijs en werkt met de Aqara-apparaten zodra alles correct
gekoppeld is. Je kunt er echter niet op vertrouwen dat apparaten zelf het beste pad naar het centrale punt vinden; ze
moeten worden gekoppeld volgens de netwerktopologie die bij jouw behoeften past. Omdat de [Zigbee2MQTT]-add-on de
eenvoudigste manier is om dat te doen, moest ik wel overschakelen op het [Home Assistant Operating System]. Daardoor is
de Raspberry Pi nu volledig voor HA bestemd en zal ik een andere oplossing moeten vinden voor mijn andere toepassingen
(zoals mijn [MemoBoard] voor boodschappen-, taken- en andere lijstjes), tenzij ik uitvind hoe ik die als HA-add-ons kan
draaien. De extra add-ons voor Home Assistant en het gemak waarmee je ze installeert, maken dat echter ruimschoots goed.



[Aqara-sensoren]: {% post_url nl/2021/2021-03-25-MQTT %}
[vorig artikel]: {% post_url nl/2021/2021-03-25-MQTT %}
[Home Assistant]: https://www.home-assistant.io/
[Home Assistant Operating System]: https://www.home-assistant.io/installation/
[Mosquitto-MQTT]: https://github.com/home-assistant/addons/blob/master/mosquitto/DOCS.md
[Zigbee2MQTT]: https://github.com/zigbee2mqtt/hassio-zigbee2mqtt#installation
[File Editor]: https://github.com/home-assistant/addons/tree/master/configurator
[Samba share]: https://github.com/home-assistant/addons/tree/master/samba
[Aqara Cube]: https://www.aqara.com/us/cube.html
[Ikea Tradfri repeater]: https://web.archive.org/web/20211203142442/https://www.ikea.com/us/en/p/tradfri-signal-repeater-30400407/
[MemoBoard]: https://github.com/sepro/MemoBoard
