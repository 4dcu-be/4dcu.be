---
layout: post
title:  "Licht, camera, GitHub, Actions: mijn favoriete GitHub Actions"
byline: ""
description: "Een rondleiding langs mijn favoriete GitHub Actions-workflows om taken te automatiseren, zoals Python-code formatteren met black, unittests uitvoeren en volgens een planning gegevens ophalen."
date:   2021-10-15 06:00:00
author: Sebastian Proost
post_id: github-actions
categories: programming
tags:	python javascript github black unittest ci automation yaml
cover:  "/assets/posts/2021-10-15-GitHub-Actions/github_logo.png"
thumbnail: "/assets/images/thumbnails/github_actions_header.jpg"
---

Met [GitHub Actions] kun je bepaalde workflows rechtstreeks op GitHub automatiseren wanneer code wordt gepusht, op
vaste tijdstippen of wanneer je ze handmatig activeert. Het vraagt wat voorbereiding, maar de voordelen zijn de tijd
die nodig is om deze geavanceerde GitHub-functie te leren kennen meer dan waard.

In dit artikel bespreek ik enkele van mijn favoriete workflows om periodiek nieuwe gegevens op te halen, code te
formatteren, unittests uit te voeren, ... Ik voeg links naar verschillende repositories toe, zodat je de acties echt
in actie kunt zien. Dit zijn niet de meest geavanceerde workflows, maar zelfs een beetje automatisering kan je veel
tijd en moeite besparen.

## Autoblack - Python-code formatteren

Het pakket [black] is de feitelijke standaard om Python-code te formatteren. Black wijst niet alleen op inconsistenties
en fouten in de codestijl, maar corrigeert ze ook. Voor je code in een repository vastlegt, is het dus een goed idee om
black uit te voeren en te controleren of de stijl in orde is. Ik vergeet dat echter nogal eens ... Je zou een
*pre-commit hook* kunnen instellen, maar die moet op het systeem van iedere ontwikkelaar geconfigureerd worden. Nog beter
is het om GitHub black op alle code te laten uitvoeren en fouten automatisch te laten herstellen en opnieuw vastleggen.
Je hoeft lokaal geen *pre-commit hooks* te installeren en zelfs niet te onthouden dat je black zelf moet uitvoeren.

Op GitHub vind je heel wat voorbeelden. Bekijk voor een uitgebreid overzicht de verzameling workflows in [cclaus'
autoblack-repository](https://github.com/cclauss/autoblack). Het bestand dat ik gebruik (hieronder weergegeven) is
daarop gebaseerd, met slechts kleine aanpassingen. Je moet dit in de map ```.github/workflows``` van de repository
opslaan. Het controleert alle Python-code die naar de repository wordt gepusht. Er zijn ook versies die pull requests
verwerken, dus bekijk zeker alle bestanden in cclaus' repository!

{:.large-code}
```yaml
# GitHub Action that uses Black to reformat the Python code in an incoming push request.

name: autoblack
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:  # https://github.com/stefanzweifel/git-auto-commit-action#checkout-the-correct-branch
            ref: ${{ github.head_ref }}
      - name: Set up Python 3.8
        uses: actions/setup-python@v2
        with:
          python-version: 3.8
          architecture: 'x64'
      - run: pip install black
      - run: black --check ./
      - name: If needed, commit black changes to a new pull request
        if: failure()
        run: |
          black ./
          git config --global user.name autoblack_push
          git config --global user.email '${GITHUB_ACTOR}@users.noreply.github.com'
          git commit -am "fixup! Format Python code with psf/black push"
          git push
```

De workflow is vrij eenvoudig, maar het kost wat tijd om te begrijpen hoe alles in het YAML-bestand wordt opgenomen.
Elke vermelding van ```uses:``` of ```run:``` roept een extern script aan of voert een bepaalde opdracht uit. Dit script
zal dus:

  * De repository uitchecken met een externe actie [actions/checkout@v2](https://github.com/stefanzweifel/git-auto-commit-action#checkout-the-correct-branch
  * Python 3.8 installeren met [actions/setup-python@v2](https://github.com/actions/setup-python)
  * Black installeren zoals je dat lokaal via pip zou doen
  * Black uitvoeren om op problemen te controleren
  * Als er problemen zijn, geeft black een foutmelding, waarna black wordt uitgevoerd om de problemen te corrigeren en de bijgewerkte code vast te leggen

Voor mij is dit voortaan zowat een automatische toevoeging aan elk nieuw Python-project (behalve voor notebooks, maar
daarvoor bestaat [nb_black](https://github.com/dnanhkhoa/nb_black)). Zet het bestand gewoon in de juiste map en klaar:
alle code wordt eenvoudig en automatisch geformatteerd.

## Unittests en codedekking

Een systeem voor continue integratie (CI) dat unittests uitvoert om te controleren of nieuwe codeversies nog werken
zoals bedoeld, is niets nieuws. Met GitHub Actions kun je dat nu volledig op GitHub doen. Daardoor is een externe
oplossing zoals [Travis CI] niet meer nodig en is er met minder "bewegende" onderdelen minder kans dat een workflow
stukgaat. Bovendien maakten sommige externe platformen het niet gemakkelijk om verschillende delen van een codebase in
meerdere programmeertalen te testen. Nu voeg je gewoon voor iedere taal een YAML-bestand toe.

Mijn vaste repository om nieuwe dingen uit te proberen, [MemoBoard](https://github.com/sepro/MemoBoard), bevat een
Python- en een JavaScript-onderdeel. Voor alle onderdelen zijn unittests geïmplementeerd. We kunnen dus gewoon twee
YAML-bestanden toevoegen die een omgeving aanmaken (Python of Node), alle afhankelijkheden installeren en de tests
uitvoeren. Dat werkt netjes voor zowel het Python- als het JavaScript-gedeelte en geeft een foutmelding zodra een van
beide mislukt.

![Schermafbeelding van MemoBoard: hopeloos overmatig ontworpen, maar nog steeds mijn vaste plek om nieuwe dingen uit te proberen](/assets/posts/2021-10-15-GitHub-Actions/memoboard.png)

Voor het Python-gedeelte wordt ook de codedekking opgenomen en aan [codecov.io] gerapporteerd. Daar bestaan al acties
voor, dus die toevoegen is heel eenvoudig.

{:.large-code}
```yaml
# GitHub Action that uses Black to reformat the Python code in an incoming push request.

name: unittest python + codecov
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:  # https://github.com/stefanzweifel/git-auto-commit-action#checkout-the-correct-branch
            ref: ${{ github.head_ref }}
      - name: Set up Python 3.8
        uses: actions/setup-python@v2
        with:
          python-version: 3.8
          architecture: 'x64'
      - name: Install requirements
        run: pip install -r requirements.txt
      - name: Generate Report
        run: |
          pip install coverage
          coverage run run_tests.py
      - name: Upload Coverage to Codecov
        uses: codecov/codecov-action@v1
```

De stappen om JavaScript te testen (meer bepaald JSX en React) zijn vergelijkbaar.

{:.large-code}
```yaml
# GitHub Action that runs unittests on javascript portion of the code

name: unittest js
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:  # https://github.com/stefanzweifel/git-auto-commit-action#checkout-the-correct-branch
            ref: ${{ github.head_ref }}
      - uses: actions/setup-node@v2
        with:
          node-version: '12'
      - name: Install dependencies
        run: npm install
      - name: Unit test
        run: npm test
```

## Een statische website bouwen

GitHub ondersteunt Jekyll voor documentatie al een tijd. Je zet de template en gegevens gewoon in je repository en
GitHub kan de website bouwen. Dat is echter enigszins beperkt: je kunt maar een handvol plugins gebruiken, je kunt je
eigen code uitvoeren en je bent tot Jekyll beperkt. Met een GitHub Action kun je nu eender welke generator voor
statische websites gebruiken, de website opnieuw bouwen en naar een gh-pages-branch sturen, vanwaar hij gehost kan
worden.

Hoewel je de website voor tests en ontwikkeling waarschijnlijk nog steeds lokaal wilt kunnen bouwen, heeft een versie
op GitHub kunnen bouwen heel wat voordelen. Voor kleine wijzigingen hoef je niet langer alle bouwgereedschappen
geïnstalleerd te hebben. Mijn [cv] is een statische website die met [Gatsby] wordt gegenereerd en de meeste wijzigingen
zijn vrij klein, zoals publicatiestatistieken verhogen of een cursus of publicatie toevoegen. Door in de repository een
actie op te nemen die de website bouwt wanneer nieuwe inhoud wordt gepusht, kun je via de GitHub-interface een kleine
wijziging aan een bestand aanbrengen, bijvoorbeeld het aantal citaties bijwerken, waarna de website zichzelf opnieuw
bouwt. Omdat dit via elke browser kan, kun je kleine updates wanneer nodig heel eenvoudig vanaf eender welk beschikbaar
apparaat uitvoeren. Je hebt alleen internettoegang nodig.

Het script hiervoor staat hieronder. Het checkt de code uit, installeert Node, Gatsby, de gewone en
ontwikkelingsafhankelijkheden, bouwt de website en gebruikt een bestaand script om de nieuwe versie naar de
gh-pages-branch te pushen (waarmee je jouw website via GitHub kunt hosten).

{:.large-code}
```yaml
# GitHub Action that builds the website and commits again

name: autobuild
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:  # https://github.com/stefanzweifel/git-auto-commit-action#checkout-the-correct-branch
            ref: ${{ github.head_ref }}
      - uses: actions/setup-node@v2
        with:
            node-version: '14'
      - run: npm i -g gatsby-cli@4.0.0
      - run: npm install
      - run: npm install --only=dev
      - run: gatsby build
      - name: Deploy to gh-pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
```

[DeckLock] kan via een GitHub Action gebouwd worden. Het doel is dat iedereen met een GitHub-account de repository kan
forken en zijn gegevens rechtstreeks via de GitHub-interface kan toevoegen. Met een beetje configuratie wordt de
bouwactie uitgevoerd wanneer er nieuwe gegevens bijkomen en maakt ze een persoonlijk platform. Je hoeft geen Python te
installeren of met de opdrachtregel te knoeien om Pelican uit te voeren.

{:.large-code}
```yaml
# GitHub Action that builds the website and commits again

name: autobuild
on: [push, workflow_dispatch]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:  # https://github.com/stefanzweifel/git-auto-commit-action#checkout-the-correct-branch
            ref: ${{ github.head_ref }}
      - name: Set up Python 3.8
        uses: actions/setup-python@v2
        with:
          python-version: 3.8
          architecture: 'x64'
      - run: pip install -r requirements.txt
      - run: mkdir -p docs
      - name: Run Pelican (build website)
        env:
          DOK_API_KEY: ${{ secrets.DOK_API_KEY }}
        run: make github
```

Een GitHub Action moet bij iedere uitvoering alle onderdelen om de website te bouwen ophalen en installeren. Dat is
eigenlijk een goede controle of al die afhankelijkheden nog beschikbaar zijn. Bij populaire frameworks is dat
misschien geen grote zorg, maar voor veel kleine generators met minder ondersteuning vormt het wel een risico! Onlangs
erfde ik een website die met een verouderd framework was gegenereerd ... De hulpmiddelen om hem opnieuw te bouwen waren
niet meer beschikbaar, waardoor alle bestaande templates en gegevens naar iets anders moesten worden omgezet. Als de
volledige toolchain bij elke gegevensupdate vanaf nul wordt geïnstalleerd, worden zulke problemen vroeg ontdekt en kun
je ze aanpakken voor ze dringend worden.

## Gegevens verzamelen

Een laatste toepassing die ik hier toon, is gegevens verzamelen met een GitHub Action. Omdat je een actie elk uur,
elke dag, elke week, ... kunt activeren, kun je een script periodiek gegevens laten verzamelen. Momenteel wordt [hier](https://github.com/4dcu-be/GitHub-Actions-KeyForge)
ieder uur het aantal geregistreerde [KeyForge]-decks bijgehouden. Het interval instellen lijkt op een cronjob.
Doorgewinterde Linux-gebruikers weten meteen hoe dat werkt; anderen bekijken best de [Wikipedia-pagina over cron](https://en.wikipedia.org/wiki/Cron).

Het Python-script ```get_keyforge.py``` laadt de huidige gegevens, haalt het nieuwe aantal geregistreerde decks op de
website op en schrijft de uitvoer weg. Het bestand met de extra gegevens wordt vervolgens vastgelegd en gepusht.

{:.large-code}
```yaml
# This is a basic workflow to help you get started with Actions

name: Update KeyForge Count Hourly

# Controls when the action will run. 
on:
  schedule:
    # execute every hour
    - cron:  '50 * * * *'

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "build"
  build:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v2
      - name: Set up Python 3.8
        uses: actions/setup-python@v2
        with:
          # Semantic version range syntax or exact version of a Python version
          python-version: '3.8'
          # Optional - x64 or x86 architecture, defaults to x64
          architecture: 'x64'

      # Runs the script
      - name: Fetch KeyForge
        run: python ./scripts/get_keyforge.py

      # Commit and Push new data
      - name: Commit and Push files
        run: |
          git config --local user.email '${GITHUB_ACTOR}@users.noreply.github.com'
          git config --local user.name "fetch-keyforge[bot]"
          git commit -m "Add changes" -a
          git push
```

Eén ding om rekening mee te houden is dat GitHub dit **ongeveer elk uur** uitvoert. De actie kan later starten of bij
hoge belasting helemaal niet worden uitgevoerd. Voor iets dat ieder uur stipt op het uur moet gebeuren, is dit dus
geen goede oplossing. Voor zaken waarbij het tijdstip niet zo nauw luistert, kan dit gemakkelijk een Raspberry Pi
vervangen die zulke taken uitvoert.

In combinatie met een generator voor statische websites kan dit trouwens een manier zijn om een dashboard te maken dat
zichzelf bijwerkt ... Misschien een goed idee voor een toekomstig artikel ...

## Conclusie

Met enkele YAML-bestanden kom je al heel ver met GitHub Actions. Het is geweldig dat je unittests kunt uitvoeren,
statische websites kunt bouwen, ... rechtstreeks op GitHub, zonder afhankelijk te zijn van externe oplossingen. Omdat
de acties samen met de code worden geforkt, kunnen anderen die aan de code werken ze heel eenvoudig activeren. Je moet
ze na het forken van een repository wel uitdrukkelijk inschakelen, maar daarna is alles in enkele seconden operationeel.

Het beste is dat dit gratis is voor openbare repositories. Voor privé-repositories bestaat een gratis pakket, maar
daarboven wordt het een betalende dienst. Voor opensourceprojecten is het echter fantastisch en absoluut de moeite om
voor je repositories in te stellen!

[GitHub Actions]: https://github.com/features/actions
[black]: https://github.com/psf/black
[Travis CI]: https://www.travis-ci.com/
[codecov.io]: https://about.codecov.io/
[cv]: https://sebastian.proost.science/
[Gatsby]: https://www.gatsbyjs.com/
[DeckLock]: https://github.com/4dcu-be/DeckLock
[KeyForge]: https://www.keyforgegame.com/
