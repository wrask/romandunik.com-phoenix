FROM node:24.6-trixie-slim AS assets

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

ARG NODE_ENV="production"
ENV NODE_ENV="${NODE_ENV}" \
    PATH="${PATH}:/node_modules/.bin" \
    USER="node"

COPY --chown=node:node . ..

RUN if [ "${NODE_ENV}" != "development" ]; then \
  ../run yarn:build:js && ../run yarn:build:css; else mkdir -p /app/priv/static; fi

###############################################################################

FROM elixir:1.18.3-slim AS dev

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

ARG MIX_ENV="prod"
ENV MIX_ENV="${MIX_ENV}" \
    USER="elixir"

COPY --chown=elixir:elixir mix.* ./

RUN if [ "${MIX_ENV}" = "dev" ]; then \
  HEX_HTTP_CONCURRENCY=1 HEX_HTTP_TIMEOUT=120 mix deps.get; \
  else HEX_HTTP_CONCURRENCY=1 HEX_HTTP_TIMEOUT=120 mix deps.get --only "${MIX_ENV}"; fi

COPY --chown=elixir:elixir config/config.exs config/"${MIX_ENV}".exs config/
RUN mix deps.compile

COPY --chown=elixir:elixir --from=assets /app/priv/static /public
COPY --chown=elixir:elixir . .

RUN if [ "${MIX_ENV}" != "dev" ]; then \
  ln -s /public /app/priv/static \
  && mix phx.digest && mix release && rm -rf /app/priv/static; fi

RUN chmod +x bin/docker-entrypoint-web
ENTRYPOINT ["/app/bin/docker-entrypoint-web"]

EXPOSE 4000

CMD ["iex", "-S", "mix", "phx.server"]

###############################################################################

FROM elixir:1.18.3-slim AS prod

WORKDIR /app

ARG UID=1000
ARG GID=1000

RUN apt-get update \
  && apt-get install -y --no-install-recommends curl \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && groupadd -g "${GID}" elixir \
  && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" elixir \
  && chown elixir:elixir -R /app

USER elixir

ENV USER=elixir

COPY --chown=elixir:elixir --from=dev /public /public
COPY --chown=elixir:elixir --from=dev /mix/_build/prod/rel/hello ./
COPY --chown=elixir:elixir bin/docker-entrypoint-web bin/

RUN chmod +x bin/docker-entrypoint-web
ENTRYPOINT ["/app/bin/docker-entrypoint-web"]

EXPOSE 4000

CMD ["/app/bin/hello", "start"]
