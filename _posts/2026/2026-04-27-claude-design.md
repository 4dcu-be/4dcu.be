---
layout: post
title: "Claude Design to revamp two projects"
byline: "... can AI do webdesign now?"
date: 2026-04-27 08:00:00
categories: ai programming
tags: claude-code claude-design javascript web-development eleventy svelte
cover: "/assets/posts/2026-04-27-claude-design/claude_design.jpg"
thumbnail: "/assets/images/thumbnails/claude_design.jpg"
author: Sebastian Proost
---

Design has always been my bottleneck. I usually have a fairly clear idea of what I want, but turning that into a consistent interface is where I get stuck. For the last redesign of my resume site, back in 2024, I ended up hiring a designer through [Fiverr](https://www.fiverr.com/) to get unstuck. So when Anthropic released [Claude Design](https://claude.ai/), a web-based tool that turns screenshots and Figma files into editable prototypes, I was genuinely curious whether it could close that gap.

To put it through its paces, I used it to redesign two projects: a small Svelte app I use as a testing ground, and the resume site I just mentioned.

![Claude Design's main interface](/assets/posts/2026-04-27-claude-design/claude_design_main.png){:.medium-image}

The interface itself is straightforward: upload screenshots, write a prompt, and iterate by commenting on specific elements or drawing directly on the layout. It can produce low-fidelity wireframes or high-fidelity, browser-ready mockups you can click through. Changes are applied in place, so it feels much more like a live design tool than a chat window with a preview pane.

## Modernising a Svelte-based web interface

For a while now I've been working on a small set of tools to track video game records: a Python package that validates game data using Pydantic which contains a CLI to manage those JSON records, a [Svelte](https://svelte.dev/)-based frontend that turns the data into a static site, and a separate repo holding my own data. I call this project MiScore. It also doubles as my playground for experimenting with Pydantic, Click, Svelte, and whatever else I feel like trying. The current version of my site lives at [sebastian.proost.science/MiScore-site/](https://sebastian.proost.science/MiScore-site/).

The original design came together with Claude Code, and I was reasonably happy with it. But over time I noticed the model kept falling back on the same visual patterns, and what started out fresh began to look like the generic "vibe-coded" layout you see everywhere. A good excuse for a redesign.

I captured screenshots of the existing pages to pin down the structure and content, uploaded them to Claude Design with a short prompt describing MiScore, and after a few clarifying questions about style and colors it produced an initial high-fidelity prototype.

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
![MiScore main interface](/assets/posts/2026-04-27-claude-design/miscore_site_main.png)
![MiScore recent records](/assets/posts/2026-04-27-claude-design/miscore_site_recent.png)
![MiScore records page](/assets/posts/2026-04-27-claude-design/miscore_site_records.png)
</div>

I asked for a retro game aesthetic: dark theme, green highlights, subtle CRT and neon touches. The first pass was close, but a few colors felt off and the whole thing looked a bit static. The comment tools were really useful here, you select a specific element and tell it what to change, rather than trying to describe it in a prompt. A couple of iterations in, I had the mood I wanted, with a subtle background animation and a flickering neon-style title to tie it together.

![Claude Design's MiScore prototype](/assets/posts/2026-04-27-claude-design/claude_design_prototype.png){:.medium-image}

For the handoff, Claude Design produced a zip with a self-contained HTML prototype and a markdown file of implementation notes aimed at Claude Code. I dropped it into the MiScore-site repo under a `redesign` folder, opened Claude Code with Opus 4.7, and asked it to integrate the new layout into the existing Svelte project, following Svelte conventions rather than copying the prototype verbatim. It handled the structural changes cleanly, used Svelte's reactive features where appropriate, and the result needed no manual correction. I'm not experienced enough with Svelte to audit every line and evaluate the overall quality, but the code was readable and maintainable, which is what I care about.

The whole redesign took a single evening, and I didn't hit usage limits on the Pro plan for either Claude Design or Claude Code.

## Updating my resume

If you want to know what I've been up to professionally, my resume site is at [sebastian.proost.science](https://sebastian.proost.science). I keep it reasonably up to date, mostly by adding new content, and occasionally I revisit the design. As I mentioned, the 2024 redesign was partly done by a Fiverr designer, which worked but never felt entirely consistent.

<div class="gallery-3-col" markdown="1">
![CV main interface](/assets/posts/2026-04-27-claude-design/cv_main.png)
![CV publications](/assets/posts/2026-04-27-claude-design/cv_publications.png)
![CV media](/assets/posts/2026-04-27-claude-design/cv_media.png)
</div>

This time I uploaded screenshots to Claude Design, asked for a refresh, answered a few questions about colors and style, and it generated a prototype in teal and cyan with plenty of whitespace.

The result was clean, but the hero banner felt flat. I asked for a JavaScript-based animation: a dynamic network graph with nodes moving and connecting using simple physics. It worked on the first try, though the nodes kept drifting into a tight cluster in the center. Adding a periodic "explosion" that pushed them outward solved that and made the whole thing feel more alive. Under the hood it's a small force-directed system on a 2D canvas: springs, repulsion, damping, and a nudge every few seconds to keep things organic. You can see it running below.

<div style="width: 100%; height: 320px; --accent-rgb: 179 57 57;">
  <canvas id="demo-network" style="width: 100%; height: 100%; display: block;"></canvas>
</div>

After a few smaller tweaks using comments, I generated the handoff and dropped it into the project repo.

![CV new main](/assets/posts/2026-04-27-claude-design/cv_new_main.png)

Unlike MiScore, this site was built with [Gatsby](https://www.gatsbyjs.com/), and it had accumulated a fair amount of technical debt: outdated dependencies, slow builds, and a generally unpleasant developer experience. My plan was to integrate the redesign into the existing setup, but Claude Code (Opus 4.7) didn't manage to produce a working build using a full session worth of tokens.

That turned out to be a blessing in disguise. Gatsby wasn't really a requirement anymore; it just happened to be what I picked last time. The only real constraint was that the site had to stay static and easy to host on GitHub Pages. So I took a step back, looked at Astro, Eleventy, and Hugo, and landed on [Eleventy](https://www.11ty.dev/) for its simplicity and how well it handles YAML data.

I started from scratch: new repo, copied over the content (publications, work experience, and more, all stored as YAML), added the design handoff, and set up a devcontainer with VS Code and Docker. Claude Code turned the prototype into a working Eleventy site in minutes. The layout matched the design, the interactive bits were implemented in vanilla JavaScript, and the YAML data was wired in cleanly.

A few gaps remained. Navigation triggered full page reloads, whereas the Gatsby version felt like a single-page app. I asked Claude Code to add a lightweight client-side navigation layer, which worked with surprisingly little code, though it broke a few things like filters and "show more" buttons that needed to be re-initialised after navigation. Easy fixes once I spotted them. A few responsive and mobile tweaks rounded it out.

The whole thing took less than a day. The failed Gatsby integration ate the morning; the Eleventy rebuild, tweaks, and deploy fit into the afternoon. I ended up with a better design **and** a simpler codebase, which rarely happens in the same redesign.

## Conclusion

Having a visual interface to build a UI, and being able to guide changes by pointing at them and describing in plain English what you want, is a real step forward. I was already happy with what Claude Code could do, but this adds a layer that makes iteration feel closer to working with a designer than engineering. Ideas can get tested faster, which changes how I make design decisions. You can quickly try things that wouldn't be worth the effort otherwise.

The one thing I'm unsure about is diversity. In these two projects the output was great, better than what I'd produce on my own. But as more people start using these tools, I wonder if we'll start noticing the same aesthetic showing up everywhere, the way "vibe-coded" layouts already do. Something to keep an eye on.

There's also a more uncomfortable shift. In 2024 I hired a designer to get this site where I wanted it. This time I didn't need to, and I don't think I will for small or medium-sized personal projects going forward. That's empowering on my end, but it also shifts work away from people who used to provide that creative input as a service.

For me, the net effect is that I'll keep using this workflow. Not as a replacement for thinking about design, but as a way to move from idea to prototype fast enough that the design thinking actually gets done, instead of being endlessly deferred.

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
