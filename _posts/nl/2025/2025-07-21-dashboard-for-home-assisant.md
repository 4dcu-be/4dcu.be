---
layout: post
title:  "Mijn Kindle PW3 als dashboard voor Home Assistant gebruiken"
byline: ""
description: "Een gejailbreakte Kindle Paperwhite 3 met KUAL hergebruiken als energiezuinig e-inkdashboard voor Home Assistant, met realtimegegevens die via Python uit de Home Assistant-API worden opgehaald."
date:   2025-07-21 08:00:00
author: Sebastian Proost
post_id: dashboard-for-home-assisant
categories: diy programming
tags:	home-assistant yaml python kindle
cover:  "/assets/posts/2025-07-21-dashboard-for-home-assisant/kindle_dashboard_update.jpg"
thumbnail: "/assets/images/thumbnails/kindle_update_header.jpg"
---


Een oude Kindle die ooit werd **[gejailbreakt]({% post_url 2020/2020-09-27-PythonKindleDashboard_1 %})** en KUAL draait, kun je hergebruiken als dashboard voor zowat alles. Ik heb dat trouwens [al eens gedaan]({% post_url 2020/2020-10-04-PythonKindleDashboard_2 %}), al heb ik die statistieken nu niet echt meer nodig.

Het zou wel fijn zijn om enkele realtimegegevens uit mijn **Home Assistant**-opstelling te tonen op een energiezuinig e-inkscherm zoals dat van de Kindle. Dat zou niet al te moeilijk mogen zijn, dus laten we er meteen aan beginnen.

De volledige code voor dit project en meer gedetailleerde instructies om het aan de praat te krijgen, vind je op GitHub: [https://github.com/4dcu-be/kual-dashboard-ha/](https://github.com/4dcu-be/kual-dashboard-ha/).

![Kindle Paperwhite 3 met een aangepast dashboard dat gegevens uit Home Assistant toont](/assets/posts/2025-07-21-dashboard-for-home-assisant/kindle_dashboard_update.jpg)

## Home Assistant configureren

Voor we de Kindle instellen, moeten we ervoor zorgen dat **Home Assistant** de nodige informatie via zijn **API** beschikbaar maakt. Daarvoor moeten we het configuratiebestand bijwerken en een API-token voor onze applicatie aanmaken.

Voeg in je configuratiebestand op `/homeassistant/configuration.yaml` de volgende regel toe om de API in te schakelen. Ik gebruikte de uitbreiding [File Editor](https://github.com/home-assistant/addons/tree/master/configurator), waarmee je configuratiebestanden eenvoudig rechtstreeks via de Home Assistant-interface kunt bewerken:

```yaml
api:
```

Vervolgens maken we een toegangstoken aan waarmee onze Kindle-app zich veilig bij Home Assistant kan aanmelden.

Klik daarvoor linksonder op je *profielnaam*. Ga op de profielpagina bovenaan naar het tabblad *Security*, scrol naar *Long-Lived Access Tokens* en klik op **Create Token**. Geef je token een naam in het pop-upvenster en klik op **OK**.

Je krijgt nu je pas aangemaakte token te zien. **Bewaar die zeker** op een veilige plek, want je krijgt hem maar één keer te zien en we hebben hem later nog nodig.


## De Python-code voor de Kindle

Net als de vorige keer verpakken we onze code als een **KUAL-extensie**, zodat die kan draaien op een gejailbreakte Kindle waarop **KUAL** geïnstalleerd is. De Python-scripts halen de nodige gegevens op, zetten die met behulp van een sjabloon om naar **SVG** en gebruiken vervolgens `rsvg-convert` om een **PNG** te genereren die de Kindle kan weergeven.

Eerst hebben we een functie nodig die met het toegangstoken gegevens uit Home Assistant ophaalt. Het onderstaande fragment handelt de aanvraag af en geeft het resultaat terug als een Python-*dictionary*:

```python
import ssl
import urllib.request
import json


def get_ha_data(url, access_token):
    ssl_context = ssl._create_unverified_context()

    request = urllib.request.Request(
        url,
        headers={
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/json'
        }
    )

    with urllib.request.urlopen(request, context=ssl_context) as response:
        html = response.read()

    return json.loads(html.decode('utf-8'))
```

Wanneer je een Home Assistant-API-endpoint met geldige inloggegevens aanroept, krijg je een JSON-respons zoals in het onderstaande voorbeeld. Voor de meeste sensoren zijn we vooral geïnteresseerd in de velden `state` en `unit_of_measurement`.

Merk op dat de structuur kan verschillen naargelang de specifieke entiteit die je opvraagt.

```json
{
  "entity_id": "sensor.upgraded_sensor_bme680_temperature",
  "state": "26.0",
  "attributes": {
    "state_class": "measurement",
    "unit_of_measurement": "°C",
    "device_class": "temperature",
    "friendly_name": "Upgraded sensor BME680 Temperature"
  },
  "last_changed": "2025-07-21T11:45:18.879717+00:00",
  "last_reported": "2025-07-21T11:45:18.879717+00:00",
  "last_updated": "2025-07-21T11:45:18.879717+00:00",
  "context": {
    "id": "01K0PCTX0ZYZ2TT9VXTQ1D6RDW",
    "parent_id": "None",
    "user_id": "None"
  }
}
```

Vervolgens hebben we een script nodig dat bepaalt welke entiteiten uit Home Assistant moeten worden opgehaald, de gegevens verwerkt en een
SVG genereert. Dit deel is vrij eenvoudig en bouwt voort op wat we in een vorige post deden. Alleen halen we de gegevens deze keer
uit Home Assistant in plaats van uit openbare API's.

{:.large-code}
```python
# bin/python3
# encoding: utf-8

from datetime import datetime
import os
from os.path import join
from extract import get_ha_data
from config import HA_URL, HA_TOKEN


svg_path = '/mnt/base-us/extensions/dashboard/svg/' if os.name != 'nt' else '../svg'


def create_svg(svg_data, svg_template, svg_output):
    with open(svg_template, 'r') as fin:
        template = fin.read()

        for k, v in svg_data.items():
            template = template.replace(k, v)

        with open(svg_output, 'w') as fout:
            fout.write(template)

if __name__ == "__main__":
    ha_urls = [
        f"{HA_URL}sensor.sensor_bedroom_temperature",
        f"{HA_URL}sensor.sensor_bedroom_humidity",
        f"{HA_URL}sensor.sensor_nursery_temperature",
        f"{HA_URL}sensor.sensor_nursery_humidity",
        f"{HA_URL}sensor.upgraded_sensor_bme680_temperature",
        f"{HA_URL}sensor.upgraded_sensor_bme680_humidity",
        f"{HA_URL}sensor.herenthumidity",
        f"{HA_URL}sensor.herenttemperature",
        f"{HA_URL}sensor.herentpressure",
        f"{HA_URL}sensor.herentuv"]

    all_data = []

    for ha_url in ha_urls:
        try:
            ha_data = get_ha_data(ha_url, HA_TOKEN)
            all_data.append({
                'sensor': ha_data['attributes']['friendly_name'],
                'readout': f"{ha_data['state']} {ha_data['attributes']['unit_of_measurement']}"
            })

            print(ha_data)

        except Exception as _:
            all_data.append({
                'sensor': "Failed read",
                'readout': "Failed Update"
            })

    print(all_data)

    # Combine into dict
    svg_data = {"LASTUPDATE": "Last Update: " + datetime.now().strftime("%d/%m/%Y - %H:%M:%S"),
                "R1_TEMP": all_data[4]['readout'].replace("°", ""),
                "R1_HUM": all_data[5]['readout'],
                "R2_TEMP": all_data[0]['readout'].replace("°", ""),
                "R2_HUM": all_data[1]['readout'],
                "R3_TEMP": all_data[2]['readout'].replace("°", ""),
                "R3_HUM": all_data[3]['readout'],
                "OUT_TEMP": all_data[7]['readout'].replace("°", ""),
                "OUT_HUM": all_data[6]['readout'],
                "OUT_PRES": all_data[8]['readout'],
                "OUT_UV": all_data[9]['readout'],}

    # Load Data into SVG
    create_svg(svg_data, join(svg_path, "template.svg"), join(svg_path, "tmp.svg"))
```

Als je dit script in je eigen opstelling wilt gebruiken, maak dan een bestand `config.py` aan waarin je `HA_URL` en `HA_TOKEN` definieert.
Je moet ook de lijst met entiteits-URL's aanpassen aan de sensoren in je eigen Home Assistant-configuratie.

Het bestand `template.svg` bevat plaatsaanduidingen (zoals `R1_TEMP`) die door de functie `create_svg()` worden vervangen door echte sensorwaarden.
Tot slot zet een shellscript, dat via **KUAL** wordt geactiveerd, het gegenereerde SVG-bestand om in een PNG-afbeelding die geschikt is om op de Kindle weer te geven.

## Conclusie

Een oude Kindle Paperwhite hergebruiken als energiezuinig Home Assistant-dashboard dat altijd aanstaat, is niet alleen praktisch, maar ook een geweldige manier om ongebruikte hardware een nieuw leven te geven. Met een beetje scripting en enkele aanpassingen maak je van je Kindle een strak en overzichtelijk scherm voor belangrijke sensorgegevens, ideaal voor een nachtkastje, gang of werkplek.

Hoewel je voor deze opstelling een [gejailbreakte Kindle](https://kindlemodding.org/jailbreaking/) en enige vertrouwdheid met Python nodig hebt, levert het uiteindelijk een bijzonder aanpasbaar en stijlvol scherm op dat naadloos in je slimme woning integreert.

## Bronnen

  * [https://kindlemodding.org/jailbreaking/](https://kindlemodding.org/jailbreaking/): Een recente handleiding om een Kindle te jailbreaken
  * [Kindle-dashboard deel 1]({% post_url 2020/2020-09-27-PythonKindleDashboard_1 %}): Oudere post over hoe je een Kindle jailbreakt en KUAL-extensies maakt
  * [Kindle-dashboard deel 2]({% post_url 2020/2020-10-04-PythonKindleDashboard_2 %}): Post uit 2020 over het eerste dashboard dat ik met deze Kindle maakte
