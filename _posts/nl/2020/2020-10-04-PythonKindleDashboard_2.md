---
layout: post
title:  "Kindle + Python = e-inkdashboard (deel 2)"
byline: "een oude Kindle Paperwhite 3 hergebruiken"
description: "Het Kindle-e-inkdashboard programmeren in Python met een kleine ETL-pijplijn die citaties van Google Scholar, de Gwent-rangschikking en uitzenddatums van tv-series in een SVG samenbrengt (deel 2)."
date:   2020-10-04 12:00:00
author: Sebastian Proost
post_id: python-kindle-dashboard-2
categories: diy
tags:	python kindle dashboard gwent TV
cover:  "/assets/posts/2020-10-04-PythonKindleDashboard_2/header.jpg"
thumbnail: "/assets/images/thumbnails/kindle_pw3_2.jpg"
github: "https://github.com/4dcu-be/kual-dashboard"
gallery_items:
  - image: "/assets/posts/2020-10-04-PythonKindleDashboard_2/final_dashboard.jpg"
    gallery_image: "/assets/images/gallery/kual_dashboard.jpg"
    description: "Een aangepast dashboard dat op een Kindle Paperwhite 3 draait."
    gallery_size: big
---

In de [vorige post] werd een Kindle Paperwhite 3 gejailbreakt, Python 3.8 geïnstalleerd en alle standaardcode toegevoegd
om ons script te starten en vanuit [KUAL] uit te voeren. Nu kunnen we in de eigenlijke Python-code duiken die het toestel
in een volwaardig dashboard verandert. Daarvoor maken we een kleine ETL-pijplijn (Extract - Transform - Load). Die haalt
gegevens van relevante websites op (extract), voegt ze samen in een woordenboek (transform) en plaatst alle onderdelen
in een SVG-afbeelding (load). Die laatste kunnen we vervolgens naar een PNG omzetten en op het scherm tonen.

Zoals altijd vind je alle code voor dit project op [GitHub](https://github.com/4dcu-be/kual-dashboard).


## De extractiefuncties programmeren

Ik heb genoeg toestellen die me de weersvoorspelling tonen en wilde dus niet nog maar eens een weerdashboard maken. Een
groot deel van de code hier is trouwens gebaseerd op een KUAL-extensie die precies dat doet. Bekijk ze
[hier](https://github.com/x-magic/kindle-weather-stand-alone) als je een weerdashboard wilt maken. Ik kies iets dat
specifieker op mij is afgestemd, maar de code zou vrij eenvoudig aan andere websites en API's aan te passen moeten zijn
om een dashboard voor je eigen interesses te maken.

Na wat nadenken besloot ik gegevens van drie websites te halen: [Google Scholar] voor het aantal citaties van mijn
publicaties en mijn [H-index], mijn huidige rang en score in [Gwent] (een competitief online kaartspel), en TVMaze voor
de uitzenddatums van komende afleveringen van series die ik graag zie. Om de installatie van deze extensie niet
onnodig ingewikkeld te maken, gebruiken we geen extra pakketten en dus alleen de standaardbibliotheek. Helaas betekent
dat dat we websites moeten ophalen met [urllib] en verwerken met reguliere expressies in plaats van [requests] en
[BeautifulSoup]. Toch is het aanvaardbaar om wat complexiteit van de installatie (een Kindle jailbreaken om dit te
laten draaien is al moeilijk genoeg) naar de code te verplaatsen.

### Gegevens van Google Scholar ophalen

Alle functies om gegevens van websites op te halen en te verwerken staan in `extract.py`. Mijn pagina op
[Google Scholar] is het eenvoudigst te verwerken, dus laten we daarmee beginnen.

```python
import ssl
import urllib.request
import re
import json


def get_google_scholar(url):
    ssl_context = ssl._create_unverified_context()
    with urllib.request.urlopen(url, context=ssl_context) as response:
        html = response.read()

    hits = re.findall(r'<td class="gsc_rsb_std">(\d+)</td>', str(html))
    fields = ['citations', 'citations_recent', 'h_index', 'h_index_recent', 'i10_index', 'i10_index_recent']

    return dict(zip(fields, hits))
```

Een HTML-pagina ophalen en verwerken wordt nauwelijks eenvoudiger. We halen de HTML-gegevens op met urllib en kunnen
met één reguliere expressie alle velden uit de tabel met citatiestatistieken halen. Dat zou op elke pagina zes
resultaten moeten opleveren. Met de functies zip en dict kunnen we die snel aan de juiste veldnamen koppelen.

Een vreemd detail is dat ssl_context moet worden gemaakt en aan het verzoek toegevoegd. Op mijn computer werkt de code
prima zonder, maar op de Kindle geeft ze zonder dit stukje een foutmelding.

### De Gwent-profielgegevens ophalen

Voor [Google Scholar] volstonden enkele eenvoudige regels, maar de gegevens van mijn [Gwent]-profiel ophalen vereist
veel meer lelijke code. Hier is het ontbreken van een degelijk pakket om HTML te verwerken, zoals [BeautifulSoup], echt
voelbaar. Hoewel het niet de mooiste code is, doet ze wat nodig is. Je hoeft alleen de plaats in de HTML-code te vinden
waar het stukje informatie staat en een reguliere expressie te schrijven om het eruit te halen.

```python
def get_gwent_data(url):
    ssl_context = ssl._create_unverified_context()
    with urllib.request.urlopen(url, context=ssl_context) as response:
        html = response.read()

    output = {
        'player':   ''.join(re.findall(r'<strong class="l-player-details__name">\\n\s+(.*?)</strong>', str(html))),
        'mmr':      ''.join(re.findall(r'<div class="l-player-details__table-mmr">.*?<strong>(.*?)</strong></div>', str(html))).replace(',',''),
        'position': ''.join(re.findall(r'<div class="l-player-details__table-position">.*?<strong>(.*?)</strong></div>', str(html))).replace(',',''),
        'rank':     ''.join(re.findall(r'<span class="l-player-details__rank"><strong>(.*?)</strong></span>', str(html))),
        'ladder':   ''.join(re.findall(r'<div class="l-player-details__table-ladder" ><span>(.*?)</span></div>', str(html))),
    }

    return output
```

Merk op dat re.findall een lijst met alle resultaten teruggeeft, die hier één element zou moeten bevatten. In plaats
van dat resultaat via zijn index op te halen, gebruiken we de functie join. Dankzij die kleine truc zal de code geen
fout geven als de website van [Gwent] wordt bijgewerkt en de reguliere expressie niet meer overeenkomt. De waarden zijn
dan gewoon lege tekenreeksen. Als ze niet langer op het dashboard verschijnen, is het tijd om de code te herzien, maar
de andere onderdelen blijven werken zoals gepland.

### TVMaze

[TVMaze] heeft een API die JSON-objecten teruggeeft. Die kun je eenvoudig in een woordenboek omzetten, zonder met
reguliere expressies stukken HTML te moeten verwerken. Er is hier wel een extra moeilijkheid: eerst moeten de gegevens
voor elke serie worden opgehaald (de functie krijgt een lijst met ID's). Als die gegevens een link naar de volgende
aflevering bevatten, moeten we ook dat eindpunt ophalen om de naam en uitzenddatum van de aflevering te vinden.

```python
def get_tvmaze_data(ids):
    output = []

    ssl_context = ssl._create_unverified_context()
    for id in ids:
        url = 'http://api.tvmaze.com/shows/%d' % id
        with urllib.request.urlopen(url, context=ssl_context) as response:
            data = json.load(response)
            links = data.get('_links', {})
            if 'nextepisode' in links.keys():
                with urllib.request.urlopen(links['nextepisode']['href'], context=ssl_context) as episode_response:
                    episode_data = json.load(episode_response)
                    output.append(
                        {
                            'name': data.get('name', 'error'),
                            'episode_name': episode_data.get('name', 'error'),
                            'airdate': episode_data.get('airdate', 'error'),
                        }
                    )

    return sorted(output, key=lambda x: x['airdate'])
```

## Cachen en fouten opvangen met een *decorator*

De meeste websites leveren niet elk uur nieuwe gegevens, dus we hoeven die niet zo vaak op te halen. We kunnen de
resultaten gewoon opslaan en bij de volgende vernieuwing controleren hoeveel tijd er sinds de laatste wijziging is
verstreken. Als het bestand recent genoeg is, laden we die gegevens en geven ze door. Is het bestand ouder dan de
cachetijd, dan halen we nieuwe gegevens van het internet.

Omdat de gegevens van het internet komen, kan er van alles misgaan. Misschien start de wifi van de Kindle niet snel
genoeg op, ligt het internet plat of reageert een van de websites niet op tijd ... en die fouten worden nog niet
opgevangen. Ik wil ook niet dat het dashboard een uur of langer lege informatie toont omdat één website tijdelijk
onbereikbaar was. Ook hier kunnen we de cache gebruiken: als we geen gegevens van het internet kunnen ophalen, laden we
de cache ongeacht de ouderdom en tonen die. Licht verouderde informatie is beter dan helemaal geen informatie.

De onderstaande *decorator* combineert beide op een elegante manier. Merk op dat er wat standaardcode in staat om de
laatste wijziging van een bestand te controleren. Dit deel van de code staat in `./dashboard/bin/cache.py`.

{:.large-code}
```python
import json
import os
from datetime import datetime
from functools import wraps

cache_dir = '/mnt/base-us/extensions/dashboard/cache/' if os.name != 'nt' else '../cache'


def hours_since_last_modification(file_path):
    """"
    Returns the number of hours since a file was modified. -1 indicates the file doesn't exists
    """
    if os.path.exists(file_path):
        last_modification = os.stat(file_path).st_mtime
        return (datetime.now().timestamp() - last_modification) / 3600
    else:
        return -1


def cache(cache_file, cache_time):
    """
    Decorator that combine two things:
        * if the decorated function fails (for any reason) it will pull the most recent data
        from cache and return those.
        * if the cache file is more recent than cache_time and return the
        cached data if the file is recent enough

    :param cache_file: File to write cache to
    :param cache_time: How long (in hours) a file should be cached
    """

    def deco_cache(f):
        @wraps(f)
        def f_cache(*args, **kwargs):
            hslm = hours_since_last_modification(cache_file)
            if 0 <= hslm < cache_time:
                with open(cache_file, 'r') as fin:
                    output = json.load(fin)
                return output

            try:
                output = f(*args, **kwargs)
                with open(cache_file, 'w') as fout:
                    json.dump(output, fout)
            except:
                with open(cache_file, 'r') as fin:
                    output = json.load(fin)
            return output

        return f_cache

    return deco_cache
```

Om dit te laten werken, moeten we de extractiefuncties van een *decorator* voorzien zoals hieronder. Die krijgt één
argument: de bestandsnaam waarnaar moet worden geschreven. (Dat zou eventueel automatisch kunnen op basis van de naam
van de gedecoreerde functie.)

```python
# ...
from dashboard.bin.cache import cache_dir, cache
# ...

@cache(join(cache_dir, 'scholar.json'), 8)
def get_google_scholar(url):
    # ...

@cache(join(cache_dir, 'gwent.json'), 1)
def get_gwent_data(url):
    # ...
```

## Tijd om te transformeren en laden

Nu moeten we `run.py` afwerken. Dat wordt elk uur door het shellscript aangeroepen, voert de extractiefuncties uit,
voegt hun uitvoer samen en visualiseert die. Een eenvoudige manier om een dashboard te maken, is een SVG-bestand dat er
precies uitziet zoals je wilt, maar met een token op de plaatsen waar dynamische tekst en waarden moeten verschijnen.
Ik gebruikte deze truc al eerder en ook het weerdashboard dat als inspiratie voor dit project diende, past hem toe.
Codegewijs is dat heel eenvoudig; bekijk hieronder de bijgewerkte `run.py`. Alle opgehaalde gegevens worden in een
woordenboek samengevoegd, `./svg/template.svg` wordt als tekstbestand geladen en alle tokens worden vervangen door de
waarden die we willen tonen. Ten slotte wordt de uitvoer naar de schijf geschreven. Eén regel controleert of het
besturingssysteem Windows is en past het pad overeenkomstig aan. Dat is handig bij het opsporen van fouten, omdat ik de
code zo zonder problemen op mijn hoofdcomputer kan uitvoeren.

{:.large-code}
```python
# bin/python3
# encoding: utf-8

from datetime import datetime
import os
from os.path import join
from extract import get_google_scholar, get_gwent_data, get_tvmaze_data


scholar_url = "http://scholar.google.com/citations?user=4niBmJUAAAAJ&hl=en"
gwent_url = "http://www.playgwent.com/en/profile/sepro"
tvmaze_ids = [6,        # The 100
              79,       # The Goldbergs
              38963,    # The Mandalorian
              17128     # This Is Us
              ]

svg_path = '/mnt/base-us/extensions/dashboard/svg/' if os.name != 'nt' else '../svg'


def create_svg(svg_data, svg_template, svg_output):
    with open(svg_template, 'r') as fin:
        template = fin.read()

        for k, v in svg_data.items():
            template = template.replace(k, v)

        with open(svg_output, 'w') as fout:
            fout.write(template)


def fmt_date(date_input):
    d = datetime.strptime(date_input, '%Y-%m-%d')
    return d.strftime('%d/%m/%Y')


def is_today(date_input, fmt="%Y-%m-%d"):
    return date_input == datetime.now().strftime(fmt)


if __name__ == "__main__":
    # Get Data
    gs_data = get_google_scholar(scholar_url)
    gwent_data = get_gwent_data(gwent_url)
    tvmaze_data = get_tvmaze_data(tvmaze_ids)

    # Combine into dict
    svg_data = {"GS_HINDEX": gs_data.get("h_index"),
                "GS_CITATIONS": gs_data.get("citations"),
                "GWENT_LADDER_RANK": gwent_data.get("ladder") + (" (Rank " + gwent_data.get("rank") + ")" if "Pro" not in gwent_data.get("ladder") else ""),
                "GWENT_MMR": gwent_data.get("mmr"),
                "GWENT_POSITION": gwent_data.get("position"),
                "LASTUPDATE": "Last Update: " + datetime.now().strftime("%d/%m/%Y - %H:%M:%S")}

    for i in range(3):
        if i < len(tvmaze_data):
            svg_data["TV_SHOW_%d" % (i + 1)] = tvmaze_data[i]["name"]
            svg_data["TV_EPISODE_%d" % (i + 1)] = tvmaze_data[i]["episode_name"]
            svg_data["TV_AIRDATE_%d" % (i + 1)] = "TODAY" if is_today(tvmaze_data[i]["airdate"]) \
                else fmt_date(tvmaze_data[i]["airdate"])
        else:
            svg_data["TV_SHOW_%d" % (i+1)] = "No upcoming episodes found"
            svg_data["TV_EPISODE_%d" % (i + 1)] = ""
            svg_data["TV_AIRDATE_%d" % (i + 1)] = ""

    # Load Data into SVG
    create_svg(svg_data, join(svg_path, "template.svg"), join(svg_path, "tmp.svg"))

```

## start.sh herzien

`run.py` maakt nu telkens wanneer het wordt aangeroepen een nieuw SVG-bestand. We moeten `start.sh` echter aanpassen
om die SVG in een PNG-afbeelding om te zetten en ze op het scherm te tonen. Het Weather Dashboard gebruikt een
combinatie van [rsvg-convert] en pngcrush om een PNG-bestand te maken dat compatibel is met het eigen `eips`-commando
van de Kindle. Hier wordt de SVG nog steeds met hetzelfde hulpmiddel omgezet, maar gebruiken we `fbink`. Dat kan elke
PNG-afbeelding correct op het scherm zetten, zonder extra omzetting met pngcrush. Bovendien ruimt dit script de
tijdelijke bestanden op.

Een groot probleem is dat de Kindle de meeste partities met de vlag `noexec` koppelt. Daardoor kun je er geen code en
scripts uitvoeren. Voor scripts is dat niet zo'n probleem, want je kunt ze via de interpreter starten: `/bin/sh <scriptname>` en `python3 <scriptname>` kun je respectievelijk voor shell-
en Python-scripts gebruiken.
Voor rsvg-convert is het probleem groter, want dat is een binair bestand. De oplossing is de uitvoerbare code en
bibliotheken naar een plaats te kopiëren waar code wel kan worden uitgevoerd. Hier gebruiken we `/var/tmp`, voegen we
het pad naar de bibliotheken toe aan de omgevingsvariabele `LD_LIBRARY_PATH` en voeren we het programma vandaar uit.

Om te voorkomen dat het logboek van KUAL na verloop van tijd volloopt (vooral `fbink` is erg uitvoerig), wordt alle
uitvoer van de hulpmiddelen opgevangen en naar `/dev/null` gestuurd (in essentie de vuilnisbak van de opdrachtregel)
door `> /dev/null 2>&1` aan het commando toe te voegen.

{:.large-code}
```bash
#!/bin/sh

cd "/mnt/base-us/extensions/dashboard/"

# Make sure there is enough time to reconnect to the wifi
sleep 30

# Remove files
if [ -f ./svg/tmp.svg ]; then
    rm ./svg/tmp.svg
fi

if [ -f ./svg/tmp.png ]; then
    rm ./svg/tmp.png
fi

# Run script to download data and generate new SVG file
python3 ./bin/run.py

# Copy rsvg-convert to a share where it can be started
# The shared folder that can be accessed via USB is mounted with the noexec flag,
# copying file to /var/tmp gets around this restriction.
if [ ! -f /var/tmp/rsvg-convert ]; then
    cp -rf ./external/* /var/tmp
fi

# Check if svg exists and if it does convert it to PNG and show on screen
if [ -e ./svg/tmp.svg ]; then
  export LD_LIBRARY_PATH=/var/tmp/rsvg-convert-lib:/usr/lib:/lib
  /var/tmp/rsvg-convert-lib/rsvg-convert --background-color=white -o ./svg/tmp.png ./svg/tmp.svg > /dev/null 2>&1
  fbink -c -g file=./svg/tmp.png,w=1072,halign=center,valign=center > /dev/null 2>&1
fi

# Make sure the screen is fully refreshed before going to sleep
sleep 5

echo "" > /sys/class/rtc/rtc1/wakealarm
# Following line contains sleep time in seconds
echo "+3600" > /sys/class/rtc/rtc1/wakealarm
# Following line will put device into deep sleep until the alarm above is triggered
echo mem > /sys/power/state

# Kill self and spawn a new instance
/bin/sh ./bin/start.sh && exit
```


## De diepe slaap van de Kindle uitschakelen

Normaal gaat een Kindle na 10 minuten inactiviteit in diepe slaap zonder dat de ontwaaktimer ingeschakeld is. Dat moet
worden uitgeschakeld. Anders begint de klok telkens te lopen wanneer het dashboard ongeveer 45 seconden ontwaakt om de
gegevens te vernieuwen ... en zodra er in totaal 10 minuten verstreken zijn, gaat de Kindle permanent in diepe slaap
tot je de aan-uitknop indrukt. Het dashboard wordt vanaf dan niet meer vernieuwd. Om de diepe slaap van de Kindle uit
te schakelen, typ je `~ds` in de **zoekbalk** en druk je op Enter.

![Het eindresultaat: het dashboard op een Kindle Paperwhite 3](/assets/posts/2020-10-04-PythonKindleDashboard_2/final_dashboard.jpg)

## Conclusie

Aanvankelijk dacht ik dat iets op een Kindle laten draaien het moeilijkste deel zou zijn, maar ik had het mis ... Een
script voortdurend laten draaien bleek moeilijker. Omdat sommige problemen pas na verloop van tijd opdoken, kostte het
veel tijd om fouten op te sporen en te herstellen. Het duurde een hele tijd voor ik ontdekte dat de Kindle nog steeds
vanzelf in diepe slaap ging. Ook een vergeten `print`-opdracht veroorzaakte een vreemde fout in combinatie met een
langlopend script en KUAL. Dat je geen code rechtstreeks vanuit de extensiemap kunt uitvoeren, was eveneens onverwacht.
Het vergde behoorlijk wat geknutsel om uit te zoeken wat er aan de hand was en vanwaar ik het programma wel kon
uitvoeren.

Ondanks alles is de Kindle nu veranderd in een dashboard voor op mijn bureau! Het toestel van de afvalberg redden:
missie geslaagd! Nu alleen nog een mooie standaard 3D-printen.



[vorige post]: {% post_url nl/2020/2020-09-27-PythonKindleDashboard_1 %}
[KUAL]: https://www.mobileread.com/forums/showthread.php?t=203326
[ETL-pijplijn]: https://en.wikipedia.org/wiki/Extract,_transform,_load
[Google Scholar]: https://scholar.google.com/citations?user=4niBmJUAAAAJ&hl=en
[H-index]: https://en.wikipedia.org/wiki/H-index
[Gwent]: https://www.playgwent.com/en/profile/sepro
[TVMaze]: https://www.tvmaze.com/
[urllib]: https://docs.python.org/3/howto/urllib2.html
[requests]: https://requests.readthedocs.io/en/master/
[BeautifulSoup]: https://www.crummy.com/software/BeautifulSoup/bs4/doc/
[Weather Dashboard]: https://github.com/x-magic/kindle-weather-stand-alone
[rsvg-convert]: https://en.wikipedia.org/wiki/Librsvg
