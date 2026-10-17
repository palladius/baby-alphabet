# Built for Baby Alphabet task runners
# First rule is always `list` -> `just -l`

list:
    @just -l

# Check for case-insensitive duplicate filenames in app/assets/
test:
    @echo "🔍 Checking for duplicate filenames in app/assets/..."
    @find app/assets/ | sort -f | uniq -di | { grep alphabet && exit 41 || :; }
    @echo "✅ Check OK: no case-insensitive duplicates in app/assets/"
    @echo "🔍 Testing static site generation..."
    @RBENV_VERSION=3.2.11 ruby bin/generate_static_site.rb /tmp/baby-alphabet-site
    @echo "✅ Static site generated in /tmp/baby-alphabet-site/index.html"

# Build the static GitHub Pages site into _site/
build-static:
    RBENV_VERSION=3.2.11 ruby bin/generate_static_site.rb _site

# Preview the static site locally on port 8080
serve-static: build-static
    python3 -m http.server 8080 --directory _site

# Run the Rails server via Docker
docker-run:
    make docker-run
