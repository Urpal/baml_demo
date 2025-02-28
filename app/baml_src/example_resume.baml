// Defining a data model.
class Resume {
  name string
  email string
  experience string[]
  skills string[]
}

// Create a function to extract the resume from a string.
function ExtractResume(resume: string) -> Resume {
  // Specify a client as provider/model-name
  // you can use custom LLM params with a custom client name from clients.baml like "client CustomHaiku"
  client Gemini20Flash // Set OPENAI_API_KEY to use this client.
  prompt #"
    Extract from this content:
    {{ resume }}

    {{ ctx.output_format }}
  "#
}

// Test the function with a sample resume. Open the VSCode playground to run this.
test phs_resume {
  functions [ExtractResume]
  args {
    resume #"
      Pål HS
      phs@hotmail.com

      Experience:
      - Founder at Nothing
      - CV Engineer at DontKnowIt
      - Systems Engineer at Ferrari

      Skills:
      - Python snakes
      - C++
    "#
  }
}
