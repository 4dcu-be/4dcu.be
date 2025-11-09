# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Jekyll-based blog website for 4DCu.be - Sebastian Proost's blog about programming, gaming, technology, and more. The site uses custom Jekyll plugins and builds to a static site hosted on GitHub Pages.

## Development Commands

### Local Development Server
```bash
# Start development server (uses _config_dev.yml)
bundle exec jekyll serve --config _config_dev.yml --incremental --port 5000

# Or use the batch file on Windows
run_server.bat
```

### Production Build
```bash
# Build for production (outputs to ./docs directory)
bundle exec jekyll build --config _config.yml && .\pagefind.exe

# Or use the batch file on Windows
run_build.bat
```

### Setup
```bash
# Install dependencies
bundle install
```

## Project Architecture

### Configuration
- `_config.yml`: Production configuration (builds to `./docs` for GitHub Pages hosting)
- `_config_dev.yml`: Development configuration (builds to `./_site`, runs on localhost:4000)
- `Gemfile`: Ruby dependencies including Jekyll, jekyll-archives, jekyll-paginate-v2, mini_magick

### Directory Structure
- `_posts/`: Blog posts in Markdown format
- `_pages/`: Static pages
- `_layouts/`: Jekyll layout templates (default, post, page, archive)
- `_includes/`: Reusable template components (header, footer, nav_links, etc.)
- `_sass/`: SCSS stylesheets
- `_plugins/`: Custom Jekyll plugins for image processing and functionality
- `assets/`: Static assets (images, icons, etc.)
- `docs/`: Production build output (for GitHub Pages hosting)
- `js/`: JavaScript files for individual pages

### Custom Jekyll Plugins
Located in `_plugins/`:
- `thumbnail_generator.rb`: Automatically generates thumbnails from cover images using MiniMagick
- `gallery_generator.rb`: Creates photo galleries
- `lightgallery_links.rb`: Integration with LightGallery for image viewing
- `json_featured.rb`: Generates featured content JSON
- `vegachart_tags.rb`: Support for Vega chart integration
- `image_size.rb`: Image size utilities

### Key Features
- **Pagination**: Uses jekyll-paginate-v2 with 7 posts per page
- **Archives**: Automatic category, tag, and year-based archives via jekyll-archives
- **Search**: Pagefind integration for static site search (configured in `pagefind.yaml`)
- **Image Processing**: Automatic thumbnail generation with MiniMagick (dimensions: 430x288)
- **Social Sharing**: Built-in social media integration (BlueSky, Facebook, LinkedIn, X)
- **Responsive**: Mobile-friendly design with AOS (Animate on Scroll) integration

### Content Categories
- programming: Everything related to code and programming
- games: Gaming-related content
- diy: DIY and maker projects
- biology: Science and nature content
- general: Site-related content

### Important Notes
- Requires ImageMagick for thumbnail generation
- Not compatible with standard GitHub Pages due to custom plugins
- Uses a workaround: builds locally to `./docs` folder which GitHub serves
- Search functionality requires running `pagefind.exe` after Jekyll build
- Development server runs on port 5000 (not default 4000)

### Dependencies
- Jekyll <4
- MiniMagick for image processing
- jekyll-archives for automatic archive generation
- jekyll-paginate-v2 for pagination
- kramdown-parser-gfm for GitHub Flavored Markdown