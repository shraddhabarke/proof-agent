from tools.code_tools import setup_azure_client
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.messages import TextMessage
from autogen_agentchat.teams import RoundRobinGroupChat
from autogen_agentchat.conditions import TextMentionTermination
from autogen_core import CancellationToken
from autogen_core.models import ChatCompletionClient
import streamlit as st
from streamlit_elements import elements, editor
from streamlit_monaco import st_monaco


class Agent:
    def __init__(self) -> None:
        # Use the existing Azure client setup
        self.model_client = setup_azure_client()
        #critic model
        self.critic_model_client = setup_azure_client(model="o1_2024-12-17", model_family="o1")
        # Read the UMA manual
        with open('uma_manual.txt', 'r') as f:
            uma_manual = f.read()
        
        with open('examples.txt', 'r') as f:
            examples = f.read()
        
        # Create system message combining the role and manual
        system_message = f"""You are an expert at modifying windows kernel code. Specifically, you remove unsafe user-mode memory accesses using the user-mode accessor manual as a guide.
                            Here is the User Mode Accessor (UMA) manual that you should follow:
                            {uma_manual}
                            You will also find these examples helpful:
                            {examples}

                            When modifying code, always refer to these guidelines to ensure safe user-mode memory access patterns and make minimal changes. 
                            **** IMPORTANT: only summarize your code edits.
                            **** HINT: the lines of bug in the defect report are not always the spots where you need to make changes."""

        # Create the primary assistant agent
        self.primary_agent = AssistantAgent(
            name="assistant",
            model_client=self.model_client,
            system_message=system_message,
            # tools=[self.share_diff],
            # reflect_on_tool_use=True
        )

        # Create the critic agent
        self.critic_agent = AssistantAgent(
            name="critic",
            model_client=self.critic_model_client,
            # tools = [self.display_diff],
            system_message=f"""You are a thoughtful critic specializing in kernel code safety. Review the assistant's response for accuracy and completeness, 
                         particularly focusing on proper user-mode memory access patterns. Respond with 'APPROVE' if the response is satisfactory, 
                         or provide specific feedback for improvement. Refer to the manual and check to make sure changes made are only described in the manual  {uma_manual}. 
                         """,
        )

        # Create the agent team
        text_termination = TextMentionTermination("APPROVE")
        self.team = RoundRobinGroupChat(
            participants=[self.primary_agent, self.critic_agent],
            termination_condition=text_termination
        )

    def display_diff(self, original: str, modified: str) -> str:
        """
        Display a diff view of the original and modified code using Streamlit Monaco editor.
        
        Args:
            original (str): The original code
            modified (str): The modified/refactored code
        
        Returns:
            str: The modified code after displaying the diff
        """
        st.markdown("# Diff of Refactored and Original Code")
        # with elements("monaco_editors"):
        #     editor.MonacoDiff(
        #         original=original,
        #         modified=modified,
        #         height=600,
        #     )
        return modified

    async def chat(self, prompt: str) -> str:
        """Legacy method for backward compatibility"""
        response = await self.primary_agent.on_messages(
            [TextMessage(content=prompt, source="user")],
            CancellationToken(),
        )
        assert isinstance(response.chat_message.content, str)
        return response.chat_message.content

    def get_team(self) -> RoundRobinGroupChat:
        """Get the agent team for team-based chat"""
        return self.team