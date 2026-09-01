# Using Qwen Code with the SciLifeLab OpenLLM API

Qwen Code is an AI-powered coding assistant that helps developers write, understand, and refactor code more efficiently. This guide explains how to configure Qwen Code to use the self-hosted SciLifeLab OpenLLM API, enabling you to leverage powerful AI coding assistance within your development workflow.

## Prerequisites

Before configuring Qwen Code, you'll need:

1. [**An API key** from the SciLifeLab OpenLLM service](getting-started-api.md#get-your-api-key)
2. **Qwen Code** installed on your system

## Installation

Qwen Code can be installed on various platforms using different methods. Choose the approach that best fits your operating system and preferences.

### For Linux and macOS

1. Open your terminal
2. Run the following command:

```bash
curl -fsSL https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen-standalone.sh | bash
```

3. After installation, restart your terminal if the `qwen` command is not immediately available in your `PATH`

### For Windows

1. Open **PowerShell** (as a regular user)
2. Run the following command:

```powershell
irm https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen-standalone.ps1 | iex
```

3. After installation, restart your terminal if the `qwen` command is not recognized

### Alternative Installation Methods

**Using npm** (requires Node.js 22 or later):

```bash
npm install -g @qwen-code/qwen-code@latest
```

**Using Homebrew** (macOS and Linux):

```bash
brew install qwen-code
```

### After Installation (All Platforms)

1. Navigate to your project directory:

```bash
cd your-project
```

2. [Configure Qwen Code](#configuring-qwen-code) with your SciLifeLab OpenLLM API key

3. Launch Qwen Code:

```bash
qwen
```

3. On first launch, you will be prompted to:
   - Connect a model provider (e.g., Alibaba ModelStudio, OpenAI, or a custom provider)
   - Configure settings as needed

## Getting Your API Key

To obtain your API key, follow the instructions in the [Getting Started with the API](getting-started-api.md#get-your-api-key) guide:

1. Log in to [https://open-llm.scilifelab.se](https://open-llm.scilifelab.se)
2. Go to **Settings → Account → API Keys**
3. Click **Create new API key**
4. Copy and save the key securely. It starts with `sk-`

!!! note
    If you do not see the option to create an API key, ask the pilot team ([serve@scilifelab.se](mailto:serve@scilifelab.se)) to add you to the Pilot Users group.

    Your API key expires after 4 weeks. Regenerate it when it stops working.

## Configuring Qwen Code

Once you have your API key, you can configure Qwen Code to use the SciLifeLab OpenLLM API. The configuration is stored in a `settings.json` file in the Qwen Code configuration directory.

### Configuration File

1. Open your Qwen Code settings file located at `~/.qwen/settings.json`
2. Add or modify the configuration to include the SciLifeLab OpenLLM API settings:

```json
{
  "ui": {
    "autoModeAcknowledged": true
  },
  "env": {
    "QWEN_CUSTOM_API_KEY_OPENAI_HTTPS_OPEN_LLM_SCILIFELAB_SE_V1_42C9F93C6043": "sk-your-api-key-here"
  },
  "modelProviders": {
    "openai": [
      {
        "id": "Qwen3-235B-A22B",
        "name": "Qwen3-235B-A22B",
        "baseUrl": "https://open-llm.scilifelab.se/api",
        "envKey": "QWEN_CUSTOM_API_KEY_OPENAI_HTTPS_OPEN_LLM_SCILIFELAB_SE_V1_42C9F93C6043",
        "generationConfig": {
          "contextWindowSize": 65536,
          "extra_body": {
            "enable_thinking": true
          },
          "modalities": {
            "image": true,
            "video": true,
            "audio": true,
            "pdf": true
          }
        }
      }
    ]
  },
  "security": {
    "auth": {
      "selectedType": "openai"
    }
  },
  "model": {
    "name": "Qwen3-235B-A22B",
    "baseUrl": "https://open-llm.scilifelab.se/api"
  },
  "$version": 4
}
```

Replace `sk-your-api-key-here` with your actual API key from the SciLifeLab OpenLLM service.

### Adding a New Model

To add a different model to your configuration, you need to add a new object to the `modelProviders.openai` array. Here's an example of how to add the `gemma3-27b` model:

```json
{
  "id": "gemma3-27b",
  "name": "gemma3-27b",
  "baseUrl": "https://open-llm.scilifelab.se/api",
  "envKey": "QWEN_CUSTOM_API_KEY_OPENAI_HTTPS_OPEN_LLM_SCILIFELAB_SE_V1_42C9F93C6043",
  "generationConfig": {
    "modalities": {
      "image": true,
      "pdf": true
    }
  }
}
```

1. Copy the example object above
2. Add it to the `modelProviders.openai` array in your settings.json file
3. Update the `model.name` field to "gemma3-27b" to use this model
4. Save the file and restart Qwen Code

You can use this pattern to add any other available model by changing the `id` and `name` fields to match the model you want to use.

## Selecting the Right Model

The SciLifeLab OpenLLM service provides multiple models, but in the Qwen Code configuration, the primary model is configured as `Qwen3-235B-A22B`. This model is optimized for coding tasks and provides advanced reasoning capabilities.

The service also offers:

- **`gemma3-27b`**: A reliable option for general coding tasks, documentation, and code explanation
- **`Qwen3.6-35B-A3B-FP8`**: A specialist model for complex reasoning, coding, and agentic work that requires deeper analysis

To switch to a different model in Qwen Code, you need to modify the `settings.json` configuration file. Follow these steps:

1. Add a new model configuration object to the `modelProviders.openai` array using the example in the "Adding a New Model" section
2. Update the `model.name` field to match the name of the model you want to use
3. Save the file and restart Qwen Code

For most coding assistance tasks in Qwen Code, the configured `Qwen3-235B-A22B` model is recommended as it provides a good balance of performance and capabilities. You can switch to `gemma3-27b` for simpler tasks or when you need a more general-purpose model by following the steps above.

## Testing Your Configuration

To verify that Qwen Code is properly configured, try a simple request:

```python
# Ask Qwen Code to explain this function
def calculate_pcr_efficiency(cq_values, template_concentrations):
    """Calculate PCR amplification efficiency from standard curve."""
    import numpy as np
    slope, intercept = np.polyfit(np.log10(template_concentrations), cq_values, 1)
    efficiency = 10**(-1/slope) - 1
    return efficiency * 100  # Return as percentage
```

If Qwen Code responds with an explanation of the function, your configuration is working correctly.

## Usage Tips

- **Be specific in your requests**: Clear, detailed prompts yield better results
- **Use system prompts**: You can set the context for your requests to guide the model's behavior
- **Consider token limits**: Large files or complex requests may exceed token limits; break them into smaller chunks when needed
- **Temperature settings**: For deterministic code generation or explanation, consider setting temperature to 0

## Troubleshooting

- **"Unauthorized" or 401 error**: Your API key is invalid or expired. Regenerate it in Open WebUI (**Settings → Account → API Keys**).
- **"Model not found" error**: The model name in your request doesn't match what's available. Check `/api/models` for the exact name.
- **Slow responses**: This is a pilot on shared infrastructure, not a production service. Response times will vary depending on load.
- **Connection timeout**: The service may be temporarily down for maintenance. Try again in a few minutes.

For additional support, refer to the [Troubleshooting section](getting-started-api.md#troubleshooting) in the Getting Started guide or contact [serve@scilifelab.se](mailto:serve@scilifelab.se).
