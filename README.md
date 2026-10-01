# luhrman.dev

- `site-root/` — static landing page served at https://www.luhrman.dev/ (plus `CNAME`, `404.html`, `robots.txt`).
- Everything else is the Sqyre Hugo site, built into `public/sqyre/` and served at https://www.luhrman.dev/sqyre/.

To add another project, build it into `public/<name>/` in `.github/workflows/hugo.yml` and add a card to `site-root/index.html`.
