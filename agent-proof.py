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
from autogen_core.tools import FunctionTool
from tools.agent_tools import compile_fstar_code



class Agent:
    def __init__(self) -> None:
        # Use the existing Azure client setup
        self.model_client = setup_azure_client()
        #critic model
        self.critic_model_client = setup_azure_client(model="o1_2024-12-17", model_family="o1")
        self.refinement_model_client = setup_azure_client(model="o1_2024-12-17", model_family="o1")  # Refinement Agent

        # Read the UMA manual
        with open('fst_manual.txt', 'r') as f: # todo
            fst_manual = f.read()
        
        with open('proof_examples.txt', 'r') as f: # todo
            proof_examples = f.read()
        
        # Create system message for the F* Syntax Expert
        system_message_syntax = f"""
        You are an expert in the F* programming language with a deep understanding of its syntax and language-specific constructs. Your responsibilities include:
        1. Generating correct and syntactically valid F* code based on the natural language intent.
        2. Analyzing the generated F* code for syntactic errors and incorporate compiler feedback.
        2. Incorporating error messages and hints from the F* compiler to identify and fix issues.
        3. Proposing corrections to ensure the code strictly adheres to F* syntax rules.
        4. Consulting the official F* tutorial at https://fstar-lang.org/tutorial/ and the guidelines below for best practices.
        F* Syntax Guidelines: {fst_manual}
        You must execute the compile_fstar function to check if the code is syntactically correct.
        """

        # Create system message for the F* Proof Expert
        system_message_proof = f"""
        You are a specialist in formal verification using F*. Your responsibilities include:
        1. Generating F* proofs and ensure that formal proofs are logically sound and verified wrt the specification.
        2. Incorporating regular feedback from the verifier, in order to assess whether the proof is in the correct direction. Also consider:
            - The importance of finding relevant lemmas before starting the proof process.
            - Variations in using library definitions: you could reuse them as-is, or consider strengthening or re-implementing them if the specifications are too weak. For instance, if a library function's specification (e.g., from FStar.List.Tot) is insufficient, consider rewriting it with a tighter specification.
        3. Evaluating the proofs step-by-step, ensuring that all necessary lemmas and definitions are correctly applied.
        4. Consulting the F* tutorial at https://fstar-lang.org/tutorial/ along with the guidelines and examples provided.
        F* Guidelines for Proofs:
            {fst_manual}
        Proof Examples:
            {proof_examples}
        """

        # Create system message for the F* Iterative Refinement Agent
        system_message_refinement = f"""
        You are an expert in iterative refinement and proof optimization in F*. Your responsibilities include:
        1. Integrating the feedback provided by both the F* Syntax Expert and the F* Proof Expert Agents.
        2. Iteratively refining the F* code so that it is syntactically correct and aligns with the specification.
        3. Prioritizing early drafting of specifications, deliberating on the most suitable representations (e.g., choosing between Seq and List) to balance efficiency with proof complexity.
        4. Carefully considering the choice of quantifiers when necessary, as this can simplify proofs.
        5. Aligning the structure of the specification with the implementation, such as setting up convenient 'spec' functions for each code portion.
        6. Consulting the official F* tutorial at https://fstar-lang.org/tutorial/ to ensure the final version adheres to best practices.
        7. Once all issues have been resolved, respond with "FINAL" to indicate that the refined code is ready.
        """

        compile_fstar = FunctionTool(compile_fstar_code, description="Compile F* code")

        # Create the three agents with their respective roles and prompts
        self.syntax_agent = AssistantAgent(
            name="F* Syntax Expert",
            model_client=self.model_client,
            system_message=system_message_syntax,
            tools=[compile_fstar]
        )

        # self.proof_agent = AssistantAgent(
        #     name="F* Proof Expert",
        #     model_client=self.proof_model_client,
        #     system_message=system_message_proof,
        # )

        # self.refinement_agent = AssistantAgent(
        #     name="F* Refinement Agent",
        #     model_client=self.refinement_model_client,
        #     system_message=system_message_refinement,
        # )

        # Create the agent team
        text_termination = TextMentionTermination("FINAL") # TODO: change termination message
        self.team = RoundRobinGroupChat(
            participants=[self.syntax_agent],
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