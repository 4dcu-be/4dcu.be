---
layout: post
title:  "Abyssal Conspiracy afdrukken"
byline: "het tweede KeyForge Adventure"
description: "Hoe je het KeyForge Adventure Abyssal Conspiracy afdrukt, de extractie van JPEG2000-afbeeldingen uit pdf's in Python herstelt en de Seal Tableau-fiche 3D-print."
date:   2021-06-19 10:00:00
author: Sebastian Proost
post_id: keyforge-adventure-abyssal-conspiracy
categories: diy games programming
tags:	printing 3d-printing python keyforge
cover:  "/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/abyssal_conspiracy_header.jpg"
thumbnail: "/assets/images/thumbnails/abyssal_conspiracy.jpg"
gallery_items:
  - image: "/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/abyssal_conspiracy_header.jpg"
    gallery_image: "/assets/images/gallery/abyssal_conspiracy.jpg"
    description: "Abyssal Conspiracy-kaarten in 2D afgedrukt, met de tableaufiche in 3D."
---

Beide KeyForge Adventures zijn al een tijdje uit. Nu ik de Keyraken met al mijn decks heb verslagen, is het tijd om
Abyssal Conspiracy te bekijken. De kaarten voorbereiden om af te drukken gebeurt in dezelfde twee stappen als in [dit
artikel]({% post_url nl/2021/2021-04-29-Printing-The-Keyraken %}) beschreven. Het afloopgebied toevoegen werkt precies
hetzelfde, maar de hoofdkaarten uitpakken lukte niet. De reden was dat de bibliotheek [pdf2jpg] de nieuwere
beeldcompressie JPEG2000, die in die pdf gebruikt wordt, niet ondersteunde. Dat probleem moeten we dus eerst oplossen!

![KeyForge Adventure: Abyssal Conspiracy afgedrukt met een 3D-geprinte tableaufiche](/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/abyssal_conspiracy_header.jpg)

De bestanden die je nodig hebt om dit avontuur af te drukken vind je [hier](https://www.fantasyflightgames.com/en/products/keyforge/)
in het onderdeel *Support* onder *KeyForge Adventures Print-and-Play Materials*. Alle kaartbestanden moeten verwerkt
worden; van het Seal Tableau maken we een 3D-printbare fiche.

  * [De kaartenpool](https://images-cdn.fantasyflightgames.com/filer_public/f7/24/f72436db-759f-4094-a1ac-5ef905013b8a/kf_adv_conspiracy_card_pool-compressed.pdf)
  * [Locatiekaarten](https://images-cdn.fantasyflightgames.com/filer_public/ae/52/ae52772b-730e-4ba0-a3be-2191f085514f/kf_adv_conspiracy_locations_compressed.pdf)
  * [Zegelkaarten](https://images-cdn.fantasyflightgames.com/filer_public/61/90/6190d735-eac0-46a8-9b75-551665808693/kf_adv_conspiracy_seals.pdf)
  * [De Tide-kaart](https://images-cdn.fantasyflightgames.com/filer_public/7a/79/7a791a64-7c6a-4a0b-87fb-51cb85d0fbe7/kf_adv_conspiracy_tide.pdf)

  * [Kaartachterkanten](https://images-cdn.fantasyflightgames.com/filer_public/13/f6/13f62bc0-7321-4a0a-8ae8-6ddfd16e48fb/kf_adv_conspiracy_card_backs_compressed.pdf)
    of gebruik die van Reddit-gebruiker [Dead-Sync](https://www.reddit.com/user/Dead-Sync) [hier](https://www.reddit.com/r/KeyforgeGame/comments/ncy2r6/abyssal_conspiracy_individual_card_pngs_custom/),
    die al een afloopgebied bevatten en klaar zijn om af te drukken

  * [Het Seal Tableau](https://images-cdn.fantasyflightgames.com/filer_public/7d/62/7d625289-55bb-4db7-82a2-aeb92d8377d2/kf_adv_card_connector.pdf)

  * Fiches om de posities van spelers bij te houden. Je kunt eender wat gebruiken, maar [hier](https://www.thingiverse.com/thing:4885866) staat een prima optie op Thingiverse

  * Een exemplaar van [de spelregels](https://images-cdn.fantasyflightgames.com/filer_public/aa/80/aa806171-5f17-4f78-b4a1-fee470deaf11/kf_adv_rulebook_id_compressed.pdf)

Alleen het bestand met de kaartenpool gebruikt
dit nieuwe formaat. De andere bestanden kun je precies verwerken zoals in mijn [vorige artikel]({% post_url nl/2021/2021-04-29-Printing-The-Keyraken %}).

## De kaartafbeeldingen uitpakken

Omdat [pdf2jpg] niet werkte, moeten we een ander pakket gebruiken. [pdf2image] kan de klus klaren! Daarvoor moet wel
[poppler] ergens op je systeem geïnstalleerd zijn. Installeer pdf2image dus met pip en plaats ergens op je systeem een
kopie van poppler.

De paden naar het invoerbestand en de uitvoer zijn vast in de code opgenomen. Omdat dit een eenmalig script is, vind ik
dat hier aanvaardbaar. Het is ook de eenvoudigste manier om werkende code via een blog te delen, maar doe dit niet in
serieuze projecten. Het ```output_path``` wordt indien nodig aangemaakt. Met deze bibliotheek moeten we iedere pagina
afzonderlijk laden en exporteren. De lus over ```range(1, 44)``` zorgt daarvoor, maar ook dit bereik staat vast in de
code en werkt dus alleen voor deze specifieke pdf.

```python
from pdf2image import convert_from_path
import pathlib

input_path = "./data/kf_adv_conspiracy_card_pool-compressed.pdf"
output_path = "./output/kf_adv_conspiracy_card_pool-compressed.blog/"

p = pathlib.Path(output_path)
p.mkdir(parents=True, exist_ok=True)

print(f"Converting {input_path}....")
for pn in range(1, 44):
    pages = convert_from_path(input_path, single_file=True, first_page=pn, poppler_path="D:\\poppler-21.03.0\\Library\\bin", dpi=1200)
    print(f"converting page {pn}")
    pages[0].save(str(p.joinpath(f"card_{pn:02}.jpg")), quality=95)

print("Done !")
```

pdf2image is wat karig gedocumenteerd en ik vond geen goede manier om het volledige bestand in één keer te verwerken.
Hier laden we dus één pagina, waarbij ```first_page=pn``` bepaalt welke pagina, en schrijven we die als een .jpg-bestand
naar de schijf.

Zodra alle 43 kaarten geëxporteerd zijn, kun je het afloopgebied toevoegen met de scripts uit het
[vorige artikel]({% post_url nl/2021/2021-04-29-Printing-The-Keyraken %}) en ben je klaar!

![Abyssal Conspiracy afgedrukt en klaargelegd om te spelen](/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/game_setup.jpg)

## Een 3D-printbare Seal Tableau-fiche maken

Nu alle code klaar is om de afbeeldingen via een dienst te laten afdrukken, rest alleen nog het Seal Tableau. Een
degelijke optie is om de pdf op [stickerpapier af te drukken en enkele lagen transparante lak aan te brengen]({% post_url nl/2021/2021-06-14-Stickers %}),
de sticker op een stuk karton te kleven en de vorm uit te snijden.

Ik wilde er echter een 3D-geprinte versie van maken. Het gebruikte proces is in wezen hetzelfde als om met een
3D-printer een [lithophane] te maken, maar dan omgekeerd. Normaal zijn de donkere delen dikker, zodat de afbeelding
zichtbaar wordt wanneer er licht langs achteren doorheen schijnt. Hier moeten de lichtste delen net het dikst worden
afgedrukt.

![Met deze online tool maak je heel eenvoudig een lithophane](/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/3dprocks_lithophane.png)

Je kunt de afbeelding online naar STL omzetten, bijvoorbeeld via [https://3dp.rocks/lithophane/](https://3dp.rocks/lithophane/).
Afhankelijk van de gebruikte dienst moet je de afbeelding misschien inverteren (bij 3dp.rocks is dat niet nodig).
Dit levert wel een rechthoekig object op, dat je tot een pentagram moet versnijden. Dat kan eenvoudig met [MeshMixer]
of, met een steilere leercurve, [Blender].

![Lithophane-STL tot een pentagram versneden; de uiteindelijke tableaufiche is klaar om af te drukken](/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/meshmixer_token.png)

Na het afdrukken heb ik het model geschuurd, van grondverf voorzien en met metallic verf van Vallejo beschilderd om het
op een oude koperen munt te laten lijken. Het resultaat is best mooi. Merk op dat ik de fiche verkleind heb tot een
formaat dat in een deckbox past. Je kunt de afmetingen van het model op [https://3dp.rocks/lithophane/](https://3dp.rocks/lithophane/)
aan jouw behoeften aanpassen.

![Afgewerkte 3D-geprinte Seal Tableau-fiche](/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/tableau_token.jpg)

Nu we toch aan het 3D-printen zijn, kunnen we meteen een set Delver-fiches afdrukken. Die zijn [hier](https://www.thingiverse.com/thing:4885866)
beschikbaar om de posities van spelers bij te houden. Ik drukte er 3 af en beschilderde ze in dezelfde stijl als mijn
Seal Tableau-fiche.

![3D-geprinte Delver-fiches om de posities van spelers bij te houden](/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/delver_tokens.jpg)

## Conclusie

Ik ben helemaal klaar om het volgende KeyForge Adventure uit te proberen! Ik kijk ernaar uit om dit avontuur te spelen!

[pdf2jpg]: https://github.com/pankajr141/pdf2jpg
[pdf2image]: https://pypi.org/project/pdf2image/
[poppler]: https://github.com/oschwartz10612/poppler-windows/releases/
[lithophane]: https://en.wikipedia.org/wiki/Lithophane
[MeshMixer]: https://www.meshmixer.com/
[Blender]: https://www.blender.org/
