{
  google = {
    options = {
      apiKey = "{env:GOOGLEAI_API_KEY}";
      baseURL = "{env:GOOGLEAI_BASE_URL}";
    };
  };
  openai = {
    options = {
      apiKey = "{env:OPENAI_API_KEY}";
      baseURL = "{env:OPENAI_BASE_URL}";
    };
  };
  mistral = {
    options = {
      apiKey = "{env:MISTRAL_API_KEY}";
      baseURL = "{env:MISTRAL_BASE_URL}";
    };
    models = {
      "mistral-medium-3-5" = {
        name = "Mistral Medium (3.5) High Reasoning";
        options = {
          "reasoningEffort" = "high";
        };
      };
    };
  };
}
