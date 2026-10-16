# Using Mistral Vibe Code with the SciLifeLab OpenLLM API

Mistral Vibe's CLI can connect to the SciLifeLab OpenLLM service through Open
WebUI's OpenAI-compatible Chat Completions endpoint. This lets you use the
same API key and models as the web interface without a Mistral account.

!!! note
The Mistral Vibe VS Code extension is oriented around Mistral-hosted
models and its built-in sign-in flow assumes a Mistral account. This guide
covers the CLI instead, which supports arbitrary OpenAI-compatible
providers through `config.toml`.

## Prerequisites

Before you begin, you need:

1. An [API key](getting-started-api.md#get-your-api-key) for the SciLifeLab
   OpenLLM service
2. The Mistral Vibe CLI installed (see below)
3. A model ID exposed by the service

## Install the CLI

On Linux or macOS:

```
curl -LsSf https://mistral.ai/vibe/install.sh | bash
```

This installs three executables (`vibe`, `vibe-acp`, `vibe-app-server`) to
`~/.local/bin`. If that directory isn't already on your `PATH`, the installer
prints a warning like:

```
[ERROR] Your PATH does not include the folder that contains 'vibe'.
[ERROR] Add this directory to your shell profile, then restart your terminal:
[ERROR]   export PATH="/home/<you>/.local/bin:$PATH"
```

Add the suggested line to your shell profile (`~/.bashrc`, `~/.zshrc`, or
equivalent), then restart your terminal or run `source` on the profile file.
Confirm it worked:

```
vibe --version
```

Alternative install methods (`uv tool install mistral-vibe` or
`pip install mistral-vibe`) are also available — see the
[CLI install guide](https://docs.mistral.ai/vibe/code/cli/install-setup) for
details and Windows instructions.

## Find an available model

List the model IDs available to your account:

```
export OPENWEBUI_URL="https://openllm.scilifelab.se"
export OPENWEBUI_API_KEY="sk-your-api-key-here"

curl -s \
  -H "Authorization: Bearer $OPENWEBUI_API_KEY" \
  "$OPENWEBUI_URL/api/models" | jq '.data[].id'
```

Use a model ID exactly as returned by this command, for example:

```
export MODEL="Qwen3-235B-A22B"
```

!!! note
Model availability can change during the pilot. Run the command above
instead of relying on an older model name.

## Configure the CLI

Vibe is configured through `~/.vibe/config.toml`. Open or create that file
and add the configuration below. Add only the TOML content — do not include
any surrounding Markdown code fences; those are formatting only, not part of
the file.

`active_model` must appear before any `[[providers]]` or `[[models]]` table
header — in TOML, a bare key placed after such a header is attached to that
table instead of being read as a top-level setting:

```
active_model = "openllm-vibe"

[[providers]]
name = "openllm-scilifelab"
api_base = "https://openllm.scilifelab.se/api"
api_style = "openai"
backend = "generic"
api_key_env_var = "OPENLLM_API_KEY"

[[models]]
name = "Qwen3-235B-A22B"
provider = "openllm-scilifelab"
alias = "openllm-vibe"
```

Replace `Qwen3-235B-A22B` with the model ID you selected. The `api_base` must
end in `/api`, not `/api/v1` or `/v1` — that is the path Open WebUI's
OpenAI-compatible layer is mounted at on this service. The `alias` is a local
nickname for this model preset — it's what `active_model` refers to, and
what the CLI displays in `/model` and `/status`, rather than the real
underlying model name (`name`).

Store your API key in `~/.vibe/.env`:

```
OPENLLM_API_KEY=sk-your-api-key-here
```

Keep this file private and do not commit it to source control.

Because `active_model` now points at this custom provider rather than a
Mistral-hosted model, Vibe uses the key above and does not prompt for a
Mistral account or API key.

## Test the setup

From a project directory, start Vibe:

```
cd your-project
vibe
```

Ask it to explain a function or make a small change. A response confirms that
Vibe can reach the selected self-hosted model.

## Verify which model is active

Since `config.toml` lets you alias a model to any name, it's worth confirming
Vibe is actually using the model you expect before relying on it.

- **`/status`** — shows the active model, provider, and API base for the
  current session. This is the most direct check; if it isn't available in
  your installed version, upgrade with `uv tool upgrade mistral-vibe` or by
  re-running the install script.
- **`/model`** — opens a picker listing configured model presets, with the
  active one highlighted. Note that this list shows each preset's `alias`
  (`openllm-vibe` in the config above), not the underlying `name` — so seeing
  `openllm-vibe` here confirms your custom preset is selected, but doesn't by
  itself tell you which real model (e.g. `Qwen3-235B-A22B`) it maps to. Cross
  check against `config.toml` or `/status` for that.
- **`cat ~/.vibe/config.toml`** — the most unambiguous check, bypassing the
  CLI entirely. Confirm `active_model` is a top-level value (before any
  `[[...]]` header) and matches the alias you intended.
- **Server-side confirmation** — if you have admin access to Open WebUI, its
  request logs show the real model ID used for each call, which is the most
  authoritative way to confirm what actually served your request.

## Troubleshooting

- **`vibe: command not found`:** The install directory (usually
  `~/.local/bin`) isn't on your `PATH`. Add
  `export PATH="$HOME/.local/bin:$PATH"` to your shell profile and restart
  your terminal.
- **`Invalid API key (from the keyring)`:** Vibe is still using its default
  Mistral-hosted model instead of your custom one. This almost always means
  `active_model` is not being read as a top-level setting — check that it
  appears *before* any `[[providers]]` or `[[models]]` header in
  `config.toml`, not after. Confirm the active model with `/status`.
- **Unauthorized or 401 error (after confirming the active model is
  correct):** Confirm the API key is current. Pilot API keys expire after
  four weeks; create a new one under **Settings -> Account -> API Keys** if
  needed.
- **Model not found:** List the models again with `GET /api/models` and use
  the returned ID verbatim in both the `[[models]]` `name` and as the
  `active_model` alias.
- **404 error:** Check that `api_base` ends in `/api`, not `/api/v1`.
- **TOML parse error / config won't load:** Make sure `config.toml` contains
  only the TOML content above, with no Markdown code fences or other extra
  lines copied in by mistake.
- **Slow responses:** The pilot runs on shared infrastructure, so response
  times vary with service load.

For account and API-key help, see
[Getting started with the API](getting-started-api.md) or contact
<openllm@scilifelab.se>.