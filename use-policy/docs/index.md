# SciLifeLab OpenLLM Policy

**[openllm.scilifelab.se](http://openllm.scilifelab.se/)**
Version 1.0.0

## What is this?

SciLifeLab OpenLLM is a pilot service run by SciLifeLab Data Centre providing access to open-weight large language models (LLMs) hosted on infrastructure controlled by SciLifeLab. The service offers both a chat interface (Open WebUI) and API endpoints. The pilot runs during spring 2026 with a limited group of users.

Our primary focus is enabling API-based access so that LLMs can be embedded in research workflows, automation pipelines, and agentic tools. The chat interface is available as a convenience, but the pilot is not optimized for users who only need a ChatGPT-style experience.

The goal is to learn what use cases SciLifeLab-hosted LLMs can realistically support, what infrastructure and expertise are needed, and what a future production service could look like.

## What you can use it for

- Embedding LLMs in research workflows and pipelines via the API
- Prototyping agentic tools and automations
- Working with data that should not leave SciLifeLab-controlled infrastructure (e.g. internal code, non-public datasets, or information containing personal data that is not patient/healthcare data)
- Evaluating open-weight models for your specific research or platform needs

## What you should not use it for

!!! warning "Not permitted"
    - Processing patient data or data classified above "internal" sensitivity
    - Any use case that requires guaranteed uptime, latency, or throughput; this is a pilot, not a production service
    - Heavy sustained workloads that could degrade the service for other pilot users
    - Anything that violates Swedish law, EU regulations, SciLifeLab policies, ethical review board or research ethics committee decisions, or your university's own policies

## Where does the data live?

All models run on infrastructure controlled by SciLifeLab Data Centre, deployed on the KTH Kubernetes cluster and SafeSpring cloud, located in Sweden. Your prompts and outputs are processed on this infrastructure and are not sent to any third-party provider. We do not train models on your data.

We may collect anonymized usage metrics (request counts, token volumes, latency) to evaluate the pilot. We do not log prompt content beyond what is needed for debugging during the pilot period.

## What we do and do not promise

**We do:**

- Provide access to a curated set of small and medium-size open-weight LLMs
- Make a reasonable effort to keep the service available during the pilot
- Actively collect your feedback to shape future decisions

**We do not:**

- Guarantee availability, performance, or specific model versions
- Commit to continuing the service beyond the pilot period
- Provide support equivalent to a production service

## Feedback

Your input is the most valuable output of this pilot. Please share feedback, use cases, issues, and ideas at [serve@scilifelab.se](mailto:serve@scilifelab.se) or through the channels provided to you when you joined the pilot.
