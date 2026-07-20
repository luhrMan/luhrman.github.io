#!/usr/bin/env bash
# Fetch the latest Sqyre WASM editor zip from GitHub Releases into static/wasm/.
# Trunk builds use absolute /asset paths; rewrite them to relative paths for /wasm/.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${ROOT}/static/wasm"
REPO="${SQYRE_RELEASES_REPO:-luhrMan/Sqyre}"
API="https://api.github.com/repos/${REPO}/releases?per_page=20"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

CURL_HEADERS=(-H "Accept: application/vnd.github+json" -H "User-Agent: sqyre-io-hugo-sync")
if [[ -n "${GITHUB_TOKEN:-}${GH_TOKEN:-}" ]]; then
  CURL_HEADERS+=(-H "Authorization: Bearer ${GITHUB_TOKEN:-${GH_TOKEN}}")
fi

echo "Looking up WASM asset on ${REPO} releases…"
ASSET_JSON="$(
  curl -fsSL "${CURL_HEADERS[@]}" "${API}" | python3 -c '
import json, sys
releases = json.load(sys.stdin)
for rel in releases:
    if rel.get("draft"):
        continue
    for asset in rel.get("assets") or []:
        name = asset.get("name") or ""
        url = asset.get("browser_download_url") or ""
        if name.endswith("-wasm.zip") and url:
            print(json.dumps({"tag": rel.get("tag_name") or "", "name": name, "url": url}))
            sys.exit(0)
sys.exit("error: no *-wasm.zip asset found in recent releases")
'
)"

TAG="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["tag"])' <<<"${ASSET_JSON}")"
NAME="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["name"])' <<<"${ASSET_JSON}")"
URL="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["url"])' <<<"${ASSET_JSON}")"

echo "Downloading ${NAME} (${TAG})…"
curl -fsSL "${CURL_HEADERS[@]}" -L -o "${TMP}/wasm.zip" "${URL}"

rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"
unzip -q -o "${TMP}/wasm.zip" -d "${OUT_DIR}"

if [[ ! -f "${OUT_DIR}/index.html" ]]; then
  echo "error: index.html missing after extracting ${NAME}" >&2
  exit 1
fi

# Trunk emits root-absolute imports; rewrite so the editor works under /wasm/.
python3 - "${OUT_DIR}/index.html" <<'PY'
import pathlib, re, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
# /sqyre-….js or /sqyre-…_bg.wasm → ./sqyre-….js / ./sqyre-…_bg.wasm
updated = re.sub(
    r"""(['"])/(sqyre-[^'"/]+\.(?:js|wasm))\1""",
    r"""\1./\2\1""",
    text,
)
if updated == text and "/sqyre-" in text:
    raise SystemExit("error: failed to rewrite absolute wasm asset paths in index.html")
path.write_text(updated, encoding="utf-8")
PY

# Record which release was synced (optional; ignored by the editor).
cat >"${OUT_DIR}/RELEASE.txt" <<EOF
repo: ${REPO}
tag: ${TAG}
asset: ${NAME}
synced_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

echo "WASM demo ready at static/wasm/ (from ${TAG} / ${NAME})"
