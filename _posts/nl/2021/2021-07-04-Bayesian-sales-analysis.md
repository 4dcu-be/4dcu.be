---
layout: post
title:  "Bayesiaanse analyse van verkoopgegevens met PyMC3"
byline: ""
description: "Een eerste poging tot Bayesiaanse analyse met PyMC3 op registratiegegevens van KeyForge-decks, waarbij de impact van nieuwe sets en COVID-19 op de verkoop wordt gemodelleerd."
date:   2021-07-04 08:00:00
author: Sebastian Proost
post_id: bayesian-sales-analysis
categories: programming games
tags:	python pymc3 keyforge data-analysis data-science machine-learning altair covid-19
cover:  "/assets/posts/2021-07-04-Bayesian-sales-analysis/bayesian_sales.jpg"
thumbnail: "/assets/images/thumbnails/bayesian_sales_header.jpg"
github: "https://github.com/4dcu-be/BayesianSalesAnalysis"
custom_js:
  - vega.min
  - vega-lite.min
  - vega-embed.min
  - justcharts
---

Bayesiaanse analyse en probabilistisch programmeren verschillen behoorlijk van een ‘gewone’ analyse. Hier neem ik je mee 
door mijn eerste poging om met [PyMC3] verkoopgegevens van [KeyForge]-decks te analyseren en de gevolgen van 
COVID-19-beperkingen en de release van nieuwe inhoud te onderzoeken. PyMC3 vergt wat gewenning, maar aan het einde zul je zien dat
deze aanpak enkele duidelijke voordelen heeft!

In deze post bekijken we de verkoop van KeyForge, een *collectible card game* van FFG dat in veel opzichten uniek is. Voor
deze post zijn echter maar enkele zaken van belang. Het spel wordt verkocht als losse decks of starterkits met
twee decks en enkele fiches om het spel te spelen. Elk deck wordt willekeurig gegenereerd en is uniek; je hoort decks te spelen
zoals ze zijn, zonder de kaarten te wijzigen. Spelers worden aangemoedigd om met de bijbehorende app de QR-code bij elk deck te scannen 
en het online te registreren. Het aantal decks dat sinds de release van KeyForge in november 2018 werd geregistreerd, staat 
op de website. Om de zes tot acht maanden verschijnt een nieuwe set met nieuwe kaarten en mechanismen. Voor elke 
release worden gedurende een periode nieuwe kaarten onthuld en neemt de reclame toe.

Hoewel het aantal geregistreerde decks niet overeenkomt met 100% van de verkochte decks, worden spelers aangemoedigd hun decks te registreren. We 
nemen daarom aan dat de meerderheid dat doet. Algemene trends in geregistreerde decks weerspiegelen dan ook trends in de werkelijke verkoop. Omdat
de website alleen het huidige aantal geregistreerde decks toont, is het cruciaal om die gegevens doorheen de tijd 
bij te houden. Gelukkig verzamelt Duk van [Archon Arcana] deze cijfers vanaf het prille begin en deelde die zo vriendelijk 
de ruwe gegevens waarmee we kunnen spelen (bekijk hun pagina [hier](https://archonarcana.com/Master_Vault#Registered_decks)).

Hieronder zie je het aantal geregistreerde decks doorheen de tijd (blauwe lijn), met daarbovenop het uiteindelijke model (grijze lijn met
het minimum-maximumbereik in lichtgrijs). Voor een model past dit bijzonder goed. In deze post neem ik je mee door de stappen
om dit punt te bereiken: van een eenvoudig lineair model tot een model dat rekening houdt met de release van nieuwe sets
en met het effect van COVID-19-maatregelen.

[![Het eindmodel sluit bijzonder goed aan bij het aantal geregistreerde decks](/assets/posts/2021-07-04-Bayesian-sales-analysis/model_5.svg)](/assets/posts/2021-07-04-Bayesian-sales-analysis/model_5.json)

## PyMC3 installeren

De eenvoudigste manier om PyMC3 in te stellen, is [Anaconda] installeren, een nieuwe omgeving maken en activeren, en
[PyMC3] via conda-forge installeren. Daarnaast zijn pandas, numpy en enkele andere pakketten handig wanneer je met
PyMC3 werkt.

Op *Windows* heb je ook de Visual Studio 2017 *build tools* met C-tools nodig. Die zijn optioneel, dus vink ze aan in
de opties tijdens de installatie. Ook het libpython-pakket moet in de omgeving worden geïnstalleerd.

```bash
conda create --name pymc3
conda activate pymc3
conda install -c conda-forge pymc3 pandas numpy  jupyterlab altair nb_black arviz

jupyter notebook
```

Je kunt ook vertrekken van [deze GitHub-repository] en de instructies in README.md volgen om de 
omgeving in te stellen, of ze starten op [binder](https://mybinder.org/v2/gh/4dcu-be/BayesianSalesAnalysis/HEAD).

## De gegevens laden

De gegevens van [Archon Arcana] laden is eenvoudig: het is een csv-bestand dat met pandas kan worden ingelezen. Het
bevat het aantal registraties per week, telkens op zondag verzameld. De eerste regel gaat echter over de eerste paar dagen
en dus niet over een volledige week; die laten we weg. Afhankelijk van het model kan het ook nuttig zijn om het
totale aantal registraties te schalen, zodat de parameters van het model binnen een beter beheersbaar bereik vallen. Hier delen we het totaal
door 10.000.

```python
data = pd.read_csv('./data/archon_arcana_weekly_20210619.csv', thousands=',')
data['Week_nr'] = data.index
data = data[data.Week_nr > 0] # ignore first line which is day 3, start with week 1
model_data = data[["Week_nr", "Total"]].copy()
model_data["Total_scaled"] = model_data["Total"]/10000
model_data

```

Omdat we alleen het weeknummer, het totale aantal decks en het geschaalde totaal nodig hebben, selecteren we die kolommen uit de 
DataFrame. Dat levert de tabel hieronder op.

{:.narrow-rows }
|     | Week_nr |   Total | Total_scaled |
|----:|--------:|--------:|-------------:|
|   1 |       1 |  158016 |      15.8016 |
|   2 |       2 |  218733 |      21.8733 |
|   3 |       3 |  268026 |      26.8026 |
|   4 |       4 |  311895 |      31.1895 |
|   5 |       5 |  358098 |      35.8098 |
| ... |     ... |     ... |          ... |
| 130 |     130 | 2308213 |     230.8213 |
| 131 |     131 | 2332833 |     233.2833 |
| 132 |     132 | 2346868 |     234.6868 |
| 133 |     133 | 2359112 |     235.9112 |
| 134 |     134 | 2368328 |     236.8328 |


## Een bescheiden begin - een lineair model fitten 

Om te beginnen fitten we een eenvoudig lineair model op deze curve. Op het eerste gezicht lijkt het aantal geregistreerde
decks vrij stabiel toe te nemen doorheen de tijd. Met een eenvoudig model controleren we dus of alles werkt 
zoals het hoort en krijgen we een eerste indruk van de gegevens. De vergelijking voor een lineair model is eenvoudig:

y = ax + b

waarbij x het aantal weken sinds de release is en y het aantal geregistreerde decks. De helling *a* is het aantal 
decks dat per week wordt geregistreerd. Omdat er op punt nul nog geen decks verkocht zouden zijn, hebben we geen intercept (*b*) nodig; 
het model heeft slechts één variabele: de helling. 

Voor Bayesiaanse modellen moeten we wel priors opnemen: we geven het model enkele zinvolle beginwaarden, 
die tijdens het samplen worden verfijnd. Als we voorkennis hebben, kunnen we die in deze stap verwerken. Hier 
gaan we er echter net als Jon Snow van uit dat we niets weten en stellen we onze priors in op zeer algemene waarden met een grote 
onzekerheid.

Om de kans te bepalen dat we bepaalde gegevens zien gegeven de priors van het model, moeten we de likelihood definiëren.  

```python
with pm.Model() as model:
    # priors
    sigma = pm.Exponential("sigma", lam=1.0)
    slope = pm.Normal("slope", mu=0, sigma=20)

    # Likelihood
    likelihood = pm.Normal(
        "y",
        mu=slope * model_data.Week_nr,
        sigma=sigma,
        observed=model_data.Total_scaled,
    )

    # posterior
    trace = pm.sample(1000, cores=4, chains=4)
```

In de [GitHub repo] vind je alle code om de uitvoer te inspecteren en te visualiseren; dat deel is niet in deze post opgenomen. 
Het werkelijke aantal geregistreerde decks wordt aangeduid door de blauwe lijn, terwijl de gemiddelde waarde en het bereik van het model
respectievelijk door een grijze lijn en een ingekleurd gebied worden weergegeven.

[![Een lineair model past niet bijzonder goed, maar het is een begin](/assets/posts/2021-07-04-Bayesian-sales-analysis/model_1.svg)](/assets/posts/2021-07-04-Bayesian-sales-analysis/model_1.json)

Dit model past niet bijzonder goed: tijdens de eerste 80 weken onderschatten we de verkoop sterk, terwijl we de recentere
verkoop overschatten. De boosdoener is COVID-19. Rond week 70 leidde de pandemie wereldwijd tot beperkingen op sociale bijeenkomsten. 
Veel winkels moesten sluiten, toernooien werden afgelast, grenzen gingen dicht en lockdowns verhinderden dat mensen bij
een vriend thuis gingen spelen. Dat moest wel gevolgen hebben voor het aantal decks dat werd geopend.

Hoewel COVID-19 het belangrijkste volgende element voor het model lijkt, moeten we eerst het eenvoudige lineaire 
model als generatief model implementeren. In plaats van één vergelijking is in een generatief model elke waarde 
gebaseerd op de vorige. We zijn nu iets wijzer en kunnen de initiële mu voor de wekelijkse registraties
instellen op 1,5 (ongeveer 15k decks per week). We weten ook dat decks niet kunnen worden uitgeschreven, dus deze waarde kan nooit
onder nul liggen (met ```pm.Bound()```).

{:.large-code}
```python
len_observed = len(model_data)

with pm.Model() as model_2:
    # priors
    sigma = pm.Exponential("sigma", lam=1.0)  # Sigma for likelihood function

    # We know from the previous analysis there are on average 15 000 decks registered per week
    # this can be the baseline (mu) with a rather large deviation (sigma)
    # as decks cannot be un-registered, this value can never go negative, so we'll put a limit on it preventing that
    BoundNormal_0 = pm.Bound(pm.Normal, lower=0)
    weekly_registrations = BoundNormal_0("weekly_registrations", mu=1.5, sigma=2)

    y0 = tt.zeros(len_observed)
    y0 = tt.set_subtensor(
        y0[0], 15
    )  # there were 150k decks registered the first week, that is the initial value (150 000/10 000)

    outputs, _ = theano.scan(
        fn=lambda t, y, ws: tt.set_subtensor(y[t], ws + y[t - 1]),
        sequences=[tt.arange(1, len_observed)],
        outputs_info=y0,
        non_sequences=weekly_registrations,
        n_steps=len_observed - 1,
    )

    total_registrations = pm.Deterministic("total_registrations", outputs[-1])

    # Likelihood
    likelihood = pm.Normal(
        "y", mu=total_registrations, sigma=sigma, observed=model_data.Total_scaled
    )

    # posterior
    trace_2 = pm.sample(1000, cores=4, chains=4)
```

Deze wijziging maakt het samplen trager terwijl de uitvoer identiek blijft, maar vormt wel een veel betere basis om
op voort te bouwen.

## Het effect van een wereldwijde pandemie toevoegen

We moeten twee onderdelen aan het model toevoegen. Eerst een startpunt voor COVID-19: we weten dat dit rond week 70 lag, maar laten
wat speling toe omdat verschillende landen aanvankelijk verschillende maatregelen namen. Daarnaast definiëren we een nieuwe helling zodra
de pandemie begint. Met ```pm.math.switch()``` kunnen we opgeven dat vóór de start de ene helling wordt gebruikt en daarna
de andere.

{:.large-code}
```python
with pm.Model() as model_3:
    # priors
    sigma = pm.Exponential("sigma", lam=1.0)  # Sigma for likelihood function

    covid_start = pm.DiscreteUniform(
        "covid_start", lower=60, upper=85
    )  # COVID started at different points in different countries lets start around week 70

    # We know from the previous analysis there are on average 15 000 decks registered per week
    # this can be the baseline (mu) with a rather large deviation (sigma)
    # as decks cannot be un-registered, this value can never go negative, so we'll put a limit on it preventing that
    BoundNormal_0 = pm.Bound(pm.Normal, lower=0)
    
    # As the average is 15 000 (1.5 after scaling), and we assume COVID-19 had a negative impact on sales, we'll set the
    # initial value for post-COVID to 1 (10 000 decks registered per week)
    weekly_registrations_covid = BoundNormal_0(
        "weekly_registrations_covid", mu=1, sigma=2
    )
    
    # As the average was affected by COVID, pre-COVID sales were likely better, this is reflected by setting the intial value
    # of this prior to 2
    weekly_registrations_precovid = BoundNormal_0(
        "weekly_registrations_precovid", mu=2, sigma=2
    )

    weekly_registrations = pm.math.switch(
        covid_start >= model_data.Week_nr,
        weekly_registrations_precovid,
        weekly_registrations_covid,
    )

    y0 = tt.zeros(len_observed)
    y0 = tt.set_subtensor(
        y0[0], 15
    )  # there were 150k decks registered the first week, that is the initial value (15 after scaling)

    outputs, _ = theano.scan(
        fn=lambda t, y, ws: tt.set_subtensor(y[t], ws[t] + y[t - 1]),
        sequences=[tt.arange(1, len_observed)],
        outputs_info=y0,
        non_sequences=weekly_registrations,
        n_steps=len_observed - 1,
    )

    total_registrations = pm.Deterministic("total_registrations", outputs[-1])

    # Likelihood
    likelihood = pm.Normal(
        "y", mu=total_registrations, sigma=sigma, observed=model_data.Total_scaled
    )

    # posterior
    trace_3 = pm.sample(1000, cores=10, chains=4)
```

[![De combinatie van twee lineaire modellen, vóór en tijdens COVID, past veel beter](/assets/posts/2021-07-04-Bayesian-sales-analysis/model_3.svg)](/assets/posts/2021-07-04-Bayesian-sales-analysis/model_3.json)

Dit past inderdaad veel beter: de knik in de grafiek door de COVID-19-beperkingen wordt duidelijk door het model opgepikt. Nu
dit op zijn plaats staat, kunnen we meer complexiteit toevoegen. De kleine knikken in de grafiek vallen samen met
de release van nieuwe sets; die nemen we hierna op!

## Het effect van nieuwe releases toevoegen

Om te voorkomen dat kaartspellen verouderen, verschijnen geregeld nieuwe sets. Voor KeyForge duurt een releasecyclus zes tot
acht maanden. Voor de release van een nieuwe set neemt de reclame voor het spel aanzienlijk toe. Bij de daadwerkelijke
release leeft de interesse in het spel doorgaans opnieuw op, waardoor de verkoop stijgt. Dat verklaart de knikjes in de curve: bij
elke nieuwe release neemt het aantal registraties scherp toe, waarna het effect geleidelijk wegebt. 

Om dit te modelleren, nemen we voor elke set een interessefactor op die doorheen de tijd met een onbekende factor afneemt. In de week waarin
een nieuwe set uitkomt, tellen we de interesse voor die set op bij de huidige totale interesse — de piek — en blijven we 
de afname in de volgende weken toepassen. De basisregistratiegraad wordt vermenigvuldigd met 1 + de huidige interesse. (Merk ook op
dat ik hier van model 3 naar 5 spring. Het kostte tijd om dit te implementeren en model 4 zat er grondig naast.)

Je kunt de interesse niet als factor bekijken, maar als een aantal extra registraties bij de release. Om 
dit in het model op te nemen, voegen we het toe met de functie ```pm.Deterministic()```. Zo kun je extra 
berekeningen zonder eigen priors aan het model toevoegen en ze achteraf onderzoeken.

{:.large-code}
```python
with pm.Model() as model_5:
    # priors
    sigma = pm.Exponential("sigma", lam=1.0)  # Sigma for likelihood function

    # COVID started at different points in different countries, it should be around week 70 give or take a week or two
    covid_start = pm.DiscreteUniform("covid_start", lower=68, upper=72)

    # We know from the previous that mu before and during covid should be around 0.8 and 3.0 respectively
    # Sigma is reduced here not to diverge to far from these values
    BoundNormal_0 = pm.Bound(pm.Normal, lower=0)
    weekly_registrations_covid = BoundNormal_0(
        "weekly_registrations_covid", mu=0.8, sigma=0.5
    )
    weekly_registrations_precovid = BoundNormal_0(
        "weekly_registrations_precovid", mu=3, sigma=0.5
    )

    weekly_registrations_base = pm.math.switch(
        covid_start >= model_data.Week_nr,
        weekly_registrations_precovid,
        weekly_registrations_covid,
    )

    # Model extra registrations due to shifting interest (like new sets being released)
    # The interest factor is calculated on a weekly basis
    decay_factor = pm.Exponential("decay_factor", lam=1.0)

    cota_interest = pm.HalfNormal("cota_interest", sigma=2)
    aoa_interest = pm.HalfNormal("aoa_interest", sigma=2)
    wc_interest = pm.HalfNormal("wc_interest", sigma=2)
    mm_interest = pm.HalfNormal("mm_interest", sigma=2)
    dt_interest = pm.HalfNormal("dt_interest", sigma=2)

    # Another way of defining interest is in extra registrations caused (not as a factor)
    cota_surplus = pm.Deterministic(
        "cota_surplus", cota_interest * weekly_registrations_base[0]
    )
    aoa_surplus = pm.Deterministic(
        "aoa_surplus", aoa_interest * weekly_registrations_base[27]
    )
    wc_surplus = pm.Deterministic(
        "wc_surplus", wc_interest * weekly_registrations_base[50]
    )
    mm_surplus = pm.Deterministic(
        "mm_surplus", mm_interest * weekly_registrations_base[85]
    )
    dt_surplus = pm.Deterministic(
        "dt_surplus", dt_interest * weekly_registrations_base[126]
    )

    interest_decayed = [cota_interest]

    for i in range(len_observed - 1):
        new_element = interest_decayed[i] * decay_factor
        if i == 27:
            new_element += aoa_interest
        if i == 50:
            new_element += wc_interest
        if i == 85:
            new_element += mm_interest
        if i == 126:
            new_element += dt_interest
        interest_decayed.append(new_element)

    # there were 150k decks registered the first week, that is the initial value
    y0 = tt.zeros(len_observed)
    y0 = tt.set_subtensor(y0[0], 15)

    outputs, _ = theano.scan(
        fn=lambda t, y, ws, intfac: tt.set_subtensor(
            y[t], (ws[t] * (1 + intfac[t])) + y[t - 1]
        ),
        sequences=[tt.arange(1, len_observed)],
        outputs_info=y0,
        non_sequences=[weekly_registrations_base, interest_decayed],
        n_steps=len_observed - 1,
    )

    total_registrations = pm.Deterministic("total_registrations", outputs[-1])

    # Likelihood
    likelihood = pm.Normal(
        "y", mu=total_registrations, sigma=sigma, observed=model_data.Total_scaled
    )

    # posterior
    trace_5 = pm.sample(1000, cores=10, chains=4)
```
[![Met de interesse in nieuwe sets in het model krijgen we een bijna perfecte fit](/assets/posts/2021-07-04-Bayesian-sales-analysis/model_5.svg)](/assets/posts/2021-07-04-Bayesian-sales-analysis/model_5.json)

Dit is het beste model dat ik met een redelijk aantal parameters op deze gegevens kon fitten, en het model 
dat aan het begin van de post werd getoond. Het is ook interessant om de posteriors te bekijken, want die kunnen verduidelijken
hoe groot de impact van COVID-19 op de basisregistratiegraad is. We krijgen daarnaast een indruk van hoe de verschillende 
sets scoren op interesse of populariteit.

```python
with model_5:
    stats = pd.DataFrame(az.summary(trace_5, round_to=2))

stats.loc[
    [
        "sigma",
        "covid_start",
        "weekly_registrations_covid",
        "weekly_registrations_precovid",
        "cota_interest",
        "aoa_interest",
        "wc_interest",
        "mm_interest",
        "dt_interest",
        "decay_factor",
        "cota_surplus",
        "aoa_surplus",
        "wc_surplus",
        "mm_surplus",
        "dt_surplus",
    ]
]
```

{:.large-table .narrow-rows}
|                               |  mean |   sd | hdi_3% | hdi_97% | mcse_mean | mcse_sd | ess_bulk | ess_tail | r_hat |
|------------------------------:|------:|-----:|-------:|--------:|----------:|--------:|---------:|---------:|------:|
|                         sigma |  1.17 | 0.07 |   1.04 |    1.30 |      0.00 |    0.00 |   354.50 |  1420.02 |  1.02 |
|                   covid_start | 68.00 | 0.00 |  68.00 |   68.00 |      0.00 |    0.00 |  4000.00 |  4000.00 |   NaN |
|    weekly_registrations_covid |  0.62 | 0.02 |   0.59 |    0.66 |      0.00 |    0.00 |   748.58 |   425.34 |  1.00 |
| weekly_registrations_precovid |  1.55 | 0.06 |   1.44 |    1.66 |      0.00 |    0.00 |   477.68 |   859.12 |  1.02 |
|                 cota_interest |  4.10 | 0.19 |   3.76 |    4.48 |      0.01 |    0.00 |  1135.77 |  1891.67 |  1.00 |
|                  aoa_interest |  1.69 | 0.16 |   1.42 |    2.01 |      0.01 |    0.00 |   902.16 |  1161.44 |  1.01 |
|                   wc_interest |  0.94 | 0.14 |   0.69 |    1.20 |      0.00 |    0.00 |   809.41 |   928.24 |  1.01 |
|                   mm_interest |  3.21 | 0.32 |   2.61 |    3.82 |      0.01 |    0.01 |   509.95 |   368.48 |  1.02 |
|                   dt_interest |  3.05 | 0.35 |   2.39 |    3.69 |      0.01 |    0.01 |  1135.77 |  2001.47 |  1.01 |
|                  decay_factor |  0.83 | 0.01 |   0.82 |    0.85 |      0.00 |    0.00 |   606.70 |  1135.31 |  1.02 |
|                  cota_surplus |  6.37 | 0.27 |   5.86 |    6.86 |      0.01 |    0.01 |  1188.87 |  1594.54 |  1.00 |
|                   aoa_surplus |  2.62 | 0.18 |   2.28 |    2.96 |      0.01 |    0.00 |  1161.85 |  1279.62 |  1.00 |
|                    wc_surplus |  1.46 | 0.16 |   1.15 |    1.76 |      0.01 |    0.00 |   911.29 |  1074.73 |  1.01 |
|                    mm_surplus |  1.99 | 0.15 |   1.73 |    2.31 |      0.01 |    0.00 |   536.09 |   919.32 |  1.02 |
|                    dt_surplus |  1.89 | 0.18 |   1.54 |    2.22 |      0.01 |    0.00 |  1315.52 |  2202.98 |  1.01 |

Interesse werd gemodelleerd als een factor waarmee de basisverkoop bij de release van een set werd verhoogd. Zo 
verhoogde Dark Tidings het aantal deckregistraties met 305% bovenop de verwachte basisgraad. Omdat Dark Tidings
tijdens COVID-19 uitkwam, toen die basisgraad laag was, bedroeg het absolute aantal extra registraties voor deze set
in de eerste week 19k.

## Wat als COVID-19 nooit was gebeurd?

Nu we een degelijk model hebben, kunnen we creatief worden en modelleren hoeveel decks er geregistreerd zouden zijn als
de pandemie nooit was gebeurd. Daarvoor moeten we het model licht aanpassen. We definiëren ```covid_start``` als
```pm.Data()```, dat na het fitten van het model kan worden gewijzigd. Ook de trace-functie verandert een beetje om
het samplen met deze vaste parameter te laten werken: ```init="adapt_diag"``` wordt toegevoegd om fouten te vermijden.


In de code hieronder worden alleen de wijzigingen tegenover het vorige model getoond.
```python
with pm.Model() as model_5:
    # ...
    # here we set the start of covid manually (based on previous notebook)
    # this way it can be changed after fitting the model
    covid_start = pm.Data("covid_start", 68)
    
    # ...
    
    # posterior
    trace_5 = pm.sample(1000, cores=10, chains=4, init="adapt_diag")
```

Nadat we het model hebben gefit, kunnen we het gewenste beginpunt van COVID-19 naar een moment in de toekomst verplaatsen. Met
```pm.sample_posterior_predictive()``` krijgen we dan het model te zien zonder het effect van COVID-19.

```python
with model_5:
    pm.set_data({"covid_start": 500})

chart_without_covid = plot_fit_altair(model_5, trace_5, model_data)
chart_without_covid
```

[![Model met en zonder COVID-19](/assets/posts/2021-07-04-Bayesian-sales-analysis/covid_start_data.svg)](/assets/posts/2021-07-04-Bayesian-sales-analysis/covid_start_data.json)

Hoewel dit prima werkt, biedt het weinig flexibiliteit om het model aan te passen. Zo kan de interesse in 
Mass Mutation en Dark Tidings zijn overschat omdat die tijdens de pandemie verschenen. Dat kan beïnvloeden 
hoe en wanneer mensen nieuwe decks kopen. Het zou dus interessant zijn om een ‘pessimistisch’ model te bouwen waarin de 
interesse in MM en DT gelijk is aan die van de minst populaire set vóór de pandemie.

Eén optie is een nieuw model te maken waarin alle priors worden ingesteld op de posteriors uit model_5. Daarna kunnen we de
gewenste waarden wijzigen en ```pm.sample_prior_predictive()``` uitvoeren om te zien hoe het model met de bijgewerkte priors werkt. In
de notebook vind je een optimistische versie met de exacte parameters van model_5 en een pessimistische versie 
waarin de interesse in MM en DT gelijk wordt gesteld aan die in WC. Alleen de laatste wordt hier getoond. Dat vergroot 
de onzekerheid van de voorspellingen, maar biedt veel meer flexibiliteit om met het model te spelen.

**Update 20/08/2021:** In de [GitHub repo] vind je een beter model dat de interesse voor alle sets berekent op basis van de registratiegraad vóór COVID.
Dat levert een veel betere voorspelling op wanneer je met ```pm.Data``` het begin van de
pandemie na het huidige tijdstip plaatst, zoals te zien is in [deze post]({% post_url nl/2021/2021-08-21-COVID_and_KeyForge %}). 
De aanpak hieronder heeft in sommige gevallen nog waarde, dus ik laat hem staan. Weet alleen dat voor
dit geval een betere oplossing bestaat.

{:.large-code}
```python
with pm.Model() as model_7:
    # priors
    sigma = pm.Normal("sigma", mu=1.17, sigma=0.07)  # Sigma for likelihood function

    weekly_registrations = pm.Normal("weekly_registrations", mu=1.55, sigma=0.06)

    # Model extra registrations due to shifting interest (like new sets being released)
    # The interest factor is calculated on a weekly basis
    decay_factor = pm.Normal("decay_factor", mu=0.84, sigma=0.01)

    cota_interest = pm.Normal("cota_interest", mu=4.11, sigma=0.19)
    aoa_interest = pm.Normal("aoa_interest", mu=1.7, sigma=0.16)
    wc_interest = pm.Normal("wc_interest", mu=0.95, sigma=0.13)
    # Maybe people's buying behaviour responds differently to
    # the release of a new set during COVID.
    # Set the two most recent sets to a worst case scenario
    mm_interest = pm.Normal(
        "mm_interest", mu=0.95, sigma=0.13
    )  
    dt_interest = pm.Normal(
        "dt_interest", mu=0.95, sigma=0.13
    )  

    interest_decayed = [cota_interest]

    for i in range(len_observed - 1):
        new_element = interest_decayed[i] * decay_factor
        if i == 27:
            new_element += aoa_interest
        if i == 50:
            new_element += wc_interest
        if i == 85:
            new_element += mm_interest
        if i == 126:
            new_element += dt_interest
        interest_decayed.append(new_element)

    # there were 150k decks registered the first week, that is the initial value
    y0 = tt.zeros(len_observed)
    y0 = tt.set_subtensor(y0[0], 15)

    outputs, _ = theano.scan(
        fn=lambda t, y, intfac: tt.set_subtensor(
            y[t], (weekly_registrations * (1 + intfac[t])) + y[t - 1]
        ),
        sequences=[tt.arange(1, len_observed)],
        outputs_info=y0,
        non_sequences=[interest_decayed],
        n_steps=len_observed - 1,
    )

    total_registrations = pm.Deterministic("total_registrations", outputs[-1])

    # Likelihood
    likelihood = pm.Normal(
        "y", mu=total_registrations, sigma=sigma, observed=model_data.Total_scaled
    )
```

[![Een alternatieve manier om modellen te wijzigen](/assets/posts/2021-07-04-Bayesian-sales-analysis/combined_predictions.svg)](/assets/posts/2021-07-04-Bayesian-sales-analysis/combined_predictions.json)

Zoals je ziet, zijn de bultjes door de release van de nieuwste sets in het pessimistische model veel bescheidener en liggen ze 
in lijn met eerdere releases. Dat kan erop wijzen dat het koopgedrag tijdens COVID-19 anders is, wat ik ook volledig
verwacht.



## Conclusie

Probabilistisch programmeren verschilt enigszins van gewoon programmeren, maar PyMC3 maakt die overstap 
haalbaar. Deze modellen bouwen vergt wel veel meer werk dan een machinelearningmodel fitten, maar daar staan 
voordelen tegenover: de modellen zijn erg eenvoudig te inspecteren, 
we kunnen begrijpen wat elke parameter doet en parameters wijzigen om scenario's te modelleren waarvoor we geen
gegevens hebben. Machinelearningmodellen zijn daarentegen vaak zwarte dozen waarvan de interne werking moeilijk te begrijpen en nog
moeilijker aan te passen is. Bij voorspellingen is dat een enorm voordeel.

Een niet-technische interpretatie van enkele resultaten vind je 
[hier]({% post_url nl/2021/2021-08-21-COVID_and_KeyForge %})! Merk op dat dit uitsluitend over het aantal *geregistreerde* decks gaat.
Ben je geïnteresseerd in het totale aantal *gedrukte* decks, lees dan [deze post]({% post_url nl/2021/2021-09-04-KeyForge_Decks_Printed %}).

## Bronnen

Wil je zelf met PyMC3 aan de slag, dan zijn dit de bronnen die ik heb gebruikt.

  * De [PyMC3 Workshop] van [Thomas Wiecki], waarin ik veel van de hier toegepaste trucs leerde
  * De officiële documentatie van [PyMC3]
  * [Bayesian Analysis with Python]
  * Het [PyMC Developers]-kanaal op YouTube


[Archon Arcana]: https://archonarcana.com/Main_Page
[Anaconda]: https://anaconda.org/
[PyMC3]: https://docs.pymc.io/
[deze GitHub-repository]: https://github.com/4dcu-be/BayesianSalesAnalysis
[GitHub repo]: https://github.com/4dcu-be/BayesianSalesAnalysis
[KeyForge]: https://www.keyforgegame.com/
[PyMC3 Workshop]: https://www.youtube.com/watch?v=ZxR3mw-Znzc
[Thomas Wiecki]: https://twitter.com/twiecki
[Bayesian Analysis with Python]: https://www.packtpub.com/product/bayesian-analysis-with-python-second-edition/9781789341652
[PyMC Developers]: https://www.youtube.com/c/PyMCDevelopers/videos
