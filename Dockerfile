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

# ---- Runtime stage: nginx serving both subpaths ----
FROM nginx:1.27-alpine

# Copy built sites into the web root
COPY --from=builder /site/use-policy /usr/share/nginx/html/use-policy
COPY --from=builder /site/guides     /usr/share/nginx/html/guides

# Replace default nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O- http://localhost/use-policy/ > /dev/null || exit 1
