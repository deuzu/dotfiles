{
  bash = {
    "*" = "allow";
    "env*" = "deny";
    "ssh *" = "deny";
    "sops *" = "deny";
    "git-crypt *" = "deny";
    "gpg *" = "deny";
    "terraform * apply*" = "deny";
    "terraform apply*" = "deny";
    "git add *" = "deny";
    "git commit *" = "deny";
    "git push *" = "deny";
    "curl *" = "ask";
  };
}
