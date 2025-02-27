// Learn more about clients at https://docs.boundaryml.com/docs/snippets/clients/overview

client<llm> CustomGPT4o {
  provider openai
  options {
    model "gpt-4o"
    api_key env.OPENAI_API_KEY
  }
}

client<llm> CustomGPT4oMini {
  provider openai
  retry_policy Exponential
  options {
    model "gpt-4o-mini"
    api_key env.OPENAI_API_KEY
  }
}

client<llm> Llama3 {
  provider ollama
  retry_policy Constant
  options {
    model "llama3.2:1b"
    temperature 0.6
  }
}

client<llm> Mistral {
  provider ollama
  retry_policy Constant
  options {
    model "mistral-small:24b"
    temperature 0.6
  }
}

client<llm> GeminiFlash {
  provider google-ai
  options {
    model "gemini-1.5-flash"
    api_key env.GOOGLE_API_KEY
    generationConfig {
    temperature 0.75
    }
  }
}

client<llm> Gemini20Flash {
  provider google-ai
  options {
    model "gemini-2.0-flash"
    api_key env.GOOGLE_API_KEY
    generationConfig {
    temperature 0.75
    }
  }
}

client<llm> Gemini20FlashLite {
  provider google-ai
  options {
    model "gemini-2.0-flash-lite-preview-02-05"
    api_key env.GOOGLE_API_KEY
    generationConfig {
    temperature 0.75
    }
  }
}

client<llm> Azure4oClient {
  provider azure-openai
  options {
    resource_name env.AZURE_RESOURCE
    deployment_id env.AZURE_MODEL 
    api_version "2024-10-01-preview"
    api_key env.AZURE_OPENAI_API_KEY
  }
}

// https://docs.boundaryml.com/docs/snippets/clients/round-robin
client<llm> CustomFast {
  provider round-robin
  options {
    // This will alternate between the two clients
    strategy [Gemini20Flash]
  }
}

// https://docs.boundaryml.com/docs/snippets/clients/fallback
client<llm> OpenaiFallback {
  provider fallback
  options {
    // This will try the clients in order until one succeeds
    strategy [Gemini20Flash]
  }
}

// https://docs.boundaryml.com/docs/snippets/clients/retry
retry_policy Constant {
  max_retries 3
  // Strategy is optional
  strategy {
    type constant_delay
    delay_ms 200
  }
}

retry_policy Exponential {
  max_retries 2
  // Strategy is optional
  strategy {
    type exponential_backoff
    delay_ms 300
    multiplier 1.5
    max_delay_ms 10000
  }
}