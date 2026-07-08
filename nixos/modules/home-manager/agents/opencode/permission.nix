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
    "terraform destroy*" = "ask";
    "terraform * destroy*" = "ask";
    "terraform state *" = "ask";
    "terraform * state *" = "ask";
    "git add *" = "deny";
    "git commit *" = "deny";
    "git push *" = "deny";
    "curl *" = "ask";
  };
}
