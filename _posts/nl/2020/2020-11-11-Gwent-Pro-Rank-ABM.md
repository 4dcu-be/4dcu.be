---
layout: post
title:  "De Gwent Pro Ladder bekeken met een agentgebaseerd model (code)"
byline: "een ABM met Mesa en Pandas"
description: "Een agentgebaseerd model in Python bouwen met Mesa en pandas om Gwent-spelers te simuleren en te testen of vaardigheid dan wel wedstrijden grinden de rangschikking op de Pro Ladder bepaalt (code)."
date:   2020-11-11 12:00:00
author: Sebastian Proost
post_id: gwent-pro-rank-abm
categories: programming games
tags:	python numpy gwent mesa abm agent-based-modeling pandas data-science
cover:  "/assets/posts/2020-11-11-Gwent-Pro-Rank-ABM/crowd_header.jpg"
thumbnail: "/assets/images/thumbnails/crowd_header.png"
github: "https://github.com/4dcu-be/GwentAgentBasedModeling"
---

Met de gegevens die we van [Gwent Masters] kunnen ophalen, is het moeilijk om te beoordelen of meer
spelen tot een hogere rang leidt. Op basis van de gegevens alleen is het dus lastig om te bepalen of vaardigheid
dan wel wedstrijden grinden je verder helpt. Met agentgebaseerde modellen, waarin we spelers en hun wedstrijden kunnen
simuleren en hun vaardigheidsniveau beheren, kunnen we dit echter degelijk onderzoeken.

Het grootste probleem met de gegevens die aan het einde van het seizoen worden vrijgegeven, is dat er geen goede manier bestaat om de werkelijke 
vaardigheid van een speler te beoordelen. Je zou het aantal gespeelde wedstrijden en de piek-MMR als maatstaf voor efficiëntie kunnen gebruiken, maar dat is
niet noodzakelijk een goede benadering van vaardigheid. Alle zes facties spelen zou die score negatief beïnvloeden. Hetzelfde geldt voor spelers die
erg goed presteren, maar na het bereiken van een MMR waar ze tevreden mee zijn losser gaan spelen met leuke, minder optimale decks.
Hoewel we dit kunnen verbeteren door spelersprofielen tijdens het seizoen meerdere keren te scrapen, 
blijven er aannames nodig om dat naar een schatting van vaardigheid te vertalen.

Hoewel vaardigheid niet rechtstreeks meetbaar is, kunnen we een populatie spelers met uiteenlopende vaardigheden modelleren die elk
een verschillend aantal wedstrijden spelen tijdens een gesimuleerd seizoen. In dit artikel onderzoeken we of een met de [Mesa]-bibliotheek
geïmplementeerd agentgebaseerd model (ABM) kan inschatten hoeveel grinden je Gwent-rangschikking kan verbeteren, of dat pure vaardigheid
de doorslag geeft.

Dit artikel behandelt de technische details van de implementatie van het model. Wil je meteen naar de resultaten en
conclusies over de *ranked ladder*, ga dan rechtstreeks naar het [volgende artikel].

## De klasse GwentAgent maken

De volledige code voor dit project staat op [GitHub], maar enkele belangrijke onderdelen worden hier uitgelicht. Wanneer je
met [Mesa] werkt, moet je een Agent-klasse definiëren. Die klasse bevat alle parameters die een entiteit in de
simulatie heeft en bepaalt hoe ze zich gedraagt. Onze agenten hebben hier dus twee belangrijke eigenschappen:

  * **ELO-niveau**: dit stelt de vaardigheid van een entiteit aan het begin van het seizoen voor. Voor elke entiteit wordt
  bij de start een [ELO]-niveau gekozen. Dit beoordelingssysteem wordt in het schaken gebruikt om spelers te rangschikken. (Merk op
  dat het MMR-systeem van Gwent in wezen een ELO-score is, waarbij wijzigingen worden berekend met een 
  K-factor van 14.)
  * **Speelfrequentie**: de kans dat een speler bij elke stap van het model speelt. Hoe hoger die is, hoe meer wedstrijden de 
  agent tijdens een gesimuleerd seizoen speelt.

Daarnaast moeten we het aantal gespeelde en gewonnen wedstrijden, de huidige MMR en de
piek-MMR bijhouden. Daarom bevat de klasse ```GwentAgent``` ook velden voor al die eigenschappen. Twee functies
met de decorator ```@property``` berekenen het winstpercentage en de ELO-score met ervaringscorrectie: het basis-
ELO-niveau plus een ervaringsscore op basis van het aantal gespeelde wedstrijden. 

{:.large-code}
```python
from mesa import Agent, Model
from mesa.time import RandomActivation
from mesa.datacollection import DataCollector

import numpy as np
from numpy import random

max_playrate = 20
experience_factor = 20


def win_probability(elo_difference):
    proba = 1 / (1 + 10 ** (-elo_difference / 400))
    return proba


def elo_change(elo_difference, K=14):
    return K * (1 - win_probability(elo_difference))


def pick_elo():
    """
    Generate a random elo value from a distribution that mimicks the distribution
    of chess elo scores on Lichess Blitz.
    """
    return min(
        1200 + (1500 / 14) * np.abs(51 - random.binomial(100, 0.5)), 2700
    ) - random.randint(100)


class GwentAgent(Agent):
    def __init__(self, unique_id, model):
        super().__init__(unique_id, model)
        self.peak_mmr = 2400
        self.current_mmr = 2400
        self.games_played = 0
        self.wins = 0

        self.elo_level = pick_elo()
        self.playrate = random.randint(1, max_playrate)

    @property
    def win_rate(self):
        if self.games_played > 0:
            return (self.wins * 100) / self.games_played
        return None

    @property
    def elo_experience(self):
        """
        Take the ELO increased with an experience score based on the number of 
        games played and the experience factor.
        """
        return self.elo_level + np.sqrt(self.games_played) * experience_factor

    def win(self, other_player):
        mmr_change = elo_change(self.current_mmr - other_player.current_mmr)
        self.current_mmr += mmr_change
        self.peak_mmr = max(self.current_mmr, self.peak_mmr)
        self.games_played += 1
        self.wins += 1

    def loss(self, other_player):
        mmr_change = elo_change(other_player.current_mmr - self.current_mmr)
        self.current_mmr -= mmr_change
        self.games_played += 1

    def find_opponent(self, min_number=20):
        """
        Pick a random other agent to play against. This agent should have a 
        comparable current mmr. So we will grow the mmr range until there 
        are at least
        """
        mmr_range = 10

        while (
            len(
                [
                    a
                    for a in self.model.schedule.agents
                    if a.unique_id != self.unique_id
                    and abs(self.current_mmr - a.current_mmr) <= mmr_range
                ]
            )
            < min_number
        ):
            mmr_range += 7

        possible_opponents = [
            a
            for a in self.model.schedule.agents
            if a.unique_id != self.unique_id
            and abs(self.current_mmr - a.current_mmr) <= mmr_range
        ]

        opponent = random.choice(
            [a for a in possible_opponents],
            1,
            [a.playrate for a in possible_opponents],
        )[0]

        return opponent

    def play_against(self, other_agent):
        # Calculate win probability, check if player won, adjust scores accordingly
        wp = win_probability(self.elo_experience - other_agent.elo_experience)
        rp = random.random()
        won = rp < wp

        if won:
            self.win(other_agent)
            other_agent.loss(self)
        else:
            other_agent.win(self)
            self.loss(other_agent)

    def step(self):
        # Check if this agent will play a round
        rp = random.randint(max_playrate + 1)
        if rp >= self.playrate:
            return

        # Find an opponent
        other_agent = self.find_opponent()

        # Play against opponent and adjust score
        self.play_against(other_agent)
```

Verder zijn nog enkele functies nodig. De functies ```win``` en ```loss``` verwerken de MMR-scores nadat
een entiteit een wedstrijd wint of verliest. De functie ```find_opponent``` bootst het Gwent-wachtrijsysteem na: ze
probeert een actieve speler met een vergelijkbare huidige MMR te vinden. Als er binnen het huidige bereik onvoldoende spelers zijn,
wordt het MMR-bereik vergroot en zoekt ze opnieuw. ```play_against``` simuleert een wedstrijd tussen twee spelers,
waarbij de uitkomst wordt berekend op basis van hun ELO-score en ervaring. Aan de hand van die kans wordt willekeurig een winnaar gekozen en
worden de statistieken van de spelers bijgewerkt. Ten slotte implementeert de verplichte functie ```step``` alles wat een speler 
bij elke simulatiestap doet. Op basis van de ```playrate``` speelt een speler in die ronde al dan niet. Als de 
speler een wedstrijd speelt, wordt een andere agent met een vergelijkbare MMR gezocht. Ze nemen het tegen elkaar op in een wedstrijd waarvan de uitslag 
door hun vaardigheidsniveau en ervaring wordt bepaald.

### De ervaringsfactor

We mogen aannemen dat een speler zijn of haar deck en de huidige meta beter leert kennen naarmate die meer wedstrijden
speelt. Door te leren hoe het deck tegen verschillende populaire decks moet worden gespeeld, stijgt de kans om te winnen.
Om dit in het model op te nemen, gebruiken we ervaring: de vierkantswortel van het aantal gespeelde wedstrijden, vermenigvuldigd
met de ervaringsfactor, die voor alle spelers gelijk is. In deze voorbeelden staat de factor op 20. Iemand die 100 wedstrijden speelde,
krijgt tijdens het spelen dus een ELO-bonus van ```sqrt(10) * 20```. Hoewel deze factor willekeurig werd gekozen, 
is een bonus van 200 ELO een aanzienlijke verbetering en waarschijnlijk groter dan je in werkelijkheid zou verwachten.

## Het GwentModel instellen

Het Mesa-model is hier eenvoudig. We maken *N* agenten, een *scheduler* die bij elke stap alle agenten
in willekeurige volgorde activeert, en een ```DataCollector``` die bij elke stap alle gewenste eigenschappen van alle agenten opslaat, zodat de 
geschiedenis van die eigenschappen tijdens de simulatie wordt bewaard en later kan worden geanalyseerd.

```python
class GwentModel(Model):
    def __init__(self, N):
        self.num_agents = N
        self.schedule = RandomActivation(self)

        for i in range(self.num_agents):
            a = GwentAgent(i, self)
            self.schedule.add(a)

            self.datacollector = DataCollector(
                agent_reporters={
                    "Peak MMR": "peak_mmr",
                    "Current MMR": "current_mmr",
                    "Win Rate": "win_rate",
                    "Games Played": "games_played",
                    "Games Won": "wins",
                    "elo": "elo_level",
                    "elo_xp": "elo_experience",
                }
            )

    def step(self):
        self.datacollector.collect(self)
        self.schedule.step()
```

## Het model uitvoeren

Met enkele regels code maken we een model met 8000 agenten dat 100 stappen doorloopt. De module [tqdm] wordt
gebruikt om een voortgangsbalk en geschatte duur voor onze simulatie weer te geven. Op één core (Ryzen 7 3700X) duurt de volledige 
simulatie 20-30 minuten (tegenstanders binnen het juiste bereik vinden is de traagste stap). Haal dus een koffie
of een snack wanneer je dit start, want het duurt even!

```python
from tqdm import tqdm

model = GwentModel(8000)
for i in tqdm(range(100)):
    model.step()
```

## Gegevens uit het GwentModel halen

Wanneer de simulatie (en die koffie of snack) klaar is, kunnen we gegevens uit het model halen om mee te werken. Dat
kan op twee manieren. Een ervan is de gegevens ophalen uit de ```DataCollector``` van het model. Die bevat de
toestand van alle agenten bij elke stap.

```python
time_df = model.datacollector.get_agent_vars_dataframe()
time_df.to_csv(f"./data/simulation_steps_experience_factor_{experience_factor}.csv")
time_df.head()
```

{:.large-table}
|      |         | Peak MMR | Current MMR | Win Rate | Games Played | Games Won |         elo |      elo_xp |
|-----:|--------:|---------:|------------:|---------:|-------------:|----------:|------------:|------------:|
| Step | AgentID |          |             |          |              |           |             |             |
|    0 |       0 |   2400.0 |      2400.0 |      NaN |            0 |         0 | 1341.285714 | 1341.285714 |
|      |       1 |   2400.0 |      2400.0 |      NaN |            0 |         0 | 1656.714286 | 1656.714286 |
|      |       2 |   2400.0 |      2400.0 |      NaN |            0 |         0 | 1625.571429 | 1625.571429 |
|      |       3 |   2400.0 |      2400.0 |      NaN |            0 |         0 | 1329.285714 | 1329.285714 |
|      |       4 |   2400.0 |      2400.0 |      NaN |            0 |         0 | 1718.714286 | 1718.714286 |

Hoewel dit uitstekend is om het model opnieuw af te spelen, is het overdreven wanneer je alleen
de eindtoestand wilt bekijken (of geen ```DataCollector``` hebt opgenomen). De onderstaande code doorloopt alle agenten, haalt 
bepaalde eigenschappen op en stopt ze in een pandas-dataframe. Spelers worden ook in verschillende groepen verdeeld volgens vaardigheid en het
aantal gespeelde wedstrijden.

```python
df = pd.DataFrame(
    {
        "player": [f"Player {agent.unique_id}" for agent in model.schedule.agents],
        "elo": [agent.elo_level for agent in model.schedule.agents],
        "playrate": [agent.playrate for agent in model.schedule.agents],
        "games played": [agent.games_played for agent in model.schedule.agents],
        "current MMR": [agent.current_mmr for agent in model.schedule.agents],
        "peak MMR": [agent.peak_mmr for agent in model.schedule.agents],
        "win rate": [agent.win_rate for agent in model.schedule.agents],
    }
)
df["rank"] = df["peak MMR"].rank(ascending=False)
df["elo bin"] = pd.cut(df["elo"], list(range(1100, 2800, 200)))
df["games played percentile"] = df["games played"].rank(pct=True)
df["games played bin"] = pd.cut(df["games played percentile"], [0, 0.25, 0.50, 0.75, 1])
df.to_excel(f"./data/final_data_experience_factor_{experience_factor}.xlsx")
df
```

{:.large-table}
|      player |         elo | playrate | games played | current MMR |    peak MMR |  win rate |   rank |      elo bin | games played percentile | games played bin |
|------------:|------------:|---------:|-------------:|------------:|------------:|----------:|-------:|-------------:|------------------------:|-----------------:|
|    Player 1 | 1284.142857 |        4 |           65 | 2344.332458 | 2408.421244 | 43.076923 | 5784.0 | (1100, 1300] |                0.179063 |      (0.0, 0.25] |
|    Player 2 | 1299.142857 |        7 |           71 | 2357.819543 | 2400.000000 | 45.070423 | 7552.0 | (1100, 1300] |                0.243312 |      (0.0, 0.25] |
|   Player 40 | 1238.142857 |        5 |           69 | 2329.815980 | 2406.859099 | 42.028986 | 6435.5 | (1100, 1300] |                0.221438 |      (0.0, 0.25] |
|   Player 49 | 1291.142857 |        4 |           60 | 2363.915782 | 2400.000000 | 45.000000 | 7552.0 | (1100, 1300] |                0.128125 |      (0.0, 0.25] |
|  Player 102 | 1212.142857 |        2 |           48 | 2349.541087 | 2413.726378 | 41.666667 | 5478.0 | (1100, 1300] |                0.028250 |      (0.0, 0.25] |
|         ... |         ... |      ... |          ... |         ... |         ... |       ... |    ... |          ... |                     ... |              ... |
| Player 6289 | 2667.000000 |       18 |          139 | 2585.247562 | 2623.316703 | 59.712230 |   16.0 | (2500, 2700] |                0.957438 |      (0.75, 1.0] |
| Player 7196 | 2547.857143 |       18 |          130 | 2571.713937 | 2578.698543 | 59.230769 |   81.0 | (2500, 2700] |                0.876062 |      (0.75, 1.0] |
| Player 7523 | 2555.857143 |       12 |          120 | 2573.058829 | 2573.058829 | 60.000000 |  100.0 | (2500, 2700] |                0.778188 |      (0.75, 1.0] |
| Player 7604 | 2649.000000 |       17 |          134 | 2626.069166 | 2640.740116 | 61.940299 |    8.0 | (2500, 2700] |                0.915875 |      (0.75, 1.0] |
| Player 7794 | 2605.000000 |       13 |          120 | 2585.842820 | 2599.283118 | 60.833333 |   44.0 | (2500, 2700] |                0.778188 |      (0.75, 1.0] |

## Resultaten

Met een agentgebaseerd model krijgen we dus een heel nette dataset waarin de echte vaardigheid van elke speler en diens uiteindelijke 
plaats op de ladder bekend zijn. De [Mesa]-bibliotheek maakte het verrassend eenvoudig om dit systeem op te zetten. Nu alle gegevens in het
vertrouwde pandas-dataframe staan, kan de eigenlijke analyse beginnen. Die bewaren we echter voor het [volgende artikel]!


[GitHub]: https://github.com/4dcu-be/GwentAgentBasedModeling
[Gwent Masters]: https://masters.playgwent.com/en/
[Mesa]: https://mesa.readthedocs.io/en/stable/#
[ELO]: https://en.wikipedia.org/wiki/Elo_rating_system
[tqdm]: https://github.com/tqdm/tqdm
[volgende artikel]: {% post_url nl/2020/2020-11-11-Gwent-Pro-Rank-ABM_2 %}
