# Use official Ruby 2.6.3 image based on Debian
FROM ruby:2.6.3-slim-buster

# Set environment variables

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Update apt sources to use Debian archive (Buster is EOL)
RUN sed -i 's|http://deb.debian.org|http://archive.debian.org|g' /etc/apt/sources.list \
    && sed -i 's|http://security.debian.org|http://archive.debian.org|g' /etc/apt/sources.list \
    && sed -i '/stretch-updates/d' /etc/apt/sources.list

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Build essentials for native gem extensions
    build-essential \
    git \
    # ImageMagick for image processing
    imagemagick \
    libmagickwand-dev \
    # Node.js and npm
    curl \
    wget \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

 
# Install Node.js 18.x (LTS) and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*


# Verify installations
RUN ruby --version && \
    node --version && \
    npm --version

# Install Bundler (specific version compatible with Ruby 2.6.3)
RUN gem update --system 3.2.3
RUN gem install bundler:2.4.22

# Install Pagefind
RUN npm install -g pagefind

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock first for better Docker layer caching
COPY Gemfile Gemfile.lock ./

# Install Ruby dependencies
RUN bundle install

# Install Claude Code globally
# Using --no-fund and --no-audit flags to reduce installation noise
RUN npm install -g @anthropic-ai/claude-code --no-fund --no-audit

# Expose Jekyll's default port
EXPOSE 4000

# Default command - run terminal
CMD ["bash"]