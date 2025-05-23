from tools.code_tools import setup_azure_client
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.messages import TextMessage
from autogen_agentchat.teams import RoundRobinGroupChat, SelectorGroupChat
from autogen_agentchat.conditions import TextMentionTermination
from autogen_core import CancellationToken
from autogen_core.models import ChatCompletionClient
import streamlit as st
from streamlit_elements import elements, editor
from streamlit_monaco import st_monaco
from autogen_core.tools import FunctionTool
from tools.agent_tools import compile_fstar_code
# from graphrag_interface import query_graphrag
from typing import Sequence
from autogen_agentchat.messages import BaseAgentEvent, BaseChatMessage

import asyncio

class Agent:
    def __init__(self) -> None:
        self.model_client = setup_azure_client()
        self.proof_model_client = setup_azure_client(model="o3-mini_2025-01-31", model_family="o3")
       
        # #fst_manual = asyncio.run(query_graphrag("Summarize F* language syntax, guidelines and few-shot examples related to the following query:"))
        #print(fst_manual)
        
        # Create system message for the F* Syntax Expert
        system_message_syntax = f"""
        You are an expert in the F* programming language with a deep understanding of its syntax and language-specific constructs. The proof agent will generate a proof sketch then you will make it happen with correct syntax. Your responsibilities include:
        1. Generating correct and syntactically valid F* code based on the proof sketch provided by the proof agent.
        2. Analyzing the generated F* code for syntactic errors and incorporate compiler feedback.
        2. Incorporating error messages and hints from the F* compiler to identify and fix issues.
        3. If you have any verification errors, you must ask the PROOF agent for help
        3. Proposing corrections to ensure the code strictly adheres to F* syntax rules.
        5. for this task, always call the module 'Test'
        6. always print the code you generate and explain it
        If the compiler gives you an error, you must fix it. The task is not complete until the f* code compiles.
        You must start with every response by saying: # Syntax Agent """

        # Create system message for the F* Proof Expert
        system_message_proof = f"""
        You are a specialist in formal verification using F*. You always go first in the speaker selection. Here is how to approach the task:
        1. Create a proof sketch, starting from the implenetation and specifications (pre, post conditions, refinements).
        2. Identify what relevant lemmas you might use in the proof sketch.
            - Variations in using library definitions: you could reuse them as-is, or consider strengthening or re-implementing them if the specifications are too weak. For instance, if a library function's specification (e.g., from FStar.List.Tot) is insufficient, consider rewriting it with a tighter specification.
        3. Evaluating the proofs step-by-step, ensuring that all necessary lemmas and definitions are correctly applied.
        
        You must start your task by thinking through the specifications and format of the ultimate solution.   
        Before calling any function, you must first generate a proof and specification sketch. thinking step by step.           
        Always explain the proof sketch you are generating. The syntax agent will ask you questions if it encourters verification errors.
        You must start with every response by saying: # Proof Agent
        """

        compile_fstar = FunctionTool(compile_fstar_code, description="Compile F* code")

        # Create the three agents with their respective roles and prompts
        self.syntax_agent = AssistantAgent(
            name="syntax_agent",
            description ="F* Syntax Expert",
            model_client=self.model_client,
            system_message=system_message_syntax,
            tools=[compile_fstar]
        )

        self.proof_agent = AssistantAgent(
            name="proof_agent",
            description ="F* Proof Expert",
            model_client=self.proof_model_client,
            system_message=system_message_proof,
        )
 
        selector_prompt = """Select an agent to perform task. 

        {roles}

        Current conversation context:
        {history}

        Read the above conversation, then select an agent from {participants} to perform the next task.

        the general plan is:
        1. The proof_agent will generate a proof sketch, starting from 1) selecting the correct representation, 2) reasonong about the specifications (pre, post conditions, refinements). 3) identifying what relevant lemmas you might use in the proof sketch.
        2. The syntax_agent will take the proof sketch and turn it into a real syntactically correct program.
        3. The syntax_agent will then fix the code if there are compiler errors or ask the proof agent for help on verification errors
        4. The process continues until the code verifies and all verification conditions are discharged successfully.
        5. The syntax_agent will then print the final code and explain it.

        """


        def selector_func(messages: Sequence[BaseAgentEvent | BaseChatMessage]) -> str | None:
            if messages[-1].source == "user":
                return self.proof_agent.name  # Use the actual agent name
            if messages[-1].source == self.proof_agent.name:
                return self.syntax_agent.name
            return None

        # Create the agent team
        text_termination = TextMentionTermination("All verification conditions discharged successfully") # TODO: change termination message
        self.team = SelectorGroupChat(
            participants=[self.syntax_agent, self.proof_agent],
            termination_condition=text_termination,
            selector_prompt=selector_prompt,
            allow_repeated_speaker=True,
            model_client=self.model_client,
            selector_func=selector_func,
        )
        


    async def chat(self, prompt: str) -> str:
        """Legacy method for backward compatibility"""
        response = await self.primary_agent.on_messages(
            [TextMessage(content=prompt, source="user")],
            CancellationToken(),
        )
        assert isinstance(response.chat_message.content, str)
        return response.chat_message.content

    def get_team(self) -> SelectorGroupChat:
        """Get the agent team for team-based chat"""
        return self.team
