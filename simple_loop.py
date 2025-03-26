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
    st.set_page_config(page_title="UMAccesor Workbench", page_icon="🤖")
    st.title("UMAccesor Workbench 🤖")

    # Initialize agent team in session state
    if "agent_team" not in st.session_state:
        st.session_state["agent_team"] = create_agent_team()

    # Initialize chat history
    if "messages" not in st.session_state:
        st.session_state["messages"] = []

    # Add file uploader
    uploaded_file = st.file_uploader("Upload a file for context", type=['py', 'c', 'cpp', 'js', 'txt', 'pdf', 'doc', 'docx', 'h', 
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
            st.markdown(prompt)

        # Get or create event loop and run async chat
        loop = get_or_create_eventloop()
        
        # Pass file_content as a separate parameter instead of modifying the prompt
        response = loop.run_until_complete(async_chat(
            st.session_state["agent_team"], 
            prompt,
            file_content=file_content if file_content else None
        ))

        if response:  # Only append if we got a valid response
            st.session_state["messages"].append({"role": "assistant", "content": response})

if __name__ == "__main__":
    main()