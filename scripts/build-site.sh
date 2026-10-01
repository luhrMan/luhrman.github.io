#!/usr/bin/env bash
# Build the full luhrman.dev site into public/: the landing page from site-root/
# at the root and the Sqyre Hugo site under public/sqyre/.
#
#   ./scripts/build-site.sh            # production build (https://www.luhrman.dev/sqyre/)
#   ./scripts/build-site.sh --preview  # host-independent build, served on http://localhost:8080
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${PORT:-8080}"
cd "${ROOT}"

HUGO_ARGS=(--minify -e production --destination public/sqyre)
if [[ "${1:-}" == "--preview" ]]; then
  # Path-only base so assets load whatever host/port the preview is reached through.
  HUGO_ARGS+=(--baseURL "/sqyre/")
fi

rm -rf public
hugo "${HUGO_ARGS[@]}"
cp -r site-root/. public/

if [[ "${1:-}" == "--preview" ]]; then
  echo "Serving http://localhost:${PORT}/ (Sqyre at /sqyre/)"
  exec python3 -m http.server "${PORT}" --directory public
fi
