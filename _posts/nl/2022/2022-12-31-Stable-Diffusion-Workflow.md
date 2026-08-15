---
layout: post
title:  "Haal alles uit Stable Diffusion 2.1: tips en trucs"
byline: ""
description: "Tips en trucs om alles uit Stable Diffusion 2.1 te halen in de webinterface, met aandacht voor installatie, afbeeldingen van 768 px, prompts en een workflow voor AI-kunst."
date:   2022-12-31 10:00:00
author: Sebastian Proost
post_id: stable-diffusion-workflow
categories: ai
tags:	aiart python stable-diffusion dreambooth art
cover:  "/assets/posts/2022-12-31-Stable-Diffusion-Workflow/header.jpg"
thumbnail: "/assets/images/thumbnails/stable_diffusion_part_1.jpg"
gallery_items:
  - image: "/assets/posts/2022-12-31-Stable-Diffusion-Workflow/train_v5_upscaled_cleanup.jpg"
    gallery_image: "/assets/images/gallery/stable_diffusion_tips.jpg"
    description: "Een trein die bij zonsondergang een station verlaat, een met Stable Diffusion 2.1 gegenereerde AI-afbeelding."
---

De nieuwste versie van Stable Diffusion, met uitgebreidere ondersteuning voor grotere afbeeldingen van 768 px, is een aanzienlijke verbetering
ten opzichte van eerdere modellen die alleen afbeeldingen van 512 px ondersteunden. Het kan wat aanpassing vragen omdat het model met een beperktere
dataset werd getraind en anders met prompts omgaat, maar dit nieuwe model heeft het potentieel om verbluffende, door AI gegenereerde 
kunstwerken te maken. In deze reeks delen we enkele nuttige tips en technieken om de
mogelijkheden van het Stable Diffusion 2.1-model ten volle te benutten.


## Vereisten

Om met Stable Diffusion aan de slag te gaan, moet je enkele tools installeren. Omdat elk van die tools eigen
installatie-instructies heeft, raadpleeg je best de handleidingen voor de specifieke installatieprocedure van elke tool. Hier
lichten we alleen de instellingen uit die specifiek voor deze workflow nodig zijn. Omdat [Stable Diffusion web UI] via Git moet worden geïnstalleerd,
moet je ervoor zorgen dat Git beschikbaar is. Op Windows verkies ik [Git SCM] boven de officiële client.

  * [Stable Diffusion web UI] van AUTOMATIC1111. De UI die we gebruiken om afbeeldingen te genereren, modellen te trainen, ...
  * [Dreambooth Extension] voor Stable Diffusion web UI. Kan via de UI worden geïnstalleerd (tabblad Extensions)
  * Stable Diffusion 2.1 768-model. Download ```v2-1_768-ema-pruned.ckpt``` van [huggingface.co] en plaats dit bestand in de
  juiste map
  * [Lama Cleaner], een op AI gebaseerde tool voor *inpainting*, handig om delen van een afbeelding te verwijderen (optioneel)
  * [ChaiNNer], een workflow-editor om workflows voor beeldbewerking te maken, bijvoorbeeld om afbeeldingen op te schalen (optioneel)
  * [GIMP], een gratis en opensourcetool voor beeldbewerking (optioneel)
  * Je hebt actuele drivers voor je NVIDIA GPU nodig, samen met [cuDNN]

Om de technieken in deze reeks optimaal te benutten, heb je best een uitstekende GPU.
Als je geen GPU met minstens 16GB VRAM ter beschikking hebt, kun je via [Runpod.io] een machine
in de cloud met een krachtige GPU huren voor minder dan een halve dollar per uur. De specificaties van mijn machine, die ik in deze reeks
gebruik, zijn:

  * NVIDIA 4080 RTX (16 Gb VRAM)
  * RAM: 32 Gb
  * CPU: Ryzen 7 3700X
  * 100 Gb vrije ruimte
  * Windows 10

Voor deze eerste post volstaat een bescheidener GPU: elke NVIDIA GPU met 6Gb VRAM zou moeten werken. Alleen voor het 
trainen van nieuwe stijlen of toevoegen van personen en objecten, wat later aan bod komt, is meer VRAM nodig.

## Stable Diffusion web UI configureren

Nadat je [Stable Diffusion web UI] hebt geïnstalleerd, moet je het bestand ```webui-user.bat``` wat aanpassen.
Het programma moet met twee extra argumenten worden gestart, ```--xformers``` en ```--no-half```. Voeg die daarom toe
aan de regel die begint met ```set COMMANDLINE_ARGS=```. Die regel moet ```set COMMANDLINE_ARGS=--xformers --no-half``` worden.
```--xformers``` is een optimalisatie die het VRAM-gebruik wat vermindert. ```--no-half``` is vereist voor SD2.1.
Sla het bestand nu op en voer het uit om Stable Diffusion te starten (merk op dat bij de eerste start enkele extra
afhankelijkheden worden geïnstalleerd).

Open na het opstarten Stable Diffusion web UI in je browser (het standaardadres is http://localhost:7860/) en ga naar het
tabblad ```Settings```. Zoek de optie ```Use cross attention optimizations while training``` en zorg ervoor dat die is
**aangevinkt**. Zo kan xformers ook worden gebruikt tijdens het trainen van een *embedding* of *hypernetwork*. Dat komt
in een toekomstige post aan bod.

## Kunst maken met AI

Persoonlijk beschouw ik mezelf niet als een kunstenaar. Wanneer je met door AI gegenereerde kunst werkt, neem je de rol van
artdirector op. Je geeft instructies, oftewel een *prompt*, aan het neurale netwerk en hoopt de juiste neuronen te prikkelen
om een resultaat te krijgen dat je bevalt. Met enkele revisierondes kom je steeds dichter bij een afbeelding die aan je
verwachtingen voldoet. De workflow die voor mij werkt, begint met het uitwerken van een prompt, waarna ik een grote reeks afbeeldingen genereer,
de beste kies, enkele variaties genereer, daar opnieuw de beste uitpik, *inpainting*/img2img/compositing gebruik om
de details goed te krijgen en ten slotte de afbeelding opschaal.

### Stap 1: prompts uitwerken

Met een prompt geef je het neurale netwerk aan wat je nodig hebt.

```
an steam engine leaving the trainstation, fall, sunset, painting, fine-art, detailed
```

Voor SD2.1 zijn negatieve prompts vrij belangrijk. Hieronder staat een reeks termen waarmee ik begin. Als ik een meer geschilderde
stijl wil, voeg ik hier *photo* en *photorealistic* aan toe (want dat is wat ik niet wil). Wanneer bepaalde ongewenste objecten
blijven opduiken, is dit de plek om ze neer te schrijven en de AI weg te sturen van afbeeldingen die
deze objecten bevatten.

```
disfigured, kitsch, ugly, oversaturated, grain, low-res, Deformed, blurry, bad anatomy, disfigured, poorly drawn face,
mutation, mutated, extra limb, ugly, poorly drawn hands, missing limb, blurry, floating limbs, disconnected limbs,
malformed hands, blur, out of focus, long neck, long body, ugly, disgusting, poorly drawn, childish, mutilated,
mangled, old, surreal
```

Na enkele pogingen kreeg ik deze afbeelding. Ik hou van de stijl en de locomotief doet me denken aan een modeltrein die ik als kind had. Dus
gaan we hiermee verder.

![Door AI gegenereerde afbeelding van een stoomlocomotief die bij zonsondergang het station verlaat](/assets/posts/2022-12-31-Stable-Diffusion-Workflow/train_v1_prompt_only.png)

Stable Diffusion toont ook de gebruikte prompts en instellingen:
 
```
an steam engine leaving the trainstation, fall, sunset, painting, fine-art, detailed
Negative prompt: photo, photorealistic, disfigured, kitsch, ugly, oversaturated, grain, low-res, Deformed, blurry, bad anatomy, disfigured, poorly drawn face, mutation, mutated, extra limb, ugly, poorly drawn hands, missing limb, blurry, floating limbs, disconnected limbs, malformed hands, blur, out of focus, long neck, long body, ugly, disgusting, poorly drawn, childish, mutilated, mangled, old, surreal
Steps: 30, Sampler: Euler a, CFG scale: 7, Seed: 3331645590, Size: 768x768, Model hash: 4bdfc29c, Batch size: 4, Batch pos: 3
```

Je zult wat heen en weer moeten gaan en instellingen wijzigen om een goede prompt te vinden met instellingen die een goede eerste afbeelding opleveren.
Je kunt hier ook brute kracht gebruiken, tientallen of zelfs honderden afbeeldingen genereren en de beste kiezen. 

### Stap 2: variaties genereren

Vervolgens genereren we enkele variaties op deze afbeelding om te zien of we een betere versie tevoorschijn kunnen halen. Kopieer daarvoor de
*seed* naar het overeenkomstige veld en vink ```Extra``` aan om de opties voor variaties te tonen. Stel de variatiesterkte in op
0.05 - 0.1 (relatief laag, omdat we de afbeelding niet te veel willen veranderen) en genereer meer afbeeldingen. Verander
de prompt of de instellingen niet.

![Instellingen van Stable Diffusion web UI om variaties op een afbeelding te genereren](/assets/posts/2022-12-31-Stable-Diffusion-Workflow/prompt_variation_settings.jpg){:.small-image}

Nadat ik enkele batches had gegenereerd, verscheen de volgende afbeelding. Het gebouw lijkt hier veel meer op een treinstation.
Hoewel de afbeelding verre van perfect is, is dit een stap in de goede richting. Dus gaan we hiermee verder!

![Door AI gegenereerde afbeelding van een stoomlocomotief die bij zonsondergang het station verlaat, versie 2 na het genereren van variaties](/assets/posts/2022-12-31-Stable-Diffusion-Workflow/train_v2_prompt_variation.png)

```
an steam engine leaving the trainstation, fall, sunset, painting, fine-art, detailed
Negative prompt: photo, photorealistic, disfigured, kitsch, ugly, oversaturated, grain, low-res, Deformed, blurry, bad anatomy, disfigured, poorly drawn face, mutation, mutated, extra limb, ugly, poorly drawn hands, missing limb, blurry, floating limbs, disconnected limbs, malformed hands, blur, out of focus, long neck, long body, ugly, disgusting, poorly drawn, childish, mutilated, mangled, old, surreal
Steps: 30, Sampler: Euler a, CFG scale: 7, Seed: 3331645590, Size: 768x768, Model hash: 4bdfc29c, Batch size: 8, Batch pos: 1, Variation seed: 2387469322, Variation seed strength: 0.05
```

Merk op dat dit niet met alle samplers werkt. Met *Euler a* lijkt het vrij goed te werken, maar sommige samplers hebben
moeite om een afbeelding met dezelfde *seed* te reproduceren wanneer niet een volledige batch afbeeldingen wordt gegenereerd. (Een oplossing is om
meerdere batches van één afbeelding te maken.) Efficiënte samplers, die al na enkele stappen convergeren,
genereren zelfs bij een kleine variatie (< 0.1) sterk verschillende afbeeldingen. Je resultaat kan dus variëren! 
Een andere manier om verschillende versies van de oorspronkelijke afbeelding te krijgen, is de ```CFG Scale``` en het aantal 
```Sampling Steps``` te variëren. Met het X/Y Plot-script (dat helemaal onderaan de text2img-instellingen kan worden ingeschakeld) 
kun je alle combinaties genereren. Je kunt ook meteen doorgaan naar stap 4 en img2img met een hoge *denoising*-instelling 
gebruiken om variaties te genereren.

### Stap 3: fouten corrigeren met inpainting

De rails in de bovenstaande afbeelding zijn duidelijk fout: er ligt een extra spoorstaaf die we de AI moeten laten verwijderen.
Dat is precies waarvoor *inpainting* is bedoeld: je schildert over een bepaald deel en geeft een nieuwe prompt om dat
te bedekken. Spelen met de instellingen en geduld hebben is hier belangrijk. Ik maskeerde de ongewenste spoorstaaf en voerde de
prompt ```ballast, pebbles, painting, fine-art, detailed``` in, omdat ik de spoorstaaf daardoor wilde vervangen.

Ik probeerde het met en zonder ```Inpaint at full resolution``` en kwam uiteindelijk uit op ```0.9``` voor de ```Denoising 
strength```, waardoor de AI veel vrijheid kreeg om de afbeelding te veranderen. Om volledig nieuwe inhoud toe te voegen of iets te verwijderen,
kan het helpen om ```Masked content``` in te stellen op ```Latent noise``` of ```Latent nothing```, zodat er iets wordt gegenereerd dat niet op
de onderliggende afbeelding is gebaseerd. Als je iets wilt verwijderen, kun je ook [Lama Cleaner] gebruiken. Die tool is 
uitstekend om snel enkele ongewenste elementen weg te werken.

Onze afbeelding ziet er nu zo uit:

![Door AI gegenereerde afbeelding van een stoomlocomotief die bij zonsondergang het station verlaat, versie 3 waarin de extra spoorstaaf met inpainting is verwijderd](/assets/posts/2022-12-31-Stable-Diffusion-Workflow/train_v3_inpainted.png)

De spoorstaaf in de onderste hoek verwijderen met *inpainting* bleek veel omslachtiger. Hier opende ik de
afbeelding in [GIMP] en gebruikte ik het kloongereedschap om wat gras te kopiëren. Vervolgens werd met *inpainting*, een lage ```Denoising 
strength``` van 0.2 en een prompt met gras en aarde opnieuw wat meer variatie in de textuur van dit deel van
de afbeelding aangebracht.

![Door AI gegenereerde afbeelding van een stoomlocomotief die bij zonsondergang het station verlaat, versie 3-2 waarin de extra spoorstaaf met inpainting is verwijderd](/assets/posts/2022-12-31-Stable-Diffusion-Workflow/train_v3-2_inpainted.png)


### Stap 4: de details verfijnen met Img2Img

Nu verplaatsen we onze afbeelding naar img2img om de details te verfijnen. Voer de oorspronkelijke prompt opnieuw in en stel de ```Denoising 
strength``` in op een lage waarde, bijvoorbeeld 0.1 tot 0.4, om te voorkomen dat de AI te veel verandert. Genereer daarna nog enkele afbeeldingen.
Je zult zien dat bij elke iteratie andere aspecten veranderen: sommige versies hebben betere wielen, andere
betere rails of meer details in het gebouw, ...

De truc is om elke afbeelding te kiezen die ergens het beste in is (je kunt afbeeldingen snel naar je Desktop slepen).
Open de afbeeldingen als verschillende lagen in [GIMP], voeg een laagmasker toe en schilder de delen van elke afbeelding die je wilt behouden.
Omdat er maar heel weinig verschil is tussen de afbeeldingen, is dit erg eenvoudig en hoef je niet bijzonder 
precies te schilderen.

![Drie met img2img gegenereerde variaties in GIMP als afzonderlijke lagen, met een masker dat het beste van elke afbeelding combineert](/assets/posts/2022-12-31-Stable-Diffusion-Workflow/gimp_composite_layers.jpg){:.small-image}

We exporteren de afbeelding uit GIMP, want we naderen de definitieve versie!

![Samengestelde afbeelding van een stoomlocomotief die bij zonsondergang het station verlaat](/assets/posts/2022-12-31-Stable-Diffusion-Workflow/train_v4_img2img_composite.png)

Stap 3 en 4 kunnen indien nodig worden herhaald.

### Stap 5: opschalen

Met SD2.1 kunnen we beginnen met een afbeelding van 768x768 of groter, die daardoor dubbel zoveel pixels telt als bij de 512x512-
modellen. Opschalen is dus aanzienlijk eenvoudiger. Waarschijnlijk volstaat het om de afbeelding naar Extras te sturen en twee methoden te selecteren
om de afmetingen mooi met een factor 2x - 4x te vergroten. 

![Definitieve opgeschaalde afbeelding van een stoomlocomotief die bij zonsondergang het station verlaat](/assets/posts/2022-12-31-Stable-Diffusion-Workflow/train_v5_upscaled.jpg)

[Stable Diffusion web UI] ondersteunt ook SD-upscaling in het tabblad img2img. Daarbij wordt de afbeelding in kleinere delen geknipt,
elk deel vergroot, met img2img van details voorzien en alles weer samengevoegd. Zorg ervoor dat de ```Denoising strength``` op
een lage waarde is ingesteld. De resultaten variëren, omdat img2img ook bij lage *denoising*-waarden delen aanpast en zo ons 
eerdere werk met *inpainting* en compositing ongedaan kan maken. 

Een andere optie is [ChaiNNer] gebruiken om een workflow voor opschalen te maken. Die ondersteunt extra modellen voor opschalen
die je met andere filters kunt combineren om de helderheid of scherpte van de afbeelding te verbeteren. Ook [CupScale], dat
verschillende neurale upscalers ondersteunt, kan hiervoor worden gebruikt.

### Stap 6: laatste correcties

Er staan nog enkele elementen in de afbeelding die ik niet mooi vind, zoals de versieringen vooraan en de antenne
achteraan. Omdat ik ze niet wil vervangen maar gewoon wil verwijderen, is [Lama Cleaner] eenvoudiger en sneller dan SD-
inpainting (met het Lama-model). 

![Opgeschaalde versie van een stoomlocomotief die bij zonsondergang het station verlaat, met de laatste handmatige aanpassingen](/assets/posts/2022-12-31-Stable-Diffusion-Workflow/train_v5_upscaled_cleanup.jpg)

## Conclusie

Door AI gegenereerde kunst kan onze manier van kunst maken en bekijken veranderen. Onze definitieve afbeelding, die doet denken aan de vintage 
doosillustraties van modelbouwsets, is daar een bewijs van. Zonder de hulp van AI-tools was het voor mij onmogelijk geweest
om zo'n afbeelding te maken. Hoewel je al geweldige resultaten kunt krijgen door simpelweg een prompt te schrijven, kost het meestal wat meer 
moeite om de gewenste afbeelding te bekomen. Daarom is het belangrijk om met instellingen te blijven experimenteren en je 
afbeeldingen te verfijnen. Wees niet bang om je afbeelding meerdere keren opnieuw te genereren tot je tevreden bent met het resultaat.


[Runpod.io]: https://www.runpod.io/
[Git SCM]: https://git-scm.com/
[Stable Diffusion web UI]: https://github.com/AUTOMATIC1111/stable-diffusion-webui
[huggingface.co]: https://huggingface.co/stabilityai/stable-diffusion-2-1
[Lama Cleaner]: https://github.com/Sanster/lama-cleaner
[GIMP]: https://www.gimp.org/
[Dreambooth Extension]: https://github.com/d8ahazard/sd_dreambooth_extension
[cuDNN]: https://developer.nvidia.com/cudnn
[ChaiNNer]:https://github.com/chaiNNer-org/chaiNNer
[CupScale]: https://github.com/n00mkrad/cupscale
