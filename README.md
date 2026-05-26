# OpenLLM docs

Two MkDocs-Material sites that sit alongside the [OpenLLM](https://open-llm.scilifelab.se) Open WebUI instance and surface user-facing documentation:

| Path | Purpose | Source |
| --- | --- | --- |
| `/use-policy/` | OpenLLM pilot use policy (single page) | `use-policy/` |
| `/guides/`     | Onboarding, API guide, announcements    | `guides/` |

Both are built into one Docker image (nginx serving static HTML) and are intended to be reverse-proxied behind the same domain as Open WebUI itself.

## Repo layout

```
openllm-docs/
├── Dockerfile               # multi-stage: builds both sites, serves with nginx
├── docker-compose.yml       # one-command local run on :8000
├── nginx.conf               # routes /use-policy/ and /guides/ inside the container
├── requirements.txt         # mkdocs-material
│
├── use-policy/
│   ├── mkdocs.yml
│   └── docs/
│       └── index.md         # the policy itself
│
└── guides/
    ├── mkdocs.yml
    └── docs/
        ├── index.md
        ├── getting-started-api.md
        ├── announcement.md
        └── images/          # drop screenshots here
```

## Quick start

### Docker

```bash
docker compose up --build
# open http://localhost:8000/use-policy/
# open http://localhost:8000/guides/
```

Or without compose:

```bash
docker build -t openllm-docs .
docker run --rm -p 8000:80 openllm-docs
```

Locally, both sites serve from `/`, not from `/use-policy/` or `/guides/`. The subpaths only exist inside the Docker image.

## Deploying alongside Open WebUI

The Docker image listens on port 80 and serves `/use-policy/` and `/guides/`. The host's reverse proxy (the same one fronting Open WebUI) should route those two paths to this container, and everything else to Open WebUI.

### nginx on the host

Add two `location` blocks **above** the catch-all that forwards to Open WebUI:

```nginx
server {
    server_name open-llm.scilifelab.se;

    # Docs container (this repo) on, e.g., 127.0.0.1:8000
    location /use-policy/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /guides/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Everything else -> Open WebUI
    location / {
        proxy_pass http://127.0.0.1:8080;          # adjust to your Open WebUI port
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Caddy

```caddy
open-llm.scilifelab.se {
    handle_path /use-policy/* {
        reverse_proxy 127.0.0.1:8000
    }
    handle_path /guides/* {
        reverse_proxy 127.0.0.1:8000
    }
    handle {
        reverse_proxy 127.0.0.1:8080
    }
}
```

Note: `handle_path` strips the prefix, which would break the in-container nginx routing. Use plain `handle` + `reverse_proxy` if you want the path passed through unchanged — adjust to taste.

### Linking from Open WebUI

Once the paths are live, surface them inside the chat UI via **Admin Panel → Settings → Interface → Banners**, e.g.:

> ⚠️ By using this service you agree to the [use policy](/use-policy/). New here? See the [guides](/guides/).

## License / ownership

MIT
