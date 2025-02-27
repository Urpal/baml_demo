
class WeatherAPI {
  city string @description("the user's city") @stream.not_null
  timeOfDay string @description("As an ISO8601 timestamp or right now / atm") @stream.not_null
//   weather string @description("Come up with something weather related such as 'extremely rainy', 'shockingly sunny' or something other funny")
}


class USPresidentAPI {
  name string @description("The name of the US president that one wants to extract data for") @stream.not_null
  note string | null @description("A note for the data extraction, might be null / empty")
//   timezone string @description("The made up time zone like; 'Galactica timezone' or something other from startrek")
}

class AssistantMsg {
  role "assistant"
  content string
}

class ChatMsg {
  role "user" | "assistant"
  content string
}


// class AssistantMsgClass {
//   message_type "greeting" | "conversation" | "farewell" @stream.not_null
//   message string @stream.with_state @stream.not_null
// }


function ChatWithTools(messages: ChatMsg[]) -> string | AssistantMsg | WeatherAPI | USPresidentAPI {
  client Gemini20Flash
  prompt #"
    {{_.role("system")}}
    You are a helpful and knowledgeable AI assistant engaging in a conversation.
    Your responses should be:
    - Clear and concise
    - Accurate and informative
    - Natural and conversational in tone
    - Focused on addressing the user's needs
    - Always choose any of the other tools than the conversational message if possible

    Use the USPresidentAPI if the user asks for the time at a specific location
    Use the WeatherAPI if the user asks for the weather for a location
    Always use AssistantMsg otherwise

    # Requirement
    Analyze the conversation history and double check your conclusion for which tool to choose to be consistent.
    Always choose a tool for the output

    {{ ctx.output_format }}

    {% for m in messages %}
    {{ _.role(m.role)}}
    {{m.content}}<br>
    {% endfor %}

  "#
}

test TestmultiTool1 {
  functions [ChatWithTools]
  args {
    messages [
      {
        role "user"
        content "What is the weather like in Brisbane right now?"
      }
    ]
  }
}

test TestmultiTool2 {
  functions [ChatWithTools]
  args {
    messages [
      {
        role "user"
        content "Abraham Lincoln. I think he was smart but dont know"
      }
    ]
  }
}

test TestmultiTool3 {
  functions [ChatWithTools]
  args {
    messages [
      {
        role "user"
        content "Hey man, how you doing? Are you a man or a woman?"
      }
    ]
  }
}


test TestmultiTool4 {
  functions [ChatWithTools]
  args {
    messages [
      {
        role "user"
        content "Hey man, is it probably raining at 17:00 the 24.05.25 in Stonehenge?"
      },
      {
        role "assistant"
        content "To check the weather in Stonehenge on May 24, 2025, at 17:00, I'll need to access a weather tool. Would you like me to do that?"
      },
      {
        role "user"
        content "Yes, please!"
      }
    ]
  }
}