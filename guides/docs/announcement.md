# SciLifeLab OpenLLM Pilot: First Announcement

## We're opening registration for the SciLifeLab OpenLLM pilot

[http://open-llm.scilifelab.se](http://open-llm.scilifelab.se) is a pilot service that SciLifeLab Data Centre is working on, and we are now accepting test users. This service gives you API access to open-weight LLMs running on our own infrastructure in Sweden.

The short version: if you want to plug an LLM into your research scripts, data pipelines, or automation tools, this is built for you. The API is OpenAI-compatible, so your existing code and tooling (LangChain, LlamaIndex, Continue for VS Code, plain `curl`, etc.) should work out of the box: just swap the base URL and API key. Currently, you get access to the model **gemma3-27b**[^1], a mid-tier model that can work with both text and images.

A few things worth knowing:

- **`gemma3-27b` is the default, but other models are available.** Smaller variants (`gemma3-4b`, `mistral-7b`), a longer-context option (`mistral-nemo-12b`), a reasoning-tuned model (`deepseek-r1-8b`), and a code-focused model (`deepseek-coder-6.7b`) are also exposed via the API for cases where the default isn't the right fit. An Arena mode is available too, for blind side-by-side comparisons. See the user guide for guidance on when to pick which, and let us know if there's another open-weight model you'd like us to consider adding during the pilot.
- **For API-based usage primarily:** the pilot is designed for programmatic use. Embed models in your workflows, build agents, run batch jobs. A chat UI exists as a convenience, but we prefer that you explore use cases with APi access.
- **Your data stays here:** all processing happens on SciLifeLab-controlled infrastructure in Sweden. No third-party providers, no training on your data.
- **We want to learn from you:** the goal of this pilot is to understand what use cases SciLifeLab-hosted LLMs can realistically support. We'll ask you to complete a short onboarding survey (~3 min) and check in with you twice during the pilot. We also welcome feedback at any time.
- **For staff at infra units and affiliated research groups:** the service is intended to be used by staff affiliated to infrastructure units at SciLifeLab as well anyone working in a SciLifeLab-affiliated research group.

## Want to join?

In order to join, you need to do two things:

1. Register here: [https://open-llm.scilifelab.se/](https://open-llm.scilifelab.se/)
2. Fill out out this onboarding survey (3 mins) here: [https://scilifelab.typeform.com/to/xF9XFHsr](https://scilifelab.typeform.com/to/xF9XFHsr)

We will approve registrations once both are complete within 24 hours, and you can grab grab your API key from **Settings → Account → API Keys**. A user guide with setup instructions, code examples, and the use policy will be shared with you upon registration. If you run into any issues, reach out to us at [serve@scilifelab.se](mailto:serve@scilifelab.se).

!!! warning "Heads up"
    Just a quick heads-up as we kick off the pilot: we do not have any agreements (such as Service Level Agreements, SLAs) in place, and uptime or continuous availability is not guaranteed at this stage. Please avoid sending any human sensitive data to the service.

We are looking forward to seeing what you build with it.

[^1]: Gemma is provided under and subject to the Gemma Terms of Use found at [ai.google.dev/gemma/terms](https://ai.google.dev/gemma/terms).
