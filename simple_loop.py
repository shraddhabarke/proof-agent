import asyncio
from asyncio import AbstractEventLoop
import streamlit as st
from agent_proof import Agent
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.base import TaskResult
from autogen_agentchat.conditions import ExternalTermination, TextMentionTermination
from autogen_agentchat.teams import RoundRobinGroupChat
from autogen_agentchat.ui import Console
from autogen_core import CancellationToken
from graphrag_inf import run_graphrag_query

# from graphrag_interface import query_graphrag
import time
import json
import ast
import re
import os

async def async_chat(team: RoundRobinGroupChat, prompt: str, file_content: str = None) -> str:
    """Async function to handle chat interactions with the agent team"""
    try:
        response_messages = []
        stop_reason = None
        
        # If there's file content, create a context prompt for the agent but don't display it
        actual_prompt = f"File content:\n{file_content}\n\nUser message:\n{prompt}" if file_content else prompt
        
        first_message = True  # Add flag to track first message
        async for message in team.run_stream(task=actual_prompt):
            if isinstance(message, TaskResult):
                stop_reason = message.stop_reason
                break
            else:
                # Skip the first message which is the context prompt
                if first_message:
                    first_message = False
                    continue
                    
                # Store messages with agent information
                agent_name = message.agent.name if hasattr(message, 'agent') else "Assistant"
                response_messages.append(f"**{agent_name}**: {str(message.content)}")
                
                
                # Original message handling
                if "FunctionCall" in str(message.content):

                #   with open("./temp_files/Test.fst", "r") as f:
                #     f.seek(0)
                #     code = f.read()
                #     st.code(code, language="C")
                #     # Keep the original warning for debugging
                    st.warning("Calling compile_fstar_code....")
                elif "FunctionExecutionResult" in str(message.content):
                    pass
                    #st.warning(str(message.content))
                elif "Verified module" in str(message.content):
                    st.success("Verified module: Test. All verification conditions discharged successfully.")
                    # Add a small delay to ensure file is written
                    time.sleep(0.1)  # 100ms delay
                    
                    # Force flush any file buffers
     
                    
                    # with open("./temp_files/Test.fst", "r") as f:
                        # # Ensure we're reading from the start of file
                        # f.seek(0)
                        # code = f.read()
                        # st.code(code, language="C")
                elif "error occurred" in str(message.content):
                    st.error(str(message.content))
                else:
                    with st.chat_message(agent_name):
                        st.markdown(str(message.content))
        return response_messages
    except Exception as e:
        st.error(f"Error during chat: {str(e)}")
        return "I encountered an error while processing your request. Please try again."

def get_or_create_eventloop() -> AbstractEventLoop:
    """Create or get event loop for async operations"""
    try:
        return asyncio.get_event_loop()
    except RuntimeError:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        return loop

def create_agent_team() -> RoundRobinGroupChat:
    """Create a team of agents including assistant and critic"""
    agent = Agent()
    return agent.get_team()

def main() -> None:
    st.set_page_config(page_title="F* Proof Copilot", page_icon="🤖")
    st.title("F* Proof Copilot 🤖")

    # Initialize agent team in session state
    if "agent_team" not in st.session_state:
        st.session_state["agent_team"] = create_agent_team()

    # Initialize chat history
    if "messages" not in st.session_state:
        st.session_state["messages"] = []

    # Add file uploader
    uploaded_file = st.file_uploader("Upload a file for context", type=['fst', 'py', 'c', 'cpp', 'js', 'txt', 'pdf', 'doc', 'docx', 'h', 
                                    'java', 'html', 'css', 'json', 'yaml', 'yml', 'xml', 'sql', 'rs', 'go', 'rb', 'php'])
    file_content = None
    if uploaded_file:
        file_content = uploaded_file.getvalue().decode('utf-8')
        st.success("File uploaded successfully!")

    # displaying chat history messages
    for message in st.session_state["messages"]:
        with st.chat_message(message["role"]):
            st.markdown(message["content"])

    prompt = st.chat_input("Type a message...")


    if prompt:
        st.session_state["messages"].append({"role": "user", "content": prompt})
        with st.chat_message("user"):
            print("User: ", prompt)
            st.markdown(prompt)
        # with st.spinner("🔎 Retrieving relevant information with GraphRAG..."):
        #     # Create and run the event loop for GraphRAG query
        #     #loop = get_or_create_eventloop()
        #     #rag_output = "Summarize F* language syntax, guidelines and few-shot examples related to the following query:" + prompt
        #     time.sleep(5)
        #     with open("./temp_files/list_rag.md", "r") as f:
        #         rag_output = f.read()
        #     print("rag:", rag_output)
        # if rag_output:
        #     st.success("✅ Retrieval successful ✅")
        #     with st.expander("📚 Retrieved Context", expanded=True):
        #         st.markdown("""
        #             <div style="
        #                 background-color: #f0f2f6;
        #                 padding: 10px;
        #                 border-radius: 5px;">
        #                 {}
        #             </div>
        #             """.format(rag_output), unsafe_allow_html=True)
        rag_output = run_graphrag_query("Summarize F* language syntax, guidelines and few-shot examples related to the following query: " + prompt)
        final_prompt = prompt + "\n\n Here is some relevant context which might be helpful, but incomplete for the task.\n"+ rag_output
        print("Final:", final_prompt)
        # Get or create event loop and run async chat
        loop = get_or_create_eventloop()
        
        # Pass file_content as a separate parameter instead of modifying the prompt
        response = loop.run_until_complete(async_chat(
            st.session_state["agent_team"], 
            final_prompt,
            file_content=file_content if file_content else None
        ))

        if response:  # Only append if we got a valid response
            st.session_state["messages"].append({"role": "assistant", "content": response})

if __name__ == "__main__":
    main()