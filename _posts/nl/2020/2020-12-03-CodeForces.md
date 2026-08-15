---
layout: post
title:  "CodeForces: wedstrijdprogrammeren uitproberen"
byline: ""
description: "Als autodidact wedstrijdprogrammeren uitproberen op CodeForces: eenvoudige algoritmeproblemen in Python oplossen om hiaten in mijn informaticakennis aan te vullen."
date:   2020-12-03 13:00:00
author: Sebastian Proost
post_id: codeforces
categories: programming
tags:	python 
cover:  "/assets/images/headers/python_code.jpg"
thumbnail: "/assets/images/thumbnails/python_code.jpg"
---

Hoe goed ken jij je algoritmen? Als je een autodidactische programmeur bent (zoals ik), kan dit een hiaat in je kennis zijn!
In deze post probeer ik wat extra oefening op te doen door algoritmen te schrijven die enkele programmeerproblemen oplossen. Op
[CodeForces], een website met programmeerwedstrijden, zijn alle opdrachten van vorige wedstrijden
beschikbaar, samen met de infrastructuur om je oplossing te controleren. Laten we deze bron dus gebruiken om onze programmeervaardigheden
wat bij te schaven.

## Aan de slag

Op [CodeForces] hebben alle problemen een moeilijkheidsgraad van 800 tot 3500. Hoe lager de score, hoe eenvoudiger het probleem
is. Om te beginnen raad ik aan een gemakkelijk probleem te kiezen, zodat je vertrouwd raakt met het platform, de invoer,
het indienen van een oplossing, ...

Ik koos probleem 119A, "[Epic Game]", met de laagste moeilijkheidsgraad van 800, om voorzichtig te beginnen. Het doel is 
een programma te schrijven dat dit probleem oplost:

---
Simon en Antisimon spelen een spel. Aan het begin krijgt elke speler één vast positief geheel getal dat tijdens het spel niet verandert. 
Simon krijgt getal *a* en Antisimon getal *b*. Ze hebben ook een hoop van *n* stenen. De 
spelers zetten om de beurt en Simon begint. Bij een zet moet een speler uit de hoop evenveel 
stenen nemen als de grootste gemene deler van zijn vaste getal en het aantal stenen dat nog in de 
hoop ligt. Een speler verliest wanneer hij het vereiste aantal stenen niet kan nemen (de hoop bevat dus __strikt__ minder stenen 
dan hij moet nemen).

Je opdracht is om voor de gegeven *a*, *b* en *n* te bepalen wie het spel wint.

**Invoer**
De enige regel bevat de door spaties gescheiden gehele getallen *a*, *b* en *n* (1≤*a*,*b*,*n*≤100): respectievelijk de vaste getallen die Simon en 
Antisimon kregen en het oorspronkelijke aantal stenen in de hoop.

**Uitvoer**
Als Simon wint, geef je "0" weer (zonder aanhalingstekens); anders geef je "1" weer (zonder aanhalingstekens).

---

De eerste oplossing die ik bedacht, is heel eenvoudig. De binnenste lus wisselt af tussen beide spelers en past
*n* aan zoals hierboven beschreven. Dit wordt herhaald (buitenste lus) totdat een speler wint. Dan wordt de winnaar weergegeven
en stopt de lus.

Het inlezen van standaardinvoer bevat wel een aardigheidje: ```input().split()``` haalt een regel op uit STDIN en
splitst die op witruimte. De functie ```map``` past ```int``` toe op alle delen en zet de invoer van tekst om naar
gehele getallen. Met ```*``` kun je een lijst als argumenten aan een functie doorgeven. Omdat alle uitdagingen hun gegevens
via STDIN ontvangen, loont het om enkele van deze trucjes te kennen zodat je die invoer snel en met weinig code kunt ophalen.

```python
import math


def solve(a, b, n):
    while True:
        for ix, value in enumerate([a, b]):
            gdc = math.gcd(value, n)
            if gdc <= n != 0:
                n -= gdc
            else:
                print(1 if ix == 0 else 0)
                return


if __name__ == "__main__":
    solve(*map(int, input().split()))
```

Als je deze code als een ```.py```-bestand bewaart, kun je hem op het platform indienen. Omdat CodeForces oplossingen in 
verschillende programmeertalen ondersteunt, moet je aangeven dat hier **Python 3.7.2** wordt gebruikt. Je kunt ook 
**PyPy 3.6 (7.2.0)** kiezen. [PyPy] is een snellere versie van Python en omdat er een limiet staat op de uitvoeringstijd van je code, 
kan dat een voordeel zijn (al maakt het hier weinig uit).

Ik merkte ook dat mijn code hier enkele nogal omslachtige stukken bevat. Onderaan de post vind je mijn poging om
ze zo kort mogelijk te schrijven.

## Het volgende probleem

Daarna ging ik door naar een moeilijker probleem, "[Skier]", waarin je de bewegingen van een skiër moet volgen en bepalen hoe
snel hij een bepaald traject kan afleggen. Over een stuk dat hij al bezocht heeft, beweegt hij sneller dan wanneer hij
er voor het eerst langskomt. Hieronder lees je de volledige probleemomschrijving:

---

Een skiër beweegt over een besneeuwd veld. Zijn bewegingen kunnen worden beschreven door een tekenreeks met 'S', 'N', 'W' en 'E' (die 
respectievelijk overeenkomen met een beweging van 1 meter naar het zuiden, noorden, westen of oosten).

Als hij over een nog niet eerder bezocht segment van een pad beweegt (dit segment wordt dus voor 
het eerst bezocht), duurt die beweging 5 seconden. Beweegt hij over een segment van een pad dat al bezocht is 
(dit segment werd al eerder door zijn route gevolgd), dan duurt het 1 seconde.

Bereken hoeveel tijd de skiër nodig heeft om het volledige pad af te leggen.

**Invoer**

De eerste regel bevat een geheel getal *t* (1≤*t*≤10<sup>4</sup>): het aantal testgevallen in de invoer. Daarna volgen *t* testgevallen.

Elk geval bestaat uit één niet-lege tekenreeks met de tekens 'S', 'N', 'W' en 'E'. De lengte van de tekenreeks bedraagt maximaal 
10<sup>5</sup> tekens.

De som van de lengtes van de *t* gegeven regels over alle testgevallen in de invoer bedraagt maximaal 10<sup>5</sup>.

**Uitvoer**

Geef voor elk testgeval de gewenste tijd voor het pad in seconden weer.

---

Mijn eerste idee was om de huidige beweging om te zetten naar begin- en eindcoördinaten. Als die al eerder waren bezocht
(of in omgekeerde volgorde), verhoogde ik de tijd met één. Anders voegde ik die coördinaten toe aan de lijst met bezochte stukken en verhoogde
ik de tijd met vijf.

```python
def solve(path):
    x,y,count = 0,0,0
    visited = []

    for p in path:
        new_x = x + 1 if p == "E" else x - 1 if p == "W" else x
        new_y = y + 1 if p == "N" else y - 1 if p == "S" else y

        if (x, y, new_x, new_y) in visited or (new_x, new_y, x, y) in visited:
            count += 1
        else:
            count += 5
            visited.append((x, y, new_x, new_y))

        x, y = new_x, new_y

    return count


if __name__ == "__main__":
    for _ in range(int(input())):
        path = input()
        print(solve(path))
```

Hoewel deze oplossing correct is, aanvaardt CodeForces ze niet omdat ze te lang duurt ... In een lijst 
opzoeken of het volgende segment al bezocht werd, is erg traag. Ik had niet opgelet dat de maximale invoer
10<sup>5</sup> stappen kan bevatten, dus **ik koos niet de juiste gegevensstructuur**. Een woordenboek is beter als je vaak en snel iets moet 
opzoeken. Lees de instructies dus zorgvuldig voordat je begint, zeker als je aan een echte wedstrijd wilt 
deelnemen, waar foute inzendingen je punten kosten. Bovendien verlies je tijd doordat je je oplossing opnieuw moet implementeren.

```python
from collections import defaultdict


def solve(path):
    x, y, c = 0, 0, 0
    s = defaultdict(lambda: 5)

    for p in path:
        nx = x + 1 if p == "E" else x - 1 if p == "W" else x
        ny = y + 1 if p == "N" else y - 1 if p == "S" else y

        c += min(s[(x, y, nx, ny)], s[(nx, ny, x, y)])
        s[(x, y, nx, ny)] = 1

        x, y = nx, ny

    return c


for _ in range(int(input())):
    print(solve(input()))
```

Hier wordt een ```defaultdict``` gebruikt, die de waarde vijf teruggeeft telkens wanneer een nog niet ingesteld element wordt 
opgevraagd. We bepalen dus de huidige coördinaten (x, y) en de volgende (nx, ny) van de skiër, halen de kleinste waarde voor dat
segment en zijn omgekeerde uit het woordenboek en verhogen de teller met die waarde. Daarna stellen we de waarde voor dat pad in het 
woordenboek in op één en werken we de huidige coördinaten bij.

## Vastlopen

Nadat ik nog enkele problemen met een moeilijkheidsgraad van 800 tot 1600 had opgelost, liep ik vast op "[Two Buttons]". Ik 
vond een oplossing met een recursieve diepte-eerstzoektocht, maar kreeg die niet snel genoeg. Zelfs nadat ik
elke optimalisatie had toegevoegd die ik kon bedenken ... niets ... nog altijd veel te traag. Daarom bekeek ik enkele geldige 
oplossingen, die opvallend eenvoudig waren! Er was een truc nodig die iedereen met een informaticadiploma
ongetwijfeld tijdens zijn opleiding heeft gezien. Het optimale pad van begin naar einde zoeken, zoals ik deed, is erg inefficiënt,
maar de oplossing vinden door in omgekeerde richting van einde naar begin te gaan, is eenvoudig. Daardoor wordt de oplossing
triviaal en past ze in enkele regels code.

```python
def solve(n, m):
    count = 0
    while n != m:
        count += 1
        if m < n or m % 2 == 1:
            m += 1
        else:
            m = m // 2

    return count


print(solve(*map(int, input().split())))
```


## Bonus: codegolf

Bij codegolf implementeer je code zo kort mogelijk. Hoewel CodeForces dat niet vereist, probeerde ik
de code voor [Epic Game] hier in te korten ...

```python
import math
s=lambda a,b,n,i:s(b,a,n-math.gcd(a,n),i+1)if n!=0else i%2
print(s(*map(int,input().split()),1))
```

... en hier staat een verkorte versie voor [Two Buttons]. Hoewel ze correct is, faalt ze voor een van de tests omdat ze de 
recursielimiet bereikt (het aantal keer dat een functie zichzelf kan aanroepen; de limiet is 1000).

```python
s=lambda n,m,c:c if n==m else s(n,m+1,c+1) if (m<n or m%2==1) else s(n,m//2,c+1)
print(s(*map(int, input().split()), 0))
```

Dit druist volledig in tegen de Zen of Python, die stelt dat code leesbaar moet zijn, want dit is allesbehalve leesbaar! Gebruik dit dus niet wanneer 
je code schrijft voor projecten die onderhouden moeten worden. Het komt terug om iemand te achtervolgen (waarschijnlijk jezelf).

## Conclusie

Naast enkele excuses om met recursie te spelen en lambda's en de functie ```map``` te gebruiken om korte (maar niet erg
leesbare) code te schrijven, leerde ik het meest door vast te lopen! Het gebruikelijke advies om een probleem vanuit een andere
hoek te bekijken, kon hier vrij letterlijk worden toegepast. Die truc houd ik in gedachten wanneer ik moeilijkere 
programmeeruitdagingen probeer op te lossen.

[CodeForces]: http://codeforces.com/
[Epic Game]: https://codeforces.com/problemset/problem/119/A
[Skier]: https://codeforces.com/problemset/problem/1351/C
[Two Buttons]: https://codeforces.com/problemset/problem/520/B
[PyPy]: https://www.pypy.org/
