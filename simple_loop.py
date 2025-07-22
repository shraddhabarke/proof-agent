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
from tools import agent_tools
# from graphrag_interface import query_graphrag
import time
import json
import ast
import re
import os

import sys

# Check if there's a file path passed as an argument
initial_prompt = None
if len(sys.argv) > 1:
    with open(sys.argv[1], "r") as f:
        initial_prompt = f.read().strip()

async def async_chat(team: RoundRobinGroupChat, prompt: str, file_content: str = None) -> str:
    """Async function to handle chat interactions with the agent team"""
    try:
        response_messages = []
        stop_reason = None
        
        # If there's file content, create a context prompt for the agent but don't display it
        actual_prompt = f"File content:\n{file_content}\n\nUser message:\n{prompt}" if file_content else prompt
        
        first_message = True  # Add flag to track first message
        max_attempts = 50
        attempt_count = 0

        async for message in team.run_stream(task=actual_prompt):
            if attempt_count >= max_attempts:
                st.warning(f"Reached {max_attempts} attempts without verifying. Moving on.")
                sys.exit(0)
                st.stop()
                break
            if isinstance(message, TaskResult):
                stop_reason = message.stop_reason
                break
            else:
                # Skip the first message which is the context prompt
                if first_message:
                    first_message = False
                    continue

                if attempt_count >= max_attempts:
                    st.warning(f"Reached {max_attempts} attempts without verifying. Moving on.")
                    sys.exit(0) 
                    st.stop()
                #break

                # Store messages with agent information
                agent_name = message.agent.name if hasattr(message, 'agent') else "Assistant"
                response_messages.append(f"**{agent_name}**: {str(message.content)}")
                
                
                # Original message handling
                if "FunctionCall" in str(message.content):
                    attempt_count += 1
                    print("attempt-count:", attempt_count)
                    code_match = code_match = re.search(r"```(?:fstar)?\s*\n(.*?)```", str(message.content), re.DOTALL) #re.search(r"```fstar\n(.*?)```", str(message.content), re.DOTALL)
                    fstar_json_entry = {
                            "prompt": prompt,
                            "fstar_code": code_match.group(1) if code_match else str(message.content),
                            "code-match": code_match
                            }
                    print("fstar_json_entry:", fstar_json_entry)
                    if os.path.exists(json_file):
                        with open(json_file, "r") as f:
                            try:
                                existing_data = json.load(f)
                                if not isinstance(existing_data, list):
                                    existing_data = []
                            except json.JSONDecodeError:
                                existing_data = []
                    else:
                        existing_data = []
                    existing_data.append(fstar_json_entry)
                    with open(json_file, "w") as f:
                        json.dump(existing_data, f, indent=4)
                    if code_match:
                        fstar_code = code_match.group(1)
                        st.info("Compiling new F* code...")
                        st.code(fstar_code, language="fstar")
                        st.info(fstar_code)
                        st.write(fstar_code)
                        compile_output = agent_tools.compile_fstar_code(fstar_code)
                        st.write(compile_output)
                        st.success("✅ Compilation done!")
                        with open("./temp_files/Test.fst", "w") as f:
                            f.write(fstar_code)
                        st.write(f"**Compilation output:**\n```\n{compile_output}\n```")
                    st.warning("Calling compile_fstar_code....")
                elif "FunctionExecutionResult" in str(message.content):
                    print("Inside FunctionExecutionResult")
                    print(message.content)
                    pass
                    #st.warning(str(message.content))
                elif "All verification conditions discharged successfully" in str(message.content):
                    with open("./temp_files/Test.fst", "r") as f:
                        fstar_code_to_save = f.read()

                    if fstar_code_to_save:
                        fstar_json_entry = {
                            "prompt": prompt,
                            "fstar_code": fstar_code_to_save,
                        }
                        json_file = "verified_fstar_snippets.json"
                        if os.path.exists(json_file):
                            with open(json_file, "r") as f:
                                existing_data = json.load(f)
                        else:
                            existing_data = []

                        existing_data.append(fstar_json_entry)
                        with open(json_file, "w") as f:
                            json.dump(existing_data, f, indent=4)

                        open("./temp_files/Test.fst", "w").close()

                        st.success(f"✅ Verified F* code saved to {json_file}!")
                        fstar_code_to_save = None

                    st.success("Verified module: Test. All verification conditions discharged successfully.")
                    st.info(fstar_code_to_save)
                    st.info(attempt_count)

                    # Add a small delay to ensure file is written
                    time.sleep(0.1)  # 100ms delay
                    
                    # Force flush any file buffers
     
                    
                    # with open("./temp_files/Test.fst", "r") as f:
                        # # Ensure we're reading from the start of file
                        # f.seek(0)
                        # code = f.read()
                        # st.code(code, language="C")
                    st.stop()
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

    # Replace st.chat_input line:
    if initial_prompt:
        prompt = initial_prompt
        st.session_state["messages"].append({"role": "user", "content": prompt})
        st.chat_input("Type a message...")  # Dummy to keep UI alive
    else:
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
        from graphrag_inf import run_graphrag_query

        rag_output = run_graphrag_query("Summarize F* language syntax and few-shot examples only related to the following query, do not talk generally about F*:" + prompt)
        #print(rag_output)
        final_prompt = prompt + "\n\n Here is some relevant context which might be helpful, but incomplete for the task.\n"+ rag_output
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