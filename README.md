# OpenLLM docs

Two MkDocs-Material sites that sit alongside the [OpenLLM](https://openllm.scilifelab.se) Open WebUI instance and surface user-facing documentation:

| Path | Purpose | Source |
| --- | --- | --- |
| `/use-policy/` | OpenLLM pilot use policy (single page) | `use-policy/` |
| `/guides/`     | Onboarding, API guide, announcements    | `guides/` |
| `/about/` | Primary landing page for the SciLifeLab OpenLLM service | `guides/docs/about.md` |

Both are built into one Docker image (nginx serving static HTML) and are intended to be reverse-proxied behind the same domain as Open WebUI itself.

## Repo layout

```
openllm-docs/
├── Dockerfile               # multi-stage: builds both sites, serves with nginx
├── docker-compose.yml       # one-command local run on :8000
├── nginx.conf               # routes /use-policy/ and /guides/ inside the container
├── requirements.txt         # mkdocs-material
├── theme/                   # shared Material overrides for both sites
│   ├── main.html
│   └── partials/
│       └── openllm-navbar.html
│
├── use-policy/
│   ├── mkdocs.yml
│   └── docs/
│       ├── index.md         # the policy itself
│       └── assets/
│           └── scilifelab_openllm_logo.svg # navbar wordmark
│
└── guides/
    ├── mkdocs.yml
    └── docs/
        ├── index.md
        ├── about.md          # service landing page; reuses source documentation
        ├── getting-started-api.md
        ├── announcement.md
        ├── stylesheets/
        │   ├── about-layout.css # About page structure and cards
        │   ├── about-code.css   # hero code card
        │   ├── about-facts.css  # facts grid
        │   └── about-policy.css # policy summary cards
        ├── assets/
        │   └── scilifelab_openllm_logo.svg # navbar wordmark
        └── images/          # drop screenshots here
```

## Quick start

### Docker

```bash
docker compose up --build
# open http://localhost:8000/about/
# open http://localhost:8000/use-policy/
# open http://localhost:8000/guides/
```

Or without compose:

```bash
docker build -t openllm-docs .
docker run --rm -p 8000:8080 openllm-docs
```

Locally, both sites serve from `/`, not from `/use-policy/` or `/guides/`. The subpaths only exist inside the Docker image.

## Deploying alongside Open WebUI

The Docker image listens on port 8080 and serves `/about/`, `/use-policy/`, and `/guides/`. The host's reverse proxy (the same one fronting Open WebUI) should route those paths to this container, and everything else to Open WebUI.

### nginx on the host

Add two `location` blocks **above** the catch-all that forwards to Open WebUI:

```nginx
server {
    server_name openllm.scilifelab.se;

    # OpenLLM service pages (this repo) on, e.g., 127.0.0.1:8000
    location /about {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

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
openllm.scilifelab.se {
    handle /about* {
        reverse_proxy 127.0.0.1:8000
    }
    handle /use-policy/* {
        reverse_proxy 127.0.0.1:8000
    }
    handle /guides/* {
        reverse_proxy 127.0.0.1:8000
    }
    handle {
        reverse_proxy 127.0.0.1:8080
    }
}
```

The plain `handle` directives preserve the path so the in-container nginx routes can serve each site.

### Linking from Open WebUI

Once the paths are live, surface them inside the chat UI via **Admin Panel → Settings → Interface → Banners**, e.g.:

> ⚠️ By using this service you agree to the [use policy](/use-policy/). New here? Start at the [OpenLLM service page](/about/).

## License / ownership

MIT
