---
layout: post
title: "Claude Design om twee projecten op te frissen"
byline: "... kan AI nu ook webdesign?"
description: "Praktijktest van Anthropics Claude Design: met AI een Svelte-app en een cv-site herontwerpen vanaf schermafbeeldingen, en de mockups vervolgens uitwerken met Claude Code."
date: 2026-04-27 08:00:00
post_id: claude-design
categories: ai programming
tags: claude-code claude-design javascript web-development eleventy svelte
cover: "/assets/posts/2026-04-27-claude-design/claude_design.jpg"
thumbnail: "/assets/images/thumbnails/claude_design.jpg"
author: Sebastian Proost
---

Design is altijd mijn achilleshiel geweest. Meestal heb ik een vrij duidelijk beeld van wat ik wil, maar bij het omzetten daarvan in een consistente interface loopt het mis. Voor de vorige herwerking van mijn cv-site, in 2024, heb ik uiteindelijk een designer ingehuurd via [Fiverr](https://www.fiverr.com/) om weer vooruit te raken. Toen Anthropic [Claude Design](https://claude.ai/) uitbracht, een webtool die schermafbeeldingen en Figma-bestanden omzet in bewerkbare prototypes, was ik dan ook oprecht benieuwd of AI nu die kloof kan dichten.

Om het grondig te testen, gebruikte ik het om twee projecten te herontwerpen: een kleine Svelte-app die ik als testomgeving gebruik, en de cv-site die ik net vermeldde.

![De hoofdinterface van Claude Design](/assets/posts/2026-04-27-claude-design/claude_design_main.png){:.medium-image}

De interface zelf is eenvoudig: schermafbeeldingen uploaden, een prompt schrijven en itereren door opmerkingen bij specifieke elementen te plaatsen of rechtstreeks op de lay-out te tekenen. Het kan wireframes met weinig detail opleveren of gedetailleerde mockups die klaar zijn voor de browser en zelfs interactief zijn. Wijzigingen worden meteen ter plaatse toegepast, waardoor het veel meer aanvoelt als een live designtool dan als een chatvenster met een voorbeeldpaneel.

## Een Svelte-webinterface moderniseren

Al een tijdje werk ik aan een kleine reeks tools om videogamerecords bij te houden: een Python-package dat spelgegevens valideert met Pydantic en een CLI bevat om die JSON-records te beheren, een frontend op basis van [Svelte](https://svelte.dev/) die de data omzet in een statische site, en een aparte repo met mijn eigen data. Dit project noemde ik MiScore. Het dient meteen ook als speeltuin om te experimenteren met Pydantic, Click, Svelte en alles wat ik verder nog wil uitproberen. De huidige versie van mijn site staat op [sebastian.proost.science/MiScore-site/](https://sebastian.proost.science/MiScore-site/).

Het oorspronkelijke design kwam tot stand met Claude Code, en ik was er redelijk tevreden over. Maar na verloop van tijd merkte ik dat het model steeds op dezelfde visuele patronen terugviel. Wat fris begon, kreeg stilaan de uitstraling van de generieke "vibe-coded" lay-out die je overal ziet. Een mooi excuus voor een redesign.

Ik maakte schermafbeeldingen van de bestaande pagina's om de structuur en de inhoud vast te leggen, uploadde die naar Claude Design met een korte prompt waarin ik MiScore beschreef, en na een paar verduidelijkende vragen over stijl en kleuren rolde er een eerste gedetailleerd prototype uit.

<style>
.post-content .gallery-3-col p a.lightgallery-link {
  aspect-ratio: 1744 / 1071;
  border: 0;
  background-color: transparent;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  position: relative;
}
.post-content .gallery-3-col p a.lightgallery-link img {
  position: absolute;
  top: 0;
  left: 0;
  transform: none;
  width: 100%;
  height: 100%;
  min-width: 0;
  min-height: 0;
  margin: 0;
  object-fit: cover;
  object-position: top center;
  -webkit-mask-image: linear-gradient(to bottom, #000 65%, transparent 100%);
          mask-image: linear-gradient(to bottom, #000 65%, transparent 100%);
}
.post-content .gallery-3-col p a.lightgallery-link:hover img {
  transform: none;
}
</style>

<div class="gallery-3-col" markdown="1">
![De hoofdinterface van MiScore](/assets/posts/2026-04-27-claude-design/miscore_site_main.png)
![Recente records in MiScore](/assets/posts/2026-04-27-claude-design/miscore_site_recent.png)
![De recordspagina van MiScore](/assets/posts/2026-04-27-claude-design/miscore_site_records.png)
</div>

Ik vroeg om een retrogame-look: donker thema, groene accenten, subtiele CRT- en neontoetsen. De eerste poging zat er dicht bij, maar een paar kleuren voelden verkeerd aan en het geheel oogde wat statisch. De opmerkingstools waren hier echt nuttig: je selecteert een specifiek element en zegt wat er moet veranderen, in plaats van te proberen dat in een prompt te omschrijven. Na een paar iteraties had ik de sfeer die ik wilde, met een subtiele achtergrondanimatie en een flikkerende neontitel die alles samenbrengt.

![Het MiScore-prototype van Claude Design](/assets/posts/2026-04-27-claude-design/claude_design_prototype.png){:.medium-image}

Voor de overdracht maakte Claude Design een zipbestand met een op zichzelf staand HTML-prototype en een markdownbestand met implementatienotities voor Claude Code. Ik plaatste dat in de MiScore-site-repo in een `redesign`-map, opende Claude Code met Opus 4.7 en vroeg om de nieuwe lay-out te integreren in het bestaande Svelte-project, volgens de Svelte-conventies in plaats van het prototype letterlijk over te nemen. De structurele wijzigingen werden netjes afgehandeld, de reactieve mogelijkheden van Svelte werden gebruikt waar dat zinvol was, en het resultaat had geen enkele manuele correctie nodig. Ik heb te weinig ervaring met Svelte om elke regel te controleren en de algemene kwaliteit te beoordelen, maar de code was leesbaar en onderhoudbaar, en dat is wat voor mij telt.

De volledige herwerking kostte één avond, en ik liep noch bij Claude Design noch bij Claude Code tegen de gebruikslimieten van het Pro-abonnement aan.

## Mijn cv bijwerken

Wil je weten wat ik professioneel zoal uitspook, dan vind je mijn cv op [sebastian.proost.science](https://sebastian.proost.science). Ik houd het redelijk actueel, vooral door nieuwe inhoud toe te voegen, en af en toe kijk ik het design opnieuw na. Zoals gezegd werd de herwerking van 2024 deels door een Fiverr-designer gedaan, wat werkte, maar nooit helemaal consistent aanvoelde.

<div class="gallery-3-col" markdown="1">
![De hoofdinterface van het cv](/assets/posts/2026-04-27-claude-design/cv_main.png)
![Publicaties op het cv](/assets/posts/2026-04-27-claude-design/cv_publications.png)
![Media op het cv](/assets/posts/2026-04-27-claude-design/cv_media.png)
</div>

Deze keer uploadde ik schermafbeeldingen naar Claude Design, vroeg ik om een opfrissing, beantwoordde ik een paar vragen over kleuren en stijl, en genereerde het een prototype in petrol en cyaan met veel witruimte.

Het resultaat was strak, maar de hero-banner oogde vlak. Ik vroeg om een animatie op basis van JavaScript: een dynamische netwerkgrafiek waarin nodes bewegen en verbindingen leggen op basis van eenvoudige fysica. Het werkte meteen, alleen dreven de nodes steeds samen tot een compacte cluster in het midden. Een periodieke "explosie" die ze naar buiten duwde, loste dat op en maakte het geheel levendiger. Onder de motorkap is het een klein force-directed systeem op een 2D-canvas: veren, afstoting, demping en om de paar seconden een duwtje om alles organisch te houden. Hieronder zie je het in actie.

<div style="width: 100%; height: 320px; --accent-rgb: 179 57 57;">
  <canvas id="demo-network" style="width: 100%; height: 100%; display: block;"></canvas>
</div>

Na een paar kleinere aanpassingen via opmerkingen genereerde ik de overdracht en zette ik die in de repo van het project.

![De nieuwe hoofdpagina van het cv](/assets/posts/2026-04-27-claude-design/cv_new_main.png)

Anders dan MiScore was deze site gebouwd met [Gatsby](https://www.gatsbyjs.com/), en er had zich behoorlijk wat technische schuld opgestapeld: verouderde dependencies, trage builds en een over het algemeen onaangename developer experience. Mijn plan was om het redesign te integreren in de bestaande opzet, maar Claude Code (Opus 4.7) slaagde er niet in om een werkende build te produceren, ook al ging daar een volledige sessie aan tokens in op.

Dat bleek een zegen in vermomming. Gatsby was eigenlijk geen vereiste meer; het was gewoon de technologie die ik de vorige keer had gekozen. De enige echte randvoorwaarde was dat de site statisch moest blijven en makkelijk op GitHub Pages gehost moest kunnen worden. Dus deed ik een stap terug, bekeek ik Astro, Eleventy en Hugo, en koos ik voor [Eleventy](https://www.11ty.dev/) omwille van de eenvoud en de manier waarop het met YAML-data omgaat.

Ik begon opnieuw: ik maakte een nieuwe repo, zette de inhoud over (publicaties, werkervaring en meer, allemaal opgeslagen als YAML), voegde de designoverdracht toe en zette een devcontainer op met VS Code en Docker. Claude Code maakte in enkele minuten een werkende Eleventy-site van het prototype. De lay-out kwam overeen met het design, de interactieve onderdelen werden in vanilla JavaScript geïmplementeerd en de YAML-data werd netjes geïntegreerd.

Er bleven een paar hiaten over. Navigeren zorgde voor volledige paginaherlaadbeurten, terwijl de Gatsby-versie aanvoelde als een single-page app. Ik vroeg Claude Code om client-side navigatie toe te voegen, wat met verrassend weinig code lukte. Daardoor werkten een paar dingen niet meer, zoals filters en "toon meer"-knoppen die na navigatie opnieuw geïnitialiseerd moesten worden. Die waren makkelijk te herstellen zodra ik de oorzaak doorhad. Een paar aanpassingen voor responsiviteit en de mobiele lay-out maakten het af.

Het geheel kostte minder dan een dag. De mislukte Gatsby-integratie slokte de voormiddag op; de heropbouw in Eleventy, de aanpassingen en de deployment pasten in de namiddag. Ik hield er een beter design **en** een eenvoudigere codebase aan over, iets wat zelden samengaat in eenzelfde redesign.

## Conclusie

Een visuele interface waarin je een UI kunt bouwen en wijzigingen kunt sturen door ergens naar te wijzen en in gewone taal te beschrijven wat je wilt, is een echte stap vooruit. Ik was al blij met wat Claude Code kon, maar dit voegt een laag toe waardoor itereren meer aanvoelt als samenwerken met een designer dan als engineering. Ideeën kunnen sneller worden getest, en dat verandert hoe ik designbeslissingen neem. Je kunt snel dingen uitproberen die anders de moeite niet waard zouden zijn.

Waar ik niet zeker over ben, is diversiteit. In deze twee projecten was het resultaat prima, beter dan wat ik zelf zou maken. Maar naarmate meer mensen deze tools gebruiken, vraag ik me af of we straks overal dezelfde esthetiek zullen opmerken, zoals dat nu al met "vibe-coded" lay-outs gebeurt. Iets om in het oog te houden.

Er is ook een ongemakkelijkere verschuiving. In 2024 huurde ik een designer in om deze site naar wens te maken. Deze keer hoefde dat niet, en ik denk niet dat het voortaan nog nodig zal zijn voor kleine of middelgrote persoonlijke projecten. Dat geeft mij meer slagkracht, maar het haalt ook werk weg bij mensen die die creatieve input vroeger als dienst aanboden.

Deze workflow zal ik zeker blijven gebruiken. Het is de ideale manier om snel van idee naar prototype te gaan, ook als je zelf wat minder aanleg hebt voor grafisch design.

<script>
(function () {
  const canvas = document.getElementById('demo-network');
  if (!canvas) return;

  const ctx = canvas.getContext('2d');

  const N = 70;
  const LINK = 160;
  const SPRING = 0.000018;
  const DAMP = 0.992;
  const REPULSE = 55;
  const REPULSE_FORCE = 0.028;
  const LONG_REPULSE = 220;
  const LONG_F = 0.0000028;
  const CENTER_PULL = 0.0000022;
  const RANDOM_WALK = 0.022;
  const KICK_PERIOD = 80;
  const KICK_MAG = 0.9;
  const MAX_SPEED = 0.9;
  const MAX_SPEED_EXPLODE = 8;
  const EXPLOSION_INTERVAL_MS = 15000;
  const EXPLOSION_DURATION_MS = 1200;

  const accentRgbVar = getComputedStyle(canvas)
    .getPropertyValue('--accent-rgb')
    .trim() || '0 135 140';
  const [cr, cg, cb] = accentRgbVar.split(/\s+|,/).map(Number);

  let nodes = [];
  let frameCount = 0;
  let lastExplosion = performance.now();
  let exploding = false;
  let animId = null;

  function resize() {
    canvas.width = canvas.offsetWidth;
    canvas.height = canvas.offsetHeight;
    if (nodes.length === 0) {
      nodes = Array.from({ length: N }, () => ({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        vx: (Math.random() - 0.5) * 0.4,
        vy: (Math.random() - 0.5) * 0.4,
        r: Math.random() * 1.8 + 1.6,
      }));
    }
  }

  function triggerExplosion() {
    const cx = canvas.width / 2;
    const cy = canvas.height / 2;
    exploding = true;
    for (const n of nodes) {
      const dx = n.x - cx;
      const dy = n.y - cy;
      const dist = Math.hypot(dx, dy) || 1;
      const mag = 5.5 + Math.random() * 3.5;
      n.vx += (dx / dist) * mag;
      n.vy += (dy / dist) * mag;
    }
    setTimeout(() => { exploding = false; }, EXPLOSION_DURATION_MS);
  }

  function tick() {
    frameCount++;
    const now = performance.now();
    if (now - lastExplosion > EXPLOSION_INTERVAL_MS) {
      lastExplosion = now;
      triggerExplosion();
    }

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    for (let i = 0; i < nodes.length; i++) {
      const a = nodes[i];

      for (let j = i + 1; j < nodes.length; j++) {
        const b = nodes[j];
        const dx = b.x - a.x;
        const dy = b.y - a.y;
        const dist = Math.hypot(dx, dy) || 0.01;
        const nx = dx / dist;
        const ny = dy / dist;

        if (dist < LINK) {
          const force = SPRING * (dist - LINK * 0.52);
          a.vx += nx * force; a.vy += ny * force;
          b.vx -= nx * force; b.vy -= ny * force;
          const alpha = (1 - dist / LINK) * 0.22;
          ctx.beginPath();
          ctx.moveTo(a.x, a.y);
          ctx.lineTo(b.x, b.y);
          ctx.strokeStyle = `rgba(${cr},${cg},${cb},${alpha})`;
          ctx.lineWidth = 0.8;
          ctx.stroke();
        }

        if (dist < REPULSE) {
          const push = (REPULSE_FORCE * (1 - dist / REPULSE)) / (dist + 1);
          a.vx -= nx * push; a.vy -= ny * push;
          b.vx += nx * push; b.vy += ny * push;
        }

        if (dist < LONG_REPULSE) {
          const push2 = LONG_F * (LONG_REPULSE - dist);
          a.vx -= nx * push2; a.vy -= ny * push2;
          b.vx += nx * push2; b.vy += ny * push2;
        }
      }

      a.vx += (canvas.width / 2 - a.x) * CENTER_PULL;
      a.vy += (canvas.height / 2 - a.y) * CENTER_PULL;

      a.vx += (Math.random() - 0.5) * RANDOM_WALK;
      a.vy += (Math.random() - 0.5) * RANDOM_WALK;

      if (frameCount % KICK_PERIOD === i % KICK_PERIOD) {
        a.vx += (Math.random() - 0.5) * KICK_MAG;
        a.vy += (Math.random() - 0.5) * KICK_MAG;
      }

      a.vx *= DAMP; a.vy *= DAMP;
      const spd = Math.hypot(a.vx, a.vy);
      const maxSpd = exploding ? MAX_SPEED_EXPLODE : MAX_SPEED;
      if (spd > maxSpd) {
        a.vx *= maxSpd / spd;
        a.vy *= maxSpd / spd;
      }

      a.x += a.vx; a.y += a.vy;
      if (a.x < 0) { a.x = 0; a.vx = Math.abs(a.vx); }
      if (a.x > canvas.width) { a.x = canvas.width; a.vx = -Math.abs(a.vx); }
      if (a.y < 0) { a.y = 0; a.vy = Math.abs(a.vy); }
      if (a.y > canvas.height) { a.y = canvas.height; a.vy = -Math.abs(a.vy); }

      ctx.beginPath();
      ctx.arc(a.x, a.y, a.r, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(${cr},${cg},${cb},0.45)`;
      ctx.fill();
    }

    animId = requestAnimationFrame(tick);
  }

  resize();
  const ro = new ResizeObserver(resize);
  ro.observe(canvas.parentElement);
  tick();

  document.addEventListener('visibilitychange', () => {
    if (document.hidden && animId) {
      cancelAnimationFrame(animId);
      animId = null;
    } else if (!document.hidden && !animId) {
      animId = requestAnimationFrame(tick);
    }
  });
})();
</script>
