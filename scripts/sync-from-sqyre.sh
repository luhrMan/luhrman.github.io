#!/usr/bin/env bash
# Pull README, DEVELOPING.md, screenshots, and packaging metadata from the Sqyre
# application repo into assets/upstream/, static/images/sqyre/, and data/sqyre_meta.yaml.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM_DIR="${ROOT}/.cache/upstream-sqyre"
ASSETS_UP="${ROOT}/assets/upstream"
IMAGES_DIR="${ROOT}/static/images/sqyre"
META_FILE="${ROOT}/data/sqyre_meta.yaml"

mkdir -p "${ASSETS_UP}" "${IMAGES_DIR}"

if [[ -n "${SQYRE_REPO_PATH:-}" ]]; then
  SRC="$(cd "${SQYRE_REPO_PATH}" && pwd)"
else
  URL="${SQYRE_REPO_URL:-https://github.com/luhrMan/sqyre.git}"
  REV="${SQYRE_REPO_REV:-main}"
  rm -rf "${UPSTREAM_DIR}"
  git clone --depth 1 --branch "${REV}" "${URL}" "${UPSTREAM_DIR}"
  SRC="${UPSTREAM_DIR}"
fi

if [[ ! -f "${SRC}/README.md" ]]; then
  echo "error: README.md not found under ${SRC}" >&2
  exit 1
fi

COMMIT="$(git -C "${SRC}" rev-parse HEAD 2>/dev/null || echo unknown)"
SYNCED="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
VERSION="unknown"
if [[ -f "${SRC}/FyneApp.toml" ]]; then
  VERSION="$(grep -E '^Version\s*=' "${SRC}/FyneApp.toml" | head -1 | sed 's/.*=\s*"\([^"]*\)".*/\1/' || true)"
fi
REPO_URL="${SQYRE_REPO_URL:-}"
if [[ -z "${REPO_URL}" && -n "${SQYRE_REPO_PATH:-}" ]]; then
  REPO_URL="$(git -C "${SRC}" remote get-url origin 2>/dev/null || true)"
fi
if [[ -z "${REPO_URL}" ]]; then
  REPO_URL="${URL:-https://github.com/luhrMan/sqyre.git}"
fi
REPO_URL="${REPO_URL%.git}"
REPO_BLOB="${REPO_URL}/blob/main"

rewrite_for_site() {
  sed \
    -e 's|docs/images/|/images/sqyre/|g' \
    -e 's|internal/assets/icons/sqyre.svg|/favicon.svg|g' \
    -e 's|(docs/DEVELOPING.md)|(#developing)|g' \
    -e 's|\[docs/DEVELOPING.md\](docs/DEVELOPING.md)|[Developing](#developing)|g' \
    -e "s|(\.\./|(${REPO_BLOB}/|g"
}

rewrite_for_site <"${SRC}/README.md" >"${ASSETS_UP}/README.md"

if [[ -f "${SRC}/docs/DEVELOPING.md" ]]; then
  rewrite_for_site <"${SRC}/docs/DEVELOPING.md" >"${ASSETS_UP}/DEVELOPING.md"
fi

if [[ -f "${SRC}/FyneApp.toml" ]]; then
  cp "${SRC}/FyneApp.toml" "${ASSETS_UP}/FyneApp.toml"
fi

if [[ -d "${SRC}/docs/images" ]]; then
  rsync -a --delete --exclude='frames/' "${SRC}/docs/images/" "${IMAGES_DIR}/"
fi

cat >"${META_FILE}" <<EOF
version: "${VERSION}"
commit: "${COMMIT}"
synced_at: "${SYNCED}"
repo_url: "${REPO_URL}"
EOF

echo "Synced from ${SRC} (commit ${COMMIT}) -> ${ASSETS_UP}/, ${IMAGES_DIR}/, ${META_FILE}"
