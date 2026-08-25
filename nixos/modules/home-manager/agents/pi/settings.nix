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
    "npm:@tintinweb/pi-subagents"
    "npm:@juicesharp/rpiv-todo"
    "npm:@juicesharp/rpiv-ask-user-question"
    "npm:@juicesharp/rpiv-btw"
    "npm:pi-mermaid"
    "npm:pi-web-access"
  ];
}
