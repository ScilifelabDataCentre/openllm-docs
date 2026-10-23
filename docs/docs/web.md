# Using SciLifeLab OpenLLM through the web interface

Please note that the web interface offered through SciLifeLab OpenLLM is quite basic at this point, and we are still working on understanding the needs from the users and use cases that we should support. So do not expect that it will be as advanced as what you may be used to from Claude or ChatGPT. Feedback is welcome.

## Prerequisites

In order to use the SciLifeLab OpenLLM service through the web interface you need to be a [registered and approved user of the service](../registration/).

## Start using the web interface

Press on the button "Log in" button on top right of this page, enter your account information, and you will end up in the web interface. This interface is provided by [Open WebUI](https://github.com/open-webui/open-webui), an open source project that we are running for SciLifeLab OpenLLM.

This interface is quite similar to other LLM-based services such as Claude, ChatGPT, or Mistral. Explore it to get familiarized with what is possible. You can send a query as text, audio, or, for example, attach files. In the bottom right corner of the form you can select a model. Note that different models have different capacities (for example, image generation is not possible with all models), different speed, etc.; read the [overview of models that we offer](../docs/models/) to learn about the differences.

At this point, the models can open a web page if given a direct URL or if a URL is stored in their memory but none of the models is able to do an independent web *search*, we are working on enabling this in a privacy-aware way.

## Issues, questions, wishes

If you have specific issues, wishes, or questions, let us know in the Slack channel for the users (#openllm_pilot_users on ScilifeLab Slack) or by emailing [openllm@scilifelab.se](mailto:openllm@scilifelab.se).