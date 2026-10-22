# Connect to Qwen Code

Qwen Code is an AI-powered coding assistant that helps developers write, understand, and refactor code more efficiently. This guide explains how to configure Qwen Code to use the self-hosted SciLifeLab OpenLLM API, enabling you to leverage powerful AI coding assistance within your development workflow.

## Prerequisites

In order to connect SciLifeLab OpenLLM to Qwen Code on your computer, you need to have [obtained an API key from your user account](../getting-started-api/). You also need Qwen Code to be installed on your computer. You can follow the [official Qwen Code guide to install it](https://qwenlm.github.io/qwen-code-docs/en/users/quickstart/).

## Configuring Qwen Code

Once you have your API key, you can configure Qwen Code to use the SciLifeLab OpenLLM API. The configuration is stored in a `settings.json` file in the Qwen Code configuration directory.

### Configuration file

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
        "baseUrl": "https://openllm.scilifelab.se/api",
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
    "baseUrl": "https://openllm.scilifelab.se/api"
  },
  "$version": 4
}
```

Replace `sk-your-api-key-here` with your actual API key from the SciLifeLab OpenLLM service. You can also replace the model references in this configuration into a model of your choice from the [current list model that we offer](../docs/models/).

### Adding a new model

To add a different model to your configuration, you need to add a new object to the `modelProviders.openai` array. Here's an example of how to add the `gemma3-27b` model:

```json
{
  "id": "gemma3-27b",
  "name": "gemma3-27b",
  "baseUrl": "https://openllm.scilifelab.se/api",
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

## Selecting the right model

The SciLifeLab OpenLLM service provides multiple models, but in the example Qwen Code configuration above the primary model is configured as `Qwen3-235B-A22B`. This model is optimized for coding tasks and provides advanced reasoning capabilities.

To switch to a different model in Qwen Code, you need to modify the `settings.json` configuration file. Follow these steps:

1. Add a new model configuration object to the `modelProviders.openai` array using the example in the "Adding a New Model" section
2. Update the `model.name` field to match the name of the model you want to use
3. Save the file and restart Qwen Code

For most coding assistance tasks in Qwen Code, the configured `Qwen3-235B-A22B` model is recommended as it provides a good balance of performance and capabilities. You can switch to `gemma3-27b` for simpler tasks or when you need a more general-purpose model by following the steps above.

## Testing your configuration

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

## Usage tips

- **Be specific in your requests**: Clear, detailed prompts yield better results
- **Use system prompts**: You can set the context for your requests to guide the model's behavior
- **Consider token limits**: Large files or complex requests may exceed token limits; break them into smaller chunks when needed
- **Temperature settings**: For deterministic code generation or explanation, consider setting temperature to 0

## Troubleshooting

- **"Unauthorized" or 401 error**: Your API key is invalid or expired. Regenerate it in Open WebUI (**Settings → Account → API Keys**).
- **"Model not found" error**: The model name in your request doesn't match what's available. Check `/api/models` for the exact name.
- **Slow responses**: This is a pilot on shared infrastructure, not a production service. Response times will vary depending on load.
- **Connection timeout**: The service may be temporarily down for maintenance. Try again in a few minutes.

For additional support, refer to the [Troubleshooting section](../getting-started-api/#troubleshooting) in the Getting Started guide, get in touch with others in the SciLifeLab Slack channel (#openllm_pilot_users) or contact the team behind the service by email ([openllm@scilifelab.se](mailto:openllm@scilifelab.se)).