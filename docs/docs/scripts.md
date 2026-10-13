# Using the API in scripts and workflows

SciLifeLab OpenLLM allows to include a step requiring an LLM in a script or a workflow that you are building. The call can be made using any OpenAI API compatible library in any programming language. Here we will give some examples.

## Prerequisites

In order to make API calls to SciLifeLab OpenLLM you need to have [obtained an API key from your user account](../getting-started-api/).

## Basic usage

### Using curl

`curl` is a command-line tool that sends HTTP requests. It comes pre-installed on macOS and Linux. On Windows, it is available in PowerShell. This is the quickest way to test that your API key works before writing any Python code.

Check which models are available:

```bash
curl https://openllm.scilifelab.se/api/models \
  -H "Authorization: Bearer <change-it-to-sk-your-api-key>"
```

Use the model name from this response in the `model` field of your requests.

```bash
curl https://openllm.scilifelab.se/api/chat/completions \
  -H "Authorization: Bearer <change-it-to-sk-your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3",
    "messages": [{"role": "user", "content": "What is mass spectrometry?"}],
    "max_tokens": 300
  }'
```

### Using Python (OpenAI client library)

Install the library:

```bash
pip install openai
```

Make a request:

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://openllm.scilifelab.se/api",
    api_key="<change-it-to-sk-your-api-key>",
)
response = client.chat.completions.create(
    model="qwen3",
    messages=[
        {"role": "user", "content": "What is mass spectrometry?"}
    ],
    max_tokens=300,
)
print(response.choices[0].message.content)
```

### Using Python (raw requests)

```python
import requests

response = requests.post(
    "https://openllm.scilifelab.se/api/chat/completions",
    headers={
        "Authorization": "Bearer <change-it-to-sk-your-api-key>",
        "Content-Type": "application/json",
    },
    json={
        "model": "qwen3",
        "messages": [{"role": "user", "content": "What is mass spectrometry?"}],
        "max_tokens": 300,
    },
)
print(response.json()["choices"][0]["message"]["content"])
```

## Examples of integration in a workflow

Below are some starting points for common research workflows. These are pointers, not full tutorials. The idea is to show you how little code it takes to plug our LLM into things you are already doing.

### Summarize a batch of abstracts

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://openllm.scilifelab.se/api",
    api_key="<change-it-to-sk-your-api-key>",
)
abstracts = [
    "Abstract text 1...",
    "Abstract text 2...",
    "Abstract text 3...",
]
for i, abstract in enumerate(abstracts):
    response = client.chat.completions.create(
        model="qwen3",
        messages=[
            {
                "role": "system",
                "content": "You are a research assistant. Summarize the following abstract in 2-3 sentences.",
            },
            {"role": "user", "content": abstract},
        ],
        max_tokens=200,
    )
    print(f"--- Abstract {i+1} ---")
    print(response.choices[0].message.content)
```

### Extract structured data from text

```python
import json
from openai import OpenAI

client = OpenAI(
    base_url="https://openllm.scilifelab.se/api",
    api_key="<change-it-to-sk-your-api-key>",
)
text = """
The patient cohort consisted of 142 individuals aged 45-72.
Treatment with 50mg metformin twice daily showed a 23% reduction
in fasting glucose levels over 12 weeks.
"""
response = client.chat.completions.create(
    model="qwen3",
    messages=[
        {
            "role": "system",
            "content": (
                "Extract structured information from the text. "
                "Return valid JSON only with keys: "
                "cohort_size, age_range, drug, dosage, outcome, duration."
            ),
        },
        {"role": "user", "content": text},
    ],
    max_tokens=300,
)
result = json.loads(response.choices[0].message.content)
print(json.dumps(result, indent=2))
```

### Classify items in a loop

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://openllm.scilifelab.se/api",
    api_key="<change-it-to-sk-your-api-key>",
)
genes = ["BRCA1", "TP53", "ACTB", "GAPDH", "EGFR"]
for gene in genes:
    response = client.chat.completions.create(
        model="qwen3",
        messages=[
            {
                "role": "user",
                "content": (
                    f"Is {gene} primarily an oncogene, tumor suppressor, "
                    f"or housekeeping gene? Answer in one word."
                ),
            }
        ],
        max_tokens=10,
    )
    print(f"{gene}: {response.choices[0].message.content.strip()}")
```
