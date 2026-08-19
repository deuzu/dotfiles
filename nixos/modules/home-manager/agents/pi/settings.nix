{ defaultProvider, defaultModel, ... }:
{
  inherit defaultProvider defaultModel;
  defaultThinkingLevel = "high";
  theme = "dark";
  quietStartup = false;
  defaultProjectTrust = "always";
  compaction = {
    enabled = true;
  };
  packages = [
    "npm:@narumitw/pi-plan-mode"
    "npm:@narumitw/pi-subagents"
  ];
}
