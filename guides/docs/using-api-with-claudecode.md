# Using Claude Code with the SciLifeLab OpenLLM API

Claude Code can use a model hosted by the SciLifeLab OpenLLM service through Open WebUI's Anthropic-compatible Messages API. This lets you use the same API key and available models as the web interface without an Anthropic API account.

## Prerequisites

Before you begin, you need:

1. An [API key](getting-started-api.md#get-your-api-key) for the SciLifeLab OpenLLM service
2. [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) installed and available as the `claude` command
3. A model ID exposed by the service

## Find an available model

Create an API key in Open WebUI under **Settings -> Account -> API Keys**. Then list the model IDs available to your account:

```bash
export OPENWEBUI_URL="https://open-llm.scilifelab.se"
export OPENWEBUI_API_KEY="sk-your-api-key-here"

curl -s \
  -H "Authorization: Bearer $OPENWEBUI_API_KEY" \
  "$OPENWEBUI_URL/api/models" | jq '.data[].id'
```

Use a model ID exactly as returned by this command. For example:

```bash
export MODEL="Qwen3-235B-A22B"
```

!!! note
    Model availability can change during the pilot. Run the command above instead of relying on an older model name.

## Configure Claude Code for the current shell

Open WebUI accepts Anthropic-format messages at its Messages API endpoint. Configure Claude Code to use the Open WebUI API base URL and your API key:

```bash
export ANTHROPIC_BASE_URL="$OPENWEBUI_URL/api"
export ANTHROPIC_API_KEY="$OPENWEBUI_API_KEY"

claude --model "$MODEL"
```

The `/api` suffix is required. Do not set the base URL to `/api/v1`: Claude Code adds `/v1/messages` itself, resulting in the Open WebUI endpoint `POST /api/v1/messages`.

For reliable use with a non-Anthropic model, also map Claude Code's named model roles and subagents to the same self-hosted model:

```bash
export ANTHROPIC_BASE_URL="$OPENWEBUI_URL/api"
export ANTHROPIC_API_KEY="$OPENWEBUI_API_KEY"
export ANTHROPIC_MODEL="$MODEL"
export ANTHROPIC_DEFAULT_SONNET_MODEL="$MODEL"
export ANTHROPIC_DEFAULT_OPUS_MODEL="$MODEL"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="$MODEL"
export CLAUDE_CODE_SUBAGENT_MODEL="$MODEL"

claude --model "$MODEL"
```

Claude Code can select distinct models for subagents and fast or background work. These mappings ensure those requests use the model served by Open WebUI as well.

## Save the configuration

To avoid exporting variables in every new shell, add the configuration to `~/.claude/settings.json`. Create the file or merge the following values into its existing JSON object:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://open-llm.scilifelab.se/api",
    "ANTHROPIC_AUTH_TOKEN": "sk-TOKEN",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "Qwen3-235B-A22B",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "Qwen3-235B-A22B",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "Qwen3-235B-A22B",
    "CLAUDE_CODE_SUBAGENT_MODEL": "Qwen3-235B-A22B",
    "CLAUDE_CODE_ENABLE_TELEMETRY": "0",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "CLAUDE_CODE_ATTRIBUTION_HEADER": "0",
    "CLAUDE_CODE_MAX_CONTEXT_TOKENS": "65536"
  },
  "attribution": {
    "commit": "",
    "pr": ""
  },
  "model": "Qwen3-235B-A22B",
  "effortLevel": "high",
  "promptSuggestionEnabled": false,
  "plansDirectory": "./plans",
  "prefersReducedMotion": true,
  "terminalProgressBarEnabled": false,
  "tui": "fullscreen"
}
```

Replace both `Qwen3-235B-A22B` values with the model ID you selected and replace `sk-your-api-key-here` with your API key. Keep the API key private and do not commit this settings file to source control.

After saving, start Claude Code from a project directory:

```bash
cd your-project
claude
```

## Test the setup

Ask Claude Code to perform a small task, such as explaining a function in the current project. A response confirms that it can reach the selected self-hosted model.

If the command fails, check the following:

- **Unauthorized or 401 error:** Confirm that the API key is current. Pilot API keys expire after four weeks; create a new one under **Settings -> Account -> API Keys** if needed.
- **Model not found:** List the models again with `GET /api/models` and use the returned ID verbatim.
- **404 error:** Check that `ANTHROPIC_BASE_URL` ends in `/api`, not `/api/v1`.
- **Slow responses:** The pilot runs on shared infrastructure, so response times vary with service load.

For account and API-key help, see [Getting started with the API](getting-started-api.md) or contact [serve@scilifelab.se](mailto:serve@scilifelab.se).
