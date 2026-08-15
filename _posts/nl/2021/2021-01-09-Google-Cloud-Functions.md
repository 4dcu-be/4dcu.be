---
layout: post
title:  "Een Google Cloud Function instellen"
byline: "een microservice maken"
description: "Een Google Cloud Function instellen als Python-microservice die via HTTP citatiegegevens uit een Google Scholar-profiel haalt."
date:   2021-01-09 13:00:00
author: Sebastian Proost
post_id: google-cloud-functions
categories: programming
tags:	python google cloud web
cover:  "/assets/posts/2021-01-09-Google-Cloud-Functions/header.jpg"
thumbnail: "/assets/images/thumbnails/server_header.jpg"
github: https://github.com/4dcu-be/ScholarJSON
---

Met Googles [Cloud Functions] kun je eenvoudige microservices maken die een taak uitvoeren op de infrastructuur van
Google. Zo kun je een deel van de functionaliteit van een app naar de cloud verplaatsen. Dat kan in verschillende
gevallen nuttig zijn, bijvoorbeeld voor het dashboard uit een [vorige post]. Als je scripts uitvoert op een platform
zoals de Kindle Paperwhite, zijn de tools en pakketten die je makkelijk kunt gebruiken enigszins beperkt. Extra
Python-pakketten installeren is bijvoorbeeld niet zo eenvoudig, net als andere software installeren. Daarom gebruikt
het script gewone reguliere expressies om HTML te verwerken in plaats van een gespecialiseerder pakket zoals
[BeautifulSoup].

Wanneer er complexere verwerking nodig is, zou alles opnieuw implementeren echter behoorlijk omslachtig zijn. Een
*cloud function* kan dan een prima oplossing zijn. Elke functie kan via een HTTP-verzoek worden aangeroepen, net als de
meeste web-API's. Het script draait vervolgens op de hardware van Google en de resultaten worden in een antwoord
teruggestuurd. Als voorbeeld stel ik een Cloud Function in die citatiegegevens uit een [Google Scholar]-profiel haalt.
Scholar heeft geen API, dus de enige manier om citatiestatistieken te verkrijgen is ze uit de HTML-code te halen. De
code vind je op [GitHub].

## Een Google Cloud-account instellen en een functie maken

Om te beginnen heb je een Google Cloud-account nodig. Dat kun je [hier](https://cloud.google.com/) aanmaken. Merk op dat
je geldige kredietkaartgegevens moet opgeven, al is er een gratis niveau in het account inbegrepen. Zolang je het aantal
verzoeken, de rekentijd enzovoort daarvan niet overschrijdt, wordt er niets aangerekend. (Je kunt ook een budget voor
je account instellen. Zo wordt er zelfs na het opgebruiken van het gratis niveau nooit meer dan het opgegeven bedrag
aangerekend.)

Vervolgens moet je een project maken, Cloud Functions inschakelen en een nieuwe Cloud Function aanmaken. Dat is goed
gedocumenteerd op Google Cloud, dus voor de details verwijs ik naar de officiële documentatie.

![Zoek in de Google Cloud-interface naar Cloud Functions in het menu en maak een nieuwe functie om te beginnen](/assets/posts/2021-01-09-Google-Cloud-Functions/cloud_functions.png)

Wanneer je een functie begint te maken, moet je ze een naam geven en een server in je buurt kiezen. Hier maken we een
dienst die via het web werkt. Die moet dus reageren op *HTTP*-verzoeken en de toegang moet op *unrestricted* staan.

Als je op *Save* en *Next* klikt, kun je de code van je functie toevoegen via een online editor, zoals hieronder. Je
mist er de mogelijkheden van een volwaardige IDE, maar voor een kleine functie volstaat dit. Hier moeten we de taal op
*Python 3.7* instellen. Extra pakketten die je wilt gebruiken, kun je aan ```requirements.txt``` toevoegen, terwijl de
hoofdcode in ```main.py``` staat. Je moet ook een *entry point* instellen. Dat is de naam van de functie die wordt
uitgevoerd wanneer het eindpunt wordt aangeroepen; in dit voorbeeld is dat ```hello_world```.

![Je kunt je functie in de online editor implementeren](/assets/posts/2021-01-09-Google-Cloud-Functions/cloud_editor.png)

## Een functie schrijven

Google rekent je (boven het gratis niveau) het uitvoeren van functies aan op basis van het aantal verzoeken en het
RAM- en CPU-gebruik per milliseconde. Functies houd je dus best eenvoudig en gestroomlijnd. Een paar regels verwerken
het verzoek (Cross Origin Resource Sharing, CORS, inschakelen zodat we deze gegevens met JS van andere websites kunnen
ophalen, en de argumenten uitlezen), bouwen de URL op en gebruiken de [requests]-bibliotheek om de HTML op te halen.
Nog een paar regels verwerken die HTML. Alles wordt als JSON teruggestuurd. Hieronder staat de code in ```main.py```.

{:.large-code}
```python
import requests
import re
import json


def parse_scholar(request):
    # Code to handle CORS (from docs)
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }

        return ('', 204, headers)

    # Set CORS headers for the main request
    headers = {
        'Access-Control-Allow-Origin': '*'
    }

    request_json = request.get_json()
    if request_json and 'user' in request_json:
        url = f'https://scholar.google.com/citations?user={request_json["user"]}'
    else:
        user = request.args.get('user')
        url = f'https://scholar.google.com/citations?user={user}'

    r = requests.get(url)

    hits = re.findall(r'<td class="gsc_rsb_std">(\d+)</td>', r.text)
    fields = ['citations', 'citations_recent', 'h_index', 'h_index_recent', 'i10_index', 'i10_index_recent']

    return (json.dumps(dict(zip(fields, hits))), 200, headers)
```
Voor Google Cloud Functions moet dit worden gecombineerd met ```requirements.txt```, dat je hieronder vindt. Vergeet
niet het doel op ```parse_scholar``` in te stellen. Daarmee zou het moeten werken!

```text
# requirements.txt
requests==2.25.1
```

Om je *cloud function* te gebruiken, open je in je browser de *trigger*-URL (die je bij Trigger in de instellingen van
Cloud Function vindt) en voeg je een gebruikersargument met de ID van het Google Scholar-profiel toe. Mijn Scholar-ID
is 4niBmJUAAAAJ, dus ik moet ?user=4niBmJUAAAAJ aan de *trigger*-URL toevoegen om die aan de functie door te geven. Als
alles werkt, krijg je een antwoord met de citatiestatistieken zoals dit ...

```json
{
   "citations":"5602",
   "citations_recent":"3240",
   "h_index":"24",
   "h_index_recent":"23",
   "i10_index":"29",
   "i10_index_recent":"29"
}
```

## Cloud Functions lokaal testen

Tijdens de ontwikkeling van je functie is het een goed idee om ze lokaal te testen voor je ze op de hardware van
Google implementeert. Het Python-pakket [functions-framework] maakt dat eenvoudig. Installeer het pakket met pip en
voer het uit met de onderstaande commando's. Merk op dat het bestand met je code ```main.py``` moet heten en dat je de
functie als doel opgeeft.

```shell
pip install functions-framework
functions-framework --target parse_scholar --debug
```

Nu kun je testen of de code werkt door je browser bijvoorbeeld naar **http://localhost:8080/?user=4niBmJUAAAAJ** te
sturen. Er bestaan ook andere oplossingen om lokaal te testen op basis van Flask, maar daarvoor is wat extra code
nodig. Een eenvoudige oneliner lijkt mij een elegantere oplossing.

## Conclusie

Hiermee kon ik bijzonder makkelijk code naar de cloud verplaatsen, waar die nu met een eenvoudig verzoek kan worden
uitgevoerd en gegevens als JSON terugstuurt die anders moeilijk te verwerken zijn. Dat kan bijvoorbeeld de code voor
het dashboard uit een [vorige post] vereenvoudigen. Bovendien kun je JSON-gegevens makkelijk met JavaScript ophalen. Ik
wil code toevoegen aan mijn cv-website, [sebastian.proost.science], die deze functie gebruikt om bij elk bezoek actuele
citatiestatistieken op te halen. Zo hoef ik die niet meer regelmatig zelf bij te werken (en daarom is CORS ingeschakeld).


Header door [Ian Battaglia](https://unsplash.com/@ianjbattaglia) op [Unsplash](https://unsplash.com/s/photos/server)

[Cloud Functions]: https://cloud.google.com/functions
[BeautifulSoup]: https://www.crummy.com/software/BeautifulSoup/bs4/doc/
[vorige post]: {% post_url nl/2020/2020-10-04-PythonKindleDashboard_2 %}
[GitHub]: https://github.com/4dcu-be/ScholarJSON
[requests]: https://requests.readthedocs.io/en/master/
[sebastian.proost.science]: https://sebastian.proost.science
[functions-framework]: https://github.com/GoogleCloudPlatform/functions-framework-python
[Google Scholar]: https://scholar.google.com/
