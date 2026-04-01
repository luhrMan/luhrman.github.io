#!/usr/bin/env bash
# Pull README and packaging metadata from the Sqyre application repo into assets/upstream/ and data/sqyre_meta.yaml.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM_DIR="${ROOT}/.cache/upstream-sqyre"
ASSETS_UP="${ROOT}/assets/upstream"
META_FILE="${ROOT}/data/sqyre_meta.yaml"

mkdir -p "${ASSETS_UP}"

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

cp "${SRC}/README.md" "${ASSETS_UP}/README.md"
if [[ -f "${SRC}/FyneApp.toml" ]]; then
  cp "${SRC}/FyneApp.toml" "${ASSETS_UP}/FyneApp.toml"
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
# Normalize .git suffix to a browser-friendly URL when possible
REPO_URL="${REPO_URL%.git}"

cat >"${META_FILE}" <<EOF
version: "${VERSION}"
commit: "${COMMIT}"
synced_at: "${SYNCED}"
repo_url: "${REPO_URL}"
EOF

echo "Synced from ${SRC} (commit ${COMMIT}) -> ${ASSETS_UP}/ and ${META_FILE}"
