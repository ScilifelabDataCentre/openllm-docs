# syntax=docker/dockerfile:1.6

# ---- Build stage: produce static HTML for both sites ----
FROM python:3.12-slim AS builder

WORKDIR /build

# Install MkDocs + Material once
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Build use-policy site -> /site/use-policy
COPY use-policy/ ./use-policy/
RUN cd use-policy && mkdocs build --strict --site-dir /site/use-policy

# Build guides site -> /site/guides
COPY guides/ ./guides/
RUN cd guides && mkdocs build --strict --site-dir /site/guides

# ---- Runtime stage: nginx serving both subpaths as non-root ----
FROM nginxinc/nginx-unprivileged:1.27-alpine

# Copy built sites into the web root
COPY --from=builder --chown=nginx:nginx /site/use-policy /usr/share/nginx/html/use-policy
COPY --from=builder --chown=nginx:nginx /site/guides     /usr/share/nginx/html/guides

# Replace default nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

USER nginx

EXPOSE 8080
