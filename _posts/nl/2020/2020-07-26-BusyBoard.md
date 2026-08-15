---
layout: post
title:  "BusyBoard: geen onderbrekingen meer tijdens vergaderingen"
byline: ""
description: "BusyBoard bouwen, een Python-Flask-webapp met SQLAlchemy, Flask-Admin en Bulma, in een uitdaging van vier uur om huisgenoten te laten weten wanneer je bezig bent."
date:   2020-07-26 12:00:00
author: Sebastian Proost
post_id: busyboard
categories: programming
tags:	python flask sqlalchemy
cover:  "/assets/posts/2020-07-26-BusyBoard/header.jpg"
thumbnail: "/assets/images/thumbnails/busyboard_header.jpg"
github: "https://github.com/4dcu-be/BusyBoard"
---

Sinds het begin van de COVID-19-pandemie is thuiswerken voor mij de norm geworden, en het ziet er niet naar uit dat dit
binnenkort verandert. Omdat thuiswerken hand in hand gaat met onlinevergaderingen, is het handig om
je huisgenoten te kunnen laten weten dat je bezig bent en liever niet wordt gestoord. Er bestaan eenvoudige
oplossingen (bijvoorbeeld een elastiek rond de deurknop ...), maar ik besloot hiervoor een webapp te maken.

![BusyBoard in actie, een eenvoudige webapp op het lokale netwerk die je huisgenoten laat zien dat je bezig bent](/assets/posts/2020-07-26-BusyBoard/busyboard.png)

Bij sollicitatiegesprekken voor technische functies is het blijkbaar gebruikelijk om kandidaten te vragen in
vrij korte tijd een klein stukje software te ontwikkelen. Omdat ik alleen in de academische wereld heb gewerkt, is dit concept nieuw voor mij! Om te testen hoe ik
het tijdens zo'n gesprek zou doen, legde ik mezelf een tijdslimiet van vier uur op (een halve werkdag) en keek ik hoe ver
ik raakte.

## De juiste tools kiezen

Om dit efficiënt te doen, is het essentieel de juiste tools voor de klus te kiezen. Omdat dit een webapp is, ligt [Flask] voor
mij voor de hand: dat is het framework waarmee ik het meest vertrouwd ben. We hebben een database nodig en een manier om gegevens toe te voegen, te wijzigen en te verwijderen,
dus [Flask-SQLAlchemy] en [Flask-Admin] zijn degelijke opties. Verder heb ik een CSS-bibliotheek nodig om de
*front-end* met weinig moeite aanvaardbaar te doen ogen. Voor grotere projecten is [Bootstrap] doorgaans mijn vaste keuze, maar hier
zou dat wat overdreven zijn. [Milligram] is dan weer uitstekend voor kleine projecten. 
Helaas ondersteunt Milligram standaard geen panelen of kaarten, die ik echt nodig had voor de lay-out die ik in
gedachten had. Omdat het behoorlijk wat werk zou zijn om die zelf te implementeren, kwam ik uiteindelijk bij [Bulma] uit.

Tot slot is het handig om met een vooraf opgebouwde codestructuur te beginnen. Je kunt een [cookiecutter]
voor Flask gebruiken om met enkele opdrachten een basisapp te maken. Omdat ik die nog nooit had gebruikt, nam ik wat code uit een 
vorig project, [MemoBoard], dat veel van dezelfde componenten gebruikt.

## Het eerste uur: een basisapp aan de praat krijgen

De code die ik in iets minder dan een uur in elkaar bokste, vind je [hier](https://github.com/4dcu-be/BusyBoard/tree/a3b013da6ae27797864c8e51611cd71a09fd5960/busyboard).
Hij gebruikt de basiscode van MemoBoard en Flask-Admin om gegevens in de database te krijgen en bevat een heel eenvoudige
sjabloon (alleen tekst) die toont wie wel en niet bezig is. Het werkte, maar het was lelijk.

## De volgende twee uur: het er mooi laten uitzien

De lay-out liet veel te wensen over en werd daarom verbeterd met wat CSS in de sjabloon. Met het [Bulma]-CSS-framework
kon ik snel kaarten voor elke gebruiker maken, en na wat bijsturen zag het er prima uit. Met enkele geavanceerdere 
opties van Flask-Admin werd het ook gemakkelijk om de status van gebruikers via het beheerpaneel te wijzigen. In dit stadium besloot ik bovendien 
dat gebruikers een foto moesten kunnen toevoegen. [Flask-Uploads] kan de uploads verwerken en er bestaan opties om
het met Flask-Admin te integreren, zoals [hier](https://web.archive.org/web/20201123223344/https://mrl33h.de/post/30) beschreven. Dit vergde enkele pogingen en
ik verloor behoorlijk wat tijd voordat ik ontdekte dat Flask-Uploads niet compatibel was met de recentste versie van
[Werkzeug]. 

Na ongeveer drie uur werken had ik dus [deze versie](https://github.com/4dcu-be/BusyBoard/tree/7a693a621d7986d6fd74861252ffb8ae18363f67).
De interessante delen van de code worden hieronder uitgelicht.


## Het laatste uur: de afwerking

Een laatste functie die ik echt wilde, was tonen wanneer iemands status werd bijgewerkt. Een elegante oplossing is inhaken op een
SQLAlchemy-event dat afgaat voordat een entiteit wordt bijgewerkt. Zo kun je het veld met de laatste wijziging aanpassen vlak voordat
de gegevens in de database worden gewijzigd. Dat kan met slechts enkele regels code en garandeert dat
elke wijziging aan een gebruiker via SQLAlchemy ook het veld bijwerkt. Om het tijdsverschil tussen het huidige tijdstip en
de laatste wijziging in een menselijk leesbaar formaat weer te geven, is de [Arrow]-bibliotheek fantastisch en eenvoudig te gebruiken.

Tot slot besteedde ik enkele minuten aan documentatie. Omdat dit ongeveer de meest traditionele Flask-app is die je kunt bedenken, kon ik 
voor veel zaken verwijzen naar de officiële documentatie.

## De code

Wil je zien hoe dit project evolueerde, bekijk dan de commitgeschiedenis in de [GitHub-repository](https://github.com/4dcu-be/BusyBoard).

### models.py

Het databasemodel bevat slechts één tabel voor gebruikers en enkele eigenschappen voor de samenwerking met Flask-Uploads
en Arrow. Het leuke deel is de functie **on_change** en de laatste regel, die ze aan het 
**before_update**-event van SQLAlchemy koppelt. Dankzij dit kleine stukje code wordt telkens wanneer een item verandert ook het veld last_update
automatisch bijgewerkt.

```python
from busyboard import db, images
from datetime import datetime
import arrow


class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Text)
    busy = db.Column(db.Boolean)
    busy_with = db.Column(db.Text)
    can_be_disturbed = db.Column(db.Boolean)
    notes = db.Column(db.Text)
    path = db.Column(db.Unicode(128))
    last_change = db.Column(db.DateTime, default=datetime.utcnow)

    @property
    def url(self):
        if self.path is None:
            return
        return images.url(self.path)

    @property
    def filepath(self):
        if self.path is None:
            return
        return images.path(self.path)

    @property
    def last_changed(self):
        age_arrow = arrow.get(self.last_change)
        return age_arrow.humanize()

    @staticmethod
    def on_change(mapper, connection, target):
        target.last_change = datetime.utcnow()


db.event.listen(User, 'before_update', User.on_change)
```

### admin.py

De allereerste versie gebruikte gewoon de standaard-ModelView van Flask-Admin. Dat is uitstekend om te beginnen en vereist
vrijwel geen code om een CRUD-interface voor een tabel te krijgen. Voor meer verfijnde controle is wat extra werk 
nodig.

**column_editable_list** is bijvoorbeeld handig om in te stellen, omdat records daarmee rechtstreeks vanuit de overzichtspagina kunnen worden bewerkt. 
**CustomIndexView** wordt hier gedefinieerd om de knop *Home* in het beheerpaneel te verbergen (die geen doel dient) en 
de link achter de naam te vervangen door een link naar de hoofdapp (zodat je na een wijziging gemakkelijk naar de app kunt terugkeren)
. 


![Beheerinterface: met enkele kleine aanpassingen is ze veel gebruiksvriendelijker](/assets/posts/2020-07-26-BusyBoard/admin_interface.png)


De functie _list_thumbnail voegt een miniatuurvoorbeeld toe zodra een afbeelding is geüpload. In de klasse staat ook extra code om
dit aan het model te koppelen. ImageUploadField wordt hier toegevoegd zodat gebruikers een afbeelding kunnen uploaden en het
pad in één beweging naar het model kunnen schrijven, zonder dat ze zelf met het pad kunnen knoeien.

```python
from flask import redirect, url_for
from flask_admin.contrib.sqla import ModelView
from busyboard import form
from jinja2 import Markup
import os
import uuid
from werkzeug import secure_filename
from flask_admin import expose, AdminIndexView


def _list_thumbnail(view, context, model, name):
    if not model.filename:
        return ''

    return Markup(
        '<img src="{model.url}" style="width: 150px;">'.format(model=model)
    )


class UserAdminView(ModelView):
    form_columns = ('name', 'busy', 'busy_with', 'can_be_disturbed', 'notes', 'path')
    form_excluded_columns = ('last_updated')
    column_editable_list = ('name', 'busy', 'busy_with', 'can_be_disturbed', 'notes')
    form_create_rules = ('name', 'busy', 'busy_with', 'can_be_disturbed', 'notes', 'path')
    form_edit_rules = ('name', 'busy', 'busy_with', 'can_be_disturbed', 'notes', 'path')

    can_create = True

    column_formatters = {
        'image': _list_thumbnail
    }

    form_extra_fields = {
        'path': form.ImageUploadField(
            'Image',
            base_path='busyboard/static/images',
            url_relative_path='images/',
        )
    }


class CustomIndexView(AdminIndexView):
    def is_visible(self):
        # This view won't appear in the menu structure
        return False

    @expose('/')
    def index(self):
        return redirect(url_for('main_route'))
```

### __init__.py

Hier staat alle code om de BusyBoard-app op te zetten. Er is niets echt verrassends, misschien met uitzondering van het gedeelte `createdb`.
Dit voegt een opdrachtregeloptie toe waarmee je de database aanmaakt via `flask createdb`.

```python
import os

from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy
from flask_admin import Admin, form
from busyboard.admin import UserAdminView, CustomIndexView
from flask_uploads import UploadSet, IMAGES, configure_uploads, patch_request_class

db = SQLAlchemy()

images = UploadSet('images', IMAGES)


def create_app(config):
    # Set up app, database and login manager before importing models and controllers
    # Important for db_create script

    app = Flask(__name__)
    app.config.from_object(config)

    db.app = app
    db.init_app(app)

    configure_uploads(app, (images))
    patch_request_class(app, 16 * 1024 * 1024)

    from busyboard.models import User

    admin = Admin(app, name='BusyBoard', template_mode='bootstrap3', index_view=CustomIndexView())
    admin.add_view(UserAdminView(User, db.session, endpoint='users'))

    @app.route('/')
    def main_route():
        users = User.query.all()
        return render_template('index.html', users=users)

    @app.cli.command()
    def createdb():
        """
        function to create the initial database and migration information
        """
        SQLALCHEMY_DATABASE_URI = app.config['SQLALCHEMY_DATABASE_URI']

        if SQLALCHEMY_DATABASE_URI.startswith('sqlite:///'):
            path = os.path.dirname(os.path.realpath(SQLALCHEMY_DATABASE_URI.replace('sqlite:///', '')))
            if not os.path.exists(path):
                os.makedirs(path)

        db.create_all(app=app)

    return app
``` 

## Conclusie

In ongeveer vier uur kon ik een grappige kleine app maken die aan al mijn eisen voldeed. Dit toont echt
hoeveel je met Python en zijn ecosysteem kunt bereiken met heel weinig tijd en code. Het was ook interessant
om te simuleren hoe zo'n sollicitatiegesprek zou verlopen. Als het om een echte situatie ging, zou ik echter meer tijd hebben besteed
aan tests in plaats van afbeeldingen van gebruikers.

[Flask]: https://flask.palletsprojects.com/
[Flask-SQLAlchemy]: https://flask-sqlalchemy.palletsprojects.com/
[Flask-Admin]: https://flask-admin.readthedocs.io/
[Bootstrap]: https://getbootstrap.com/
[Milligram]: https://milligram.io/
[Bulma]: https://bulma.io/
[Cookiecutter]: https://github.com/cookiecutter-flask/cookiecutter-flask
[MemoBoard]: https://github.com/sepro/MemoBoard
[Flask-Uploads]: https://pythonhosted.org/Flask-Uploads/
[Werkzeug]: https://werkzeug.palletsprojects.com/
[Arrow]: https://arrow.readthedocs.io/
