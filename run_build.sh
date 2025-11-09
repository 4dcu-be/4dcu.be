#!/bin/bash
set -e

rm -rf docs/pagefind/*

bundle exec jekyll build --config _config.yml && \
pagefind