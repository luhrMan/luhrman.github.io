# Hugo Extended + Node — keep versions in sync with .github/workflows/hugo.yml
FROM mcr.microsoft.com/devcontainers/base:jammy

ARG HUGO_VERSION=0.156.0
ARG NODE_MAJOR=24

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get install -y --no-install-recommends curl ca-certificates git python3 unzip \
  && curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - \
  && apt-get install -y --no-install-recommends nodejs \
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
