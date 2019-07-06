# home-config
Config files for linux home

## Prerequisites

- `apt install git httpie jq htop ncdu`
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [bat](https://github.com/sharkdp/bat#installation)
- [prettyping](https://github.com/denilsonsa/prettyping#installation)
- [fzf](https://github.com/junegunn/fzf#installation)
- [n node version manager](https://github.com/tj/n)
- [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [gcloud cli](https://cloud.google.com/sdk/docs/#install_the_latest_cloud_tools_version_cloudsdk_current_version)
- `npm install -g awsp`
- `npm install -g tldr`

## Setup

```bash
# Git
curl https://raw.githubusercontent.com/deuzu/home-config/master/git/config > ~/.gitconfig

# Bash config files
curl https://raw.githubusercontent.com/deuzu/home-config/master/.bashrc > ~/.bashrc
curl https://raw.githubusercontent.com/deuzu/home-config/master/.bash_aliases > ~/.bash_aliases
curl https://raw.githubusercontent.com/deuzu/home-config/master/.bash_completion > ~/.bash_completion
