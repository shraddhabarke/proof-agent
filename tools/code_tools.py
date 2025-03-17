from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.openai import AzureOpenAIChatCompletionClient
from azure.identity import DefaultAzureCredential, ChainedTokenCredential, AzureCliCredential, get_bearer_token_provider
import os
from typing import Optional

def setup_azure_client(model: str = "gpt-4o_2024-05-13", model_family: str = "gpt4-o"):
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

def create_code_agent(model: str = "gpt-4o_2024-05-13", 
                     model_family: str = "gpt4-o", 
                     system_message: Optional[str] = None) -> AssistantAgent:
    client = setup_azure_client(model, model_family)
    return AssistantAgent(
        name="code_agent",
        model_client=client,
        system_message=system_message or AGENT_SYSTEM_MESSAGE
    ) 