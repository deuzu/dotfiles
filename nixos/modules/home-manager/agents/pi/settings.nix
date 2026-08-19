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
    "npm:@tintinweb/pi-subagents"
    "npm:@juicesharp/rpiv-todo"
    "npm:@juicesharp/rpiv-ask-user-question"
    "npm:@juicesharp/rpiv-btw"
    "npm:@juicesharp/rpiv-voice"
  ];
}
