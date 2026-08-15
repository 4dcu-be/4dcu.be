---
layout: post
title:  "Kindle + Python = e-inkdashboard (deel 1)"
byline: "een oude Kindle Paperwhite 3 hergebruiken"
description: "Een oude Kindle Paperwhite 3 hergebruiken als energiezuinig e-inkdashboard door hem via de seriële poort te jailbreaken en Python te installeren (deel 1)."
date:   2020-09-27 12:00:00
author: Sebastian Proost
post_id: python-kindle-dashboard-1
categories: diy
tags:	python kindle dashboard
cover:  "/assets/posts/2020-09-27-PythonKindleDashboard_1/kindle_pw3.jpg"
thumbnail: "/assets/images/thumbnails/kindle_pw3.jpg"
github: "https://github.com/4dcu-be/kual-dashboard"
---

Kindles hebben fantastische e-inkschermen. Als we erin slagen Python op zo'n toestel te installeren, kunnen we een oude
Kindle in een energiezuinig dashboard veranderen! Een oude Kindle is ook aanzienlijk goedkoper dan een nieuwe
e-inkmodule die je op een Raspberry Pi kunt aansluiten. Het is dus heel logisch om mijn oude Kindle, die problemen
heeft, te hergebruiken. Zelfs nadat ik de batterij verving, gaat hij bij matig gebruik maar 2 à 3 dagen mee. Dat is lang
niet genoeg voor reizen waarop hij niet dagelijks kan worden opgeladen. Vroeg of laat koop ik wel een nieuwe
e-bookreader, maar ik gooi een verder prima toestel echt niet graag weg. Zeker niet eentje met een geweldig scherm dat
nog perfect werkt. Gelukkig vond ik een manier om hem te hergebruiken en dit toestel nieuw leven in te blazen.

![Alle onderdelen voor de jailbreak via de seriële poort](/assets/posts/2020-09-27-PythonKindleDashboard_1/all_parts.jpg)

## Python op de Kindle installeren

Omdat je geen extra software op een standaard-Kindle kunt installeren, moet je hem eerst jailbreaken. Daardoor vervalt
je garantie, dus als je dit wilt proberen, doe je dat op eigen risico. Er zijn twee belangrijke manieren:

  * Upgrade naar specifieke firmware die gekraakt kan worden en gebruik een softwarematige jailbreak (je huidige versie
  moet ouder zijn dan de firmware die kan worden gekraakt). Details vind je [hier](https://www.mobileread.com/forums/showthread.php?t=320564)
  en [hier](https://www.mobileread.com/forums/showthread.php?t=313086).
  * Open de Kindle, soldeer draden aan de seriële poort, maak er via een computer verbinding mee en meld je op het
  toestel aan om een jailbreak toe te passen. Gebruik [deze handleiding](https://www.mobileread.com/forums/showthread.php?t=267541)
  als je deze methode wilt proberen.

Voor de jailbreak via de seriële poort heb je naast een soldeerbout en enkele draden ook een USB-naar-serieeladapter
nodig. Op Amazon, eBay enzovoort vind je er genoeg, maar zorg dat je model **1,8 V** ondersteunt, want dat heeft de
Kindle nodig.

![USB-naar-serieeladapter die 1,8, 3,3 en 5 V ondersteunt](/assets/posts/2020-09-27-PythonKindleDashboard_1/usb_to_serial.jpg)

Omdat mijn firmwareversie te nieuw was voor de softwarematige jailbreak, begon ik met de jailbreak via de seriële
poort/hardware. Nadat ik de Kindle met mijn computer had verbonden, aanvaardde hij het rootwachtwoord niet (mogelijk
omdat ik eerder de softwarematige jailbreak had uitgevoerd en die verloor toen ik naar de nieuwste versie bijwerkte in
een poging het batterijprobleem op te lossen). Daardoor kon ik mijn toestel ook niet op die manier jailbreaken. Als je
echter via de seriële poort met de Kindle verbonden bent en ook een USB-kabel aansluit, kun je hem in
**herstelmodus** opstarten (druk op het juiste moment tijdens het opstarten op Enter) en van daaruit de
**partitietabel exporteren**. De Kindle verschijnt dan als USB-opslagapparaat op je computer. Je kunt eender welk
firmwarebestand naar de hoofdmap van de Kindle kopiëren en de installatie vanaf de opdrachtregel forceren, waardoor je
de Kindle feitelijk naar een oudere versie terugbrengt. (Je kunt de oude firmware niet vooraf kopiëren, want bij het
herstarten van het toestel wordt die verwijderd.) Daarna kun je de softwarematige jailbreak gebruiken.

![Vastgesoldeerde draden](/assets/posts/2020-09-27-PythonKindleDashboard_1/soldering.jpg)

Zodra je de Kindle met succes hebt gejailbreakt, installeer je [KUAL](https://www.mobileread.com/forums/showthread.php?t=203326).
Dat is een startprogramma waarmee je andere pakketten vanuit een menu kunt openen. Installeer vervolgens de MobileRead
Package Installer, ook wel [MRPI](https://www.mobileread.com/forums/showthread.php?t=251143), die de volgende stap
vereenvoudigt. Ten slotte hebben we Python 3.8 nodig, dat je [hier](https://www.mobileread.com/forums/showthread.php?t=225030)
vindt. Plaats de binaire bestanden in de juiste map en start MRPI vanuit KUAL om ze te installeren.

![Gelukt, Python wordt geïnstalleerd](/assets/posts/2020-09-27-PythonKindleDashboard_1/python_installing.jpg)

## Een KUAL-extensie maken

Python is geïnstalleerd en KUAL geeft ons een manier om ons script te starten. Laten we een KUAL-extensie bouwen. Hier
bespreken we alleen de standaardcode; het Python-script voor het dashboard komt in de volgende post aan bod. Hieronder
zie je de bestandsstructuur van onze extensie. De map `dashboard` moet naar de map `extensions` op de Kindle worden
gekopieerd.


```text
│   .gitignore
│   README.md
│
└───dashboard
    │   config.xml
    │   menu.json
    │
    ├───bin
    │       run.py
    │       start.sh
    │       start_once.sh
    │
    └───cache
```

Twee bestanden zijn essentieel voor de KUAL-extensie: `config.xml` en `menu.json`. Je ziet ze hieronder. Ze spreken
grotendeels voor zich, maar zorg dat de ID in het configuratiebestand overeenkomt met de naam van de map van je
extensie (in dit geval dashboard). In `menu.json` kun je bepalen waar in het KUAL-menu knoppen komen om je script te
starten (hier staan ze in het hoofdmenu). Omdat het dashboardscript (`start.sh`) in een oneindige lus terechtkomt en de
Kindle opnieuw moet worden opgestart om het te stoppen, is er voor foutopsporing en tests ook een versie toegevoegd die
maar één lus uitvoert om te testen of alles in orde is (`start_once.sh`).

`run.py` is een tijdelijk bestand dat in de volgende post wordt besproken. Dat Python-script haalt online gegevens op
en zet ze om in iets wat we op de Kindle kunnen tonen.

**config.xml**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<extension>
    <information>
        <name>Dashboard 4DCu.be</name>
        <version>0.1</version>
        <author>4DCu.be - Sebastian Proost</author>
        <id>dashboard</id>
    </information>
    <menus>
        <menu type="json" dynamic="true">menu.json</menu>
    </menus>
</extension>
```

**menu.json**
```json
{
    "items": [
    {
        "name": "Dashboard 4DCu.be",
        "priority": -999,
        "exitmenu": false,
        "refresh": false,
        "status": false,
        "action": "./bin/start.sh"
    }, {
        "name": "Dashboard 4DCu.be (Debug)",
        "priority": -998,
        "exitmenu": false,
		"refresh": false,
		"status": false,
        "action": "./bin/start_once.sh"
    }
    ]
}
```

Voor het eigenlijke dashboard staan alle bestanden in de map `bin`. Daar staat een shellscript, `start.sh`, dat het
Python-script uitvoert, het systeem in diepe slaap zet en dat herhaalt zodra het weer ontwaakt. Dit script blijft voor
altijd draaien en je moet de Kindle opnieuw opstarten om het te beëindigen. Voor een dashboard is dat prima, maar bij
foutopsporing en tests is het wat vervelend. Daarom is ook `start_once.sh` toegevoegd, dat het script één keer uitvoert
en vervolgens stopt.

**bin/start.sh**
```bash
#!/bin/sh

cd "$(dirname "$0")"

/usr/sbin/eips -c
/usr/sbin/eips 15  4 'Starting 4DCu.be Dashboard'

while true
do
    # Make sure there is enough time to reconnect to the wifi
    sleep 30
    # Refresh Dashboard
    python3 /mnt/base-us/extensions/dashboard/bin/run.py
    sleep 5

    echo "" > /sys/class/rtc/rtc1/wakealarm
    # Following line contains the sleep time in seconds
    echo "+3600" > /sys/class/rtc/rtc1/wakealarm
    # Following line will put device into deep sleep until the alarm above is triggered
    echo mem > /sys/power/state
done
```

Met deze scripts is alles klaar om aan de Python-code te beginnen die gegevens ophaalt en ze op het scherm toont. Die
komt echter in de volgende post aan bod. Voorlopig kun je naar de onderstaande foto kijken, waarop KUAL onze eigen
gloednieuwe knoppen toont. Binnenkort zullen die Python-code uitvoeren om voor ons aan de slag te gaan.

![KUAL is helemaal klaar om onze code te starten](/assets/posts/2020-09-27-PythonKindleDashboard_1/kual_menu.jpg)

## Conclusie

Ondanks enkele problemen was het mogelijk om de Kindle Paperwhite 3 te jailbreaken, Python te installeren en er eigen
code op uit te voeren. Alles is dus klaar om enkele scripts in elkaar te knutselen die de Kindle echt in een dashboard
veranderen. Binnenkort lees je daarover in de [volgende post]({% post_url nl/2020/2020-10-04-PythonKindleDashboard_2 %}).

