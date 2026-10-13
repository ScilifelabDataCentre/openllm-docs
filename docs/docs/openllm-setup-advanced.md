# How SciLifeLab OpenLLM is set up

On this page we describe the setup behind SciLifeLab OpenLLM for advanced users who are curious to learn about it. We are making use of a number of open source projects out there to run the service. The parts that we modify or create ourselves are also shared as open source code.

## Summary

The front-end (in other words, the chat interface) uses Open WebUI deployed at `openllm.scilifelab.se` (alias is `open-llm.scilifelab.se`). It runs on a Kubernetes cluster at KTH in Stockholm and handles login, chat history, API keys, document search and rate limits. Our deployment files are public on [GitHub](https://github.com/ScilifelabDataCentre/openllm-setup).

Different models run on GPUs at one of three sites in Sweden that we currently use: Chalmers University (handled by Chalmers e-Commons e-Infrastructure group, C3SE) in Gothenburg, Safespring in Stockholm, and KTH Royal Institute of Technology (handled by KTH IT) in Stockholm.

The models are served by vLLM with an OpenAI-compatible API.

```
 you (browser or API client)
   |
   | HTTPS
   v
 openllm.scilifelab.se ........................ KTH, Stockholm
 Open WebUI + PostgreSQL + Qdrant
   |
   |--- internal ------------> KTH, Stockholm
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

| Site | GPUs |
|---|---|
| Chalmers e-Commons (C3SE), Gothenburg | 20 × NVIDIA A100 SXM4 80 GB, in 5 nodes with 4 GPUs each (1.6 TB of GPU memory). NVLink inside a node, 200 Gbit/s InfiniBand between nodes, RDMA is also supported. |
| Safespring, Stockholm | 2 × NVIDIA H100, in one GPU virtual machine |
| KTH, Stockholm | NVIDIA A40 48 GB, shared to Kubernetes as VMware vGPUs (profile A40-48C). |

## KTH: Open WebUI and embeddings

[Open WebUI](https://github.com/open-webui/open-webui) runs in its own namespace on SciLifeLab's production Kubernetes cluster at KTH. We deploy it from a Helm chart with ArgoCD. Traffic comes in through the cluster's Gateway API, implemented by NGINX Gateway Fabric. You can explore our exact customized version of Open WebUI [in our fork on GitHub](https://github.com/ScilifelabDataCentre/open-webui).

Two services run next to Open WebUI.

- PostgreSQL stores accounts, settings and chat history.

- Qdrant is the vector database for document search (RAG, or Retrieval-Augmented Generation). When you upload a document, Open WebUI splits it into chunks, turns each chunk into a vector and stores the vectors in Qdrant. The vectors come from [bge-m3](https://huggingface.co/BAAI/bge-m3) model, which runs in its own vLLM server on one A40. The service has no public address and only Open WebUI can reach it. You can still use it from code through Open WebUI's API.

On top of Open WebUI we add a few functions (filters and actions), for example limits each user to 60 requests per minute.

The A40s are shared through VMware vGPU. This blocks the direct GPU-to-GPU memory access that multi-GPU inference needs, so at KTH we only run models that fit on a single GPU.

## Chalmers e-Commons (C3SE): the large models

Most of our GPU capacity is at [C3SE](https://www.c3se.chalmers.se/), through Chalmers e-Commons. We have five compute nodes and one login node. Each compute node has four A100 80 GB GPUs joined in a full NVLink mesh, which gives 320 GB of GPU memory per node. The nodes are connected with 200 Gbit/s InfiniBand. Model weights sit on shared project storage (Mimer) that all compute nodes mount.

C3SE runs the hardware, the operating system and the TLS (Transport Layer Security) front end. We run everything else in rootless Podman containers. Each model has its own vLLM server. On the login node, LiteLLM puts all C3SE models behind one OpenAI-compatible endpoint, with nginx in front for TLS. For these models Open WebUI talks only to that endpoint.

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

## Safespring: two H100s

[Safespring](https://www.safespring.com/) is a Swedish cloud provider. We run a GPU virtual machine with two NVIDIA H100 GPUs in their Stockholm region. vLLM runs in Docker Compose, one container per model, for gemma3-27b and voxtral-small-24b. Open WebUI connects to these vLLM servers directly.

## How we run it

Everything is configuration as code in the [openllm-setup](https://github.com/ScilifelabDataCentre/openllm-setup) repository. Folder names follow the pattern `{what}-{nr}-{where}-{how}`, for example `vllm-02-safespring-docker`. On KTH, ArgoCD applies the Helm charts from Git. On C3SE, the hosts pull the repository and a bootstrap script installs the files. On Safespring, vLLM starts from the Compose files in the repository. All changes go through reviewed pull requests.

Grafana sends a small chat request through Open WebUI to each main model every five minutes and alerts us when one fails or is slow. We load test with Locust, using the scripts in [openwebui-locust](https://github.com/ScilifelabDataCentre/openwebui-locust). The tests go through Open WebUI, so they measure the same path you use.

## User data

Everything runs in Sweden, at KTH, Chalmers, and Safespring. Prompts and answers are not sent to any commercial AI provider, and we do not train models on your data. Chat history is stored in PostgreSQL, and uploaded documents and their vectors are stored by Open WebUI and in Qdrant, all on the KTH cluster.

## Open-source projects we build on

- [vLLM](https://github.com/vllm-project/vllm)
- [Open WebUI](https://github.com/open-webui/open-webui)
- [LiteLLM](https://github.com/BerriAI/litellm)
- [Ray](https://github.com/ray-project/ray)
- [Qdrant](https://github.com/qdrant/qdrant)

## Questions and feedback

Feel free to get in touch with us: `openllm@scilifelab.se`
