---
layout: post
title:  "Steganografie met PIL en NumPy"
byline: "berichten in het volle zicht verbergen"
description: "Geheime berichten in afbeeldingen verbergen met Python, PIL en NumPy door tekst in de minst significante bits van de RGB-waarden van elke pixel te coderen."
date:   2020-11-02 12:00:00
author: Sebastian Proost
post_id: steganography
categories: programming
tags:	python numpy steganography 
cover:  "/assets/posts/2020-11-02-Steganography/post_header.jpg"
thumbnail: "/assets/images/thumbnails/steganography_header.jpg"
github: "https://github.com/4dcu-be/Steganography"
---

Steganografie is het verbergen van informatie in andere afbeeldingen, audio, tekst enzovoort. Je kunt verborgen
berichten aan foto's toevoegen, een bestand in een ander bestand verbergen ... Hier proberen we informatie in een
afbeelding te verstoppen.

Afbeeldingen zijn in essentie tweedimensionale lijsten van pixels, die elk bestaan uit drie gehele getallen van 0 tot
255 voor de waarden rood, groen en blauw. Het verschil tussen een pixel met waarde rgb(230, 129, 200) en rgb(229, 129,
201) is vrijwel onzichtbaar. Daar kunnen we gebruik van maken om informatie in de minst significante bits van elke
pixel te verbergen.

Om een bericht in een afbeelding te verbergen, hebben we een functie nodig die **een tekenreeks naar een binaire
voorstelling omzet** en eentje die **die gegevens in de minst significante bits van een afbeelding inbedt**. Om het
bericht zichtbaar te maken, moeten we dat proces kunnen omkeren. Eerst zal een functie dus **de minst significante bits
uitlezen** en ten slotte moeten we **ze opnieuw in een tekenreeks omzetten**.

## Tekst naar binair omzetten en terug

Om tekst naar binair om te zetten en terug vond ik een functie op [StackOverflow](https://stackoverflow.com/questions/7396849/convert-binary-to-ascii-and-vice-versa),
al is die wat moeilijk te begrijpen. Laten we de functie encode_text daarom stap voor stap ontleden.

  * ```str.encode``` wordt gebruikt om de tekenreeks in bytes om te zetten
  * ```int.from_bytes``` maakt vervolgens een geheel getal van die bytes. Dat werkt omdat gehele getallen in Python willekeurig groot kunnen zijn.
  * dit getal wordt met ```bin()``` omgezet naar binair (bijvoorbeeld 0b00101011010101010101010001... )
  * met een *array slice* worden de eerste twee tekens (0b) verwijderd
  * ```zfill``` zorgt ervoor dat de lengte van de uitvoer een veelvoud van 8 is
  
Om de binaire voorstelling weer om te zetten, kunnen we de opvulling en het afsnijden weglaten en moeten we de andere
stappen omkeren.

  * ```int()``` zet een binaire voorstelling terug om naar een geheel getal; let op de parameter 2
  * met ```int.to_bytes``` wordt dat getal opnieuw omgezet naar een lijst van bytes
  * ```str.decode``` zet bytes weer om in tekst
  
Om te controleren of dit werkt, zetten we een stukje *Lorem ipsum* om naar binair en vervolgens weer terug.

```python
# Convert the hidden message to bytes

def encode_text(text, encoding='utf-8', errors='surrogatepass'):
    bits = bin(int.from_bytes(text.encode(encoding, errors), 'big'))[2:]
    return bits.zfill(8 * ((len(bits) + 7) // 8))

def decode_text(bits, encoding='utf-8', errors='surrogatepass'):
    n = int(bits, 2)
    return n.to_bytes((n.bit_length() + 7) // 8, 'big').decode(encoding, errors) or '\0'
        

hidden_message = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

encoded_text = encode_text(hidden_message)
decoded_text = decode_text(encoded_text)

print("encoded:", encoded_text)
print("decoded:", decoded_text)
```

```text
encoded: 010011000110111101110010011001010110110100100000011010010111000001110011011101010110110100100000011001000110111101101100011011110111001000100000011100110110100101110100001000000110000101101101011001010111010000101100001000000110001101101111011011100111001101100101011000110111010001100101011101000111010101110010001000000110000101100100011010010111000001101001011100110110001101101001011011100110011100100000011001010110110001101001011101000010110000100000011100110110010101100100001000000110010001101111001000000110010101101001011101010111001101101101011011110110010000100000011101000110010101101101011100000110111101110010001000000110100101101110011000110110100101100100011010010110010001110101011011100111010000100000011101010111010000100000011011000110000101100010011011110111001001100101001000000110010101110100001000000110010001101111011011000110111101110010011001010010000001101101011000010110011101101110011000010010000001100001011011000110100101110001011101010110000100101110
decoded: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
```

## Informatie in een afbeelding verbergen

Nu we functies hebben om eender welke tekst naar binair om te zetten en terug, kunnen we de binaire informatie in een
afbeelding verwerken. Hier wordt de bibliotheek [PIL](https://pillow.readthedocs.io/en/stable/) gebruikt om de afbeelding
te laden. Daarna wordt ze omgezet in een eendimensionale lijst van alle rood-, groen- en blauwwaarden van de pixels.

Aan het verborgen bericht wordt het achtervoegsel <STOP> toegevoegd, zodat bij het decoderen van de afbeelding
duidelijk is waar het bericht eindigt. Vervolgens wordt het geheel naar binair omgezet. Daarna loopt een lus over alle
bits en codeert ze in de minst significante bit van de afgevlakte afbeelding. Daarvoor wordt een binair masker
(0b11111110) op de waarde toegepast om de minst significante bit op nul te zetten. Vervolgens stelt een binaire
*or*-bewerking die bit in op de gewenste waarde.
    
De voorwaarde ```ix < len(encoded_text) else value``` zorgt ervoor dat pixels op plaatsen waar geen verborgen
informatie wordt opgeslagen, identiek blijven.
    
Ten slotte wordt de eendimensionale array weer omgezet in een 2D-afbeelding met drie kleurkanalen en als PIL-afbeelding
geëxporteerd. Om dit te testen, laden we een afbeelding ```pear.png```, voegen we een Hello World-bericht toe en
schrijven we de afbeelding opnieuw naar de schijf. Zorg dat je bij het opslaan een bestandsformaat zonder
kwaliteitsverlies gebruikt. JPEG-bestanden worden zo gecomprimeerd dat kleine details verloren gaan. Daardoor kan de
verborgen inhoud verdwijnen, dus gebruiken we hier PNG.

```python
from PIL import Image
import numpy as np

def encode_in_image(filename, text_message):
    # Open the image, store the shape and convert to one-dimensional list
    input_im = Image.open(filename, 'r').convert("RGB")
    image_shape = np.asarray(input_im).shape
    flat_array = np.asarray(input_im).flatten()

    # Encode the message and add prefix
    encoded_text = encode_text(text_message + "<STOP>")
    
    # Enter message in the least significant bit where necessary
    encoded_array = [
        (0b11111110 & value) | int(encode_bit) if ix < len(encoded_text) else value
        for ix, (encode_bit, value) in enumerate(zip(encoded_text.ljust(len(flat_array), '0'), flat_array))]

    # Turn encoded array into image and return
    encoded_im = np.array(encoded_array).reshape(image_shape)    
    return Image.fromarray(np.uint8(encoded_im)).convert('RGB')



encoded_im = encode_in_image('pears.png', "Hello World")
encoded_im.save('pears_with_hidden_message.png')
encoded_im
```

![Afbeelding van enkele peren ... maar met een verborgen bericht erin ...](/assets/posts/2020-11-02-Steganography/pears_with_hidden_message.png)

## De verborgen inhoud uitlezen

Mooi, onze afbeelding ziet er identiek uit aan de invoer. De kleine verschillen zijn met het blote oog niet waar te
nemen. We moeten nog één functie toevoegen om het verborgen bericht uit een afbeelding te halen. Dat is vrij eenvoudig:
nadat de afbeelding is geladen, wordt ze opnieuw afgevlakt tot een eendimensionale array. Voor elke waarde wordt de
minst significante bit met een bitmasker uitgelezen. Die waarden worden tot één tekenreeks samengevoegd, die met de
functie ```decode_text``` wordt gedecodeerd. Ten slotte moeten we de gedecodeerde tekst bij het achtervoegsel <STOP>
afbreken. Na dat achtervoegsel is geen informatie gecodeerd en krijgen we een hoop onzin terug. Een eenvoudige
```split()``` klaart die klus.
    
Ten slotte voeren we de code uit op de afbeelding waarin een bericht werd ingebed ... en voilà, ons oorspronkelijke
bericht verschijnt opnieuw.
```python
def extract_from_image(filename):
    # Open image
    encoded_im = np.asarray(Image.open(filename, 'r').convert("RGB"))

    # Extract least significant bits from flat (one-dimensional) image
    extracted_bits = [str(0b00000001 & value) for value in encoded_im.flatten()]

    # Join bits together, decode and split at <STOP>
    extracted_bits = ''.join(extracted_bits)
    return decode_text(extracted_bits, errors='replace').split('<STOP>')[0]
    
extract_from_image('pears_with_hidden_message.png')
```

```text
'Hello World'
```

## Conclusie

Informatie in een alledaags bestand kunnen verbergen, is een leuke gimmick. Er bestaan heel wat interessante
toepassingen; op [WikiPedia] vind je daar meer informatie over. Omdat er een binaire signatuur wordt ingevoegd, kun je
in essentie allerlei soorten gegevens verbergen. Voor tekst heb je met alleen de minst significante bit net geen drie
pixels nodig om één teken op te slaan. Je kunt dus behoorlijk veel tekst in een afbeelding kwijt. Die hoeveelheid kun
je verdubbelen door de tekst te comprimeren en de informatie in de twee minst significante bits van elk pixelkanaal op
te slaan. Computerphile heeft een voorbeeld waarin het volledige werk van Shakespeare in één afbeelding van een boom
zit. Bekijk die video [hier](https://www.youtube.com/watch?v=TWEXCYQKyDc).

[WikiPedia]: https://en.wikipedia.org/wiki/Steganography
