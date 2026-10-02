# luhrman.dev

- `site-root/` — static landing page served at https://luhrman.dev/ (plus `CNAME`, `404.html`, `robots.txt`).
- Everything else is the Sqyre Hugo site, built into `public/sqyre/` and served at https://luhrman.dev/sqyre/.

To add another project, build it into `public/<name>/` in `.github/workflows/hugo.yml` and add a card to `site-root/index.html`.

## Testing locally

Open the repo in the devcontainer (Hugo Extended, Node 24, Python 3; `npm ci` runs on create), then:

```bash
./scripts/sync-from-sqyre.sh     # upstream README, screenshots, metadata
./scripts/sync-wasm-demo.sh      # WASM editor into static/wasm/
./scripts/build-site.sh --preview  # full site at http://localhost:8080/ (Sqyre at /sqyre/)
npm run dev                      # Sqyre-only live reload at http://localhost:1313/
```
