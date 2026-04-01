# Sqyre website

Static site built with [Hugo](https://gohugo.io/). This tree is meant to live in **its own Git repository**; it pulls build documentation and metadata from the [Sqyre application repository](https://github.com/your-org/sqyre) at build time.

## Prerequisites

Install Hugo (extended recommended):

```bash
go install -tags extended github.com/gohugoio/hugo@latest
```

## Sync data from the Sqyre repo

Before `hugo` locally (or let CI do it), copy README and version info from the main repo:

```bash
./scripts/sync-from-sqyre.sh
```

| Environment variable | Meaning |
|----------------------|---------|
| `SQYRE_REPO_PATH` | Path to an existing clone (skips network clone). |
| `SQYRE_REPO_URL` | Git URL when cloning (default: `https://github.com/your-org/sqyre.git`). |
| `SQYRE_REPO_REV` | Branch or tag (default: `main`). |

Replace `your-org/sqyre` in the default URL or in `.github/workflows/hugo.yml` with your real GitHub `owner/repo`.

## Develop locally

```bash
./scripts/sync-from-sqyre.sh
hugo server -D
```

Open http://localhost:1313

## Build for production

```bash
./scripts/sync-from-sqyre.sh
hugo --minify
```

Output is in `public/`.

## Publishing as a separate repository

From the monorepo root (if this folder still lives there), you can split history:

```bash
git subtree split --prefix=sqyre-website -b sqyre-website-split
```

Then add a remote for the new site repository, push `sqyre-website-split`, and set the default branch on GitHub.

Alternatively, copy this directory into a new repo (`git init`, first commit, push).
