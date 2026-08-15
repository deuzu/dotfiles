{
  providers = {
    # google = {
    #   # baseUrl = "$GOOGLEAI_BASE_URL";
    #   baseUrl = "/google/v1beta";
    #   apiKey = "$GOOGLEAI_API_KEY";
    #   api = "google-generative-ai";
    # };
  #   openai = {
  #     baseUrl = "\${OPENAI_BASE_URL}";
  #     apiKey = "\${OPENAI_API_KEY}";
  #     api = "openai-completions";
  #   };
  #   mistral = {
  #     baseUrl = "\${MISTRAL_BASE_URL}";
  #     apiKey = "\${MISTRAL_API_KEY}";
  #     api = "openai-completions";
  #     models = [
  #       {
  #         id = "mistral-medium-3-5";
  #         name = "Mistral Medium (3.5) High Reasoning";
  #         reasoning = true;
  #         input = [ "text" "image" ];
  #       }
  #     ];
  #   };
  #   openrouter = {
  #     baseUrl = "\${OPENROUTER_BASE_URL}";
  #     apiKey = "\${OPENROUTER_API_KEY}";
  #     api = "openai-completions";
  #     compat = {
  #       openRouterRouting = {
  #         data_collection = "deny";
  #         zdr = true;
  #       };
  #     };
  #     models = [
  #       {
  #         id = "moonshotai/kimi-k3";
  #         name = "Kimi K3";
  #         reasoning = true;
  #         input = [ "text" "image" ];
  #       }
  #       {
  #         id = "z-ai/glm-5.3";
  #         name = "GLM 5.3";
  #         reasoning = true;
  #         input = [ "text" "image" ];
  #       }
  #       {
  #         id = "mistralai/mistral-medium-3-5";
  #         name = "Mistral Medium 3.5";
  #         reasoning = true;
  #         input = [ "text" "image" ];
  #       }
  #     ];
  #   };
  };
}
