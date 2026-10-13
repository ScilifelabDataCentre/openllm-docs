# Using SciLifeLab OpenLLM in agent frameworks

## Prerequisites

In order to build agents with SciLifeLab OpenLLM as the underlying service you need to have [obtained an API key from your user account](../getting-started-api/).

## Examples

### LangChain

LangChain is a framework for building LLM-powered applications with chains, agents, and tool integrations

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    base_url="https://openllm.scilifelab.se/api",
    api_key="<change-it-to-sk-your-api-key>",
    model="qwen3",
)
response = llm.invoke("What is CRISPR-Cas9?")
print(response.content)
```

### LlamaIndex

LlamaIndex is a framework for connecting LLMs to your own data (documents, databases, APIs) for retrieval-augmented generation (RAG).

```python
from llama_index.llms.openai_like import OpenAILike

llm = OpenAILike(
    api_base="https://openllm.scilifelab.se/api",
    api_key="<change-it-to-sk-your-api-key>",
    model="qwen3",
    is_chat_model=True,
)
response = llm.complete("What is CRISPR-Cas9?")
print(response)
```

## Learning materials

If you are interested in building more advanced workflows where LLMs call tools, query databases, or orchestrate multi-step research pipelines, here are resources from our team.

### Workshop materials (hands-on code)

**Developing AI Agents in Life Sciences** (March 2026 workshop). Hands-on sessions on building AI agents with LangGraph/ReAct and the Model Context Protocol (MCP). Repository: [https://github.com/ScilifelabDataCentre/scilifelab-ai-agent-mcp-workshop-2026-03-05](https://github.com/ScilifelabDataCentre/scilifelab-ai-agent-mcp-workshop-2026-03-05)

The repo has two self-contained sessions you can work through on your own:

- `Section_1_LangGraph/` — build drug discovery AI agents using LangGraph and the ReAct pattern
- `session-2-mcp/` — expose tools over MCP and connect agents across servers

Both run in Docker containers with no local Python setup required.