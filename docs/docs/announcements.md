---
hide:
  - navigation
---

# Announcements

## 2026-10-21: Moving on to the second phase of the pilot

After positive feedback and high uptake among the first set of pilot users, we are making some changes. One change is in the account creation process for SciLifeLab OpenLLM. Those who wish to create an account and use the service will no longer need to fill out a survey. Instead, you need to answer a few basic questions about yourself. After you verify your email, the team will review the registration request and approve it if we have enough room to accept another user. The pilot service continues to be accessible to SciLifeLab infrasructure and researcher communities.

We received great feedback and made a large number of changes when it comes to availability of models through the API endpoints. We are now starting to explore use cases and requirements for using SciLifelab OpenLLM through the web interface (for ChatGPT or Claude style experience). We welcome users sending us feedback regarding the web interface.

Finally, we now have a public channel on SciLifeLab Slack for the community around this service: #openllm_pilot_users. The important announcements regarding this pilot will be made in this channel as well as on this page which you are reading right now.

## 2026-05-28: We're opening registration for the SciLifeLab OpenLLM pilot

[http://openllm.scilifelab.se](http://openllm.scilifelab.se) is a pilot service that SciLifeLab Data Centre is working on, and we are now accepting test users. This service gives you API access to open-weight LLMs running on our own infrastructure in Sweden.

The short version: if you want to plug an LLM into your research scripts, data pipelines, or automation tools, this is built for you. The API is OpenAI-compatible, so your existing code and tooling (LangChain, LlamaIndex, Continue for VS Code, plain `curl`, etc.) should work out of the box: just swap the base URL and API key. Currently, you get access to the model **gemma3-27b**[^1], a mid-tier model that can work with both text and images.

A few things worth knowing:

- **For API-based usage primarily:** the pilot is designed for programmatic use. Embed models in your workflows, build agents, run batch jobs. A chat UI exists as a convenience, but we prefer that you explore use cases with APi access.
- **Your data stays here:** all processing happens on SciLifeLab-controlled infrastructure in Sweden. No third-party providers, no training on your data.
- **We want to learn from you:** the goal of this pilot is to understand what use cases SciLifeLab-hosted LLMs can realistically support. We'll ask you to complete a short onboarding survey (~3 min) and check in with you twice during the pilot. We also welcome feedback at any time.
- **For staff at infra units and affiliated research groups:** the service is intended to be used by staff affiliated to infrastructure units at SciLifeLab as well anyone working in a SciLifeLab-affiliated research group.

!!! warning "Heads up"
    Just a quick heads-up as we kick off the pilot: we do not have any agreements (such as Service Level Agreements, SLAs) in place, and uptime or continuous availability is not guaranteed at this stage. Please avoid sending any human sensitive data to the service.

We are looking forward to seeing what you build with it.