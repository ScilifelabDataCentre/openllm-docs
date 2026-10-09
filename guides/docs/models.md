---
hide:
  - navigation
---

# SciLifeLab OpenLLM pilot: Our models

**For:** Pilot users of the SciLifeLab-hosted LLM service
**Service URL:** [https://openllm.scilifelab.se](https://openllm.scilifelab.se)
**Contact:** [openllm@scilifelab.se](mailto:openllm@scilifelab.se)

Please note that we will be considering adding or replacing models during the pilot based on what users actually need in the future. If there is a specific open-weight model you would like access to, let us know at [openllm@scilifelab.se](mailto:openllm@scilifelab.se).

---

**`Mistral-Large-3-675B-Instruct-2512-NVFP4`**: A large general-purpose multimodal Mixture-of-Experts model with 41B active parameters, 675B total parameters, and a 2.5B vision encoder. Useful for advanced chat, long documents, scientific work, RAG, agents, tool use, and coding tasks.

**Our Recommendation:** Advanced chat and long documents

- **Context Length: 65536**

- **Precision: NVFP4**

- **Release Date:** 09 September, 2026

- **[Official Site](https://huggingface.co/mistralai/Mistral-Large-3-675B-Instruct-2512-NVFP4)**

---


**`Qwen3.8-27B`**: A 27B compact general-purpose multimodal model that understands text, images, and video. Useful for coding, reasoning, complex tasks, agent workflows, research, document/image understanding, and everyday chat.

**Our Recommendation:** AI-assisted coding.


- **Context Length: 262144**

- **Precision: BF16**

- **[Release Date](https://qwen.ai/blog?id=qwen3.8):** 03 August, 2026 

- **[Official Site](https://huggingface.co/Qwen/Qwen3.8-27B)**

---


**`Qwen3-235B-A22B`**: A large Mixture-of-Experts model with 235B total parameters and 22B active parameters. Useful for complex instructions, coding, research, long documents, tool use, reasoning, and long-context tasks.

**Our Recommendation:** Researchand reasoning.
 

- **Context Length: 131072**

- **Precision: BF16**

- **[Release Date](https://arxiv.org/abs/2505.09388):** 14 May, 2025 

- **[Official Site](https://huggingface.co/Qwen/Qwen3-235B-A22B-Instruct-2507)**

---

**`gemma3-27b`**: A 27B general-purpose multimodal model from Google. Useful for general chat, reasoning, summarization, multilingual tasks, image understanding, and document analysis.

**Our Recommendation:** Multilingual tasks.


- **Context Length: 131072**

- **Precision: BF16**

- **[Release Date](https://storage.googleapis.com/deepmind-media/gemma/Gemma3Report.pdf):** 12 March, 2025 

- **[Official Site](https://huggingface.co/google/gemma-3-27b-it)**

---

**`bge-m3`**: A multilingual text embedding model that performs dense, sparse, and multi-vector retrieval simultaneously. Useful for retrieval-augmented Generation (RAG), semantic and keyword Search, and knowledge management. Can not be used in the chat interface.

**Our Recommendation:** retrieval-augmented Generation (RAG) and natural language processing (NLP) tasks.

- **Context Length: 8192**

- **Dimension: 1024**

- **[Release Date](https://huggingface.co/papers/2402.03216):** 05 February, 2024 

- **[Official Site](https://huggingface.co/BAAI/bge-m3)**

---



