---
layout: post
title:  "Slimme luchtkwaliteitsmonitoring met een IKEA Vindriktning, ESP8266 en BME680"
byline: "Een stapsgewijze handleiding"
description: "Stapsgewijze handleiding om de IKEA Vindriktning-luchtkwaliteitsmonitor uit te breiden met een ESP8266 en BME680-VOC-sensor, en via ESPHome te integreren in Home Assistant."
date:   2024-01-21 08:00:00
author: Sebastian Proost
post_id: air-quality-sensor
slug: diy-smart-air-quality-monitor-ikea-vindriktning-esp8266-bme680
categories: diy
tags:	Ikea soldering electronics home-assistant yaml esphome esp8266
cover:  "/assets/posts/2024-01-21-air-quality-sensor/ikea_vindriktning_with_esp8266_bme680.jpg"
thumbnail: "/assets/images/thumbnails/ikea_vindriktning_hack.jpg"
---

Goede isolatie is essentieel in moderne woningen: ze biedt comfort en energiezuinigheid. Vaak is daardoor echter ook 
betere ventilatie nodig om de luchtkwaliteit gezond te houden. In deze handleiding richten we ons op een innovatieve, 
betaalbare manier om de luchtkwaliteit in huis te verbeteren met enkele slimme technologieën. We tonen hoe je de 
[IKEA Vindriktning]-luchtkwaliteitsmonitor combineert met een ESP8266-microcontroller en een BME680-sensor voor vluchtige organische stoffen (VOC's), waarmee je het CO<sub>2</sub>-niveau kunt schatten. Met deze IKEA-*hack* 
kun je op basis van nauwkeurige gegevens weloverwogen beslissen wanneer je ramen moet openen, de ventilatie moet verhogen 
of filters moet vervangen. Bovendien integreert het geheel vlot met domoticasystemen zoals [Home Assistant] via [ESPHome].

In deze handleiding nemen we elk aspect van dit project grondig door. We beginnen helemaal bij de basis met de 
elektronica, gaan vlot verder met de integratie in Home Assistant (HA) en geven zelfs enkele handige tips 
om de resultaten te interpreteren. 

## Wat heb je nodig?

Het idee om de IKEA Vindriktning uit te breiden is niet bepaald nieuw — er bestaat al een overvloed 
aan informatie en verschillende *hacks* — maar wie later komt, kan wel de beste 
oplossing uitkiezen. Na wat opzoekwerk koos ik voor de Wemos D1 Mini Pro. Het is een handige kleine microcontroller op basis van de 
ESP8266. Vooral zijn compacte formaat maakt hem ideaal voor dit project: hij past netjes in de behuizing van de Vindriktning 
en is bovendien erg betaalbaar. Dan is er nog de Bosch BME680. Deze kleine sensor meet 
temperatuur, luchtdruk en luchtvochtigheid in een bijzonder compact formaat, maar zijn echte troef is de 
VOC-sensor. En het beste van al? Hij maakt probleemloos verbinding met de ESP8266 via een eenvoudige I2C-aansluiting met vier draden, waardoor 
de integratie kinderspel wordt.

1. **IKEA Vindriktning-luchtkwaliteitsmonitor**: Vergeet niet dat die een eigen voeding nodig heeft. Neem dus een USB-C-kabel en een compatibele voedingsadapter (die worden niet meegeleverd met de Vindriktning, dus zorg dat je ze bij de hand hebt).

2. **Wemos D1 Mini Pro-microcontrollerbord**: Dit is het brein van het geheel. Het is compact, efficiënt en precies wat je voor dit project nodig hebt.

3. **Bosch BME680-sensorbord**: Hiermee meet je temperatuur, luchtdruk, luchtvochtigheid en VOC-niveaus. Het is een cruciaal onderdeel om die gedetailleerde metingen van de luchtkwaliteit te verkrijgen.

4. **Draden**: Ik hergebruikte enkele draden uit een oude USB-kabel. Een prima manier om te recycleren en een paar euro te besparen!

5. **USB-kabel voor de D1 Mini Pro**: Welke je nodig hebt, hangt af van de versie van je D1 Mini Pro. Sommige gebruiken micro-USB, andere USB-C. Controleer dus goed welke je nodig hebt!

6. **Soldeermateriaal**: Voorzie een soldeerbout met temperatuurregeling. Vergeet ook soldeertin, flux en andere benodigdheden niet om vlot te kunnen solderen.

De totale kostprijs van dit project kan sterk variëren afhankelijk van waar je de onderdelen koopt. Voor mij loonde wat 
slim winkelen op AliExpress — ik vond de microcontroller en sensor voor respectievelijk ongeveer $3 en $5. Tel daar 
de IKEA Vindriktning van $12 bij op en je komt uit op een totaalbedrag van ongeveer $20-25. Het opvallende is dat 
dit ongeveer de helft kost van de goedkoopste slimme luchtkwaliteitssensor die ik op de markt kon vinden! 

## De ESP8266 verbinden met de BME680

Dankzij de I2C-interface is het vrij eenvoudig om het BME680-sensorbord met onze microcontroller te verbinden. 
Door dit handige protocol hebben we slechts vier draden nodig. Zo heb ik alles aangesloten: 


| D1 Mini-pin | BME680-pin | Kabelkleur |
|-------------|------------|-------------|
| 3V3         | VCC        | Rood        |
| G           | GND        | Zwart       |
| D1          | SDA        | Groen       |
| D2          | SCL        | Wit         |

Een tip: hou de bedrading kort en netjes. Ik heb mijn oorspronkelijke opstelling uiteindelijk aangepast om de draden in te korten 
nadat ik de onderstaande foto had genomen. In de behuizing wil je alles netjes en efficiënt houden om 
de luchtstroom niet te belemmeren.

![Een D1 Mini Pro-bord (ESP8266) verbonden met het BME680-bord](/assets/posts/2024-01-21-air-quality-sensor/esp8266_bme680_wired_up.jpg)

## ESPHome flashen

Nu je ESP8266 nog goed bereikbaar is, is dit het perfecte moment om 
[ESPHome] op je Wemos D1 Mini Pro te installeren. Dat gaat bijzonder vlot, zeker als je
[Home Assistant] gebruikt. Ga naar hun [handleiding om aan de slag te gaan](https://esphome.io/guides/getting_started_hassio) 
en klik op de knop **Add-on weergeven in Mijn HA**. Je wordt gevraagd de URL van je HA-installatie te bevestigen voordat je op 
**Link openen** klikt. Daarna zijn de installatie en configuratie van ESPHome eenvoudig. Vergeet ook niet de opties 
**Starten bij opstarten** en **Waakhond** aan te vinken. Die zorgen ervoor dat ESPHome indien nodig opnieuw opstart.

Verbind nu de D1 Mini via een USB-kabel met je computer. Ga vervolgens naar Home Assistant en zoek 
ESPHome in de zijbalk. Klik op **NIEUW APPARAAT** en geef je apparaat een naam die voor jou logisch is; ik koos 
'Woonkamersensor'. Volg daarna gewoon de instructies op het scherm. Selecteer wanneer daarom gevraagd wordt de COM-poort die 
bij je apparaat hoort (bij mij was dat COM6). Zo wordt er basisfirmware naar je ESP8266 geflasht. Geen problemen? 
Perfect! Als alles hier vlot verliep, kun je het volgende deel overslaan.

{: #manual-setup-flash-esp8266 }
### De ESP8266 handmatig instellen en flashen

Bij mij werkte dit echter niet (misschien omdat mijn Home Assistant op een stokoude Raspberry Pi draait). 
Als je net als ik tegen een probleem aanloopt, wordt de firmware waarschijnlijk niet correct gecompileerd op je Home Assistant-apparaat. 
Gelukkig kan dit ook handmatig. Voer een [handmatige installatie van ESPHome](https://esphome.io/guides/installing_esphome) uit. 
Zo kreeg ik de opdrachtregelversie van ESPHome op mijn computer aan de praat.

Om je apparaat te flashen, maak je nu een configuratiebestand aan (of gebruik je het onderstaande) en voer je de twee 
onderstaande opdrachten uit. Die compileren nieuwe firmware met jouw configuratie en sturen die rechtstreeks naar je apparaat. 
Let op: de eerste upload moet via USB gebeuren. Daarna kun je *over-the-air*-updates gebruiken!

```bash
esphome compile living-room-sensor.yaml
esphome upload living-room-sensor.yaml
```

**Opmerking:** Als je bepaalde gegevens, zoals het WiFi-netwerk en wachtwoord, als geheim wilt toevoegen, moet je die definiëren
in een bestand ```secrets.yaml``` in dezelfde map als het configuratiebestand dat je compileert en uploadt.

Zodra je apparaat de nieuwe firmware met succes uitvoert, voeg je het toe aan Home Assistant. Klik in het ESPHome-
gedeelte op NIEUW APPARAAT en voer de naam in die je in het yaml-bestand hebt opgegeven. Maak wanneer daarom gevraagd wordt verbinding via de COM-poort. Een 
korte opmerking: je kunt de stappen voor het compileren en uploaden van de firmware overslaan, want die zijn nu niet nodig.

Er rest nog één detail. Het is belangrijk dat het yaml-bestand op je apparaat overeenkomt met het bestand 
in de ESPHome-add-on van Home Assistant. Ga daarvoor naar het ESPHome-gedeelte, kies **Bewerken** bij het apparaat waaraan je net hebt gewerkt, 
vervang de inhoud van het yaml-bestand door je bijgewerkte versie en klik vervolgens op **Opslaan**. Deze stap is telkens nodig wanneer je 
de configuratie bijwerkt, zodat alles gesynchroniseerd blijft.

## De IKEA Vindriktning verbinden met de D1 Mini

De IKEA Vindriktning lijkt haast ontworpen met doe-het-zelvers in gedachten. Eén blik op de printplaat en je ziet 
de duidelijk gemarkeerde testpunten — een droom voor elke *hacker*. Voor ons project moeten we ons op drie cruciale 
aansluitingen richten: +5V, GND en REST. Die voeden niet alleen de ESP8266, maar sturen ook de metingen van de 
PM1006-sensor van de Vindriktning naar onze microcontroller. 

![Detailopname van de testpunten op de IKEA Vindriktning](/assets/posts/2024-01-21-air-quality-sensor/ikea_vindriktning_pcb_test_pads.jpg)

Zo heb ik alles aangesloten:

| D1 Mini-pin | IKEA Vindriktning | Kabelkleur |
|-------------|-------------------|-------------|
| 5V          | +5V               | Rood        |
| G           | GND               | Zwart       |
| D7          | REST              | Groen       |

![IKEA Vindriktning, BME680 en D1 Mini Pro (ESP8266)](/assets/posts/2024-01-21-air-quality-sensor/esp8266_connected_to_ikea_vindriktning.jpg)

Overweeg om de draden met een beetje hete lijm aan de printplaten te bevestigen. Het is een eenvoudige stap die je veel problemen kan besparen 
doordat er minder spanning op de soldeerverbindingen komt. Hou er ook rekening mee dat de Vindriktning 5V gebruikt, terwijl de ESP8266 
doorgaans 3,3V nodig heeft. Omdat de ESP8266 bestand is tegen 5V, kun je ze rechtstreeks met elkaar verbinden. Je kunt echter ook een 
spanningsdeler of *level shifter* gebruiken om de juiste spanning naar de ESP8266 te sturen.

## Het apparaat configureren

Hieronder vind je mijn huidige configuratie. Als je bedrading identiek is aan de mijne, kun je die gerust als sjabloon gebruiken. Maar 
als je andere pinnen op de D1 Mini hebt gebruikt, moet je de 
aansluitingen met de sensoren uiteraard aanpassen. Het is ook verstandig om de instellingen `name` en `friendly_name` 
aan je eigen situatie aan te passen. Overweeg meteen ook om de encryptiesleutel en het OTA-wachtwoord te wijzigen voor een extra 
beveiligingslaag.

Dan is er nog een cruciale instelling voor de BME680: de `temperature_offset`. De metingen van de relatieve luchtvochtigheid hangen 
nauw samen met de luchttemperatuur. Maar als je BME680 vlak bij apparaten zit die warmte afgeven, 
kan de sensor een iets hogere temperatuur meten dan de werkelijke kamertemperatuur. Daardoor kunnen je metingen 
afwijken. Mijn advies? Hou de temperatuurmetingen een tijdje in de gaten. Vergelijk ze met een andere betrouwbare thermometer, bijvoorbeeld 
de thermostaat van je woning of een andere sensor. Als de BME680 consequent te hoog meet, verhoog dan de waarde van 
`temperature_offset`. Op mijn bureau, met alle onderdelen open en bloot, volstond een correctie van 2 of 3 graden. 
Maar zodra ik alles in de behuizing had geplaatst, moest ik die verhogen tot 6 graden om overeen te komen met een andere sensor in 
dezelfde kamer.

{:.large-code}
```yaml
esphome:
  name: living-room-sensor
  friendly_name: Living Room Sensor

esp8266:
  board: d1_mini

# Enable logging
logger:

# Enable Home Assistant API
api:
  encryption:
    key: "r5e+0e+eigBjFpfNo+r/TIykX9lK40oG7+2NZ3RiG08="

ota:
  password: "eb24ad75972211d1fea73e45f5b90661"

wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password

  # Enable fallback hotspot (captive portal) in case wifi connection fails
  ap:
    ssid: "Living-Room-Sensor"
    password: !secret wifi_password

captive_portal:
    
    
## Serial Port for the IKEA Sensor
uart:
  - rx_pin: D7
    # tx_pin: D8
    baud_rate: 9600

i2c:
  ## I²C Port - For Temp/Humidity/Pressure & CO²/VOC Sensors
  sda: D1
  scl: D2
  scan: true
  id: bus_a

bme680_bsec:
    # id
    # -----------
    # Identifier for this component, useful when working with multiple devices.
    # Must be unique, and can be used in the sensor sections to refer to the correct device.
    # Default: auto-computed
    id: bme680_internal

    # i2c address
    # -----------
    # Common values are:
    # - 0x76
    # - 0x77
    # Default: 0x76
    address: 0x77

    # Temperature offset
    # ------------------
    # Useful if device is in enclosure and reads too high
    # For example, if it reads 5C too high, set this to 5
    # This also corrects the relative humidity readings
    # Default: 0
    temperature_offset: 6

    # IAQ calculation mode
    # --------------------
    # Available options:
    # - static (for fixed position devices)
    # - mobile (for on a person or other moveable devices)
    # Default: static
    iaq_mode: static

    # Sample rate
    # -----------
    # Available options:
    # - lp (low power - samples every 3 seconds)
    # - ulp (ultra-low power - samples every 5 minutes)
    # Default: lp
    sample_rate: lp

    # Interval at which to save BSEC state
    # ------------------------------------
    # Default: 6h
    state_save_interval: 6h

sensor:
  ## IKEA PMS 2.5um Sensor
  - platform: pm1006
    id: aq_sensor
    pm_2_5:
      name: "IKEA 2.5µg"
      
  - platform: bme680_bsec
    # ID of the bme680_bsec component to use for the next sensors.
    # Useful when working with multiple devices
    bme680_bsec_id: bme680_internal

    temperature:
      # Temperature in °C
      name: "BME680 Temperature"
      sample_rate: lp
      filters:
        - median
    pressure:
      # Pressure in hPa
      name: "BME680 Pressure"
      sample_rate: lp
      filters:
        - median
    humidity:
      # Relative humidity %
      name: "BME680 Humidity"
      sample_rate: lp
      filters:
        - median
    gas_resistance:
      # Gas resistance in Ω
      name: "BME680 Gas Resistance"
      filters:
        - median
    iaq:
      # Indoor air quality value
      name: "BME680 IAQ"
      filters:
        - median
    iaq_accuracy:
      # IAQ accuracy as a numeric value of 0, 1, 2, 3
      name: "BME680 Numeric IAQ Accuracy"
    co2_equivalent:
      # CO2 equivalent estimate in ppm
      name: "BME680 CO2 Equivalent"
      filters:
        - median
    breath_voc_equivalent:
      # Volatile organic compounds equivalent estimate in ppm
      name: "BME680 Breath VOC Equivalent"
      filters:
        - median

text_sensor:
  - platform: bme680_bsec
    iaq_accuracy:
      # IAQ accuracy as a text value of Stabilizing, Uncertain, Calibrating, Calibrated
      name: "BME680 IAQ Accuracy"

```

Zodra alles werkt, kun je alles weer in de behuizing van de Vindriktning plaatsen en de nieuwe sensor 
en de ESP8266 met een beetje hete lijm vastzetten.

## Home Assistant instellen

Nu alle vorige stappen voltooid zijn, zou ESPHome de sensorgegevens met succes met Home Assistant moeten delen. 
De volgende stap is een dashboardkaart instellen om die gegevens weer te geven. Hieronder zie je ter illustratie een schermafbeelding van mijn opstelling. 
Die toont de temperatuur- en luchtvochtigheidstrends van de voorbije twee dagen, evenals de waarden voor fijnstof (PM2.5) en CO<sub>2</sub> 
van de voorbije twee uur. Ik heb de yaml-code voor deze kaart hieronder toegevoegd, maar pas de apparaatnamen 
zeker aan je eigen configuratie aan.

![Schermafbeelding van de kaart in Home Assistant met alle gegevens van de uitgebreide Vindriktning-sensor](/assets/posts/2024-01-21-air-quality-sensor/HA_screenshot.png){:.small-image}

Door op de grafiek van een sensor te klikken, krijg je een gedetailleerdere weergave waarin je de trends van de luchtkwaliteit over 
verschillende tijdsperiodes kunt bekijken. Wil je veranderingen over langere periodes opvolgen, dan volstaat een eenvoudige klik op de 
grafiek om een pop-up met een uitgebreidere grafiek weer te geven.

{:.large-code}
```yaml
type: vertical-stack
title: Living Room
cards:
  - type: glance
    entities:
      - entity: sensor.living_room_sensor_bme680_temperature
      - entity: sensor.living_room_sensor_bme680_humidity
      - entity: sensor.living_room_sensor_bme680_pressure
    show_name: false
  - type: horizontal-stack
    cards:
      - graph: line
        type: sensor
        entity: sensor.living_room_sensor_bme680_temperature
        hours_to_show: 48
        name: Temperature
        detail: 2
      - graph: line
        type: sensor
        entity: sensor.living_room_sensor_bme680_humidity
        hours_to_show: 48
        detail: 2
        name: Humidity
  - type: glance
    entities:
      - entity: sensor.living_room_sensor_ikea_2_5_g
        name: PM2.5
      - entity: sensor.living_room_sensor_bme680_co2_equivalent
        name: CO2 Level
      - entity: sensor.living_room_sensor_bme680_iaq
        name: Air Quality
    show_name: true
  - type: horizontal-stack
    cards:
      - graph: line
        type: sensor
        entity: sensor.living_room_sensor_ikea_2_5_g
        hours_to_show: 2
        name: PM 2.5 (2 hours)
        detail: 2
      - graph: line
        type: sensor
        entity: sensor.living_room_sensor_bme680_co2_equivalent
        hours_to_show: 2
        detail: 2
        name: CO2 levels (2 hours)
  - type: glance
    entities:
      - entity: sensor.living_room_sensor_bme680_gas_resistance
        name: Gas Resistance
      - entity: sensor.living_room_sensor_bme680_breath_voc_equivalent
        name: bVOCe
      - entity: sensor.living_room_sensor_bme680_iaq_accuracy
        name: Status
    show_name: true

```

## Hoe interpreteer je de PM2.5- en CO<sub>2</sub>-metingen?

Het is belangrijk om te onthouden dat dit een doe-het-zelfoplossing is en geen uiterst nauwkeurig gekalibreerde laboratoriumapparatuur. Daarom moet je 
de absolute waarden met enige voorzichtigheid benaderen, maar kunnen relatieve trends waardevolle inzichten geven in 
veranderingen in de luchtkwaliteit van je woning en de doeltreffendheid van je ventilatie. Hou er ook rekening mee dat de BME680-
sensor de totale hoeveelheid vluchtige organische stoffen (VOC's) in de lucht meet en niet specifiek CO<sub>2</sub>. Hij schat 
het CO<sub>2</sub>-niveau op basis van de algemene VOC-metingen en verschillende aannames.

Voor PM2.5 luidt de algemene aanbeveling dat het niveau over een periode van 24 uur niet hoger mag zijn dan 35 μg/m<sup>3</sup>, met ideale waarden onder 12 μg/m<sup>3</sup>. Normale CO<sub>2</sub>-waarden binnenshuis liggen tussen 400 en 1000 ppm. Het is aan te raden om meer te ventileren wanneer die waarden worden overschreden.

Let bij het analyseren van de grafieken op het volgende:

  * **Scherpe pieken herkennen:** Bij het koken komen bijvoorbeeld verschillende VOC's vrij die de sensor kan detecteren. Let op activiteiten die je lucht mogelijk vervuilen en reageer door meer te ventileren of ramen te openen.
  * **Duur van piekwaarden:** Als de VOC's van het koken lange tijd blijven hangen, wijst dat erop dat je ventilatie mogelijk onvoldoende is.
  * **Geleidelijke stijgingen tot onveilige niveaus:** Dit gebeurt vaak tijdens bijvoorbeeld feestjes of in kleinere kamers zoals slaapkamers, waar CO<sub>2</sub> zich na verloop van tijd kan ophopen en mogelijk de slaapkwaliteit beïnvloedt.
  * **Ongewoon hoge basiswaarden:** Als je normaal CO2-waarden van ongeveer 600-700 ppm in je woonkamer meet en die plots consequent hoger liggen, is het misschien tijd om je ventilatiesysteem te controleren of de filters te vervangen.

## Conclusie

Als je tot hier hebt meegevolgd, ben je erin geslaagd een betaalbare doe-het-zelfoplossing te maken om 
de luchtkwaliteit in huis te meten en te verbeteren. We combineerden de IKEA Vindriktning-luchtkwaliteitsmonitor met een 
Wemos D1 Mini Pro-microcontroller en een Bosch BME680-VOC-sensor, met een slim en efficiënt luchtkwaliteitssysteem als resultaat. Dit 
systeem levert niet alleen realtimegegevens, maar integreert ook naadloos met domoticasystemen zoals Home Assistant 
en ESPHome.

We behandelden alles, van de juiste hardware kiezen en aansluiten tot het apparaat configureren en de 
gegevens interpreteren. Dankzij deze handleiding heb je nu een hulpmiddel waarmee je weloverwogen kunt beslissen wanneer je 
ramen moet openen, meer moet ventileren of filters moet vervangen, zodat de luchtkwaliteit in huis altijd optimaal blijft.

Onthoud dat dit een doe-het-zelfproject is en geen vervanging voor professionele apparatuur. Maak je je zorgen om de gezondheid 
van jezelf en je gezin, of vrees je blootstelling aan specifieke schadelijke gassen zoals koolstofmonoxide, ... schakel dan zeker 
een professional in.

## Meer informatie

Er bestaan heel wat varianten op dit project. Bekijk de links hieronder voor meer informatie!

  * [Maak van je IKEA-luchtkwaliteitssensor een onmisbaar onderdeel van je slimme woning met deze doe-het-zelfupgrade] : [3ATIVE VFX Studio] toont hoe je een BME280- en CSS811-sensor toevoegt en ook sensoren van de Vindriktning uitleest (de lichtsensor en ventilatorstatus)
  * [De IKEA VINDRIKTNING PM2.5-sensor hacken met Tasmota] : Handleiding van [VoltLog] waarin een BME680 wordt gebruikt, al wordt hier Tasmota gebruikt in plaats van ESPHome
  * [Deze handleiding](https://www.youtube.com/watch?v=swz7h40PMgs) van [Salvamipc], die aanwezigheidsdetectie (met de HLK-LD2410) en een omgevingslichtsensor (bh1750) aan de Vindriktning toevoegt

Of lees de [volgende post]({% post_url nl/2024/2024-04-04-air-quality-sensor-part-two %}), waarin we de sensor loskoppelen van Home Assistant en er een zelfstandig apparaat van maken.

[IKEA Vindriktning]: https://web.archive.org/web/20221003172915/https://www.ikea.com/be/en/p/vindriktning-air-quality-sensor-70498242/
[Home Assistant]: https://www.home-assistant.io/
[ESPHome]: https://esphome.io/
[Maak van je IKEA-luchtkwaliteitssensor een onmisbaar onderdeel van je slimme woning met deze doe-het-zelfupgrade]: https://www.youtube.com/watch?v=YmqtMTO5NVc
[3ATIVE VFX Studio]: https://www.youtube.com/@3ATIVE
[De IKEA VINDRIKTNING PM2.5-sensor hacken met Tasmota]: https://www.youtube.com/watch?v=QRke2ww2VTw
[VoltLog]: https://www.youtube.com/@voltlog
[Salvamipc]: https://www.youtube.com/@salvamipc
