###############################################################################
FROM node:20.16-bookworm-slim AS assets

WORKDIR /app/assets

ARG UID=1000
ARG GID=1000

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && groupmod -g "${GID}" node && usermod -u "${UID}" -g "${GID}" node \
  && mkdir -p /node_modules && chown node:node -R /node_modules /app

USER node

COPY --chown=node:node assets/package.json assets/*yarn* ./

RUN yarn install && yarn cache clean

ENV NODE_ENV="${NODE_ENV}" \
    PATH="${PATH}:/node_modules/.bin" \
    USER="node"

COPY --chown=node:node . ..

RUN mkdir -p /app/priv/static

###############################################################################
FROM elixir:1.17.2-slim AS dev

WORKDIR /app

ARG UID=1000
ARG GID=1000

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates build-essential curl inotify-tools \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && groupadd -g "${GID}" elixir \
  && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" elixir \
  && mkdir -p /mix && chown elixir:elixir -R /mix /app

USER elixir

RUN mix local.hex --force && mix local.rebar --force

ARG MIX_ENV="dev"
ENV MIX_ENV="${MIX_ENV}" \
    USER="elixir"

COPY --chown=elixir:elixir mix.* ./
RUN mix deps.get

COPY --chown=elixir:elixir config/config.exs config/"${MIX_ENV}".exs config/
RUN mix deps.compile

COPY --chown=elixir:elixir --from=assets /app/priv/static /public
COPY --chown=elixir:elixir . .

ENTRYPOINT ["/app/bin/docker-entrypoint-web"]

CMD ["iex", "-S", "mix", "phx.server"]