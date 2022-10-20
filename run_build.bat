del /q "docs\pagefind\*"

bundle exec jekyll build --config _config.yml && ^
.\pagefind.exe
