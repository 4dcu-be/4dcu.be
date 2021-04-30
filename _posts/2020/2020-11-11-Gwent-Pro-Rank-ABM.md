---
layout: post
title:  "An Agent Based Model to look at Gwent Pro Ladder (code)"
byline: "ABM using Mesa and Pandas"
date:   2020-11-11 12:00:00
author: Sebastian Proost
categories: programming games
tags:	python numpy gwent mesa abm agent-based-modeling pandas data-science
cover:  "/assets/posts/2020-11-11-Gwent-Pro-Rank-ABM/crowd_header.jpg"
thumbnail: "/assets/images/thumbnails/crowd_header.png"
github: "https://github.com/4dcu-be/GwentAgentBasedModeling"
---

In an article I contributed to [Team Bandit Gang]'s website, data is shown about the number of games Pro Ranked players
play at different ranks. Tough with the data that can be pulled from [Gwent Masters] assessing whether or not playing
more will result in a higher ranking is difficult. So answering the question posed in the article, whether it is skill
vs grinding games that will help you further, no definitive conclusions could be drawn. 

The main issue with the data released at the end of the season is that there is no good way to judge a player's 
actual skill. You could use the number of games played and peak MMR as a metric for efficiency, but that isn't
necessarily a good proxy for skill. Playing all six factions would affect that score negatively, as well as players that
have a very good performance but decide to play more casually with fun, less optimal, decks after achieving an MMR
score they are happy with. While this could be improved by scraping players' profiles several times throughout the 
season, assumptions would still need to be made how to translate this into an approximation for skill.

While skill can't be directly measured, we can model a population of players with different skill that all play
a different number of games during a simulated season. In this post we'll explore if an Agent Based Model (ABM), implemented
using the [Mesa] library, can assess how much grinding can improve your ranking while playing Gwent or if pure skill
prevails.

This post is about the technical details how to implement the model. If you want to jump directly into the results and
conclusions about ranked ladder, skip right ahead to the [next post] where that will be covered.

## Creating the GwentAgent Class

The full code for this project is available on [GitHub], though some of the important part are highlighted here. When
working with [Mesa] an Agent class needs to be defined. This class should contain all parameters an entity in the
simulation would have and how that entity should behave. So here our agents will have two important traits :

  * **ELO level** : This represents an entities proficiency at the game at the beginning of the season. Here an
  [ELO] level is selected at the beginning for each entity. This is a rating system used in Chess to rank players. (Note
  that the MMR system included in Gwent is essentially an ELO rating, where changes are calculated with a 
  K-factor of 14.)
  * **Playrate** : The chance a player will play at each step of the model, the higher this is, the more games that 
  agent will play through a simulated season.

On top of that we'll need to keep track of the number of games played, the number of games won, the current MMR and the
peak MMR. So for all those properties fields are included in the ```GwentAgent``` class as well. With two functions
decorated with ```@property``` to calculate the win rate and the ELO score with experience correction, which is the base
ELO level + an experience score based on the number of games played. 

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

Furthermore, there are a few functions required, the ```win``` and ```loss``` functions to handle the MMR scores after
an entity won or lost a game. ```find_opponent``` this is a function to mimic the queuing system in Gwent, where it will
try to find an active player with a similar current MMR, if not enough players can be found in the current range it
will increase the MMR range it is looking in and search again. ```play_against``` simulates a game played by two players,
the outcome is calculated by their ELO score and experience. Based on that probability the victor is picked randomly and
the players' stats are updated accordingly. Finally, the required ```step``` function implements everything a player 
does at each step of the simulation. Here, based on the ```playrate```, a player will play or sit this round out. If the 
player plays a game, another agent with a similar MMR will be found and they will face off in a game where the outcome 
is determined by their skill level and experience.

### The Experience Factor

It is reasonable to assume that as a player plays more games his/her familiarity with the deck and the current meta will
increase. As they learn how to play their deck against different popular decks their ability to win should become higher.
To include this in the model the experience is included which is the square root of the number of games played multiplied
with the experience factor which is the same for all players. In the examples here the factor is set to 20 which means
that someone that played 100 games has an ```sqrt(10) * 20``` ELO bonus when playing. While this factor was set 
arbitrarily, a 200 ELO bonus is a significant improvement and likely higher than you would expect in reality.

## Setting up the GwentModel

The Mesa model here is simple, we create a number of *N* agents, a scheduler that will activate all the agents each step
in random order and a ```DataCollector``` that will store all desired properties, for all agents each step so the 
history of those properties during the simulation can be stored and analysed later on.

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

## Running the Model

With a few lines of code we can create a model with 8000 agents that will play for 100 steps. Here the [tqdm] module is
used to create a progress bar for our simulation and estimated time. On a single core (Ryzen 7 3700X) it takes 20-30 
minutes to go through the entire simulation (finding opponents in the correct range being the slowest step). So if you
start this, grab a coffee or a snack, it will take some time !

```python
from tqdm import tqdm

model = GwentModel(8000)
for i in tqdm(range(100)):
    model.step()
```

## Getting Data from the GwentModel

After the simulation (and that coffee or snack) is finished, we can extract data from the model to work with. There
are two ways to do this, one is to grab data from the ```DataCollector``` included in the model. Which contains the
state of all agents at all steps.

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

While this is great to replay the model, it is overkill when you just want to
examine the final state (or didn't include the ```DataCollector```). The code below will loop over all agents, grab 
certain properties and put them in a pandas dataframe. It will also put players in different bins based on skill and the
number of games played.

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

## Results

So using an Agent Based Model a very clean dataset, where the actual skill of each player is known and their final 
place on ladder. The [Mesa] library made it surprisingly easy to set up this system. With all data now included in the
familiar pandas dataframe the actual analysis can begin. This however is reserved for the [next post]!


[Team Bandit Gang]: https://teambanditgang.com/climbing-pro-ladder-grind-vs-skill/
[GitHub]: https://github.com/4dcu-be/GwentAgentBasedModeling
[Gwent Masters]: https://masters.playgwent.com/en/
[Mesa]: https://mesa.readthedocs.io/en/stable/#
[ELO]: https://en.wikipedia.org/wiki/Elo_rating_system
[tqdm]: https://github.com/tqdm/tqdm
[next post]: {% post_url 2020/2020-11-11-Gwent-Pro-Rank-ABM_2 %}
