# Docker Setup for 4DCu.be

This guide explains how to use Docker to develop and build the 4DCu.be blog.

## Prerequisites

- [Docker](https://www.docker.com/get-started) installed on your system
- [Docker Compose](https://docs.docker.com/compose/install/) (usually included with Docker Desktop)

## Quick Start

### Using Docker Compose (Recommended)

1. **Start the development server:**
   ```bash
   docker-compose up
   ```
   The site will be available at http://localhost:4000

2. **Build the production site:**
   ```bash
   docker-compose run --rm jekyll-build
   ```
   This will generate the site in the `docs/` folder.

3. **Run pagefind indexing:**
   ```bash
   docker-compose run --rm jekyll npx pagefind --site docs
   ```

4. **Stop the development server:**
   ```bash
   docker-compose down
   ```

### Using Docker Directly

1. **Build the Docker image:**
   ```bash
   docker build -t 4dcu-blog .
   ```

2. **Run the development server:**
   ```bash
   docker run -p 4000:4000 -v $(pwd):/app 4dcu-blog
   ```

3. **Build the production site:**
   ```bash
   docker run -v $(pwd):/app 4dcu-blog bundle exec jekyll build --config _config.yml
   ```

## What's Included

The Docker image includes:
- **Ruby 2.6.3** (Debian-based)
- **Bundler** with all required gems
- **ImageMagick** for image processing
- **Node.js 18.x and npm** for Claude Code and other tools
- **Pagefind** for search indexing

## Development Workflow

1. Make changes to your files locally
2. The development server will automatically rebuild (with `--livereload` enabled)
3. Refresh your browser to see changes

## Installing Claude Code in Container

To install Claude Code in the running container:

```bash
# Enter the running container
docker-compose exec jekyll bash

# Inside the container, install Claude Code
npm install -g @anthropic-ai/claude-code
```

## Troubleshooting

### Port already in use
If port 4000 is already in use, you can change it in `docker-compose.yml`:
```yaml
ports:
  - "4001:4000"  # Use port 4001 instead
```

### Permission issues
If you encounter permission issues with generated files:
```bash
# On Linux/Mac, you may need to fix ownership
sudo chown -R $USER:$USER docs/
```

### Clean rebuild
To rebuild the Docker image from scratch:
```bash
docker-compose build --no-cache
```

## Notes

- The `_site/` and `docs/` folders are excluded from the Docker build context via `.dockerignore`
- Bundle dependencies are cached in a Docker volume for faster rebuilds
- Changes to `Gemfile` require rebuilding the image: `docker-compose build`
