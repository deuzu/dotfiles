{ inputs, config, lib, pkgs, system, ... }:
let
  cfg = config.modules.textEditors.helix;
in
{
  options.modules.textEditors.helix = with lib; {
    enable = mkEnableOption "Helix Editor";
  };

  config = lib.mkIf cfg.enable {
    # FIXME: Hack for Gnome
    # See: https://github.com/nix-community/home-manager/issues/1011#issuecomment-847684985
    programs.bash = lib.mkIf config.modules.display.gnome.enable {
      bashrcExtra = ''
        export EDITOR="hx";
      '';
    };
    # FIXME: nushell isn't included in `programs.helix.defaultEditor` in upstream
    programs.nushell.environmentVariables = {
      EDITOR = "hx";
    };

    programs.helix = {
      enable = true;
      package = inputs.helix.packages."${system}".helix;
      defaultEditor = true;
      extraPackages = with pkgs; [
        bash-language-server
        biome
        clang-tools
        docker-compose-language-service
        dockerfile-language-server
        golangci-lint
        golangci-lint-langserver
        gopls
        gotools
        marksman
        nil
        nixd
        nixpkgs-fmt
        # nodePackages.intelephense
        # PHP
        intelephense
        phpactor
        php83Packages.php-codesniffer
        php83Packages.php-cs-fixer
        php83Packages.psalm
        # Python
        (python3.withPackages (p: (with p; [
          python-lsp-ruff
          python-lsp-server
        ])))
        ruff
        #
        sql-formatter
        rust-analyzer
        taplo
        terraform-ls
        typescript
        vscode-langservers-extracted
        yaml-language-server
      ];
      settings = {
        editor = {
          color-modes = true;
          cursorline = true;
          bufferline = "multiple";
          line-number = "relative";
          auto-pairs = false;

          soft-wrap.enable = true;

          auto-save = {
            focus-lost = true;
            after-delay.enable = true;
          };

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          file-picker = {
            hidden = false;
            ignore = false;
          };

          indent-guides = {
            character = "┊";
            render = true;
            skip-levels = 1;
          };

          whitespace = {
            render = {
              space = "none";
              tab = "none";
              nbsp = "all";
              nnbsp = "none";
              newline = "none";
            };
          };

          end-of-line-diagnostics = "hint";
          inline-diagnostics.cursor-line = "warning";

          lsp = {
            display-inlay-hints = true;
            display-messages = true;
          };

          statusline = {
            left = [ "mode" "file-name" "spinner" "read-only-indicator" "file-modification-indicator" ];
            right = [ "diagnostics" "selections" "register" "file-type" "file-line-ending" "position" ];
            mode.normal = "N";
            mode.insert = "I";
            mode.select = "S";
          };
        };

        keys =
          let
            normalAndInsertKeys = {
              # "C-c" by helix default. And Using "C-/" is not simple. It requires Kitty keyboard protocol and be different on each terminal.
              # See https://github.com/helix-editor/helix/discussions/12899
              # "C-/" = "toggle_comments"; # Such as vscode. Simply works on ghostty.
              # "C-7" = "toggle_comments"; # Trick for realizing "C-/" in Windows Terminal. See https://github.com/helix-editor/helix/issues/1369#issuecomment-1749330353. And not working on ghostty.
            };
          in
          {
            normal = normalAndInsertKeys // {
              ":" = "collapse_selection";
              ";" = "command_mode";
              space = {
                space = "command_mode";
                l = ":! echo -e \"\\e]52;;$(echo %{buffer_name} | base64)\\007\" > /dev/tty";
                B = ":echo %sh{git blame -L %{cursor_line},+1 %{buffer_name}}";
              };
              # https://github.com/helix-editor/helix/issues/6338
              # https://github.com/helix-editor/helix/discussions/7690
              C-h = ":toggle lsp.display-inlay-hints";
              C-r = ":reload";
              C-y = [
                ":sh rm -f /tmp/hx-yazi-picker"
                ":insert-output yazi %{buffer_name} --chooser-file=/tmp/hx-yazi-picker"
                ":insert-output echo '\x1b[?1049h\x1b[?2004h' > /dev/tty"
                # Doesn't support opening multiple files.
                ":open %sh{cat /tmp/hx-yazi-picker | head -n1}"
                ":redraw"
                ":set mouse false"
                ":set mouse true"
              ];
              C-e = [
                ":sh zellij run -n Sops -c -f -x 10%% -y 10%% --width 80%% --height 80%% -- sops edit %{buffer_name}"
              ];
              # [goto] definition other window
              g.o = "@<C-w>o<C-w>vgd";
            };
            insert = normalAndInsertKeys;
          };
      };

      languages = {
        language-server = {
          biome = {
            command = "biome";
            args = [ "lsp-proxy" ];
          };

          rust-analyzer.config.check = {
            command = "clippy";
          };

          yaml-language-server.config.yaml.schemas = {
            kubernetes = "k8s/*.yaml";
          };

          typescript-language-server = {
            command = lib.getExe pkgs.typescript-language-server;
            args = [ "--stdio" ];
          };

          terraform-ls = {
            command = lib.getExe pkgs.terraform-ls;
            args = [ "serve" "-log-file" "/dev/null" ];
            filetypes = [
              "hcl"
              "tf"
              "tfvars"
            ];
          };
        };

        language = [
          {
            name = "css";
            language-servers = [
              "vscode-css-language-server"
            ];
            formatter = {
              command = lib.getExe pkgs.prettier;
              args = [ "--stdin-filepath" "file.css" ];
            };
            auto-format = true;
          }
          {
            name = "go";
            language-servers = [
              "gopls"
              "golangci-lint-lsp"
            ];
            formatter = {
              command = "goimports";
            };
            auto-format = true;
          }
          {
            name = "html";
            language-servers = [
              "vscode-html-language-server"
            ];
            formatter = {
              command = lib.getExe pkgs.prettier;
              args = [ "--stdin-filepath" "file.html" ];
            };
            auto-format = true;
          }
          {
            name = "javascript";
            language-servers = [
              { name = "typescript-language-server"; except-features = [ "format" ]; }
              "biome"
            ];
            auto-format = true;
          }
          {
            name = "json";
            language-servers = [
              { name = "vscode-json-language-server"; except-features = [ "format" ]; }
              "biome"
            ];
            formatter = {
              command = "biome";
              args = [ "format" "--indent-style" "space" "--stdin-file-path" "file.json" ];
            };
            auto-format = true;
          }
          {
            name = "jsonc";
            language-servers = [
              { name = "vscode-json-language-server"; except-features = [ "format" ]; }
              "biome"
            ];
            formatter = {
              command = "biome";
              args = [ "format" "--indent-style" "space" "--stdin-file-path" "file.jsonc" ];
            };
            file-types = [ "jsonc" "hujson" ];
            auto-format = true;
          }
          {
            name = "jsx";
            language-servers = [
              { name = "typescript-language-server"; except-features = [ "format" ]; }
              "biome"
            ];
            formatter = {
              command = "biome";
              args = [ "format" "--indent-style" "space" "--stdin-file-path" "file.jsx" ];
            };
            auto-format = true;
          }
          {
            name = "markdown";
            language-servers = [
              "marksman"
            ];
            formatter = {
              command = lib.getExe pkgs.prettier;
              args = [ "--stdin-filepath" "file.md" ];
            };
            auto-format = true;
          }
          {
            name = "nix";
            formatter = {
              command = "nixpkgs-fmt";
            };
            auto-format = true;
          }
          {
            name = "php";
            language-servers = [
              "phpactor"
              "intelephense"
            ];
            indent = {
              tab-width = 4;
              unit = " ";
            };
            auto-format = true;
          }
          # {
          #   name = "php";
          #   file-types = ["php"];
          #   debugger = {
          #     name = "vscode-php-debug";
          #     transport = "stdio";
          #     command = "node";
          #     args = [ "/home/josh/.vscode/extensions/xdebug.php-debug-1.34.0/out/phpDebug.js" ];
          #     templates = [{
          #       name = "Listen for XDebug";
          #       request = "launch";
          #       completion = ["ignored"];
          #       args = {};
          #     }];
          #   };
          # }
          {
            name = "python";
            language-servers = [
              "pylsp"
            ];
            formatter = {
              command = "sh";
              args = [ "-c" "ruff check --select I --fix - | ruff format --line-length 88 -" ];
            };
            auto-format = true;
          }
          {
            name = "rust";
            language-servers = [
              "rust-analyzer"
            ];
            auto-format = true;
          }
          {
            name = "scss";
            language-servers = [
              "vscode-css-language-server"
            ];
            formatter = {
              command = lib.getExe pkgs.prettier;
              args = [ "--stdin-filepath" "file.scss" ];
            };
            auto-format = true;
          }
          {
            name = "sql";
            language-servers = [
            ];
            formatter = {
              command = "sql-formatter";
              args = [ "-l" "postgresql" "-c" "{\"keywordCase\": \"lower\", \"dataTypeCase\": \"lower\", \"functionCase\": \"lower\", \"expressionWidth\": 120, \"tabWidth\": 4}" ];
            };
            auto-format = true;
          }
          {
            name = "toml";
            language-servers = [
              "taplo"
            ];
            formatter = {
              command = "taplo";
              args = [ "fmt" "-o" "column_width=120" "-" ];
            };
            auto-format = true;
          }
          {
            name = "tsx";
            language-servers = [
              { name = "typescript-language-server"; except-features = [ "format" ]; }
              "biome"
            ];
            formatter = {
              command = "biome";
              args = [ "format" "--indent-style" "space" "--stdin-file-path" "file.tsx" ];
            };
            auto-format = true;
          }
          {
            name = "typescript";
            language-servers = [
              { name = "typescript-language-server"; except-features = [ "format" "inlay-hints" ]; }
              "biome"
            ];
            formatter = {
              command = "biome";
              args = [ "format" "--indent-style" "space" "--stdin-file-path" "file.ts" ];
            };
            auto-format = true;
          }
          {
            name = "yaml";
            language-servers = [
              "yaml-language-server"
            ];
            formatter = {
              command = lib.getExe pkgs.prettier;
              args = [ "--stdin-filepath" "file.yaml" ];
            };
            auto-format = true;
          }
          {
            name = "hcl";
            auto-format = true;
            language-id = "terraform";
            language-servers = [
              "terraform-ls"
            ];
            formatter = {
              command = lib.getExe pkgs.terraform;
              args = [
                "fmt"
                "-"
              ];
            };
          }
          {
            name = "tfvars";
            auto-format = true;
            language-id = "terraform-vars";
            language-servers = [
              "terraform-ls"
            ];
            formatter = {
              command = lib.getExe pkgs.terraform;
              args = [
                "fmt"
                "-"
              ];
            };
          }
        ];
      };
    };
  };
}
