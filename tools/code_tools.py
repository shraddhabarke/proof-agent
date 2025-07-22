from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.openai import AzureOpenAIChatCompletionClient
from azure.identity import DefaultAzureCredential, ChainedTokenCredential, AzureCliCredential, get_bearer_token_provider
import os
from typing import Optional

def setup_azure_client(model: str = "gpt-4o_2024-05-13", model_family: str = "gpt4-o"):
#def setup_azure_client(model: str = "gpt-35-turbo_1106", model_family: str = "gpt-35-turbo"):

    scope = "api://trapi/.default"
    credential = get_bearer_token_provider(ChainedTokenCredential(
        AzureCliCredential(),
        DefaultAzureCredential(
            exclude_cli_credential=True,
            exclude_environment_credential=True,
            exclude_shared_token_cache_credential=True,
            exclude_developer_cli_credential=True,
            exclude_powershell_credential=True,
            exclude_interactive_browser_credential=True,
            exclude_visual_studio_code_credentials=True,
            managed_identity_client_id=os.environ.get("DEFAULT_IDENTITY_CLIENT_ID"),
        )
    ), scope)

    return AzureOpenAIChatCompletionClient(
        model=model,
        model_info={
            "json_output": False,
            "function_calling": True,
            "vision": False,
            "family": model_family,
        },
        api_version="2025-01-01-preview",
        azure_endpoint="https://trapi.research.microsoft.com/gcr/shared",
        azure_ad_token_provider=credential
    )

# tools/local_model_client.py

import requests
from autogen_core.models import ChatCompletionClient

class VLLMCompletionClient(ChatCompletionClient):
    def __init__(
        self,
        model: str = "qwq-32b",
        model_family: str = "qwq",
        base_url: str = "http://gcrazgdl3159.westus2.cloudapp.azure.com:8000/generate",
    ):
        self.model = model
        self.model_family = model_family
        self.base_url = base_url

    def chat(self, messages, **kwargs):
        prompt = self._build_prompt(messages)

        payload = {
            "prompt": prompt,
            "stream": False,
            "max_tokens": kwargs.get("max_tokens", 1024),
        }

        headers = {
            "User-Agent": "vLLM Client"
        }

        response = requests.post(self.base_url, headers=headers, json=payload)
        if not response.ok:
            raise RuntimeError(f"vLLM request failed: {response.status_code} {response.text}")

        result = response.json()
        return {
            "choices": [{
                "message": {
                    "content": result["text"][0]
                }
            }]
        }

    def _build_prompt(self, messages):
        """Formats messages in OpenAI-style multi-turn chat format."""
        role_map = {
            "system": "<|system|>",
            "user": "<|user|>",
            "assistant": "<|assistant|>"
        }
        formatted = []
        for msg in messages:
            role = msg.get("role", "user")
            content = msg.get("content", "")
            role_token = role_map.get(role, "<|user|>")
            formatted.append(f"{role_token}\n{content}")
        return "\n".join(formatted) + "\n<|assistant|>\n"

def setup_local_client(
    model: str = "qwq-32b",
    model_family: str = "qwq"
) -> ChatCompletionClient:
    return VLLMCompletionClient(model=model, model_family=model_family)

def create_code_agent(model: str = "gpt-4o_2024-08-06",
                     model_family: str = "gpt-4o",
                     system_message: Optional[str] = None) -> AssistantAgent:
    client = setup_azure_client(model, model_family)
    return AssistantAgent(
        name="code_agent",
        model_client=client,
        system_message=system_message or AGENT_SYSTEM_MESSAGE
    )
