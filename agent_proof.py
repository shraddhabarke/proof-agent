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
from autogen_core.memory import ListMemory, MemoryContent, MemoryMimeType
import asyncio

import os
from pathlib import Path

from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.ui import Console
from autogen_ext.memory.chromadb import ChromaDBVectorMemory, PersistentChromaDBVectorMemoryConfig

class Agent:
    def __init__(self) -> None:
        self.model_client = setup_azure_client()
        self.proof_model_client = setup_azure_client(model="o1_2024-12-17", model_family="o1")
       
        with open("fstar_example_syntax.txt", "r") as f:
            syntax_example = f.read()

        with open("fstar_example_proof.txt", "r") as f:
            proof_example = f.read()

        # #fst_manual = asyncio.run(query_graphrag("Summarize F* language syntax, guidelines and few-shot examples related to the following query:"))
        #print(fst_manual)
        
        # Create system message for the F* Syntax Expert
        system_message_syntax = f"""
        You are an expert in the F* programming language with a deep understanding of its syntax and language-specific constructs. The proof agent will generate a proof sketch then you will make it happen with correct syntax. You work with a proof agent and a rag agent. The rag agent helps you when you are stuck with syntax and proof. Your responsibilities include:
        1. Generating correct and syntactically valid F* code based on the proof sketch provided by the proof agent.
        2. Analyzing the generated F* code for syntactic errors and incorporate compiler feedback.
        2. Incorporating error messages and hints from the F* compiler to identify and fix issues.
        3. If you have any verification errors, you must ask the PROOF agent for help. if you need syntax help ask the RETRIVAL AGENT FOR HELP
        3. Proposing corrections to ensure the code strictly adheres to F* syntax rules.
        5. for this task, always call the module 'Test'
        6. always print the code you generate and explain it
        If the compiler gives you an error, you must fix it. The task is not complete until the f* code compiles.
        You must start with every response by saying: # Syntax Agent 
        
        example of a F* code:
        {syntax_example}"""

        # Create system message for the F* Proof Expert
        system_message_proof = f"""
        You are a specialist in formal verification using F*. You always go first in the speaker selection. Here is how to approach the task:
        1. Create a proof sketch, starting from the implenetation and specifications (pre, post conditions, refinements).
        2. Identify what relevant lemmas you might use in the proof sketch.
            - Variations in using library definitions: you could reuse them as-is, or consider strengthening or re-implementing them if the specifications are too weak. For instance, if a library function's specification (e.g., from FStar.List.Tot) is insufficient, consider rewriting it with a tighter specification.
        3. Evaluating the proofs step-by-step, ensuring that all necessary lemmas and definitions are correctly applied.
        . Clear Goal
another set of criteria to consider:
1. Specify the goal of the proof. What are we trying to prove? For example, the function maintains certain invariants, the correctness of the algorithm, or the preservation of some property.
2. Pre-conditions and Post-conditions
Define the pre-conditions for the function (what assumptions are made before the function runs).
Define the post-conditions (what must be true after the function completes). This includes any invariants or properties that must hold.
3. Helper Functions and Invariants
Identify any helper functions or invariants that need to be defined and proven.
Invariants: What properties are preserved throughout the execution? This could be things like sorting, non-negativity, or the preservation of certain data structures.
Auxiliary Lemmas: Provide and prove any necessary supporting lemmas, such as proving that a function maintains a property throughout recursive calls or that a data structure invariant holds after each operation.
4. Inductive Reasoning
Use inductive reasoning to prove correctness, especially for recursive functions.
Base Case: Prove the property holds for simple cases, such as an empty list or a single element.
Inductive Case: Assume the property holds for a smaller or simpler version of the input, and prove that it holds after performing the next operation (e.g., inserting an element, making a recursive call).
Ensure the induction hypothesis is clearly stated and used effectively.
5. Function Specification
For each function being proved, specify the following:
Pre-conditions: What must be true before the function runs?
Post-conditions: What must be true after the function runs?
Correctness Proof: Prove that the function satisfies the post-conditions, maintaining all required properties.
6. Clarity and Modularity
Ensure the proof is modular and easy to follow:
Break down complex proofs into smaller sub-proofs, each handling a specific part of the correctness.
Use clear logical steps and formal reasoning at each stage of the proof.
Avoid unnecessary complexity. The proof should be as simple as possible while still being rigorous.
7. Edge Cases
Consider edge cases and prove that the function works correctly in those cases (e.g., empty input, input of length 1, etc.).
8. Optimization Considerations
If applicable, suggest or prove any performance optimizations, especially those that improve efficiency without breaking correctness. This is especially important for algorithms that might be computationally expensive.
9. Verification in F*
If possible, connect your proof to F*’s verification tools and its refinement types.
Use F*’s features such as refinement types to capture the correctness of properties like sorting or uniqueness of elements.
Ensure that the proof follows F*’s verification process, such as using requires, ensures, and lemma annotations for correctness.
10. Iterative Proof Process
Provide the proof step-by-step, allowing for iterative refinement if necessary. This includes reasoning at each recursive call or operation.
The proof should ultimately show that the function is correct, based on the specifications, and adheres to the required properties. The process should be formal, with clear logical steps and rigorous use of F*’s capabilities for formal verification.
        You must start your task by thinking through the specifications and format of the ultimate solution.   
        Before calling any function, you must first generate a proof and specification sketch. thinking step by step.           
        Always explain the proof sketch you are generating. The syntax agent will ask you questions if it encourters verification errors.
        You must start with every response by saying: # Proof Agent

        example of a proof sketch:
        {proof_example}
        """

        compile_fstar = FunctionTool(compile_fstar_code, description="Compile F* code")


        # Initialize vector memory

        self.rag_memory = ChromaDBVectorMemory(
                config=PersistentChromaDBVectorMemoryConfig(
                    collection_name="fstar_docs",
                    persistence_path=os.path.join("./", ".chromadb_fstar"),
                    k=3,  # Return top 3 results
                    score_threshold=0.4,  # Minimum similarity score
                )
        )


        # Create the three agents with their respective roles and prompts
        self.syntax_agent = AssistantAgent(
            name="syntax_agent",
            description ="F* Syntax Expert",
            model_client=self.model_client,
            system_message=system_message_syntax,
            tools=[compile_fstar],
        )

        self.rag_agent = AssistantAgent(
            name="rag_agent",
            description ="F* RAG Agent",
            model_client=self.model_client,
            system_message="You are a retrieval-augmented generation (RAG) agent. You will be used to query the F* documentation and provide relevant information to the proof agent.",
            memory=[self.rag_memory],
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
        3. The syntax_agent will then fix the code if there are compiler errors or ask the proof agent for help on verification errors, OR THE RAG AGENT FOR HELP ON SYNTAX ERRORS.
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
            participants=[self.syntax_agent, self.proof_agent, self.rag_agent],
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




