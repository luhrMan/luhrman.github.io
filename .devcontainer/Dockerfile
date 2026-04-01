# Hugo Extended — keep HUGO_VERSION in sync with .github/workflows/hugo.yml
FROM mcr.microsoft.com/devcontainers/base:jammy

ARG HUGO_VERSION=0.156.0

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get install -y --no-install-recommends curl ca-certificates \
  && ARCH="$(dpkg --print-architecture)" \
  && case "$ARCH" in \
       amd64) HUGO_DEB_ARCH=amd64 ;; \
       arm64) HUGO_DEB_ARCH=arm64 ;; \
       *) echo "unsupported architecture: $ARCH" >&2; exit 1 ;; \
     esac \
  && curl -fsSL -o /tmp/hugo.deb \
       "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-${HUGO_DEB_ARCH}.deb" \
  && apt-get install -y /tmp/hugo.deb \
  && rm /tmp/hugo.deb \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
