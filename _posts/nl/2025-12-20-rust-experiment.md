---
layout: post
title:  "Van Python naar Rust: mijn genetisch kunstalgoritme"
byline: ""
description: "Een genetisch kunstalgoritme van Python vertalen naar Rust met Claude Code als voornaamste codeerhulp, en onderzoeken hoe agentic AI werkt wanneer je absolute beginner bent in een taal."
date:   2025-12-20 08:00:00
author: Sebastian Proost
post_id: rust-experiment
categories: ai programming
tags:	python rust evolution genetic-algorithm algorithm art
cover:  "/assets/posts/2025-12-20-Rust-Experiment/python_rust.jpg"
thumbnail: "/assets/images/thumbnails/rust_experiment.jpg"
---

Eén van de eerste posts op deze blog toonde hoe je [een genetisch algoritme implementeert in Python]({% post_url 2020/2020-01-12-Genetic-Art-Algorithm %}). Toen ik dat project opnieuw bekeek, besefte ik dat het een ideale kandidaat is om te porten naar [Rust](https://rust-lang.org/): het is rekenintensief en raakt aan performantie, parallellisme en datastructuren. Kortom, een goed excuus om eindelijk eens tijd te steken in Rust.

Tegelijk was dit project een gelegenheid om te experimenteren met agentic AI-codeertools, in het bijzonder [Claude Code](https://claude.ai/). Ik gebruik AI-ondersteunde ontwikkeling al een tijdje om documentatie en testdekking te verbeteren, verouderde codebases te moderniseren en sneller kleine tools te bouwen dan ik zelf kunnen. In al die gevallen kende ik de taal en het ecosysteem echter al goed genoeg om de AI te sturen en de output kritisch te beoordelen.

Dat riep een interessantere vraag op: hoe ziet agentic coding eruit wanneer je de taal helemaal niet beheerst? Hoe effectief is het als je een absolute beginner bent in een nieuw ecosysteem, en kan het dan nog steeds bijdragen aan echt leren in plaats van enkel aan snelle resultaten? Deze post documenteert dat experiment: een genetisch algoritme in Python vertalen naar Rust met agentic AI als voornaamste implementatiehulp, en reflecteren over wat die aanpak mogelijk maakt, waar ze tekortschiet en wat ik onderweg heb geleerd.

Zoals altijd vind je de [code voor dit project](https://github.com/4dcu-be/Genetic-Art-Rust) op GitHub.

## De omgeving opzetten


Mijn vaste IDE is [VSCode](https://code.visualstudio.com/), en ik heb de gewoonte ontwikkeld om voor de meeste van mijn projecten een devcontainer op te zetten. Voor experimenten als dit vind ik het fijn dat ik de Rust-toolchain niet op mijn hoofdsysteem moet installeren. Dus vroeg ik Claude Code om mijn bestaande Python-Dockerfile om te bouwen tot een die alle Rust-tooling bevatte die ik nodig zou hebben. Het resultaat zag er zinnig uit, en het werkte perfect voor dit project: geen extra kopzorgen, geen geknoei met lokale installaties. Een mooie herinnering aan hoeveel vlotter experimenteren verloopt als je de omgeving isoleert van je dagelijkse opzet.

{:.large-code}
```Dockerfile
# Use Debian Trixie slim as base for Rust development
FROM debian:trixie-slim

# Install system dependencies needed for Rust development and VS Code devcontainer
# - curl: for downloading Rust installer and general use
# - git: version control
# - build-essential: C compiler and build tools (needed for some Rust crates)
# - pkg-config: helps Rust find system libraries
# - ca-certificates: SSL certificate validation
# - gnupg: GPG key management
# - libssl-dev: OpenSSL development files (commonly needed by Rust projects)
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    pkg-config \
    ca-certificates \
    gnupg \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust using rustup (official Rust installer)
# - Install to /usr/local/cargo and /usr/local/rustup for system-wide access
# - Use default stable toolchain
# - Add cargo bin to PATH
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile default \
    && chmod -R a+w $RUSTUP_HOME $CARGO_HOME

# Install Node.js LTS (needed for Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code globally
# Using --no-fund and --no-audit flags to reduce installation noise
RUN npm install -g @anthropic-ai/claude-code --no-fund --no-audit

# Set the working directory
WORKDIR /workspace

# Verify installations
RUN rustc --version && \
    cargo --version && \
    claude --version

# Pre-create cargo registry directory with proper permissions
# This helps avoid permission issues when first running cargo commands
RUN mkdir -p $CARGO_HOME/registry && chmod -R a+w $CARGO_HOME

# Keep container running for devcontainer usage
CMD ["sleep", "infinity"]
```

## De Python-code omzetten

In de [oorspronkelijke blogpost]({% post_url 2020/2020-01-12-Genetic-Art-Algorithm %}) stond het grootste deel van de code, dus die voerde ik in in de online interface van Claude en ik verwees naar mijn GitHub-repository. Vervolgens vroeg ik Claude Opus 4.5 om een plan op te stellen om het project naar Rust te vertalen. Dat plan bewaarde ik als een markdownbestand in mijn project.

Vanuit VSCode opende ik Claude Code in de terminal en vroeg ik om het plan na te kijken en de eerste fase te beginnen implementeren. Ik maakte ook duidelijk dat ik iets wilde leren uit het proces, en vroeg om implementatiekeuzes toe te lichten en nuttige commentaar in de code te zetten.


### Stap 1: De Triangle-klasse

{:.large-code}
```rust
// Import the random number generator trait from the rand crate
use rand::Rng;
// Import serialization traits - these allow converting our Triangle to/from JSON
use serde::{Deserialize, Serialize};

/// Represents a single triangle gene with position, shape, and color
///
/// The `#[derive(...)]` macro automatically generates implementations for common traits:
/// - Clone: Allows creating copies with .clone()
/// - Debug: Allows printing with {:?} for debugging
/// - Serialize/Deserialize: Allows converting to/from JSON
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Triangle {
    /// Three points defining the triangle vertices
    /// `pub` makes this accessible from outside the module
    /// `[(i32, i32); 3]` is a fixed-size array of 3 tuples, stored on the stack (fast!)
    pub points: [(i32, i32); 3],

    /// RGBA color values (0-255)
    /// `[u8; 4]` is an array of 4 unsigned 8-bit integers
    pub color: [u8; 4],

    /// Image dimensions for boundary checking
    /// These are private (no `pub`) - implementation details hidden from users
    img_width: u32,
    img_height: u32,
}

/// Types of mutations that can occur
///
/// Rust enums are more powerful than C enums - they can hold data (though these don't)
/// This is private to the module (no `pub`) since it's just an implementation detail
enum MutationType {
    Shift,  // Move entire triangle
    Point,  // Move single point
    Color,  // Change color
    Reset,  // Complete reset to random
}

// Implementation block - this is where we define methods for Triangle
// Like a class in other languages, but without inheritance
impl Triangle {
    /// Create a new random triangle within image boundaries
    ///
    /// `pub fn new(...)` is a public associated function (like a static method)
    /// Returns `Self` (which means Triangle in this context)
    pub fn new(img_width: u32, img_height: u32) -> Self {
        // Get a thread-local random number generator
        // `mut` means the variable can be modified (mutability must be explicit in Rust)
        let mut rng = rand::thread_rng();

        // Pick a random center point for the triangle
        // `as i32` converts u32 to i32 (signed integer, can be negative)
        let x = rng.gen_range(0..img_width as i32);
        let y = rng.gen_range(0..img_height as i32);

        // Generate three points around the center
        // `Self { ... }` constructs a new Triangle instance
        Self {
            // Array syntax: create 3 points with random offsets from center
            points: [
                (x + rng.gen_range(-50..=50), y + rng.gen_range(-50..=50)),
                (x + rng.gen_range(-50..=50), y + rng.gen_range(-50..=50)),
                (x + rng.gen_range(-50..=50), y + rng.gen_range(-50..=50)),
            ],
            // Random RGBA color (RGB + Alpha for transparency)
            color: [
                rng.gen_range(0..=255),  // Red
                rng.gen_range(0..=255),  // Green
                rng.gen_range(0..=255),  // Blue
                rng.gen_range(0..=255),  // Alpha (transparency)
            ],
            img_width,
            img_height,
        }
    }

    /// Apply a random mutation to this triangle
    ///
    /// # Arguments
    /// * `sigma` - Mutation strength (0.0-2.0, default 1.0)
    ///
    /// `&mut self` means:
    /// - `&` = borrowed (we don't take ownership)
    /// - `mut` = mutable borrow (we can modify the triangle)
    /// - `self` = this is a method that operates on an instance
    pub fn mutate(&mut self, sigma: f32) {
        // Import the weighted index distribution for selecting mutation types
        use rand::distributions::WeightedIndex;
        use rand::prelude::*;

        let mut rng = rand::thread_rng();

        // Weighted selection of mutation type
        // Higher weights = more likely to be selected
        // [30, 35, 30, 5] means Shift and Color are less common, Point is most common, Reset is rare
        let weights = [30, 35, 30, 5];
        let dist = WeightedIndex::new(&weights).unwrap();

        // Sample from the distribution to pick a mutation type
        // `match` is Rust's pattern matching - like switch but exhaustive (compiler checks all cases)
        let mutation_type = match dist.sample(&mut rng) {
            0 => MutationType::Shift,
            1 => MutationType::Point,
            2 => MutationType::Color,
            _ => MutationType::Reset,  // `_` is a catch-all pattern
        };

        // Apply the selected mutation
        // Note how each mutation method borrows the RNG mutably
        match mutation_type {
            MutationType::Shift => self.mutate_shift(sigma, &mut rng),
            MutationType::Point => self.mutate_point(sigma, &mut rng),
            MutationType::Color => self.mutate_color(sigma, &mut rng),
            // For reset, we create a new random triangle and replace self's data with `*self = ...`
            // The `*` dereferences the mutable reference to assign to the actual value
            MutationType::Reset => *self = Triangle::new(self.img_width, self.img_height),
        }
    }

    /// Shift entire triangle by a random amount
    ///
    /// Private method (no `pub`) - internal implementation detail
    /// `&mut self` - we need to modify the triangle's points
    /// `rng: &mut impl Rng` - accepts ANY type that implements the Rng trait
    ///   This is a "trait bound" - enables zero-cost polymorphism
    fn mutate_shift(&mut self, sigma: f32, rng: &mut impl Rng) {
        // Calculate random x and y shifts, scaled by sigma
        // `as f32` converts i32 to f32, then multiply by sigma, then `as i32` converts back
        let x_shift = (rng.gen_range(-50..=50) as f32 * sigma) as i32;
        let y_shift = (rng.gen_range(-50..=50) as f32 * sigma) as i32;

        // Iterate through all points and shift them
        // `&mut self.points` borrows the array mutably
        // `point` is a mutable reference to each element
        for point in &mut self.points {
            point.0 += x_shift;  // .0 accesses first tuple element (x)
            point.1 += y_shift;  // .1 accesses second tuple element (y)
        }
    }

    /// Move a single point of the triangle
    fn mutate_point(&mut self, sigma: f32, rng: &mut impl Rng) {
        // Pick a random point index (0, 1, or 2)
        let index = rng.gen_range(0..3);
        // Modify that point's coordinates
        self.points[index].0 += (rng.gen_range(-50..=50) as f32 * sigma) as i32;
        self.points[index].1 += (rng.gen_range(-50..=50) as f32 * sigma) as i32;
    }

    /// Change the color of the triangle
    fn mutate_color(&mut self, sigma: f32, rng: &mut impl Rng) {
        // Iterate through each color channel (R, G, B, A)
        for channel in &mut self.color {
            let change = (rng.gen_range(-50..=50) as f32 * sigma) as i32;
            // Important: clamp the value to 0-255 range to prevent overflow
            // `*channel` dereferences to get the u8 value
            // `.clamp(0, 255)` ensures value stays in valid range
            *channel = (*channel as i32 + change).clamp(0, 255) as u8;
        }
    }
}

// Conditional compilation: this module only exists in test builds
// Keeps test code out of release binaries
#[cfg(test)]
mod tests {
    // Import everything from parent module (Triangle and its types)
    use super::*;

    /// Test that triangle creation works correctly
    ///
    /// `#[test]` marks this function as a test - cargo test will run it
    #[test]
    fn test_triangle_creation() {
        let tri = Triangle::new(800, 600);
        // `assert_eq!` checks equality and panics with helpful message if they differ
        assert_eq!(tri.img_width, 800);
        assert_eq!(tri.img_height, 600);
        assert_eq!(tri.points.len(), 3);
        assert_eq!(tri.color.len(), 4);
    }

    /// Test that mutation actually changes the triangle
    #[test]
    fn test_triangle_mutation() {
        let mut tri = Triangle::new(800, 600);
        let original_color = tri.color;

        // Mutate multiple times - should eventually change something
        // `_` means we don't use the loop variable
        for _ in 0..10 {
            tri.mutate(1.0);
        }

        // Very unlikely to be identical after 10 mutations
        // `||` is logical OR - check if EITHER color OR points changed
        // `!=` works because we derived PartialEq (via Debug)
        assert!(tri.color != original_color || tri.points != [(0, 0); 3]);
    }
}
```

Dit staat duidelijk ver van Python-code af: we moeten het type van de getallen opgeven, expliciet bepalen welke variabelen muteerbaar zijn, ... maar Claude Code deed het erg goed door aan te duiden waar bepaalde Rust-paradigma's van belang zijn. Ook de manier waarop tests geïmplementeerd worden, binnen het bestand dat ze testen, verschilt sterk van Python. Hier stootte ik op het eerste nadeel van agentic coding: dit is geen goede manier om de syntax van een nieuwe taal te leren, althans niet voor mij. Om een nieuwe syntax te onthouden moet ik het op de moeilijke manier doen en een paar duizend regels code uittypen.

Bovendien werden in de commentaar cruciale Rust-concepten als [ownership](https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html) en [borrowing](https://doc.rust-lang.org/book/ch04-02-references-and-borrowing.html) vermeld. Omdat ik die niet kende uit andere programmeertalen, nam ik me voor daar later in te duiken. Door dieper in de code te graven besefte ik ook hoe centraal Rusts `enum`- en `match`-keywords staan: ze maken een expressieve en typeveilige afhandeling van meerdere gevallen mogelijk, wat de implementatie zowel duidelijk als robuust maakte.

Alles compileerde, maar ik had nog geen werkend programma, dus gaf ik Claude Code de opdracht om verder te gaan met de implementatie.

### Stap 2: Paintings en Populations

Net als in de Python-code worden driehoeken (of cirkels, die ik later als extra vorm heb toegevoegd) samengebracht in een lijst, de painting. Die klasse kan zichzelf ook `render`en en haar driehoeken laten `mutate`n. Meerdere paintings worden gegroepeerd in een population, met functies om de fitness van de individuen te `evaluate`n en het meest fitte individu te vinden. De meeste gegenereerde code lag in lijn met het voorgaande, maar die `evaluate` viel op omdat er code in zat die parallel kon draaien. Toegegeven, dit is een triviaal probleem om te parallelliseren, maar in Python zou het niet zo eenvoudig zijn (het vereist multiprocessing). Hier gebruik je gewoon `.par_iter_mut()` uit de [rayon](https://docs.rs/rayon/latest/rayon/)-crate (zo heten packages/libraries in Rust) op een lijst en klaar is kees.

{:.large-code}
```rust
    /// Evaluate fitness for all individuals in parallel
    ///
    /// This is where Rust really shines!
    /// We're going to evaluate ALL individuals simultaneously across all CPU cores.
    ///
    /// **Rust Concept: Parallel Mutation**
    /// - `.par_iter_mut()` creates a parallel iterator over mutable references
    /// - Each thread gets exclusive access to different individuals
    ///
    /// **Why is this safe?**
    /// 1. Each individual is independent (no shared state)
    /// 2. `&mut` ensures exclusive access per thread
    /// 3. Compiler verifies this at compile time
    pub fn evaluate(&mut self) {
        // Process all individuals in parallel
        // `.par_iter_mut()` is the parallel version of `.iter_mut()`
        self.individuals.par_iter_mut().for_each(|individual| {
            // Render this individual's painting to an image
            let rendered = individual.chromosome.render();

            // Compare to target using the configured fitness function
            // Lower score = better match to target
            individual.fitness = Some(match self.fitness_config.function {
                FitnessFunction::Mad => {
                    image_diff_parallel(&rendered, &self.target_image)
                }
                FitnessFunction::EdgeWeighted => {
                    edge_weighted_fitness(&rendered, &self.target_image, &self.fitness_config)
                }
                FitnessFunction::MsSsim => {
                    ms_ssim_fitness(&rendered, &self.target_image, self.fitness_config.detail_weight)
                }
            });
        });
```

### Stap 3: Evolutie en de fitnessfunctie

Zodra we populaties hebben, hebben we een manier nodig om individuen te rangschikken, de beste te laten voortplanten en de volgende generatie te maken, die hopelijk wat beter is dan de vorige. Beter betekent hier: een painting die uit een aantal driehoeken (of cirkels) bestaat en op een referentiebeeld lijkt. Hoe dichter de pixelwaarden bij elkaar liggen, hoe beter. Voor het evolutiegedeelte kon de Python-implementatie terugvallen op de [evol](https://github.com/godatadriven/evol)-library; Claude Code besloot het in Rust te implementeren, en het werkte. Best indrukwekkend, want het evol-package maakte geen deel uit van de code die ik had aangeleverd (en voor zover ik kan zien heeft het dat niet online opgezocht), dus puur op basis van hoe het package gebruikt werd, reconstrueerde het de interne werking feilloos. Bij agentic coding merk ik dat relatief eenvoudige functionaliteit vaak als code gegenereerd wordt in plaats van dat er een bestaand package binnengehaald wordt. Dat kan bloat creëren en extra onderhoud met zich meebrengen, al biedt het anderzijds ook makkelijke toegang tot die functies om ze verder aan te passen indien nodig.

De fitnessfunctie is waar Claude Code het interessant maakte: het implementeerde die als een parallelle functie, die verschillende pixels in verschillende threads berekent. De functie `.par_iter()` uit de rayon-library maakt dit opnieuw multithreaded, zodat alle beschikbare cores in je machine tijdens deze stap benut worden.

{:.large-code}
```rust
/// Parallel version of image_diff (faster for large images)
///
/// **Rust Concept: Fearless Concurrency**
/// This function uses ALL your CPU cores automatically, safely!
///
/// How does Rust make parallel programming safe?
/// 1. The borrow checker prevents data races at compile time
/// 2. Only immutable references (&) are used, so parallel access is safe
/// 3. No locks, no mutexes needed - the type system guarantees safety
///
/// **When to use this?**
/// - Large images (>1000x1000 pixels) - overhead is worth it
/// - When you have multiple CPU cores (which you probably do!)
/// - The population evaluation (comparing many images) benefits hugely
pub fn image_diff_parallel(source: &RgbaImage, target: &RgbaImage) -> f64 {
    assert_eq!(
        source.dimensions(),
        target.dimensions(),
        "Images must have same dimensions"
    );

    // The ONLY difference: collect into vectors and use par_iter!
    //
    // **What's .par_iter()?**
    // - Creates a parallel iterator over a collection
    // - Rayon automatically splits work across CPU cores
    // - Uses work-stealing: idle cores help busy cores
    // - No manual thread management needed!
    //
    // We need to collect both iterators first since rayon's zip needs both sides parallel
    let source_pixels: Vec<_> = source.pixels().collect();
    let target_pixels: Vec<_> = target.pixels().collect();

    let total_diff: u64 = source_pixels
        .par_iter() // <-- Parallel iterator over source pixels
        .zip(target_pixels.par_iter()) // <-- Zip with parallel iterator over target pixels
        .map(|(s, t)| {
            let dr = (s[0] as i32 - t[0] as i32).abs() as u64;
            let dg = (s[1] as i32 - t[1] as i32).abs() as u64;
            let db = (s[2] as i32 - t[2] as i32).abs() as u64;
            dr + dg + db
        })
        .sum(); // Rayon's sum() automatically combines results from all threads

    total_diff as f64 / (source.width() * source.height() * 3) as f64
}
```

### Stap 4: De CLI

Iets waarvoor ik Claude Code bijzonder nuttig vond, is het maken van een CLI voor applicaties. Ik vind dat persoonlijk vervelend werk en geef die taak graag door aan AI. Hier gebruikte Claude Code de [clap](https://docs.rs/clap/latest/clap/)-crate, een uitstekende keuze! De CLI zelf is eenvoudig maar functioneel.


### Stap 5: Alles uittesten

Omdat ik Claude Code de opdracht had gegeven om de app in fases te bouwen en bij elke stap tests te draaien, compileerde de code na een paar rondes bouwen-falen-debuggen-opnieuw proberen en was de app klaar om door mij getest te worden. Op een klein probleempje bij het renderen van de afbeelding na werkte alles!

Ik testte het uit op dezelfde afbeelding die ik in 2020 gebruikte, Van Goghs [*De sterrennacht*](https://en.wikipedia.org/wiki/The_Starry_Night), en het eerste wat me opviel, was dat mijn CPU snel naar 95% verbruik ging en daar bleef!

```bash
# Run a quick test with triangles (100 generations)
./target/release/genetic-art \
  --input input/starry_night.jpg \
  --generations 100 \
  --shapes 100
```

Ik merkte ook dat het een pak sneller liep, al gebruik ik ook een nieuwe computer, dus laten we uitzoeken hoeveel daarvan aan de implementatie te danken is.

## Performantietests en optimalisatie

"Rewrite in Rust" is misschien een beetje een meme, maar ik merkte meteen een versnelling toen ik mijn code draaide. Om beter te begrijpen wat er aan de hand was, deed ik een paar testruns en vergeleek ik de looptijden met de oorspronkelijke Python-implementatie. Elke test gebruikte een doelafbeelding van 570×452 pixels; de andere parameters staan in de tabellen hieronder.

De resultaten waren wat verrassend. Op één thread was Rust eigenlijk trager dan Python, waarschijnlijk omdat de Pillow-library in Python het grootste deel van het tekenen en vergelijken van afbeeldingen efficiënter afhandelt dan de initiële implementatie. Het bracht ook iets aan het licht wat ik me niet realiseerde: Python schaalde bijzonder slecht over meerdere cores en werd merkbaar trager (!) naarmate er meer threads gebruikt werden. Rust daarentegen ging prachtig om met multithreading. Op mijn 8-core Ryzen 7 3700X was de parallelle efficiëntie uitstekend, en zodra Rust meerdere cores mocht gebruiken, liet het Python moeiteloos achter zich.


| Generaties (n) | Vormen (n) | Threads (n) | Rust (mm:ss) | Threads (n) | Python (mm:ss) | Versnelling (%) |
|-----------------|------------|-------------|--------------|-------------|----------------|-------------|
|             100 |        100 |           1 |        15:22 |           1 |          09:34 |         62% |
|             100 |        100 |           4 |        04:28 |           4 |          12:05 |        271% |
|             100 |        100 |           8 |        02:30 |           8 |          11:30 |        460% |


| Generaties (n) | Vormen (n) | Threads (n) | Rust (mm:ss) | Threads (n) | Python (mm:ss) | Versnelling (%) |
|-----------------|------------|-------------|--------------|-------------|----------------|-------------|
|             100 |        100 |          16 |        02:07 |           1 |          09:34 |        452% |
|             100 |        300 |          16 |        06:04 |           1 |          25:47 |        425% |
|             300 |        100 |          16 |        06:17 |           1 |          30:19 |        482% |


Nadat ik Claude Code had gevraagd om na te gaan waarom de singlethreaded performantie eigenlijk slechter was dan die van Python, vond het een paar plekken (met betrekking tot het tekenen van de afbeeldingen en het vergelijken met de referentie) waar de code geoptimaliseerd kon worden. Dat klonk allemaal plausibel, dus besloot ik het te proberen en gaf ik Claude Code groen licht om de meest impactvolle wijziging door te voeren (het tekenen van de vormen optimaliseren door een klein deel van de afbeelding bij te werken in plaats van de hele afbeelding). Plots duurden 100 generaties met 100 vormen nog 23 seconden in plaats van 2 minuten en 7 seconden. Claude Code weet duidelijk hoe je zaken optimaliseert, dus ik begon me in te lezen over de volgende verbetering die het voorstelde: [SIMD](https://doc.rust-lang.org/std/simd/index.html) gebruiken, *Single Instruction, Multiple Data*, om een deel van de berekeningen te optimaliseren. Na wat studiewerk leek het me inderdaad een heel redelijke aanpak hier, dus gaf ik het akkoord om de wijzigingen door te voeren.


| Generaties (n) | Vormen (n) | Threads (n) | Rust (mm:ss) | Threads (n) | Python (mm:ss) | Versnelling (%) | Opmerking                    |
|-----------------|------------|-------------|--------------|-------------|----------------|-------------|----------------------------|
|             100 |        100 |          16 |        02:07 |           1 |          09:34 |        452% | Eerste implementatie       |
|             100 |        100 |          16 |        00:23 |           1 |          09:34 |       2496% | Beter tekenen            |
|             100 |        100 |          16 |        00:11 |           1 |          09:34 |       5218% | Met SIMD                 |
|             100 |        100 |           1 |        01:45 |           1 |          09:34 |        547% | Alle optimalisaties (1 core) |

Die extra optimalisaties bleken bijzonder de moeite waard: in dit kleine testje ging de looptijd van 127 seconden naar 23 na de verbetering aan het tekenen, en met SIMD zakte het verder tot amper 11 seconden. Dat is een verbetering van 10x tegenover de niet-geoptimaliseerde Rust-versie, en met alle cores benut zijn we nu 52x sneller dan de Python-versie ooit kan draaien.

Hou er wel rekening mee dat deze benchmarks uit enkele runs bestaan, dus beschouw de cijfers als indicatief eerder dan absoluut. Het verschil in performantie tussen de implementaties is echter meteen duidelijk.

## De resultaten

De Rust-versie draaien met dezelfde parameters als de oorspronkelijke Python-code leverde erg vergelijkbare resultaten op. Na voldoende iteraties convergeren beide naar beelden die duidelijk op het doelbeeld lijken. Zoals je bij een genetisch algoritme mag verwachten, zit er veel willekeur in, dus elke run is anders, maar Rust (links) gedroeg zich in dat opzicht niet anders dan Python (rechts). Hieronder staat een vergelijking van de outputs naast elkaar; visueel zijn ze, afgezien van de gebruikelijke stochastische variatie, erg gelijkaardig.

<div class="gallery-2-col" markdown="1">
![Rust 150 driehoeken, 5000 generaties](/assets/posts/2025-12-20-Rust-Experiment/rust_150_5000.png)
![Python 150 driehoeken, 5000 generaties](/assets/posts/2025-12-20-Rust-Experiment/python_150_5000.png)
</div>


Een leuk neveneffect van agentic coding was hoe makkelijk het was om te experimenteren. Ik vroeg Claude Code om een modus toe te voegen met cirkels in plaats van driehoeken, en het werkte! De output met René Magrittes [*De zoon van de mens*](https://en.wikipedia.org/wiki/The_Son_of_Man) als doelbeeld toont dat het kernalgoritme flexibel genoeg is om met andere vormen om te gaan zonder de engine te herschrijven.

<div class="gallery-3-col" markdown="1">
![De zoon van de mens, schilderij van René Magritte](/assets/posts/2025-12-20-Rust-Experiment/the_son_of_man.jpg)
![De zoon van de mens, 100 cirkels, 500 generaties, versie 1](/assets/posts/2025-12-20-Rust-Experiment/som_100_500_ew.png)
![De zoon van de mens, 100 cirkels, 500 generaties, versie 2](/assets/posts/2025-12-20-Rust-Experiment/som_100_500_mad.png)
</div>

Al bij al levert Rust je ruwweg dezelfde resultaten als Python, maar sneller en met volledige benutting van de CPU, terwijl je ook veel vrijer kunt experimenteren en bijsturen.

## Conclusie

Als technologie is Claude Code indrukwekkend: een bestaande tool vertalen naar een andere taal kostte minder dan een uur, met nog eens ongeveer een uur voor de optimalisaties. De gegenereerde code was leesbaar, compileerde zonder gedoe en kwam met zinvolle commentaar, tests en dekking. Tegelijk is het verleidelijk om de AI vooruit te laten hollen zonder zelf betrokken te blijven. Het blonk uit in het implementeren van bekende patronen en het maken van redelijke architecturale keuzes, zoals het reconstrueren van de interne werking van de evol-library of het introduceren van parallellisme met rayon, maar het had nog steeds sturing nodig over de grote lijnen en verificatie dat de output aan de verwachtingen voldeed. De vroege problemen bij het renderen van afbeeldingen waren een goede herinnering dat code die er correct uitziet niet hetzelfde is als correct gedrag.

Als leermiddel had de ervaring duidelijke sterktes en beperkingen. Werken aan een project dat ik al begreep, maakte het makkelijk om te zien welke Rust-concepten er voor dit soort applicaties echt toe deden. Door de gegenereerde code na te kijken, kreeg ik een veel beter begrip van concepten als ownership en borrowing, enums en pattern matching, rayon, en de omliggende tooling met cargo. De commentaar die Claude Code genereerde, was bijzonder nuttig om die concepten aan te wijzen en de juiste zoektermen aan te reiken voor de officiële documentatie. Maar doordat alle code voor mij geschreven werd, bleef de syntax gewoon niet hangen. Na dit project zou ik geen Rust vanaf nul kunnen schrijven, en ik kan niet zinvol beoordelen hoe idiomatisch de code stilistisch is. Dat ik geen enkele regel code moest schrijven of aanpassen was efficiënt, en ik zou ook nooit de tijd gehad hebben om dit project aan te vatten, maar het voelt ook wat bitterzoet, want dat deel van het proces vind ik eigenlijk best plezant.

<div class="gallery-3-col" markdown="1">
![American Gothic van Grant Wood](/assets/posts/2025-12-20-Rust-Experiment/american_gothic.jpg)
![American Gothic, 400 driehoeken, 5000 generaties, Edge Weight](/assets/posts/2025-12-20-Rust-Experiment/american_gothic_400_triangles_5000_gen_edge.png)
![American Gothic, 600 cirkels, 5000 generaties, Edge Weight](/assets/posts/2025-12-20-Rust-Experiment/american_gothic_600_circles_5000_gen_edge.png)
</div>

De echte waarde zat dus niet alleen in de 50x versnelling tegenover Python, hoe fijn die ook is (en die laat vergelijkingen toe met meer vormen, grotere populaties en meer generaties, zoals je hierboven ziet bij Grant Woods [*American Gothic*](https://en.wikipedia.org/wiki/American_Gothic), waar 400 driehoeken of 600 cirkels gebruikt werden). Het zat in de mogelijkheid om met beperkte tijd een nieuwe taal te verkennen en snel een indruk te krijgen van de tooling en het ecosysteem. Claude Code inzetten op een project dat ik zelf niet had kunnen doen, was ook een nederig makende ervaring: deze tools zijn ongelooflijk krachtig! Maar het zijn geen volledig autonome agents die zo'n project van A tot Z zonder sturing aankunnen. De sleutel is de AI behandelen als een ervaren pair programmer: hij kan de code schrijven, maar jij moet nog steeds de architectuur begrijpen, de implementatie nakijken en verifiëren dat ze het juiste probleem oplost. Om nieuwe technologieën te verkennen en tegelijk uit een concreet, echt project te leren, werkte deze aanpak opmerkelijk goed.
