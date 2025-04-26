# v0.7.7

# Base node image
FROM node:20-slim AS node

# Install Python3, venv, pip, build deps, and jemalloc
RUN apt-get update && apt-get install -y python3 python3-venv python3-pip build-essential libssl-dev pkg-config libffi-dev libjemalloc2
# Create Python venv for MCP servers and update PATH
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"
ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2

# Add `uv` for extended MCP support
COPY --from=ghcr.io/astral-sh/uv:0.6.13 /uv /uvx /bin/
RUN uv --version

RUN mkdir -p /app && chown node:node /app
WORKDIR /app

USER node

COPY --chown=node:node . .
COPY --chown=node:node --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh

RUN \
    # Allow mounting of these files, which have no default
    touch .env ; \
    # Create directories for the volumes to inherit the correct permissions
    mkdir -p /app/client/public/images /app/api/logs ; \
    npm config set fetch-retry-maxtimeout 600000 ; \
    npm config set fetch-retries 5 ; \
    npm config set fetch-retry-mintimeout 15000 ; \
    npm install --no-audit; \
    # React client build
    NODE_OPTIONS="--max-old-space-size=2048" npm run frontend; \
    npm prune --production; \
    npm cache clean --force

RUN mkdir -p /app/client/public/images /app/api/logs

# Node API setup
EXPOSE 3080
ENV HOST=0.0.0.0
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Optional: for client with nginx routing
# FROM nginx:stable-alpine AS nginx-client
# WORKDIR /usr/share/nginx/html
# COPY --from=node /app/client/dist /usr/share/nginx/html
# COPY client/nginx.conf /etc/nginx/conf.d/default.conf
# ENTRYPOINT ["nginx", "-g", "daemon off;"]