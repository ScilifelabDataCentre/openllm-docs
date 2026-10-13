# syntax=docker/dockerfile:1.27

# ---- Build stage: produce static HTML for both sites ----
FROM python:3.14-slim AS builder

WORKDIR /build

# Install MkDocs + Material once
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Shared Material override used by both documentation sites.
COPY theme/ ./theme/

# Build docs site -> /site/docs
COPY docs/ ./docs/
RUN cd docs && mkdocs build --strict --site-dir /site/docs

# ---- Runtime stage: nginx serving both subpaths as non-root ----
FROM nginxinc/nginx-unprivileged:1.31-alpine

# Copy built sites into the web root
COPY --from=builder --chown=nginx:nginx /site/docs     /usr/share/nginx/html/docs

# Replace default nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Use a numeric UID/GID so Kubernetes can verify runAsNonRoot.
USER 101:101

EXPOSE 8080
