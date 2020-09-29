---
layout: post
title:  "Kindle + Python = e-Ink Dashboard (part 2)"
byline: "repurposing an old kindle paperwhite 3"
date:   2020-10-04 12:00:00
author: Sebastian Proost
categories: diy
tags:	python kindle dashboard
cover:  "/assets/posts/2020-09-27-PythonKindleDashboard_1/kindle_pw3.jpg"
thumbnail: "/assets/images/thumbnails/kindle_pw3"
github: "https://github.com/4dcu-be/kual-dashboard"
---

In the [last post] a Kindle Paperwhite 3 was jailbroken, Python 3.8 installed and all boilerplate code was added to 
have a way to start our script and launch it from [KUAL]. Now we can actually dive into the actual Python code that
will turn the device in a proper DashBoard. To do this we'll create a miniature ETL pipeline (Extract - Transform - Load),
that will fetch data from relevant websites (the extract part), combine it into a dictionary (the transform) and 
put all parts in an SVG image (the load). The latter can then be converted into a PNG which we can show on the screen.

So in this post we'll create the last files shown in the file structure for our KUAL Dashboard extension, *run.py* and
*extract.py*. As always, all code for this project can be found on [GitHub](https://github.com/4dcu-be/kual-dashboard).

```text
│   .gitignore
│   README.md
│
└───dashboard
    │   config.xml
    │   menu.json
    │
    ├───bin
    │       extract.py
    │       run.py
    │       start.sh
    │       start_once.sh
    │
    └───cache
```

## Coding the Extract Functions

I have plenty of devices telling me the weather forecast, so I didn't want to do yet another weather dashboard. Matter 
of fact, a lot of the code here is based on a KUAL Extension that does exactly that. Check it out [here](https://github.com/x-magic/kindle-weather-stand-alone)
if you are looking to do a weather dashboard. I'll pick something more specific for me, but it should be relatively 
easy to adapt the code to other websites and API's to make a dashboard tailored to your own interests.

After some thinking I decided to pull data from three websites; [Google Scholar] to grab the number of citations my
publications have received as well as my [H-index], my current [Gwent] rank and score (a competitive online card-game) 
and from TVMaze air dates of upcoming episode for series I like. To avoid making the installation of this extension 
overly complicated, no additional packages will be used, so only the standard library will be used. Unfortunately, 
this means getting websites with [urllib] and regular expressions rather than [requests] and [BeautifulSoup]. Though,
moving some complexity from the installation (jailbreaking a Kindle to get this to run is hard enough already) to the 
code is an acceptable trade-off.

### Grabbing Data from Google Scholar

All functions to grab and parse data from websites is contained in *extract.py*, my [Google Scholar] page is the
easiest to parse so let's start there. 

```python
import ssl
import urllib.request
import re
import json


def get_google_scholar(url):
    ssl_context = ssl._create_unverified_context()
    with urllib.request.urlopen(url, context=ssl_context) as response:
        html = response.read()

    hits = re.findall(r'<td class="gsc_rsb_std">(\d+)</td>', str(html))
    fields = ['citations', 'citations_recent', 'h_index', 'h_index_recent', 'i10_index', 'i10_index_recent']

    return dict(zip(fields, hits))
```

As far as getting and parsing an html page goes, this couldn't be more straightforward. We use urllib to get the 
html data and with a single regular expression can get all fields in the table with the citation statistics. This should
give us six hits on each page and by using the zip and dict function it is possible to quickly merge those hits with the
correct names for the fields.

One odd thing is that the ssl_context needs to be created and added to the request. While the code works fine on
my computer without, it gives an error on the Kindle without this bit included.

### Getting the Gwent Profile Data

While a few simple lines sufficed for [Google Scholar], getting the data from my [Gwent] profile contains a lot more
ugly code. Here the lack of a proper package to parse HTML, like [BeautifulSoup], is really tangible. However, while
not the prettiest code, it get's the job done. It is just a matter of finding the spot in the HTML code where the piece
of information is located and writing up a regular expression to parse it out. 

```python
def get_gwent_data(url):
    ssl_context = ssl._create_unverified_context()
    with urllib.request.urlopen(url, context=ssl_context) as response:
        html = response.read()

    output = {
        'player':   ''.join(re.findall(r'<strong class="l-player-details__name">\\n\s+(.*?)</strong>', str(html))),
        'mmr':      ''.join(re.findall(r'<div class="l-player-details__table-mmr">.*?<strong>(.*?)</strong></div>', str(html))).replace(',',''),
        'position': ''.join(re.findall(r'<div class="l-player-details__table-position">.*?<strong>(.*?)</strong></div>', str(html))).replace(',',''),
        'rank':     ''.join(re.findall(r'<span class="l-player-details__rank"><strong>(.*?)</strong></span>', str(html))),
        'ladder':   ''.join(re.findall(r'<div class="l-player-details__table-ladder" ><span>(.*?)</span></div>', str(html))),
    }

    return output
```

Note that re.findall returns a list of all hits, which should contain one element here. Though rather than extracting
that hit with its index, the join function is used. Due to this little trick, if the [Gwent] website is updated and the
regular expression won't match the code won't yield errors, it will just have an empty strings as values. If the values
no longer appear on the dashboard it is time to revise the code, but the other items will still work as planned.

### TVMaze

[TVMaze] has an API that returns JSON objects, so that is easy to convert to a dict and doesn't need messing around with
regular expressions to parse out parts of HTML. However, here there is an extra complexity that data for each show (which
will be passed to the function as a list of IDs) has to be fetched first. If that contains a link to the upcoming episode
we need to get that endpoint additionally to find the name of the episode and the airdate.

```python
def get_tvmaze_data(ids):
    output = []

    ssl_context = ssl._create_unverified_context()
    for id in ids:
        url = 'http://api.tvmaze.com/shows/%d' % id
        with urllib.request.urlopen(url, context=ssl_context) as response:
            data = json.load(response)
            links = data.get('_links', {})
            if 'nextepisode' in links.keys():
                with urllib.request.urlopen(links['nextepisode']['href'], context=ssl_context) as episode_response:
                    episode_data = json.load(episode_response)
                    output.append(
                        {
                            'name': data.get('name', 'error'),
                            'episode_name': episode_data.get('name', 'error'),
                            'airdate': episode_data.get('airdate', 'error'),
                        }
                    )

    return sorted(output, key=lambda x: x['airdate'])
```

## Catching Errors with a Decorator

As the data comes from the internet a few things can go wrong, the Kindle's Wifi might not come up fast enough, or 
the internet might be down, or one of the websites times out ... and these errors aren't caught yet. I also don't want
the dashboard to display empty information for an hour or more because one website was temporarily unreachable. To over-
come this issue a decorator can be created that will try to run one of the extract functions, if it works write a file
to disk with the output, if it fails load the previously written file and return that.

```python
import json
from functools import wraps
from os.path import join

cache_dir = '/mnt/base-us/extensions/dashboard/cache/'

def failwithcache(cache_file):
    def deco_failwithcache(f):
        @wraps(f)
        def f_failwithcache(*args, **kwargs):
            try:
                output = f(*args, **kwargs)
                with open(join(cache_dir, cache_file), 'w') as fout:
                    json.dump(output, fout)
            except:
                with open(join(cache_dir, cache_file)) as fin:
                    output = json.load(fin)
            return output
        return f_failwithcache
    return deco_failwithcache
```

To get this running we'll need to decorate the extract functions like shown below. The decorator takes one argument, the 
filename to write to (potentially this could be done automatically based on the decorated function's name).

```python
@failwithcache('scholar.json')
def get_google_scholar(url):
    ...

@failwithcache('gwent.json')
def get_gwent_data(url):
    ...
```

## Time to Transform and Load

So now we have to finish *run.py* which will be called by the shell script every hour, run the extract functions,
combine the output and visualize it. Though let's forget about that for a second and just create something that
puts some useful information on the screen. We can do a system call to *eips* which is a system tool available on the
kindle to draw something on the screen or, with the *-c* flag, clear the screen.

```python
# bin/python3
# encoding: utf-8

from datetime import datetime
import os
from extract import get_google_scholar, get_gwent_data, get_tvmaze_data

scholar_url = "http://scholar.google.com/citations?user=4niBmJUAAAAJ&hl=en"
gwent_url = "http://www.playgwent.com/en/profile/sepro"

tvmaze_ids = [6,  # The 100
              79,  # The Goldbergs
              38963,  # The Mandalorian
              ]

if __name__ == "__main__":
    # Load data. printing text here is for debugging only, should be removed later
    os.system('eips -c')

    os.system('eips 15  4 \'Loading Data ...\'')
    os.system('eips 15  6 \'Google Scholar ...\'')
    gs_data = get_google_scholar(scholar_url)
    os.system('eips 15  7 \'Gwent ...\'')
    gwent_data = get_gwent_data(gwent_url)
    os.system('eips 15  8 \'TVMaze ...\'')
    tvmaze_data = get_tvmaze_data(tvmaze_ids)

    # All data is loaded, let's put it on the screen
    os.system('eips -c')
    os.system('eips -c')
    os.system('eips 15  2 \'Google Scholar\'')
    os.system('eips 15  4 \'H-index   : %s\'' % gs_data.get('h_index', 'NA'))
    os.system('eips 15  5 \'Citations : %s\'' % gs_data.get('citations', 'NA'))

    os.system('eips 15  9 \'Gwent (%s)\'' % gwent_data.get('ladder', 'error'))
    os.system('eips 15  11 \'Player    : %s\'' % gwent_data.get('player', 'NA'))
    os.system('eips 15  12 \'MMR       : %s\'' % gwent_data.get('mmr', 'NA'))
    os.system('eips 15  13 \'Position  : %s\'' % gwent_data.get('position', 'NA'))

    os.system('eips 15  17 \'TVMaze\'')
    for line, episode in enumerate(tvmaze_data[:3], start=19):
        os.system('eips 15  %d \'%s: %s %s\'' % (line, episode['name'], episode['episode_name'], episode['airdate']))

    os.system('eips 15  26 \'Last Update  : %s\'' % datetime.now().strftime("%d/%m/%Y, %H:%M:%S"))

```

It works ! See the picture below how it looks on the Kindle. The font is ugly and small, but all information is pulled 
in and shown. I left it running overnight a couple days to catch errors (this is how I found out errors fetching data
needed to be handled and that the cache can not be written to the Kindle's designated temp folder as it is cleared to 
frequently). So one more thing to do, make everything look nice!






[last post]: {% post_url 2020-09-27-PythonKindleDashboard_1 %}
[KUAL]: https://www.mobileread.com/forums/showthread.php?t=203326
[ETL pipeline]: https://en.wikipedia.org/wiki/Extract,_transform,_load
[Google Scholar]: https://scholar.google.com/citations?user=4niBmJUAAAAJ&hl=en
[H-index]: https://en.wikipedia.org/wiki/H-index
[Gwent]: https://www.playgwent.com/en/profile/sepro
[TVMaze]: https://www.tvmaze.com/
[urllib]: https://docs.python.org/3/howto/urllib2.html
[requests]: https://requests.readthedocs.io/en/master/
[BeautifulSoup]: https://www.crummy.com/software/BeautifulSoup/bs4/doc/
