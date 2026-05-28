{
  google = {
    options = {
      apiKey = "{env:GOOGLEAI_API_KEY}";
    };
  };
  openai = {
    options = {
      apiKey = "{env:OPENAI_API_KEY}";
    };
  };
  mistral = {
    options = {
      apiKey = "{env:MISTRAL_API_KEY}";
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
