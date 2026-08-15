---
layout: post
title:  "Van onze verbeterde IKEA Vindriktning een zelfstandige luchtkwaliteitsmonitor maken"
byline: "ESPHome loskoppelen van Home Assistant"
description: "Van de verbeterde IKEA Vindriktning-luchtkwaliteitsmonitor een zelfstandig toestel maken door statusleds toe te voegen en ESPHome op de ESP8266 zo te configureren dat die een eigen webpagina aanbiedt."
date:   2024-02-11 08:00:00
author: Sebastian Proost
post_id: air-quality-sensor-part-two
slug: stand-alone-air-quality-monitor-ikea-vindriktning-esp8266-bme680
categories: diy
tags:	Ikea soldering electronics home-assistant yaml esphome esp8266
cover:  "/assets/posts/2024-04-04-air-quality-sensor-part-two/completed_project.jpg"
thumbnail: "/assets/images/thumbnails/ikea_vindriktning_hack_2.jpg"
---

De luchtkwaliteit opvolgen in ruimtes waar je veel tijd doorbrengt, kan een wereld van verschil maken voor je welzijn en 
productiviteit. De [luchtkwaliteitsmonitor] die we in een vorige post bouwden, is echter nauw gekoppeld aan [Home Assistant] (HA), 
wat het gebruik ervan kan beperken in omgevingen zoals kantoren, werkplaatsen en garages. Het goede nieuws? We kunnen eenvoudig
extra leds toevoegen en die rechtstreeks in ESPHome aan de nieuwe sensorwaarden koppelen, zodat ze ook werken wanneer er geen 
verbinding met HA is. Bovendien is de ESP8266 net krachtig genoeg om als WiFi-accesspoint te werken en tegelijk een 
webpagina aan te bieden die alle sensorwaarden weergeeft. Deze gids toont hoe je extra statusleds toevoegt en 
[ESPHome] opnieuw configureert om deze zelfstandige werking mogelijk te maken. Zo wordt je luchtkwaliteitsmonitor een 
hulpmiddel dat je overal kunt gebruiken!

![Afgewerkte IKEA Vindriktning met extra statusleds](/assets/posts/2024-04-04-air-quality-sensor-part-two/completed_project.jpg)

## Wat heb je nodig?

Deze post bouwt voort op de [slimme doe-het-zelfluchtkwaliteitssensor] die je kunt maken met een IKEA Vindriktning-
luchtkwaliteitsmonitor, een ESP8266 en een Bosch BME680 (een sensor voor luchtvochtigheid, luchtdruk, temperatuur en vluchtige organische stoffen (VOC's)). We
kunnen er ook twee witte leds aan toevoegen die je zo kunt programmeren dat ze de meetwaarden van de BME680 visueel weergeven. Daardoor
is de sensor beter geschikt om zelfstandig te werken. Hiervoor heb je kleine leds nodig (bv. 1.8mm) die op 2 V werken en één
weerstand van 82 Ohm per led (ik gebruikte er twee, maar je kunt er indien nodig makkelijk nog enkele toevoegen). 

De volledige onderdelenlijst:

  * **IKEA Vindriktning-luchtkwaliteitsmonitor**
  * **Wemos D1 Mini Pro-microcontrollerbord** of een ander klein ESP8266-bord dat in de behuizing van de Vindriktning past
  * **Bosch BME680-sensorbord**
  * 2x **leds van 1.8mm**
  * 2x **weerstanden van 82 Ohm**
  * UV-hars (om de leds vast te lijmen)
  * Draad (gerecupereerd uit een USB-kabel)
  * Soldeergereedschap (soldeerbout, soldeertin, flux, ...)


Als je eerst op deze pagina terechtkwam, begin dan met de [slimme doe-het-zelfluchtkwaliteitssensor] uit een vorige post te bouwen.
Daarin lees je hoe je ESPHome instelt en alle sensoren correct op het microcontrollerbord aansluit.

## De sensor verbeteren (optioneel)

Als je geen extra statusleds wilt installeren, kun je dit deel gerust overslaan.

Nadat ik de printplaat uit de Vindriktning had gehaald, lijmde ik met UV-hars twee witte leds van 1.8mm tussen
de SMD-leds op de voorkant van de printplaat. Wees voorzichtig wanneer je de pinnen buigt: ik brak daarbij enkele leds! 
Zorg ervoor dat de leds mooi op één lijn staan met de bestaande exemplaren. Bij mij was dat niet het geval en dat valt enorm op zodra de 
leds branden.

![Printplaat met twee extra leds van 1.8mm die met UV-hars vastgelijmd zijn](/assets/posts/2024-04-04-air-quality-sensor-part-two/leds_mounted.jpg)

De aardingspinnen werden aangesloten op het 
aardingsvlak van een niet-gemonteerde connector op de Vindriktning-printplaat.

![Aardingspinnen aangesloten op de niet-gemonteerde soldeervlakken voor een pinheader](/assets/posts/2024-04-04-air-quality-sensor-part-two/leds_ground.jpg)

De foto's hieronder tonen hoe de anodes van de leds (de positieve aansluitingen) verbonden zijn met pinnen D5 en D6 van de D1 
Mini. De weerstanden van 82 Ohm die nodig zijn om 2V-leds op de 3.3V-uitgang van het bord aan te sluiten, werden rechtstreeks op het 
bord gesoldeerd. Aan het andere uiteinde van de weerstanden zitten draden die naar de anodes van de leds lopen.

![De positieve pinnen van de leds kunnen aan de zijkant van de printplaat aangesloten worden](/assets/posts/2024-04-04-air-quality-sensor-part-two/leds_positive.jpg)

![Weerstanden tussen de leds en de microcontroller](/assets/posts/2024-04-04-air-quality-sensor-part-two/resistors_in_place.jpg)

Nu configureren we de D1 Mini om de nieuwe leds te gebruiken en ze automatisch in te schakelen op basis van de door de BME680 gemeten luchtkwaliteit binnenshuis 
(IAQ). Het grootste deel van de configuratie is identiek aan die uit de vorige post, maar we moeten wel aangeven
waar onze leds aangesloten zijn. De onderstaande code stelt ze in. 

```yaml
light:
  - platform: monochromatic
    name: "Bottom Light"
    output: output_led_one
    id: bottom_light
  - platform: monochromatic
    name: "Top Light"
    output: output_led_two
    id: top_light
    
output:
  - platform: esp8266_pwm
    id: output_led_one
    pin: D5
  - platform: esp8266_pwm
    id: output_led_two
    pin: D6
```

Vervolgens voegen we een sjabloon toe dat de IAQ-waarden van de BME680 omzet in leesbare labels. We koppelen de automatisering hier rechtstreeks in 
ESPHome, zodat de leds op basis van die waarden in- of uitschakelen.

{:.large-code}
```yaml
text_sensor:
  - platform: template
    name: "BME680 IAQ Classification"
    icon: "mdi:checkbox-marked-circle-outline"
    lambda: |-
      auto label = "error";
      auto call1 = id(bottom_light).turn_off();
      auto call2 = id(top_light).turn_off();
      if ( int(id(iaq).state) <= 50) {
        label = "Excellent";
      }
      else if (int(id(iaq).state) >= 51 && int(id(iaq).state) <= 100) {
        label = "Good";
      }
      else if (int(id(iaq).state) >= 101 && int(id(iaq).state) <= 150) {
        call1 = id(bottom_light).turn_on();
        label = "Lightly polluted";
      }
      else if (int(id(iaq).state) >= 151 && int(id(iaq).state) <= 200) {
        call1 = id(bottom_light).turn_on();
        label = "Moderately polluted";
      }
      else if (int(id(iaq).state) >= 201 && int(id(iaq).state) <= 250) {
        call2 = id(top_light).turn_on();
        label = "Heavily polluted";
      }
      else if (int(id(iaq).state) >= 251 && int(id(iaq).state) <= 350) {
        call2 = id(top_light).turn_on();
        label = "Severely polluted";
      }
      else if (int(id(iaq).state) >= 351) {
        call1 = id(bottom_light).turn_on();
        call2 = id(top_light).turn_on();
        label = "Extremely polluted";
      }
      call1.set_brightness(0.5);
      call2.set_brightness(0.5);
      call1.perform();
      call2.perform();
      return {label};
```

De volledige configuratie staat hieronder (merk op dat je een bestand ```secrets.yaml``` nodig hebt met je WiFi-SSID en wachtwoord). 
Als je hulp nodig hebt om dit naar je toestel te flashen, vind je meer informatie in de vorige post.

{:.large-code}
```yaml
esphome:
  name: upgraded-sensor
  friendly_name: Upgraded sensor

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
    ssid: "Upgraded sensor"
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
    temperature_offset: 4.4

    # IAQ calculation mode
    # --------------------
    # Available options:
    # - static (for fixed position devices)
    # - mobile (for on a person or other moveable devices)
    # Default: static
    iaq_mode: mobile

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
      id: iaq
      filters:
        - median
        # - calibrate_linear:
          # - 137.0 -> 27.0
          # - 181.0 -> 189.0
          # - 430.0 -> 436
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
      
  - platform: template
    name: "BME680 IAQ Classification"
    icon: "mdi:checkbox-marked-circle-outline"
    lambda: |-
      auto label = "error";
      auto call1 = id(bottom_light).turn_off();
      auto call2 = id(top_light).turn_off();
      if ( int(id(iaq).state) <= 50) {
        label = "Excellent";
      }
      else if (int(id(iaq).state) >= 51 && int(id(iaq).state) <= 100) {
        label = "Good";
      }
      else if (int(id(iaq).state) >= 101 && int(id(iaq).state) <= 150) {
        call1 = id(bottom_light).turn_on();
        label = "Lightly polluted";
      }
      else if (int(id(iaq).state) >= 151 && int(id(iaq).state) <= 200) {
        call1 = id(bottom_light).turn_on();
        label = "Moderately polluted";
      }
      else if (int(id(iaq).state) >= 201 && int(id(iaq).state) <= 250) {
        call2 = id(top_light).turn_on();
        label = "Heavily polluted";
      }
      else if (int(id(iaq).state) >= 251 && int(id(iaq).state) <= 350) {
        call2 = id(top_light).turn_on();
        label = "Severely polluted";
      }
      else if (int(id(iaq).state) >= 351) {
        call1 = id(bottom_light).turn_on();
        call2 = id(top_light).turn_on();
        label = "Extremely polluted";
      }
      call1.set_brightness(0.5);
      call2.set_brightness(0.5);
      call1.perform();
      call2.perform();
      return {label};
      
light:
  - platform: monochromatic
    name: "Bottom Light"
    output: output_led_one
    id: bottom_light
  - platform: monochromatic
    name: "Top Light"
    output: output_led_two
    id: top_light
    
output:
  - platform: esp8266_pwm
    id: output_led_one
    pin: D5
  - platform: esp8266_pwm
    id: output_led_two
    pin: D6
```

Wil je de nieuwe leds door HA laten bedienen? Dat kan! Vervang gewoon de lambdafunctie die de IAQ genereert door de
onderstaande versie. Die schakelt de leds niet in en uit op basis van de nieuwe sensorwaarden, zodat
HA ze vrij kan bedienen.

{:.large-code}
```yaml
  - platform: template
    name: "BME680 IAQ Classification"
    icon: "mdi:checkbox-marked-circle-outline"
    lambda: |-
      auto label = "error";
      if ( int(id(iaq).state) <= 50) {
        label = "Excellent";
      }
      else if (int(id(iaq).state) >= 51 && int(id(iaq).state) <= 100) {
        label = "Good";
      }
      else if (int(id(iaq).state) >= 101 && int(id(iaq).state) <= 150) {
        label = "Lightly polluted";
      }
      else if (int(id(iaq).state) >= 151 && int(id(iaq).state) <= 200) {
        label = "Moderately polluted";
      }
      else if (int(id(iaq).state) >= 201 && int(id(iaq).state) <= 250) {
        label = "Heavily polluted";
      }
      else if (int(id(iaq).state) >= 251 && int(id(iaq).state) <= 350) {
        label = "Severely polluted";
      }
      else if (int(id(iaq).state) >= 351) {
        label = "Extremely polluted";
      }
      return {label};
```

## ESPHome als accesspoint instellen en de webserver starten

Extra statusleds geven je snel een algemeen beeld van de luchtkwaliteit die de BME680 meet, maar deze methode biedt 
weinig detail. Als je voor nauwkeurige metingen niet op Home Assistant kunt rekenen, is het een degelijke oplossing om het toestel als 
zelfstandig WiFi-accesspoint te configureren en een webpagina met deze waarden aan te bieden.

De volledige configuratie hieronder komt overeen met onze vorige opstelling, maar verschilt op één belangrijk punt in de `wifi`-
configuratie en door de toevoeging van het onderdeel `web_server`. De aanpassingen aan de `wifi`-instellingen activeren de 
accesspointfunctie van de ESP8266. Door 
`web_server` toe te voegen, nemen we de [ESPHome Web Server-component] op en starten we zo een lokale webserver. Deze server 
biedt een webpagina aan waarop de waarden van alle aangesloten sensoren te zien zijn voor elk toestel dat met 
het accesspoint verbonden is.

**Belangrijk**: Wanneer het toestel als WiFi-accesspoint geconfigureerd is, kan het geen verbinding maken met HA en geen 
firmware-updates via de ether ontvangen met het commando `esphome`. Om nieuwe firmware te installeren, moet je de webpagina van het toestel openen 
en de firmware van daaruit uploaden. Als je `ota` uitschakelt in het onderdeel `web_server`, kun je de 
firmware alleen nog bijwerken door ze rechtstreeks via een kabel te flashen.

```yaml
##### Stand-alone Access Point Config #####
api:
  reboot_timeout: 24h

ota:
  password: "eb24ad75972211d1fea73e45f5b90661"

wifi:
  ap:
    ssid: "Upgraded sensor"
    password: "BadAir2024"

web_server:
  port: 80
  local: true
  ota: true
```

De volledige configuratie, inclusief de configuratie van alle aangesloten sensoren, staat hieronder.

{:.large-code}
```yaml
esphome:
  name: upgraded-sensor
  friendly_name: Upgraded sensor

esp8266:
  board: d1_mini

# Enable logging
logger:

##### Stand-alone Access Point Config #####
api:
  # ESPHome will reboot if Home Assistant or any other client won't access it within the indicated
  # timeout in reboot_timeout, as a "watchdog" condition.
  # If you need to use ESPHome standalone, set reboot_timeout to something greater than the default
  # 15min
  reboot_timeout: 24h

ota:
  password: "eb24ad75972211d1fea73e45f5b90661"

wifi:
  ap:
    ssid: "Upgraded sensor"
    password: "BadAir2024"

web_server:
  port: 80
  local: true
  ota: true
    
    
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
    temperature_offset: 4.4

    # IAQ calculation mode
    # --------------------
    # Available options:
    # - static (for fixed position devices)
    # - mobile (for on a person or other moveable devices)
    # Default: static
    iaq_mode: mobile

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
      id: iaq
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
      
  - platform: template
    name: "BME680 IAQ Classification"
    icon: "mdi:checkbox-marked-circle-outline"
    lambda: |-
      auto label = "error";
      auto call1 = id(bottom_light).turn_off();
      auto call2 = id(top_light).turn_off();
      if ( int(id(iaq).state) <= 50) {
        label = "Excellent";
      }
      else if (int(id(iaq).state) >= 51 && int(id(iaq).state) <= 100) {
        label = "Good";
      }
      else if (int(id(iaq).state) >= 101 && int(id(iaq).state) <= 150) {
        call1 = id(bottom_light).turn_on();
        label = "Lightly polluted";
      }
      else if (int(id(iaq).state) >= 151 && int(id(iaq).state) <= 200) {
        call1 = id(bottom_light).turn_on();
        label = "Moderately polluted";
      }
      else if (int(id(iaq).state) >= 201 && int(id(iaq).state) <= 250) {
        call2 = id(top_light).turn_on();
        label = "Heavily polluted";
      }
      else if (int(id(iaq).state) >= 251 && int(id(iaq).state) <= 350) {
        call2 = id(top_light).turn_on();
        label = "Severely polluted";
      }
      else if (int(id(iaq).state) >= 351) {
        call1 = id(bottom_light).turn_on();
        call2 = id(top_light).turn_on();
        label = "Extremely polluted";
      }
      call1.set_brightness(0.5);
      call2.set_brightness(0.5);
      call1.perform();
      call2.perform();
      return {label};
      
light:
  - platform: monochromatic
    name: "Bottom Light"
    output: output_led_one
    id: bottom_light
  - platform: monochromatic
    name: "Top Light"
    output: output_led_two
    id: top_light
    
output:
  - platform: esp8266_pwm
    id: output_led_one
    pin: D5
  - platform: esp8266_pwm
    id: output_led_two
    pin: D6
```

## Verbinding maken met het toestel

Verbinding maken met je nieuwe zelfstandige luchtkwaliteitsmonitor is eenvoudig. Schakel het toestel in, geef het even de tijd om 
op te starten en gebruik daarna een pc, laptop of telefoon om met het WiFi-netwerk verbinding te maken via het wachtwoord dat je in de ESPHome-configuratie hebt ingesteld. 
Het is mogelijk dat je een waarschuwing krijgt omdat er geen internetverbinding is. Geen zorgen, 
dat is normaal. Open gewoon je webbrowser, ga naar **192.168.4.1** en je krijgt een webpagina te zien met de actuele 
luchtkwaliteitsmetingen.

![Schermafbeelding van de ingebouwde ESPHome-website met alle sensorwaarden en bedieningselementen voor de leds](/assets/posts/2024-04-04-air-quality-sensor-part-two/esphome_screenshot.png){:.small-image}

## Conclusie

Dit project toont twee erg leuke mogelijkheden. De eerste is hoe je eenvoudige automatiseringen rechtstreeks in ESPHome implementeert, 
waardoor ze veel robuuster worden. Als de WiFi uitvalt of de server waarop Home Assistant (HA) draait crasht, blijven ze 
gewoon werken. De tweede mogelijkheid is een ESP8266 configureren om als WiFi-accesspoint te werken en tegelijk een 
eenvoudige website aan te bieden. Zo krijg je een interface die je kunt integreren zonder extra onderdelen aan 
je project toe te voegen!


[luchtkwaliteitsmonitor]: {% post_url nl/2024/2024-01-21-air-quality-sensor %}
[slimme doe-het-zelfluchtkwaliteitssensor]: {% post_url nl/2024/2024-01-21-air-quality-sensor %}
[ESPHome compileren en flashen]: {% post_url nl/2024/2024-01-21-air-quality-sensor %}#manual-setup-flash-esp8266 
[Home Assistant]: https://www.home-assistant.io/
[manual installation of ESPHome]: https://esphome.io/guides/installing_esphome
[ESPHome]: https://esphome.io/
[ESPHome Web Server-component]: https://esphome.io/components/web_server.html
