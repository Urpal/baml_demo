from typing import List
import rich
import streamlit as st
from baml_client.async_client import b as b_async
from baml_client.types import ChatMsg, WeatherAPI, USPresidentAPI, AssistantMsg
import asyncio
from collections import deque

# Set max messages such that 
MAX_MESSAGES = 12

async def chat_message_stream(messages: list[ChatMsg]):
    stream = b_async.stream.ChatWithTools(messages = messages)
    async for partial in stream:
      yield partial
    final = await stream.get_final_response()
    yield final

def render_tool():
   if st.session_state["tool_used"]:
      st.json(st.session_state["tool_output"])

def handle_tool(final_response):
  if isinstance(final_response, AssistantMsg):
    st.session_state.messages.append({"role": "assistant", "content": final_response.content})
    return final_response.content
  elif isinstance(final_response, WeatherAPI):
    st.session_state.tool_used = True
    st.session_state.messages.append({"role": "assistant", "content": final_response.model_dump_json()}) # TODO: Test this
    return f"Tool Call: Weather in {final_response.city} at {final_response.timeOfDay}\n"
  elif isinstance(final_response, USPresidentAPI):
    st.session_state.tool_used = True
    final_string = f"Tool Call: President name: {final_response.name}.  Note: {final_response.note}\n"
    st.session_state.messages.append({"role": "assistant", "content": final_string})
    return final_string
  else:
      st.session_state.messages.append({"role": "assistant", "content": final_response})
      print(f"Other response: {final_response}")
      return final_response

# Initialize chat history in session state
if "messages" not in st.session_state:
    st.session_state.messages = deque(maxlen=MAX_MESSAGES) #[]
if "tool_used" not in st.session_state:
    st.session_state.tool_used = False
    st.session_state.tool_output = ""

st.title("Simple chat interface")

# Display chat messages from history on app rerun
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Accept user input
if prompt := st.chat_input("What is up?"):
    # Add user message to chat history and display it
    st.session_state.messages.append({"role": "user", "content": prompt})
    st.session_state.tool_used = False
    with st.chat_message("user"):
        st.markdown(prompt)

    
    # In the assistant message container, stream the assistant response incrementally.
    with st.chat_message("assistant"):
        # Create a placeholder to update the message
        placeholder = st.empty()
        response_chunks: List[str] = []  # Mutable list to store chunks
        

        async def update_stream() -> str:
            full_response = ""
            async for raw_chunk in chat_message_stream(
                messages=[ChatMsg(role=msg["role"], content=msg["content"]) for msg in st.session_state.messages]
            ):
                # If raw_chunk is a coroutine, await it; otherwise use it directly.
                chunk = await raw_chunk if asyncio.iscoroutine(raw_chunk) else raw_chunk
                if chunk is None:                
                    continue 
                placeholder.markdown(chunk)
                full_response = chunk
            return full_response # type: ignore
        # Start the asynchronous task
        final_response = asyncio.run(update_stream())
        rich.print(f"Final response:{final_response} and type: {type(final_response)}")
        response_handled =   handle_tool(final_response)
        st.session_state.tool_output = final_response
        placeholder.markdown(response_handled)

with st.sidebar:
   render_tool()