# home-config
Config files for linux home

## Setup

```bash
# Git
curl https://raw.githubusercontent.com/deuzu/home-config/master/git/config > ~/.gitconfig

# Bash config files
curl https://raw.githubusercontent.com/deuzu/home-config/master/.bashrc > ~/.bashrc
curl https://raw.githubusercontent.com/deuzu/home-config/master/.bash_aliases > ~/.bash_aliases
curl https://raw.githubusercontent.com/deuzu/home-config/master/.bash_completion > ~/.bash_completion

# Scripts
curl https://raw.githubusercontent.com/deuzu/home-config/master/bin/github-release-note > ~/bin/github-release-note
curl https://raw.githubusercontent.com/deuzu/home-config/master/bin/kubectl-exec > ~/bin/kubectl-exec
curl https://raw.githubusercontent.com/deuzu/home-config/master/bin/kubectl-grep > ~/bin/kubectl-grep
curl https://raw.githubusercontent.com/deuzu/home-config/master/bin/kubectl-secret > ~/bin/kubectl-secret
chmod -R +x ~/bin

# vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
curl https://raw.githubusercontent.com/deuzu/home-config/master/.vimrc > ~/.vimrc
vim +PluginInstall +qall
```
