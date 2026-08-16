{ cfg ? { }, ... }:
let
  baseUrls = cfg.baseUrls;
in
{
  providers = {}
  // (if (baseUrls ? googleai) then {
    google = {
      apiKey = "dummy";
      api = "google-generative-ai";
      baseUrl = baseUrls.googleai;
      models = [
        {
          id = "gemini-3.7-flash";
          name = "Gemini 3.7 Flash";
          reasoning = true;
          input = [
            "text"
            "image"
          ];
          thinkingLevelMap = {
            off = null;
          };
          contextWindow = 1048576;
          maxTokens = 65536;
          cost = {
            input = 0.75;
            output = 3.75;
            cacheRead = 0.075;
            cacheWrite = 0;
          };
        }
      ];
    };
  } else { })
  // (if (baseUrls ? openai) then {
    openai = {
      baseUrl = baseUrls.openai;
      apiKey = "dummy";
      api = "openai-completions";
    };
  } else { })
  // (if (baseUrls ? mistral) then {
    mistral = {
      baseUrl = baseUrls.mistral;
      apiKey = "dummy";
      api = "openai-completions";
      models = [
        {
          id = "mistral-medium-3-5";
          name = "Mistral Medium (3.5)";
          reasoning = true;
          input = [ "text" "image" ];
        }
      ];
    };
  } else { })
  // (if (baseUrls ? openrouter) then {
    openrouter = {
      baseUrl = baseUrls.openrouter;
      apiKey = "dummy";
      api = "openai-completions";
      compat = {
        openRouterRouting = {
          data_collection = "deny";
          zdr = true;
        };
      };
      models = [
        {
          id = "moonshotai/kimi-k3";
          name = "Kimi K3";
          reasoning = true;
          input = [ "text" "image" ];
        }
        {
          id = "z-ai/glm-5.3";
          name = "GLM 5.3";
          reasoning = true;
          input = [ "text" "image" ];
        }
        {
          id = "mistralai/mistral-medium-3-5";
          name = "Mistral Medium 3.5";
          reasoning = true;
          input = [ "text" "image" ];
        }
      ];
    };
  } else { });
}

