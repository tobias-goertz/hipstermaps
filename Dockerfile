# syntax=docker/dockerfile:1

# ============================================================
# Stage 1: Builder – install gems and compile assets
# ============================================================
FROM ruby:2.7.6-slim AS builder

# Build dependencies (compilers, dev headers)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libicu-dev \
    libpq-dev \
    libtre-dev \
    zlib1g-dev

# Install Node.js 16 (needed only as ExecJS runtime for asset compilation)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
  && apt-get install -y --no-install-recommends nodejs

ENV LANG=C.UTF-8
ENV TZ=Europe/Berlin

# Install compatible Bundler (don't update rubygems – latest requires Ruby 3.2+)
RUN gem install bundler -v '~> 2.3.0'

RUN adduser --shell /bin/bash --home /app --disabled-password nonroot
USER nonroot

WORKDIR /app

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}
ARG BUNDLE_WITHOUT="development test"

# Bundle install with persistent vendor cache for incremental rebuilds.
# When Gemfile changes, the cache restores previously compiled gems so only
# changed/new gems need to be compiled (saves 2-4 min vs full rebuild).
COPY --chown=nonroot .ruby-version Gemfile Gemfile.lock ./
RUN --mount=type=cache,target=/tmp/vendor-cache,uid=1000 \
    --mount=type=cache,target=/usr/local/bundle/cache \
    bundle config set deployment 'true' \
    && bundle config set without "${BUNDLE_WITHOUT}" \
    && (cp -a /tmp/vendor-cache/bundle vendor/ 2>/dev/null || true) \
    && bundle install \
      --jobs "$(nproc)" \
      --retry 3 \
    && rm -rf /tmp/vendor-cache/bundle \
    && cp -a vendor/bundle /tmp/vendor-cache/bundle

# Copy application code
COPY --chown=nonroot . ./

# Precompile assets with Sprockets cache for incremental rebuilds.
# The cache mount persists tmp/cache across builds so only changed
# assets need recompilation (saves 1-2 min vs full recompile).
ARG GIT_REV=unknown
ENV GIT_REV=${GIT_REV}
RUN --mount=type=cache,target=/app/tmp/cache,uid=1000 \
    export $(cat .env.build | xargs) && bundle exec rake assets:precompile

# ============================================================
# Stage 2: Runtime – minimal image without build tooling
# ============================================================
FROM ruby:2.7.6-slim

# Node.js binary only (ExecJS runtime needed by uglifier at boot)
COPY --from=builder /usr/bin/node /usr/bin/node

# Runtime-only libraries (no compilers, no -dev headers)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    ca-certificates \
    ghostscript \
    libgs9-common \
    libicu67 \
    libnss3 \
    libpq5 \
    libtre5 \
    postgresql-client

ENV LANG=C.UTF-8
ENV TZ=Europe/Berlin

RUN gem install bundler -v '~> 2.3.0'

RUN adduser --shell /bin/bash --home /app --disabled-password nonroot
USER nonroot

WORKDIR /app

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}
ARG GIT_REV=unknown
ENV GIT_REV=${GIT_REV}

# Copy app with compiled gems and precompiled assets from builder
COPY --from=builder --chown=nonroot /app /app

# Re-set bundle config (builder's /usr/local/bundle/config is not copied)
RUN bundle config set deployment 'true' \
    && bundle config set path vendor/bundle \
    && bundle config set without "development test"

ENV PORT=5000
EXPOSE 5000
CMD ["bundle", "exec", "puma"]
