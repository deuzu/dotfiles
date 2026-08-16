{ config, lib, pkgs, ... }:
let
  cfg = config.modules.terminals.zellij;
in
{
  options.modules.terminals.zellij = with lib; {
    enable = mkEnableOption "Zellij Terminal Multiplexer";

    initialCodeTabs = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.nonEmptyStr;
          };
          cwd = mkOption {
            type = types.nonEmptyStr;
          };
        };
      });
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      package = pkgs.zellij;
      settings = {
        mouse_mode = true;
        simplified_ui = false;
        default_layout = "compact";
        default_mode = "normal";
        pane_frames = false;
        show_startup_tips = false;
        show_release_notes = true;
        ui.pane_frames = {
          hide_session_name = true;
        };

        keybinds = {
          shared = {
            "bind \"Alt home\"" = { PreviousSwapLayout = { }; };
            "bind \"Alt end\"" = { NextSwapLayout = { }; };
          };
          "shared_among \"normal\" \"locked\"" = {
            "bind \"Alt f\"" = { ToggleFloatingPanes = { }; };
            "bind \"Alt Left\"" = { MoveFocusOrTab = "Left"; };
            "bind \"Alt Right\"" = { MoveFocusOrTab = "Right"; };
            "bind \"Alt Down\"" = { MoveFocus = "Down"; };
            "bind \"Alt Up\"" = { MoveFocus = "Up"; };
            "bind \"Alt n\"" = { NewPane = {}; };
          };
        };
      };
    };

    home.file =
      let
        ponosInstances = config.modules.ponos.instances or { };
        enabledPonosInstances = lib.filterAttrs (n: v: v.enable or false) ponosInstances;

        ponosTab = if enabledPonosInstances == { } then "" else
          let
            instancesList = lib.mapAttrsToList (name: instance: { inherit name instance; }) enabledPonosInstances;
            numInstances = builtins.length instancesList;
            halfLen = (numInstances + 1) / 2;
            firstHalf = lib.take halfLen instancesList;
            secondHalf = lib.drop halfLen instancesList;
            mkPane = { name, instance }: ''
              pane {
                command "bash"
                args "-c" "export RUST_LOG=info GH_PROMPT_DISABLED=1; while true; do ponos-${name}; sleep 3; done"
                cwd "${instance.settings.main_repo}"
              }
            '';
          in
          ''
            tab name="ponos-bots" {
              pane size=1 borderless=true {
                plugin location="zellij:compact-bar"
              }
              ${if numInstances > 2 then ''
              pane split_direction="vertical" {
                pane split_direction="horizontal" {
                  ${lib.concatStringsSep "\n                  " (map mkPane firstHalf)}
                }
                pane split_direction="horizontal" {
                  ${lib.concatStringsSep "\n                  " (map mkPane secondHalf)}
                }
              }'' else ''
              ${lib.concatStringsSep "\n              " (map mkPane instancesList)}''}
            }
          '';

        value = ''
          layout {
            default_tab_template {
              children
              pane size=1 {
                plugin location="zellij:compact-bar"
              }
            }

            tab_template name="code" {
              pane borderless=true {
                command "$EDITOR"
                args "."
              }
              pane size=1 borderless=true {
                plugin location="zellij:compact-bar"
              }
            }

            ${lib.concatStringsSep "\n  " (map (c: "code name=\"${c.name}\" cwd=\"${c.cwd}\"") cfg.initialCodeTabs)}

            ${ponosTab}

            tab_template name="ui" {
               pane size=1 borderless=true {
                   plugin location="tab-bar"
               }
               children
               pane size=1 borderless=true {
                   plugin location="status-bar"
               }
            }

            swap_tiled_layout name="vertical" {
                ui max_panes=5 {
                    pane split_direction="vertical" {
                        pane
                        pane { children; }
                    }
                }
                ui max_panes=8 {
                    pane split_direction="vertical" {
                        pane { children; }
                        pane { pane; pane; pane; pane; }
                    }
                }
                ui max_panes=12 {
                    pane split_direction="vertical" {
                        pane { children; }
                        pane { pane; pane; pane; pane; }
                        pane { pane; pane; pane; pane; }
                    }
                }
            }

            swap_tiled_layout name="horizontal" {
                ui max_panes=4 {
                    pane
                    pane
                }
                ui max_panes=8 {
                    pane {
                        pane split_direction="vertical" { children; }
                        pane split_direction="vertical" { pane; pane; pane; pane; }
                    }
                }
                ui max_panes=12 {
                    pane {
                        pane split_direction="vertical" { children; }
                        pane split_direction="vertical" { pane; pane; pane; pane; }
                        pane split_direction="vertical" { pane; pane; pane; pane; }
                    }
                }
            }

            swap_tiled_layout name="stacked" {
                ui min_panes=5 {
                    pane split_direction="vertical" {
                        pane
                        pane stacked=true { children; }
                    }
                }
            }

            swap_floating_layout name="staggered" {
              floating_panes min_panes=5
            }
  
            swap_floating_layout name="spread" {
              floating_panes max_panes=1 {
                pane { width "46%"; }
              }
              floating_panes max_panes=2 {
                pane { x "3%";  y "25%"; width "46%"; }
                pane { x "50%"; y "25%"; width "46%"; }
              }
              floating_panes max_panes=3 {
                pane {          y "50%"; width "46%"; height "46%"; }
                pane { x "3%";  y "2%";  width "46%"; height "46%"; }
                pane { x "50%"; y "2%";  width "46%"; height "46%"; }
              }
              floating_panes max_panes=4 {
                pane { x "3%";  y "3%";  width "46%"; height "45%"; }
                pane { x "3%";  y "50%"; width "46%"; height "45%"; }
                pane { x "50%"; y "3%";  width "46%"; height "45%"; }
                pane { x "50%"; y "50%"; width "46%"; height "45%"; }
              }
            }

            swap_floating_layout name="enlarged" {
              floating_panes max_panes=10 {
                pane { x "5%"; y 1; width "90%"; height "90%"; }
                pane { x "5%"; y 2; width "90%"; height "90%"; }
                pane { x "5%"; y 3; width "90%"; height "90%"; }
                pane { x "5%"; y 4; width "90%"; height "90%"; }
                pane { x "5%"; y 5; width "90%"; height "90%"; }
                pane { x "5%"; y 6; width "90%"; height "90%"; }
                pane { x "5%"; y 7; width "90%"; height "90%"; }
                pane { x "5%"; y 8; width "90%"; height "90%"; }
                pane { x "5%"; y 9; width "90%"; height "90%"; }
                pane { x 10; y 10; width "90%"; height "90%"; }
              }
            }

            swap_floating_layout name="spread_tall" {
              floating_panes max_panes=1 {
                pane { y 1; width "46%"; height "90%"; }
              }
              floating_panes max_panes=2 {
                pane { y 1; x "3%";  width "46%"; height "90%"; }
                pane { y 1; x "50%"; width "46%"; height "90%"; }
              }
            }
          }
        '';
      in
      {
        ".config/zellij/layouts/code.kdl".text = value;
      };
  };
}
