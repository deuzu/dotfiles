{
  bash = {
    "*" = "allow";
    "env*" = "deny";
    "ssh *" = "deny";
    "sops *" = "deny";
    "git-crypt *" = "deny";
    "gpg *" = "deny";
    "terraform *" = "deny";
    # "terraform fmt*" = "allow";
    # "terraform validate*" = "allow";
    "git add *" = "deny";
    "git commit *" = "deny";
    "git push *" = "deny";
    "curl" = "ask";
    # "kubectl*" = "allow";
    # "gcloud*" = "allow";
    # "jq*" = "allow";
    # "echo*" = "allow";
    # "cat*" = "allow";
    # "head*" = "allow";
    # "less*" = "allow";
    # "tail*" = "allow";
    # "ls*" = "allow";
    # "find*" = "allow";
    # "grep*" = "allow";
    # "rg*" = "allow";
  };
}
