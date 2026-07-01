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
    -e 's|docs/images/|images/sqyre/|g' \
    -e 's|internal/assets/icons/sqyre.svg|/favicon.svg|g' \
    -e 's|(docs/DEVELOPING.md)|(#developing)|g' \
    -e 's|\[docs/DEVELOPING.md\](docs/DEVELOPING.md)|[Developing](#developing)|g' \
    -e 's|\[docs/DEVELOPING.md\](#developing)|[Developing](#developing)|g' \
    -e "s|(docs/README.md)|(${REPO_BLOB}/docs/README.md)|g" \
    -e "s|(\.\./|(${REPO_BLOB}/|g"
}

rewrite_for_features() {
  rewrite_for_site | sed -e 's|\[Developing\](#developing)|[Developing](/docs/build/#developing)|g'
}

extract_readme_section() {
  local file="$1"
  local heading="$2"
  awk -v h="## ${heading}" '
    $0 == h { p = 1; print; next }
    p && /^## / { exit }
    p { print }
  ' "${file}"
}

README_RAW="${SRC}/README.md"
rewrite_for_site <"${README_RAW}" >"${ASSETS_UP}/README.md"

{
  extract_readme_section "${README_RAW}" "Build (quick start)"
  echo ""
  echo "## Run"
  echo ""
  echo "After building, launch \`./bin/sqyre\` (Linux) or the Windows binary from \`bin/windows-amd64/\`. For creating and running macros, see [Docs](/docs/)."
} | rewrite_for_site >"${ASSETS_UP}/README.build.md"

{
  extract_readme_section "${README_RAW}" "What it does" | sed -e '/^---$/d'
  echo ""
  extract_readme_section "${README_RAW}" "Actions" | sed -e '/^---$/d'
} | rewrite_for_features >"${ASSETS_UP}/README.features.md"

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
