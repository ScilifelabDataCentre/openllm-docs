# How OpenLLM is set up

Our deployment files are public on [GitHub](https://github.com/ScilifelabDataCentre/openllm-setup).

## Summary

The front-end or chat interface uses the service Open WebUI at `open-llm.scilifelab.se` (alias is `openllm.scilifelab.se`). It runs on a Kubernetes cluster at KTH and handles login, chat history, API keys, document search and rate limits.

The models run on GPUs at three sites in Sweden: Chalmers e-Commons (C3SE) in Gothenburg, Safespring in Stockholm and KTH in Stockholm.

The models are served by vLLM with an OpenAI-compatible API.

```
 you (browser or API client)
   |
   | HTTPS
   v
 open-llm.scilifelab.se ........................ KTH, Stockholm
 Open WebUI + PostgreSQL + Qdrant
   |
   |--- internal ------------> BGE-M3 embeddings
   |                           vLLM on 1 x NVIDIA A40
   |
   |--- HTTPS, allowlisted --> Chalmers e-Commons (C3SE), Gothenburg
   |                           nginx -> LiteLLM -> vLLM
   |                           5 nodes, 4 x NVIDIA A100 80 GB each
   |
   |--- firewalled ----------> Safespring, Stockholm
                               vLLM on 2 x NVIDIA H100
```

## The GPUs

| Site | GPUs | Models |
|---|---|---|
| Chalmers e-Commons (C3SE), Gothenburg | 20 × NVIDIA A100 SXM4 80 GB, in 5 nodes with 4 GPUs each (1.6 TB of GPU memory). NVLink inside a node, 200 Gbit/s InfiniBand between nodes, RDMA is also supported. | Mistral Large 3, Qwen3-235B-A22B, Qwen3.8-27B |
| Safespring, Stockholm | 2 × NVIDIA H100, in one GPU virtual machine | gemma3-27b, voxtral-small-24b |
| KTH, Stockholm | NVIDIA A40 48 GB, shared to Kubernetes as VMware vGPUs (profile A40-48C). | bge-m3 (embeddings), **also OpenLLM uses one of them.** |

## KTH: Open WebUI and embeddings

Open WebUI runs in its own namespace on SciLifeLab's production Kubernetes cluster at KTH (`scilifelab-2-prod`). We deploy it from a Helm chart with ArgoCD. Traffic comes in through the cluster's Gateway API, implemented by NGINX Gateway Fabric.

Two services run next to Open WebUI.

- PostgreSQL stores accounts, settings and chat history.

- Qdrant is the vector database for document search (RAG, or Retrieval-Augmented Generation). When you upload a document, Open WebUI splits it into chunks, turns each chunk into a vector and stores the vectors in Qdrant. The vectors come from [bge-m3](https://huggingface.co/BAAI/bge-m3) model, which runs in its own vLLM server on one A40. The service has no public address and only Open WebUI can reach it. You can still use it from code through Open WebUI's API (see "Using the API" below).

On top of Open WebUI we add a few functions (filters and actions), for example limits each user to 60 requests per minute.

The A40s are shared through VMware vGPU. This blocks the direct GPU-to-GPU memory access that multi-GPU inference needs, so at KTH we only run models that fit on a single GPU.

## Chalmers e-Commons (C3SE): the large models

Most of our GPU capacity is at [C3SE](https://www.c3se.chalmers.se/), through Chalmers e-Commons. We have five compute nodes and one login node. Each compute node has four A100 80 GB GPUs joined in a full NVLink mesh, which gives 320 GB of GPU memory per node. The nodes are connected with 200 Gbit/s InfiniBand. Model weights sit on shared project storage (Mimer) that all compute nodes mount, so we download each model only once.

C3SE runs the hardware, the operating system and the TLS (Transport Layer Security) front end. We run everything else in rootless Podman containers, started as systemd user services under an unprivileged account. Each model has its own vLLM server. On the login node, LiteLLM puts all C3SE models behind one OpenAI-compatible endpoint, with nginx in front for TLS. For these models Open WebUI talks only to that endpoint, and the firewall lets in only the KTH cluster. Because LiteLLM holds the routing table, we can move or restart a model without changing anything in Open WebUI. There is no batch scheduler in the path: we assign nodes to models by hand.

A model that fits in one node's 320 GB runs on that node, split over its four GPUs with tensor parallelism. A larger model spans several nodes. vLLM joins them with Ray, keeps tensor parallelism inside each node and adds pipeline parallelism between nodes.

```
 LiteLLM (login node)
   |
   |--> one node:  vLLM, model split over 4 GPUs
   |               tensor parallel (NVLink)
   |
   |--> two nodes: vLLM + Ray, model split over 8 GPUs
                   tensor parallel inside each node (NVLink)
                   pipeline parallel between nodes (InfiniBand)
```

Mistral Large 3 and Qwen3-235B-A22B run this way, on two nodes each. Spreading a model over nodes buys memory, not speed: a model that fits on one node runs faster there. Traffic between the nodes uses TCP over InfiniBand for now, and RDMA is also supported.

The A100 GPU has no FP8 or FP4 hardware. Qwen3-235B-A22B (about 470 GB of weights) and Qwen3.8-27B run in BF16. Mistral Large 3 uses NVFP4, a 4-bit weight format: vLLM keeps the weights in 4 bits in GPU memory and converts them to 16 bits for the computation. This saves memory, not compute, and it is how a 675B-parameter model fits on two nodes with about 403 GB of weights.

## Safespring: two H100s

[Safespring](https://www.safespring.com/) is a Swedish cloud provider. We run a GPU virtual machine with two NVIDIA H100 GPUs in their Stockholm region. vLLM runs in Docker Compose, one container per model, for gemma3-27b and voxtral-small-24b. Open WebUI connects to these vLLM servers directly.

## Models

Models change during the pilot, and the table shows what runs at the time of writing. If you would like a specific open-weight model, tell us at open-llm@scilifelab.se. For the live list, with the exact model IDs to use in API calls, call `GET https://open-llm.scilifelab.se/api/models`.

| Model | Runs on | Weights | Serving setup |
|---|---|---|---|
| [Mistral-Large-3-675B-Instruct-2512-NVFP4](https://huggingface.co/mistralai/Mistral-Large-3-675B-Instruct-2512-NVFP4) | C3SE, 2 nodes (8 × A100) | NVFP4 | Multi-node with Ray: tensor parallel 4 × pipeline parallel 2. 65,536-token context. |
| [Qwen3-235B-A22B](https://huggingface.co/Qwen/Qwen3-235B-A22B-Instruct-2507) | C3SE, 2 nodes (8 × A100) | BF16 | Multi-node with Ray: tensor parallel 4 × pipeline parallel 2. 131,072-token context. |
| [Qwen3.8-27B](https://huggingface.co/Qwen/Qwen3.8-27B) | C3SE, 1 node (4 × A100) | BF16 | 262,144-token context. |
| [gemma3-27b](https://huggingface.co/google/gemma-3-27b-it) | Safespring, H100 | BF16 | 131,072-token context. |
| [voxtral-small-24b](https://huggingface.co/mistralai/Voxtral-Small-24B-2507) | Safespring, H100 | BF16 | Audio input. 32,768-token context. |
| [bge-m3](https://huggingface.co/BAAI/bge-m3) | KTH, 1 × A40 | 16-bit | Embeddings only: 1,024 dimensions, up to 8,192 input tokens. |

## Using the API

The backends have no public endpoints, so everything goes through Open WebUI. The base URL is `https://open-llm.scilifelab.se/api`, and you authenticate with a personal API key from **Settings → Account** in Open WebUI. If you cannot create a key, write to `open-llm@scilifelab.se` and we will help to provide the API access for your account. The paths follow the OpenAI API: `GET /api/models`, `POST /api/chat/completions`, and `POST /api/embeddings` with `"model": "bge-m3"`. Most OpenAI-compatible clients work once you change the base URL and the key.

A few things follow from the setup. Each user can send up to 60 requests per minute, and requests above that get an error. Tool calling is enabled on the chat models. Qwen3.8-27B thinks before it answers, and the thinking counts against `max_tokens`. To turn thinking off for one request, add `"chat_template_kwargs": {"enable_thinking": false}`. For long answers, use streaming.

### Examples, using curl


Check which models are available:

```bash
curl https://openllm.scilifelab.se/api/models \
  -H "Authorization: Bearer <change-it-to-your-api-key>"
```

Use the model name from this response in the `model` field of your requests.

```bash
curl https://openllm.scilifelab.se/api/chat/completions \
  -H "Authorization: Bearer <change-it-to-your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": <INSERT-MODEL-NAME>,
    "messages": [{"role": "user", "content": "What is mass spectrometry?"}],
    "max_tokens": 300
  }'
```

## How we run it

Everything is configuration as code in the [openllm-setup](https://github.com/ScilifelabDataCentre/openllm-setup) repository. Folder names follow the pattern `{what}-{nr}-{where}-{how}`, for example `vllm-02-safespring-docker`. On KTH, ArgoCD applies the Helm charts from Git. On C3SE, the hosts pull the repository and a bootstrap script installs the files. On Safespring, vLLM starts from the Compose files in the repository. All changes go through reviewed pull requests.

Grafana sends a small chat request through Open WebUI to each main model every five minutes and alerts us when one fails or is slow. Logs from the OpenLLM namespace on the KTH cluster go to Loki through Grafana Alloy, and vLLM and LiteLLM expose Prometheus metrics. We load test with Locust, using the scripts in [openwebui-locust](https://github.com/ScilifelabDataCentre/openwebui-locust). The tests go through Open WebUI, so they measure the same path you use.

## Your data

Everything on this page runs in Sweden, at KTH, Chalmers and Safespring. Prompts and answers are not sent to any commercial AI provider, and we do not train models on your data. Chat history is stored in PostgreSQL, and uploaded documents and their vectors are stored by Open WebUI and in Qdrant, all on the KTH cluster. The use policy still applies: no patient data, and nothing classified above "internal".

## Code and configuration

| What | Where |
|---|---|
| Overview and all deployment files | [openllm-setup](https://github.com/ScilifelabDataCentre/openllm-setup) |
| Open WebUI on KTH: Helm chart for ArgoCD | [openwebui-kth-cluster-helm](https://github.com/ScilifelabDataCentre/openllm-setup/tree/main/openwebui-kth-cluster-helm) |
| Open WebUI functions, including the rate limit filter | [openwebui-functionality](https://github.com/ScilifelabDataCentre/openllm-setup/tree/main/openwebui-functionality) |
| BGE-M3 embedding service on KTH: Helm chart | [embeddings-kth-cluster-helm](https://github.com/ScilifelabDataCentre/openllm-setup/tree/main/embeddings-kth-cluster-helm) |
| vLLM on Safespring: Docker Compose | [vllm-02-safespring-docker](https://github.com/ScilifelabDataCentre/openllm-setup/tree/main/vllm-02-safespring-docker) |
| vLLM and LiteLLM on C3SE: Podman, systemd units, bootstrap script | [vllm-03-c3se-podman](https://github.com/ScilifelabDataCentre/openllm-setup/tree/main/vllm-03-c3se-podman) |
| Load tests | [openwebui-locust](https://github.com/ScilifelabDataCentre/openwebui-locust) |

## open-source projects we build on

- [vLLM](https://github.com/vllm-project/vllm)
- [Open WebUI](https://github.com/open-webui/open-webui)
- [LiteLLM](https://github.com/BerriAI/litellm)
- [Ray](https://github.com/ray-project/ray)
- [Qdrant](https://github.com/qdrant/qdrant)

## Questions and feedback

`open-llm@scilifelab.se`
