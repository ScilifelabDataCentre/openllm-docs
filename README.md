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

### Option A — Docker (recommended)

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

### Option B — Local dev with live reload

Run each site on its own port; edits to Markdown reload automatically.

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# Use policy at http://127.0.0.1:8001
(cd use-policy && mkdocs serve -a 127.0.0.1:8001)

# Guides at http://127.0.0.1:8002 (in another terminal)
(cd guides && mkdocs serve -a 127.0.0.1:8002)
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

## Editing content

- Add or edit `.md` files under `use-policy/docs/` or `guides/docs/`.
- For the **guides** site, add new pages to `nav:` in `guides/mkdocs.yml` so they appear in the sidebar.
- The use-policy site is single-page; the policy lives at `use-policy/docs/index.md`.
- Drop screenshots in `guides/docs/images/`. Filenames expected by `getting-started-api.md` are listed in `guides/docs/images/README.txt`.

Both `mkdocs.yml` files enable Material's `admonition` extension, so you can use callouts like:

```markdown
!!! warning "Heads up"
    Don't paste sensitive data into prompts.
```

## Rebuilding after changes

```bash
docker compose up --build -d
```

If you're using a registry/CI:

```bash
docker build -t registry.example.org/openllm-docs:$(git rev-parse --short HEAD) .
docker push  registry.example.org/openllm-docs:$(git rev-parse --short HEAD)
```

## Troubleshooting

- **Broken CSS/JS in production but fine locally.** The `site_url` in each `mkdocs.yml` controls the asset base path. They are set to `https://open-llm.scilifelab.se/use-policy/` and `.../guides/`. Change both if you serve from a different domain or subpath, and rebuild.
- **`mkdocs build --strict` fails on a broken link.** Strict mode is intentional — it catches typos before they ship. Fix the link or remove `--strict` from the Dockerfile temporarily.
- **404 inside the container but file exists.** Clean URLs need a trailing slash. `try_files` in `nginx.conf` handles this for normal navigation; if you hit it with `curl`, request `/guides/getting-started-api/` not `.../getting-started-api`.

## License / ownership

MIT
