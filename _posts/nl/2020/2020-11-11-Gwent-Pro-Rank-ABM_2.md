---
layout: post
title:  "De Gwent Pro Ladder bekeken met een agentgebaseerd model (resultaten)"
byline: "duiken in de gegevens die het ABM opleverde"
description: "De resultaten van het agentgebaseerde Gwent-model analyseren om te tonen dat meer wedstrijden grinden en puur geluk, naast vaardigheid, de piek-MMR op de Pro Ladder verhogen (resultaten)."
date:   2020-11-11 13:00:00
author: Sebastian Proost
post_id: gwent-pro-rank-abm-2
categories: programming games
tags:	python numpy gwent mesa abm agent-based-modeling pandas seaborn data-science
cover:  "/assets/posts/2020-11-11-Gwent-Pro-Rank-ABM/graph_header.jpg"
thumbnail: "/assets/images/thumbnails/graph_header.png"
github: "https://github.com/4dcu-be/GwentAgentBasedModeling"
---

Met het agentgebaseerde model (ABM) uit het [vorige artikel] kunnen we eender welk aantal Gwent-spelers met een bekende 
vaardigheid en speelfrequentie gedurende een seizoen simuleren. Met dit model proberen we het laddersysteem beter te begrijpen
en te testen of het vaardigheid of wedstrijden grinden beloont...

## De Pro Ladder beklimmen: vaardigheid versus grinden

Het ABM bootst een populatie agenten na die een volledig seizoen Gwent spelen, met verschillende aangeboren vaardigheden en beschikbare speeltijd. 
Anders dan bij echte mensen kunnen we de parameters van het model aanpassen om precies te onderzoeken wat we willen testen. In het 
eerste model schakelen we daarom elke vorm van leren uit, waarbij agenten beter zouden worden naarmate ze meer wedstrijden spelen. Zo zien we uitsluitend 
het effect van meer wedstrijden spelen op de piek-MMR (van één factie). 

Daarvoor werd een model met deze parameters uitgevoerd:

  * **8000 spelers**
  * **100 stappen**, waardoor spelers 25-170 wedstrijden per seizoen spelen
  * **niet leren**: spelers worden niet beter door meer wedstrijden te spelen
  * **startvaardigheid** van 1200-2700, vergelijkbaar verdeeld met die van schakers
  
Na het uitvoeren van het model met deze parameters kunnen we spelers groeperen volgens vaardigheid (in groepen van 200 ELO) en aantal
gespeelde wedstrijden (in percentielgroepen van 25). Vervolgens zetten we hun piek-MMR uit om te zien hoe goed ze presteerden. De resulterende grafiek 
(hieronder) toont meteen twee gebreken van het huidige systeem. Binnen een groep spelers met een vergelijkbare vaardigheid
die ongeveer evenveel wedstrijden speelden, is de spreiding vrij groot. Puur geluk bij het tijdstip waarop je speelt en wie je in de wachtrij treft, kan
een verschil tot 70 MMR opleveren! Bovendien bereiken spelers die meer spelen doorgaans een hogere piek-MMR dan spelers met 
een vergelijkbare vaardigheid die minder wedstrijden spelen. Spelers die elk seizoen meer wedstrijden kunnen spelen, hebben dus een duidelijk voordeel
tegenover wie minder tijd heeft.

![Piek-MMR bij verschillende groepen spelers in de ABM-simulatie](/assets/posts/2020-11-11-Gwent-Pro-Rank-ABM/elo_vs_peakMMR_experience_factor_0.png)

Uit echte gegevens bleek duidelijk dat spelers in de hogere rangen doorgaans meer spelen dan spelers die lager
staan. Wanneer we deze grafiek met de gesimuleerde gegevens namaken, verschijnt dat patroon niet. Verderop in het artikel
gaan we daar dieper op in.

![Ridgelinegrafiek met de verdeling van gespeelde wedstrijden in verschillende groepen spelers volgens hun eindrang](/assets/posts/2020-11-11-Gwent-Pro-Rank-ABM/ridgeplot_experience_factor_0.png){:.small-image}

## Leren aan het model toevoegen

We kunnen redelijkerwijs aannemen dat spelers hun deck en de
meta beter leren kennen naarmate ze meer wedstrijden spelen. Eenvoudig gezegd: door meer te spelen worden ze beter. Kan dat de 
toename verklaren van spelers met veel wedstrijden op de hogere posities? Om dit te testen wordt een ervaringsfactor aan
het model toegevoegd, die spelers een ELO-bonus geeft wanneer ze meer wedstrijden spelen. Een nieuw model werd uitgevoerd met deze
leerfactor op 20. Omdat de ELO-bonus wordt berekend als ```experience_factor * sqrt(games_played)```, krijgt
een speler met 100 wedstrijden een bonus van 200 ELO ten opzichte van iemand die er geen speelde, zelfs bij dezelfde aangeboren vaardigheid.

Omdat de overige parameters hetzelfde bleven, gebruikte deze simulatie de volgende instellingen:

  * **ervaringsfactor 20**
  * **8000 spelers**
  * **100 stappen**, zoals voordien
  * **startvaardigheid** van 1200-2700, met dezelfde verdeling als voordien
  
Nu kunnen we dezelfde grafiek maken met de piek-MMR van de agenten, gegroepeerd volgens aangeboren vaardigheid en het aantal
gespeelde wedstrijden. Omdat agenten nu leren door te spelen, wordt het verschil in piek-MMR tussen spelers die weinig en
spelers die veel spelen groter, hoewel ze met een vergelijkbaar vaardigheidsniveau begonnen.

![Piek-MMR bij verschillende groepen spelers in de ABM-simulatie waarin agenten leren door wedstrijden te spelen](/assets/posts/2020-11-11-Gwent-Pro-Rank-ABM/elo_vs_peakMMR_experience_factor_20.png)

Om te controleren of vaker spelende agenten, nu ze zoals echte spelers leren, naar
hogere rangen opschuiven, werd dezelfde ridgelinegrafiek gemaakt. Er is een kleine verschuiving, maar die is nauwelijks zichtbaar en komt niet in de buurt van
de duidelijke verschuiving in echte gegevens. 

![Ridgelinegrafiek met de verdeling van gespeelde wedstrijden in verschillende groepen spelers volgens hun eindrang, met leren ingeschakeld](/assets/posts/2020-11-11-Gwent-Pro-Rank-ABM/ridgeplot_experience_factor_20.png){:.small-image}

Zelfs wanneer de ervaringsfactor tot 100 wordt opgedreven (gegevens in de repository), veel meer dan de vaardigheidstoename die je in werkelijkheid mag verwachten, kan dit
patroon niet worden nagebootst. Er speelt nog een andere factor mee die niet in ons model zit...

## Bespreking

Met een model kunnen we enkele zaken controleren die in werkelijkheid niet gemakkelijk te testen zijn. Dat onthult een paar
aspecten van de werking van het laddersysteem. Met een agentgebaseerd model kennen we exact de aangeboren vaardigheid van elke
agent en kunnen we nagaan hoe hoog die in een bepaald aantal wedstrijden op de ladder geraakt. Zo kunnen we meten hoe goed de ladder
individuen op basis van hun echte vaardigheid rangschikt. Ook het effect van meer wedstrijden spelen kon worden blootgelegd, zowel wanneer
spelers beter worden door meer te spelen als zonder enige vorm van leren.

### Kom je hoger door meer wedstrijden te spelen?

**Antwoord: ja, maar niet veel**

Meer wedstrijden spelen levert een vrij klein voordeel op tegenover spelers die minder wedstrijden spelen, zelfs wanneer
een speler niet beter wordt door meer te spelen. Het voordeel is echter niet groot genoeg om een gemiddelde speler
plots in de top 200 of zelfs de top 500 te brengen door gewoon enorm veel wedstrijden te spelen.

Er is zelfs veel variatie tussen aangeboren vaardigheid en bereikte piek-MMR. Door 30-50 wedstrijden te spelen en
geluk te hebben met wie je in de wachtrij treft, kun je 50 MMR hoger eindigen dan een even vaardige speler die twee- of driemaal
zoveel wedstrijden speelt maar minder geluk heeft.

### Waarom spelen hoger geklasseerde spelers meer?

**Antwoord: menselijke psychologie?**

Spelers die meer spelen eindigen niet louter daardoor hoger in het klassement. Geen enkele hoeveelheid leren kan
de verschuiving uit de echte gegevens verklaren. Menselijke spelers vertonen dus gedrag dat niet uit het model ontstaat. Ik
waag me aan enkele hypothesen die het verschil tussen model en waarneming kunnen verklaren.

  * Spelers die in vorige seizoenen veel speelden, zijn (i) door hun ervaring beter in het spel en 
  (ii) zullen vaker dan gemiddeld blijven spelen.
  * Hoewel de winst vrij klein is, geeft de werking van de ladder frequente spelers een beperkt voordeel. Hoe hoger 
  je op de ladder komt, hoe competitiever het wordt en hoe meer spelers bereid zijn extra wedstrijden te spelen om dit
  kleine voordeel tegenover hun concurrenten te benutten.
  * Spelers in hogere rangen merken dat andere spelers op hun niveau meer spelen. Daardoor voelen ze druk om
  het tempo bij te houden.
  * Een combinatie van al het bovenstaande ... waarschijnlijk geldt niet één verklaring voor alle spelers.

### Moet je grinden?

**Antwoord: ja, in hogere rangen**

Meer wedstrijden spelen levert een voordeel op en dat voordeel wordt groter binnen de vaardigste groepen spelers. In combinatie
met het feit dat spelers in die groepen elk seizoen doorgaans vrij veel wedstrijden spelen, verlies je dat voordeel tenzij je nóg meer speelt ...
Dit is een feedbacklus waardoor spelers zich verplicht kunnen voelen meer te spelen dan ze anders zouden doen. Hoewel het 
voordeel niet groot is, kan een klein MMR-verschil in die relatief kleine groep topspelers het verschil betekenen tussen
een plaats in de top 200, kroonpunten en een plek in een officieel toernooi, of dat allemaal mislopen.

### Is piek-MMR een goede maatstaf?

**Antwoord: het kan beter**

Piek-MMR correleert als maatstaf redelijk goed met de aangeboren vaardigheid van een speler en geeft die vaardigheid dus over het algemeen behoorlijk
weer. Uit deze analyse kwamen wel twee belangrijke problemen naar voren:

  * **Er is veel variatie**: spelers met een vergelijkbare vaardigheid die ongeveer evenveel wedstrijden spelen, kunnen 
  piek-MMR-scores bereiken die tot ongeveer 70 punten verschillen. Dat hangt enkel af van geluk en wie je in de wachtrij treft.
  * **Meer spelen leidt tot een hogere piek-MMR**, zelfs zonder leren. Een winstreeks op het juiste moment
  kan de piek-MMR verhogen. Meer wedstrijden spelen vergroot de kans dat zo'n reeks op het juiste moment voorkomt.
  
Omdat de simulatie veronderstelt dat spelers met één factie spelen, terwijl Gwent de MMR-scores van je
vier beste facties optelt, is de variatie in het echte systeem kleiner: geluk met de ene factie wordt gecompenseerd door pech met een andere.
Dat kan verder worden verbeterd door de MMR om de 5-10 wedstrijden opnieuw te berekenen, vergelijkbaar met de berekeningen waarmee ELO-
scores van schakers aan het einde van een toernooi worden aangepast.

Het effect van meer wedstrijden spelen is heel eenvoudig weg te nemen ... door op de huidige MMR te rangschikken in plaats van op de piek-
MMR. Zoals je in de onderstaande grafiek ziet, is er zonder leren bij de huidige MMR geen verschil
tussen spelers met een vergelijkbare vaardigheid op basis van het aantal wedstrijden dat ze spelen.

![Huidige MMR bij verschillende groepen spelers in de ABM-simulatie](/assets/posts/2020-11-11-Gwent-Pro-Rank-ABM/elo_vs_currentMMR_experience_factor_0.png)

Piek-MMR moedigt aan om zoveel mogelijk wedstrijden te spelen en geeft spelers de mogelijkheid om rustiger te spelen
zodra ze met een bepaalde factie niet meer willen klimmen. Dat bevordert een actievere spelersbasis.
Met de huidige MMR zouden spelers niet losser in *ranked* kunnen spelen, omdat hun score dan weer zou dalen.
Zodra je een MMR bereikt die voor jou als een piek aanvoelt, kun je eigenlijk beter de rest van het seizoen niet meer met die
factie spelen. Daardoor zouden minder mensen actief zijn, zouden de wachttijden oplopen en zou
dat deel van het spel slechter worden.

## Conclusie

Nee, je kunt je niet naar een plek in de top 200 grinden zonder de nodige vaardigheid. Meer wedstrijden spelen dan 
concurrenten met een vergelijkbare vaardigheid is wel een voordeel. In de hoogste groepen, waar spelers vrij vaak spelen, 
betekent dat nog meer wedstrijden spelen om dat concurrentievoordeel te benutten. 

Moet de huidige MMR de piek-MMR als maatstaf vervangen? Als gameontwikkelaar wil CDPR waarschijnlijk zoveel mogelijk mensen online 
laten spelen, en piek-MMR gebruiken om prestaties op de ladder te meten sluit daar goed bij aan. Het moedigt 
spelers echter aan om meer te spelen en competitieve spelers om niet alleen zo goed, maar ook zo veel mogelijk te spelen. In een
tijd waarin [digitaal welzijn] op de agenda van bedrijven als Google, Samsung en Apple verschijnt, is dit iets
waar CDPR vroeg of laat naar moet kijken.


[vorige artikel]: {% post_url nl/2020/2020-11-11-Gwent-Pro-Rank-ABM %}
[digitaal welzijn]: https://digitalwellbeing.org/
