---
layout: post
title:  "ComfyUI en SDXL: nieuwe workflows"
byline: "experimenten met Control-LoRas en de SDXL Refiner"
description: "Praktische ComfyUI-workflows voor Stable Diffusion SDXL, met experimenten met Control-LoRas en de SDXL Refiner via de interface met knooppunten in plaats van Automatic1111."
date:   2023-09-03 08:00:00
author: Sebastian Proost
post_id: comfyui-sdxl-workflows
categories: ai
tags:	aiart python stable-diffusion art
cover:  "/assets/posts/2023-09-04-comfyui-sdxl-workflows/sdxl_header.jpg"
thumbnail: "/assets/images/thumbnails/sdxl_header.jpg"
gallery_items:
  - image: "/assets/posts/2023-09-04-comfyui-sdxl-workflows/sdxl_header.jpg"
    gallery_image: "/assets/images/gallery/sdxl_vermeer_gallery.jpg"
    description: "Meisje met de parel van Johannes Vermeer en een herwerkte filmische cyberpunkversie met SDXL"
    gallery_size: wide
---

De nieuwste versie van onze software, StableDiffusion, met de toepasselijke naam SDXL, is onlangs uitgebracht. Daardoor is 
tegelijk ook de belangstelling voor [ComfyUI] aangewakkerd, een nieuwe tool die het gebruik van deze modellen eenvoudiger maakt. Het is 
wel belangrijk om te weten dat de workflows met knooppunten van ComfyUI sterk verschillen van het [Automatic1111]-framework 
dat ik eerder gebruikte (mijn tips en trucs voor dat framework vind je in een [vorige post]). In dit artikel 
neem ik je mee langs enkele technieken die voor mij goed werken met ComfyUI. 

## Achtergrond
Nog niet zo lang geleden organiseerde de geweldige kunstenaar en YouTuber Ten Hundred (of Ten Hun) een wedstrijd 
waarin iedereen een eigen interpretatie van zijn kunstfiguurtje [Hammerhood] mocht maken. Ik greep die 
kans aan om te experimenteren met de technologieën waarin ik me toen verdiepte, namelijk StableDiffusion 2.1 en 
ControlNet. Daarom besloot ik een versie te maken en in te sturen die volledig door AI was gegenereerd. 

![Vier versies van Ten Huns Hammerhood, gemaakt met StableDiffusion 2.1 en ControlNet](/assets/posts/2023-09-04-comfyui-sdxl-workflows/ai_hammerhood_versions.jpg){:.small-image}

Om duidelijk en transparant te zijn, vermeldde ik in de beschrijving van mijn inzending uitdrukkelijk dat deze 
creatie met artificiële intelligentie tot stand was gekomen. Verrassend genoeg kregen mijn door AI gegenereerde afbeeldingen een plaats tussen de 
uitgelichte inzendingen op [Ten Huns kanaal]! Zoals verwacht kon mijn 
door AI gemaakte werk niet op tegen de winnende inzendingen. Dat benadrukt hoe onvervangbaar de menselijke creativiteit 
in de kunstwereld is en hoe AI daar voorlopig nog niet aan kan tippen.

![Ten Hun toont mijn Hammerhood-inzending op zijn kanaal](/assets/posts/2023-09-04-comfyui-sdxl-workflows/ten_hun_feature.jpg){:.medium-image}

Sinds ik deze afbeeldingen instuurde, heeft Stability AI verschillende nieuwe tools uitgebracht. Dat zette me ertoe aan mijn 
oorspronkelijke workflow te verfijnen. In deze post licht ik de nieuwe workflows toe die ik sindsdien gebruik, en dan vooral 
de workflows met ControlNet.

## De nieuwe tools

Om deze post te kunnen volgen, moet je enkele nieuwe tools installeren en de nieuwe modellen downloaden. Voor elk van deze tools 
is er een eigen uitgebreide installatiehandleiding. Volg die nauwgezet om alles zonder problemen op te zetten. Hou er 
rekening mee dat de installatie, doordat deze softwaretools zo nieuw zijn, iets 
ingewikkelder kan zijn dan die van klassieke softwarepakketten.

* [Stability AI](https://huggingface.co/stabilityai) op Huggingface: hier vind je alle officiële SDXL-modellen
    * [SDXL 1.0](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0): het basismodel, dat wordt gebruikt om de eerste stappen van elke afbeelding te genereren met een resolutie van ongeveer 1024x1024.
    * [SDXL Refiner](https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0): het verfijningsmodel, een nieuwe functie van SDXL 
    * [SDXL VAE](https://huggingface.co/stabilityai/sdxl-vae): optioneel, want zowel het basis- als het verfijningsmodel heeft een ingebouwde VAE. Toch is het handig om die afzonderlijk in de workflow te hebben, zodat je hem kunt bijwerken of vervangen zonder een nieuw model nodig te hebben.
    * [Control-Lora](https://huggingface.co/stabilityai/control-lora): officiële uitgave van modellen in de stijl van ControlNet, samen met enkele andere interessante modellen.
* [OpenPose SDXL](https://huggingface.co/thibaud/controlnet-openpose-sdxl-1.0): OpenPose ControlNet voor SDXL.
* [ComfyUI](https://github.com/comfyanonymous/ComfyUI): workflowbeheer met knooppunten dat je met Stable Diffusion kunt gebruiken
    * [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Manager): plug-in voor ComfyUI die ontbrekende plug-ins helpt op te sporen en te installeren.
    * [ComfyUI ControlNet aux](https://github.com/Fannovel16/comfyui_controlnet_aux): plug-in met preprocessors voor ControlNet, zodat je afbeeldingen rechtstreeks vanuit ComfyUI kunt genereren.
* [ESRGAN-upscalermodellen](https://openmodeldb.info/): ik raad een UltraSharp-model (voor foto's) en Remacri (voor schilderijen) aan, maar er bestaan veel opties die voor uiteenlopende toepassingen zijn geoptimaliseerd.

## Mijn ComfyUI-workflows met ControlNet 

Voor de kunstwedstrijd kregen we verschillende referentieafbeeldingen. In dit geval gebruikte ik een van de 3D-renders als 
referentie. Eerst gaat deze afbeelding door twee preprocessors: een dieptekaart en randdetectie. De dieptekaart zorgt ervoor 
dat we de algemene vorm van het onderwerp vastleggen, of het nu om een voorwerp of een persoon in een bepaalde houding gaat. Door die 
met randdetectie te combineren, blijven zelfs de fijne details behouden. Zo kunnen we een afbeelding aanpassen en 
toch herkenbaar houden. 

In ComfyUI is het essentieel om alle knooppunten correct met elkaar te verbinden, zodat elk model de nodige bijdrage levert. Zodra alles 
goed is ingesteld, heb je tal van 
aanpasbare opties tot je beschikking: van de referentieafbeelding bijstellen tot bepalen hoeveel invloed elke ControlNet op het 
eindresultaat heeft. Samen met de variatiemogelijkheden van prompts en LoRa-modellen geeft deze methode je enorm veel controle 
over de inhoud en compositie van een afbeelding.

![ComfyUI-workflow met twee gecombineerde ControlNets, het SDXL-basismodel en offset noise LoRa](/assets/posts/2023-09-04-comfyui-sdxl-workflows/dual_controlnet_workflow.jpg)

[**Download deze workflow**](/assets/posts/2023-09-04-comfyui-sdxl-workflows/dual_controlnet_basic.json) als .json-bestand.

Zodra je een afbeelding hebt die dicht bij 
het gewenste resultaat ligt, kun je img2img nog altijd gebruiken om vergelijkbare afbeeldingen te genereren, zoals in een [vorige post] wordt getoond! Laad de afbeelding met het juiste 
knooppunt, stuur ze door een ```VAE Encode```-knooppunt en gebruik het resulterende latent als invoer voor de sampler (ter vervanging van ```Empty Latent Image``` als startpunt). Vergeet niet de 
denoise-sterkte te verlagen (0.6 geeft de AI veel vrijheid om de invoerafbeelding te wijzigen; hoe lager deze waarde, hoe minder speelruimte 
de AI heeft), en je kunt aan de slag. 

Hou er rekening mee dat je de [SDXL Refiner] niet nodig hebt voor werk waarvoor je een artistieke, schilderachtige stijl nastreeft. 
Wil je daarentegen iets maken dat er levensechter of fotorealistischer uitziet, dan kan de refiner 
een grote hulp zijn. 

![The Mandalorian als Hammerhood, of is het andersom?](/assets/posts/2023-09-04-comfyui-sdxl-workflows/mandalorian_hammerhood.jpg){:.small-image}

Zoek je een vergelijkbare workflow die de refiner wel gebruikt, dan kun je die [**hier downloaden**](/assets/posts/2023-09-04-comfyui-sdxl-workflows/dual_controlnet_refiner.json).

Hoewel de refiner een zegen is voor fotorealisme, is het moeilijker om een img2img-stap toe te voegen waarmee je een afbeelding meerdere keren doorloopt,
omdat daarvoor ```KSampler (advanced)```-knooppunten nodig zijn.

![Het Meisje met de parel: het origineel, als bronzen beeld en als fotorealistische oude vrouw](/assets/posts/2023-09-04-comfyui-sdxl-workflows/girl_with_pearl_earring.jpg){:.medium-image}

## Andere workflows verkennen

Wil je ControlNet niet gebruiken, maar wel met SDXL en de refiner aan de slag? Bekijk dan de 
[Sytan SDXL ComfyUI]-workflow. Die vormt de basis voor mijn [andere workflows], die op GitHub beschikbaar zijn en 
ook een opschalingsfase bevatten. Met [ESRGAN-upscalermodellen] verhoogt deze fase de resolutie van de gemaakte 
afbeeldingen met behoud van een hoge kwaliteit. 

## Tot slot

[ComfyUI] doorgronden en leren werken met een systeem van knooppunten kan in het begin een uitdaging lijken, zeker als dit 
nieuw voor je is. Toch is het een bijzonder krachtig instrument. [Automatic1111] is ook een betrouwbare keuze die 
SDXL ondersteunt als je de voorkeur geeft aan een traditionelere gebruikersinterface; daar is evenmin iets mis mee!

De snelle vooruitgang in dit domein blijft me verbazen. Terwijl bepaalde elementen met SD2.1 bijna 
onmogelijk goed te krijgen waren, geeft SDXL ze correct weer (handen blijven het grootste probleem). Het basismodel 
kan veel realistischere resultaten maken en de resolutie is aanzienlijk verbeterd. Voor mensen zoals ik, die af en toe een creatieve uitlaatklep nodig hebben en beter overweg kunnen met computers dan met penselen, is deze gereedschapskist onmisbaar om fraaie afbeeldingen te maken.

[vorige post]: {% post_url 2022/2022-12-31-Stable-Diffusion-Workflow %}
[ComfyUI]: https://github.com/comfyanonymous/ComfyUI
[Automatic1111]: https://github.com/AUTOMATIC1111/stable-diffusion-webui
[Stability AI]: https://huggingface.co/stabilityai
[SDXL 1.0]: https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0
[SDXL Refiner]: https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0
[SDXL VAE]: https://huggingface.co/stabilityai/sdxl-vae
[Control-Lora]: https://huggingface.co/stabilityai/control-lora
[OpenPose SDXL]: https://huggingface.co/thibaud/controlnet-openpose-sdxl-1.0
[ComfyUI Manager]: https://github.com/ltdrdata/ComfyUI-Manager
[ComfyUI ControlNet aux]: https://github.com/Fannovel16/comfyui_controlnet_aux
[Sytan SDXL ComfyUI]: https://github.com/SytanSD/Sytan-SDXL-ComfyUI
[ESRGAN-upscalermodellen]: https://openmodeldb.info/
[Ten Huns kanaal]:https://www.youtube.com/channel/UCh-ArhaGOqFsBPrR2yQd42w
[Hammerhood]: https://www.youtube.com/watch?v=bw3KCIsGhrU
[andere workflows]: https://github.com/sepro/SDXL-ComfyUI-workflows
