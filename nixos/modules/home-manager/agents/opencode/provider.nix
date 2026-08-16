{ cfg ? { }, ... }:
let
  baseUrls = cfg.baseUrls or { };
in
{ }
// (if (baseUrls ? googleai) then {
  google = {
    options = {
      apiKey = "{env:GOOGLEAI_API_KEY}";
      baseURL = baseUrls.googleai;
    };
  };
} else { })
// (if (baseUrls ? openai) then {
  openai = {
    options = {
      apiKey = "{env:OPENAI_API_KEY}";
      baseURL = baseUrls.openai;
    };
  };
} else { })
// (if (baseUrls ? mistral) then {
  mistral = {
    options = {
      apiKey = "{env:MISTRAL_API_KEY}";
      baseURL = baseUrls.mistral;
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
} else { })
// (if (baseUrls ? openrouter) then {
  openrouter =
    let
      privacyRouting = {
        provider = {
          data_collection = "deny";
          zdr = true;
        };
      };
      allowedModels = [
        "moonshotai/kimi-k3"
        "z-ai/glm-5.2"
        "mistralai/mistral-medium-3-5"
      ];
      models = builtins.listToAttrs (
        map (id: { name = id; value = { options = privacyRouting; }; }) allowedModels
      );
    in
    {
      options = {
        baseURL = baseUrls.openrouter;
      };
      inherit models;
      whitelist = allowedModels;
    };
} else { })
