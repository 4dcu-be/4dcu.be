---
layout: post
title:  "<em>Rise of the Keyraken</em> afdrukken met PrinterStudio/MPC"
byline: "en de andere Print-and-Play-bestanden van FFG"
description: "Hoe je de Print-and-Play-pdf's van Fantasy Flight Games voor Rise of the Keyraken voorbereidt om ze professioneel te laten afdrukken bij PrinterStudio of MakePlayingCards."
date:   2021-04-29 06:00:00
author: Sebastian Proost
post_id: printing-the-keyraken
categories: programming games diy
tags:	python keyforge printing 
cover:  "/assets/posts/2021-04-29-Printing-The-Keyraken/keyraken_header.jpg"
thumbnail: "/assets/images/thumbnails/printing_keyraken.jpg"
---

Wil je professioneel gedrukte kaarten voor [Rise of the Keyraken]? Hier lees je hoe je de Print-and-Play-bestanden van
[Fantasy Flight Games] voorbereidt om ze via een dienst zoals [PrinterStudio] of [Make Playing Cards] (MPC) af te drukken.

FFG bracht eerder al Print-and-Play-decks voor KeyForge uit. Het idee is dat je deze pdf's met eender welke thuisprinter
kunt afdrukken, met wat werk tot afzonderlijke kaarten kunt versnijden, samen met een echte kaart in een hoesje kunt
steken en ermee kunt spelen. Dat is een bijzonder leuk idee waarmee potentiële spelers het spel kunnen uitproberen
voor ze er geld aan uitgeven. Maar omdat 37 kaarten via PrinterStudio of MPC laten drukken ongeveer evenveel kost als
een echt KeyForge-deck, heeft het weinig zin om die decks via zo'n dienst te laten afdrukken.

Voor de KeyForge Adventures, waarvan [Rise of the Keyraken] de eerste is, ligt dat anders. Deze set kaarten lijkt niet
op een gewoon KeyForge-deck en is bedoeld om maximaal drie spelers samen tegen een oeroud monster, de Keyraken, te
laten strijden. Er bestaat dus geen vergelijkbaar product dat je gewoon in de winkel kunt kopen. Als je niet volledig
zelf aan de slag wilt, wordt het interessant om de kaarten via een dienst te laten afdrukken. Er zijn wel enkele
stappen nodig om de afbeeldingen op de juiste resolutie en afmetingen te krijgen en ervoor te zorgen dat de kaarten er
zo goed mogelijk uitzien!

## De gegevens downloaden

FFG brengt zijn Print-and-Play-inhoud uit als pdf's die je
[hier](https://drafts.fantasyflightgames.com/en/products/keyforge/) vindt (scrol naar het onderdeel **Support**). Bij
de **KeyForge Adventures Print-and-Play Materials** moet je enkele bestanden downloaden:

  * [The Keyraken Card](https://images-cdn.fantasyflightgames.com/filer_public/23/6e/236ed2c4-de85-4e3f-82b1-908f2ed0f2f9/kf_adv_keyraken_keyraken.pdf)
  * [The Tide Card](https://images-cdn.fantasyflightgames.com/filer_public/99/46/9946ea16-6525-4abe-9774-fba884420524/kf_adv_keyraken_tide.pdf)
  * [The Card Pool](https://images-cdn.fantasyflightgames.com/filer_public/c5/0c/c50c2857-cdcd-4e82-9e3f-58cc2f39ba4d/kf_adv_keyraken_card_pool_compressed.pdf)

Download ook zeker [de spelregels](https://images-cdn.fantasyflightgames.com/filer_public/09/6b/096bc01e-b9a2-4b73-82d7-a467fe5cc8bd/kf_adv_rulebook_kr_compressed.pdf),
want enkele zaken verschillen van een gewone partij KeyForge.

## Afbeeldingen voorbereiden om af te drukken

Om via een dienst af te drukken, zijn deze pdf's niet rechtstreeks bruikbaar. Ze moeten eerst naar afzonderlijke
afbeeldingen worden omgezet en rond elke kaart moet een afloopgebied komen. Dat laatste is een stukje extra rand dat
rond iedere kaart wordt afgedrukt, zodat er na het snijden geen onbedrukt stukje naast de kaart zichtbaar is wanneer
de snede ook maar een beetje uit het midden zit.

Gelukkig kun je dit met een beetje Python-code doen. Met het pakket [pdf2jpg] haal je de afbeeldingen in enkele regels
code uit de pdf. Merk op dat ik de gedownloade bestanden in een map ```./data/``` heb gezet en een map ```./output/```
heb aangemaakt om de resultaten op te slaan.

```python
from pdf2jpg import pdf2jpg

inputpaths = [
    "./data/kf_adv_keyraken_tide.pdf",
    "./data/kf_adv_keyraken_keyraken.pdf",
    "./data/kf_adv_keyraken_card_pool_compressed.pdf"]

outputpath = "./output/"

for inputpath in inputpaths:
    print(f"Converting {inputpath}....")
    result = pdf2jpg.convert_pdf2jpg(inputpath, outputpath, dpi=1200, pages="ALL")

print("Done !")
```

Dit maakt in de map ```./output/``` voor elk bestand een map aan met daarin voor elke pagina van de pdf een jpg. Hier
worden de pagina's met 1200 dpi geëxporteerd, ruim voldoende om af te drukken (de kaarten worden op 800 dpi gedrukt).
Het afloopgebied moet echter nog worden toegevoegd en de afmetingen moeten exact 3288 bij 4488 pixels zijn.

Afbeeldingen kun je in Python bewerken met de bibliotheek [Pillow], dus zorg ervoor dat die geïnstalleerd is voordat je
de onderstaande code uitvoert.

De onderstaande code bekijkt alle bestanden in een lijst met ```input_directories``` en voegt het afloopgebied toe. Ze
begint met een lege afbeelding met de afmetingen ```target_size``` en tekent de afbeelding precies in het midden.
Vervolgens wordt de linkerrand van de afbeelding gekopieerd, horizontaal gespiegeld en op de juiste plaats gezet. Dat
wordt herhaald voor de rechterkant. Daarna wordt het gebied voor de bovenkant gekopieerd (waarin het al toegevoegde
linker- en rechterafloopgebied zit), verticaal gespiegeld en erboven geplaatst. Ten slotte wordt die stap voor de
onderkant herhaald. In de gif hieronder zie je hoe de afbeelding stap voor stap wordt opgebouwd.

![Zo bouwt de code de afbeelding stap voor stap op](/assets/posts/2021-04-29-Printing-The-Keyraken/bleed_step_by_step.gif){:.small-image}

Qua code is dit niet echt moeilijk, al moet je goed nadenken om de juiste delen van de afbeelding te nemen en op de
juiste plaats te plakken. Er komt wat proberen en bijstellen bij kijken om de juiste coördinaten te vinden en alles te
laten passen, en je zit al snel één pixel verkeerd. Wanneer je code schrijft om afbeeldingen te bewerken, voer ze dan
zeker uit en bekijk het resultaat ingezoomd. Een fout van één pixel zie je misschien niet wanneer de afbeelding
verkleind wordt weergegeven!

{:.large-code}
```python
from PIL import Image, ImageOps
import os

input_directories = ["./data/kf_adv_keyraken_tide.pdf_dir",
                     "./output/kf_adv_keyraken_card_pool_compressed.pdf_dir"]
output_directories = ["./data/kf_adv_keyraken_tide_eng",
                      "./output/kf_adv_keyraken_card_pool_compressed_eng"]

target_size = (3288, 4488)

for input_dir, output_dir in zip(input_directories, output_directories):
    try:
        os.mkdir(output_dir)
    except:
        pass

    for card_image in os.listdir(input_dir):
        card_path = os.path.join(input_dir, card_image)
        card_output_path = os.path.join(output_dir, card_image)

        background = Image.new("RGB", target_size, (255, 255, 255))
        background_w, background_h = background.size

        card = Image.open(card_path)
        card_w, card_h = card.size

        pos_x = (background_w - card_w) // 2
        pos_y = (background_h - card_h) // 2

        offset = (pos_x, pos_y)

        background.paste(card.crop((0, 0, card_w - 1, card_h)), offset)
        background.paste(ImageOps.mirror(card.crop((0, 0, pos_x, card_h))), (0, pos_y))
        background.paste(ImageOps.mirror(card.crop((card_w-pos_x-3, 0, card_w-1, card_h))), (pos_x+card_w, pos_y))

        background.paste(ImageOps.flip(background.crop((0, pos_y, background_w, pos_y*2))),
                         (0, 0))
        background.paste(ImageOps.flip(background.crop((0, card_h, background_w, card_h+pos_y))),
                         (0, card_h+pos_y))

        background.save(card_output_path)
```

## De Keyraken behandelen

Omdat het de bedoeling is om de Keyraken-kaart in een groter formaat af te drukken, moet ze apart worden behandeld.
Ik bewaar al mijn kaarten liever in een eenvoudige standaarddeckbox en wil dus geen enkele extra grote kaart. Daarom
koos ik ervoor de kaart over twee kaarten van normaal formaat te verdelen, vergelijkbaar met de *mega-creatures* uit
Mass Mutation. Daarvoor was een apart script nodig, maar het principe is hetzelfde als voordien.

{:.large-code}
```python
from PIL import Image, ImageOps
import os

output_dir = "./output/kf_adv_keyraken_keyraken"

try:
    os.mkdir(output_dir)
except:
    pass

image = Image.open('./output/kf_adv_keyraken_keyraken.pdf_dir/0_kf_adv_keyraken_keyraken.pdf.jpg', 'r')

# rotate and resize image

input_size = (2953 * 2, 4193)
resized_image = image.rotate(-90, expand=1).resize(input_size)

# add bleed area
target_size = (3288, 4488)

pos_x = (target_size[0] * 2 - input_size[0]) // 4
pos_y = (target_size[1] - input_size[1]) // 2

offset = (pos_x, pos_y)

image_bleed = Image.new("RGB", (target_size[0] * 2 - pos_x * 2, target_size[1]), (255, 255, 255))
image_w, image_h = image_bleed.size

image_bleed.paste(resized_image, offset)

image_bleed.paste(ImageOps.mirror(resized_image.crop((0, 0, pos_x, input_size[1]))), (0, pos_y))
image_bleed.paste(ImageOps.mirror(resized_image.crop((input_size[0] - pos_x - 1, 0, input_size[0], input_size[1]))), (pos_x + input_size[0], pos_y))

image_bleed.paste(ImageOps.flip(image_bleed.crop((0, pos_y, image_w, pos_y * 2))),
                 (0, 0))

image_bleed.paste(ImageOps.flip(image_bleed.crop((0, input_size[1], image_w, input_size[1] + pos_y))),
                  (0, input_size[1] + pos_y))

# Save image (full image and left and right halves)
image_bleed.save(os.path.join(output_dir, "keyraken.jpg"))
image_bleed.crop((0, 0, target_size[0], target_size[1])).save(os.path.join(output_dir, "keyraken_left.jpg"))
image_bleed.crop((image_w - target_size[0], 0, image_w, target_size[1])).save(os.path.join(output_dir, "keyraken_right.jpg"))
```

## Een achterkant voor de kaarten maken

Hiervoor is geen Python nodig. Ik gebruikte een kaartlijst (uit een Print-and-Play-deck) en de Keyraken-kaart om de
onderstaande afbeelding te maken. Gebruik deze gerust als je de stappen volgt (ze heeft de juiste afmetingen en bevat
een afloopgebied om af te drukken).

![Achterkant voor de Keyraken-kaarten](/assets/posts/2021-04-29-Printing-The-Keyraken/keyraken_back.jpg){:.small-image}

## De kaarten afdrukken

Het juiste formaat voor KeyForge-kaarten is *poker size* bij Printer Studio en *poker size (63.5 x 88.9 mm)* bij Make
Playing Cards. Exact dezelfde afbeeldingsafmetingen kunnen echter als 63 x 88 mm (Printer Studio) en poker size (63 x
88 mm) (MPC) worden afgedrukt, wat overeenkomt met het formaat van Magic: the Gathering-kaarten. Omdat je deze kaarten
nooit met officiële kaarten zult mengen, maakt het niet veel uit. Ik kies voor 63 x 88 mm, zodat ik mijn bestelling kan
aanvullen met enkele M:tG-proxy's en -fiches (die moeten wel exact even groot zijn als de echte kaarten, maar die keuze
is volledig aan jou!)

## Conclusie

Het is bijzonder gul van FFG om deze uitbreidingen uit te brengen, die een unieke draai geven aan een toch al geweldig
spel. Met de code hier kun je deze gratis bestanden omzetten in iets dat je voor een redelijke prijs professioneel kunt
laten afdrukken. Zo krijg je een fantastisch uitziend KeyForge Adventure-deck dat je bovenhaalt wanneer je samen met
vrienden wilt spelen in plaats van het tegen hen op te nemen.

Zelf wacht ik tot het volgende avontuur uitkomt om ze allebei tegelijk af te drukken. Als er extra code nodig is om de
nieuwe bestanden te verwerken, zal ik die zeker op deze blog plaatsen. En zodra ik de fysieke kaarten in handen heb,
zullen er hier ook foto's verschijnen!

[Rise of the Keyraken]: https://www.fantasyflightgames.com/en/news/2021/4/23/available-now-april-23/
[Fantasy Flight Games]: https://www.fantasyflightgames.com/
[PrinterStudio]: https://www.printerstudio.de/
[Make Playing Cards]: https://www.makeplayingcards.com/
[pdf2jpg]: https://github.com/pankajr141/pdf2jpg
[Pillow]: https://python-pillow.org/
