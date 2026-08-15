---
layout: post
title:  "Een aangepaste Deej-volumemixer bouwen met een RP2040 Pro Micro"
byline: "met CircuitPython"
description: "Een opensource Deej-USB-volumemixer bouwen met een RP2040 Pro Micro en CircuitPython, met een USB-C-poort en enkele handige verbeteringen om het volume per app te regelen."
date:   2025-02-03 08:00:00
author: Sebastian Proost
post_id: deej-open-hardware-volume-controller
categories: diy programming
tags:	deej python raspberry-pi soldering electronics
cover:  "/assets/posts/2025-02-03-deej-open-hardware-volume-controller/deej_02.jpg"
thumbnail: "/assets/images/thumbnails/deej_header.jpg"
gallery_items:
  - image: "/assets/posts/2025-02-03-deej-open-hardware-volume-controller/deej_03.jpg"
    gallery_image: "/assets/images/gallery/deej.jpg"
    description: "Een fysieke volumemixer met een minimalistisch ontwerp en een vintage ogende behuizing: dit is mijn Deej."
---

Op zoek naar een zelfgebouwde hardwarevolumemixer waarmee je moeiteloos het volume van afzonderlijke apps regelt? Of je nu gamer, streamer of audiofanaat bent, softwarematige volumeregelaars handmatig aanpassen kan frustrerend zijn. Daar komt [Deej] van pas, een opensource USB-volumemixer.

In deze handleiding toon ik hoe ik een Deej-volumemixer bouwde met een RP2040 Pro Micro, een Raspberry Pi Pico-kloon in een compacter formaat, met een paar verbeteringen voor het gebruiksgemak en een USB-C-poort. In tegenstelling tot de vaker voorkomende builds met Arduino gebruikt deze opstelling [CircuitPython] als eenvoudig te programmeren en krachtig alternatief.

Omdat je een Deej op heel wat manieren kunt bouwen, toon ik eerst mijn versie. Daarna bekijken we hoe je de code schrijft en Deej configureert. Hopelijk geeft dit je een goed vertrekpunt voor je eigen aangepaste volumemixer.

## Wat heb je nodig?

Verzamel voor je begint de volgende onderdelen en gereedschappen:

  * **RP2040 Pro Micro** – Een microcontroller op basis van de RP2040 die het zware werk zal doen.
  * **Potentiometers** – Drie potentiometers van 10 kOhm om het volume te regelen.
  * **Knoppen** – Drie knoppen voor op de potentiometers.
  * **Gaatjesprintplaat** – Een klein stukje gaatjesprintplaat om de onderdelen op te solderen.
  * **Jumperdraden** – Om de onderdelen op de gaatjesprintplaat te verbinden.
  * **Behuizing** – Een aangepaste behuizing voor de onderdelen.
  * **Soldeermateriaal** – Een soldeerbout, soldeertin en flux om de hardware in elkaar te zetten.

  * Optionele onderdelen als je een **stroomindicator** wilt toevoegen:
    * **Led van 3 mm** - Een led die aangeeft wanneer het toestel aanstaat.
    * **Weerstand van 82 Ohm** – Om de stroom naar de led te begrenzen.
    * **Ledhouder** - Om de led op zijn plaats te houden en het geheel mooi af te werken.

## De hardware monteren

Ik begon met de behuizing. In [Inkscape](https://inkscape.org/) maakte ik een model van het voorpaneel en verschoof ik de onderdelen tot ik
tevreden was met de indeling. Ik printte dit ontwerp op stickerpapier en kleefde het daarna op het voorpaneel. Zo kon ik
de gaten voor de potentiometers en de ledhouder precies op de juiste plaats boren.

![Ontwerp van het voorpaneel voor de Deej-volumemixer](/assets/posts/2025-02-03-deej-open-hardware-volume-controller/front_panel_design.png)

Vervolgens soldeerde ik de RP2040 Pro Micro op de gaatjesprintplaat en verbond ik de potentiometers en led met de microcontroller. De kathode van de led moet met de massa verbonden worden en de anode via de weerstand van **82 Ohm** met pin **GP8** van de RP2040 (al kan dit bijna om het even welke andere GPIO-pin zijn). De **middelste pinnen** van de potentiometers worden respectievelijk met pinnen **GP26, GP27 en GP28** van de RP2040 verbonden. Voor de potentiometers kun je alleen deze pinnen gebruiken, omdat enkel zij analoog-naar-digitaalconversie (ADC) ondersteunen. Dat is nodig om de waarden van de potentiometers uit te lezen. De andere pinnen van de potentiometers gaan naar de massa en 3,3 V.

Daarna monteerde ik de gaatjesprintplaat in mijn behuizing, waarvoor ik twee schroefgaten in de printplaat moest boren. De behuizing had al enkele plekken om een printplaat vast te schroeven. Daar plaatste ik schroefdraadbussen in, zodat de schroeven de printplaat stevig op haar plaats zouden houden. Ik maakte in het achterpaneel ook een opening zodat de USB-C-poort van de RP2040 Pro Micro bereikbaar bleef. Tot slot zette ik de knoppen op de potentiometers en bevestigde ik de ledhouder.

![Een zelfgebouwde audiovolumemixer met een minimalistisch ontwerp en een vintage ogende behuizing, drie zwarte draaiknoppen met witte markeringen en een brandende witte led op het voorpaneel. Het toestel staat op een houten oppervlak.](/assets/posts/2025-02-03-deej-open-hardware-volume-controller/deej_03.jpg)

De behuizing die ik koos, moet al ruim twintig jaar in mijn onderdelenbak gelegen hebben. De doe-het-zelf-elektronicakit waarvoor ik ze oorspronkelijk kocht, paste er ondanks de aanbevolen behuizing niet goed in. Vanwege de retrosfeer koos ik voor even retro knoppen. De ene witte led is de enige hint dat dit project niet uit de jaren 80 of 90 komt.


## De RP2040 voorbereiden

Als je dat nog niet gedaan hebt, moet je de RP2040 Pro Micro instellen voor gebruik met CircuitPython. Volg de stappen in de [handleiding van Adafruit](https://learn.adafruit.com/getting-started-with-raspberry-pi-pico-circuitpython/circuitpython) om CircuitPython op de RP2040 te installeren. Daarna kun je verder met de volgende stappen.

## De code schrijven

Om met Deej te communiceren heb je een toestel nodig dat een serieel apparaat nabootst en via die seriële verbinding berichten met de gewenste volumeniveaus verstuurt. De waarden moeten tussen 0 en 1023 liggen, waarbij 0 gedempt is en 1023 het maximale volume, en worden gescheiden door verticale strepen (`|`). CircuitPython maakt dit heel eenvoudig: het opent standaard een seriële verbinding en verstuurt *print statements* via die verbinding. Als je bijvoorbeeld `0|512|1023` afdrukt en Deej dat ontvangt, wordt het eerste kanaal op 0, het tweede op 50% en het laatste op 100% gezet.

De code die ik gebruik om de potentiometers uit te lezen en de waarden via de seriële verbinding te versturen ziet er zo uit:

```python
import board
import analogio
import time
import pwmio

# Constants
MIN_VALUE = 340
MAX_VALUE = 65535
RANGE = MAX_VALUE - MIN_VALUE
ADC_PINS = [board.GP26, board.GP28, board.GP27]
SAMPLES = 10
SLEEP_TIME = 0.1  # 100ms delay

# Set up ADC inputs
ADCs = [analogio.AnalogIn(pin) for pin in ADC_PINS]

# Set up LED, use PWM otherwise it is too bright
pwm = pwmio.PWMOut(board.GP8, frequency=8000, duty_cycle=32768)

def get_smoothed_adc_value(adc, samples=SAMPLES):
    """Reads and averages multiple ADC samples for noise reduction."""
    smooth_value = sum(adc.value for _ in range(samples)) // samples
    return (max(0, smooth_value - MIN_VALUE) * 1023) // RANGE

def read_pot_values():
    """Reads and returns smoothed values from all ADCs."""
    return [get_smoothed_adc_value(adc) for adc in ADCs]

def send_pot_values(pot_values):
    """Formats and prints potentiometer values."""
    print('|'.join(map(str, pot_values)))

# Main loop
while True:
    pot_values = read_pot_values()
    send_pot_values(pot_values)
    time.sleep(SLEEP_TIME)
```

Deze code leest de waarden van de potentiometers uit, vlakt ze af door het gemiddelde van meerdere metingen te nemen en verstuurt ze via de seriële verbinding. De constanten `MIN_VALUE` en `MAX_VALUE` schalen de ADC-waarden naar het gewenste bereik en moeten voor andere toestellen mogelijk aangepast worden. De constante `RANGE` is het verschil tussen de maximum- en minimumwaarden. De constante `SAMPLES` bepaalt hoeveel metingen er genomen worden om de ADC-waarden af te vlakken. De constante `SLEEP_TIME` bepaalt de wachttijd tussen elke meting. Dit moet vaak genoeg gebeuren zodat Deej snel op wijzigingen reageert, maar niet zo vaak dat de seriële verbinding overspoeld raakt. Ik vond 100 ms een goed evenwicht, maar ik heb implementaties gezien met wachttijden tot slechts 10 ms. Als je dit wilt gebruiken, sla je het gewoon als `code.py` op de RP2040 Pro Micro op.

## Deej configureren

Download Deej op de hostcomputer van de [officiële GitHub-repository](https://github.com/omriharel/deej). Het uitvoerbare bestand moet gewoon ergens opgeslagen worden. In dezelfde map maak je een bestand `config.yaml` aan, waarin je bepaalt welke seriële poort gebruikt wordt en welk kanaal welke app bedient. Het bestand `config.yaml` ziet er ongeveer zo uit:

```yaml
slider_mapping:
  0: master
  1: chrome.exe
  2: mic


# set this to true if you want the controls inverted (i.e. top is 0%, bottom is 100%)
invert_sliders: false

# settings for connecting to the RP2040 Pro Micro
com_port: COM4
baud_rate: 9600

# adjust the amount of signal noise reduction depending on your hardware quality
# supported values are "low" (excellent hardware), "default" (regular hardware) or "high" (bad, noisy hardware)
noise_reduction: default
```

Ik heb alles zo ingesteld dat de knoppen van links naar rechts het mastervolume, Chrome (handig voor YouTube, ...) en de microfoon bedienen. Stel `com_port` in op de poort die aan de RP2040 Pro Micro is toegewezen (tip: die vind je via Apparaatbeheer in Windows). Nu kun je Deej starten en van je nieuwe hardwarevolumemixer genieten!

## Besluit

Een aangepaste Deej-volumemixer bouwen met een RP2040 Pro Micro is een leuk en bevredigend project waarmee je het geluid van je systeem op een tastbare manier kunt regelen. Een microcontroller op basis van de RP2040 met CircuitPython is een uitstekend alternatief voor oplossingen op basis van Arduino als je vertrouwd bent met Python en de mogelijkheden van de RP2040 wilt benutten. Met een paar onderdelen en wat basiskennis van solderen bouw je een aangepaste volumemixer die je audio-ervaring verbetert. Veel knutselplezier!

![Een zelfgebouwde volumemixer met een strakke retrobehuizing en een zwart voorpaneel, drie zwarte draaiknoppen met witte markeringen en een kleine metalen ledhouder. Het toestel staat op een houten oppervlak, waardoor het cleane en minimalistische ontwerp goed tot zijn recht komt.](/assets/posts/2025-02-03-deej-open-hardware-volume-controller/deej_01.jpg)

[Deej]: https://github.com/omriharel/deej
[CircuitPython]: https://circuitpython.org/
