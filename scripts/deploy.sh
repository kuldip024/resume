#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  deploy.sh  —  Local dev/prod build & serve simulator
#  Usage:
#    ./scripts/deploy.sh dev     → build & serve dev locally
#    ./scripts/deploy.sh prod    → build optimised prod bundle
#    ./scripts/deploy.sh clean   → remove dist/
# ─────────────────────────────────────────────────────────────

set -euo pipefail

ENV="${1:-dev}"
DIST="dist"
SRC="src"
SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "local")
DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)

print_banner() {
  echo ""
  echo "  ╔════════════════════════════════════╗"
  echo "  ║  Resume Deploy Script              ║"
  echo "  ║  Env  : ${ENV}                         ║"
  echo "  ║  SHA  : ${SHA}                     ║"
  echo "  ╚════════════════════════════════════╝"
  echo ""
}

clean() {
  echo "🧹 Cleaning dist/"
  rm -rf "$DIST"
  echo "✅ Done"
}

build() {
  echo "📦 Building for ${ENV}..."
  rm -rf "$DIST"
  mkdir -p "$DIST"
  cp -r "${SRC}/." "$DIST/"

  # Inject environment meta tag
  if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_INPLACE=(-i '')
  else
    SED_INPLACE=(-i)
  fi

  sed "${SED_INPLACE[@]}" \
    "s|<meta charset=\"UTF-8\" />|<meta charset=\"UTF-8\" />\n  <meta name=\"deploy-env\" content=\"${ENV}\" />\n  <meta name=\"build-sha\" content=\"${SHA}\" />|" \
    "$DIST/index.html"

  echo "<!-- ${ENV^^} BUILD · ${SHA} · ${DATE} -->" >> "$DIST/index.html"
  echo "✅ Build complete → ${DIST}/"
}

serve() {
  echo ""
  echo "🌐 Starting local server..."
  echo "   Open: http://localhost:8080"
  echo "   Press Ctrl+C to stop"
  echo ""
  if command -v python3 &>/dev/null; then
    cd "$DIST" && python3 -m http.server 8080
  elif command -v npx &>/dev/null; then
    npx --yes serve "$DIST" -p 8080
  else
    echo "❌ No server found. Install Python 3 or Node.js."
    exit 1
  fi
}

print_banner

case "$ENV" in
  dev)
    build
    serve
    ;;
  prod)
    build
    echo ""
    echo "✅ Production bundle ready in ./${DIST}/"
    echo "   Files:"
    find "$DIST" -type f | while read -r f; do
      SIZE=$(du -sh "$f" | cut -f1)
      echo "   ${SIZE}  ${f#$DIST/}"
    done
    ;;
  clean)
    clean
    ;;
  *)
    echo "❌ Unknown env: ${ENV}"
    echo "   Usage: ./scripts/deploy.sh [dev|prod|clean]"
    exit 1
    ;;
esac
