# VSCode Dev Container Setup

This project includes a VSCode Dev Container configuration for a consistent development environment.

## Prerequisites

- [Visual Studio Code](https://code.visualstudio.com/)
- [Docker](https://www.docker.com/get-started)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Getting Started

1. Open this project in VSCode
2. When prompted, click **"Reopen in Container"** (or press F1 and select "Dev Containers: Reopen in Container")
3. Wait for the container to build and start
4. The terminal will be ready to use with all dependencies installed

## What's Included

The dev container includes:
- **Ruby 2.6.3** (Debian-based)
- **Bundler** with all required gems
- **ImageMagick** for image processing
- **Node.js 18.x and npm** for Claude Code installation
- **Pagefind** for search indexing

## Running the Development Server

In the VSCode terminal:

```bash
bundle exec jekyll serve --host 0.0.0.0 --config _config_dev.yml --livereload
```

The site will be available at http://localhost:4000

## Building the Production Site

```bash
bundle exec jekyll build --config _config.yml
```

The site will be generated in the `docs/` folder.

## Installing Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

## Indexing with Pagefind

After building the site:

```bash
npx pagefind --site docs
```
