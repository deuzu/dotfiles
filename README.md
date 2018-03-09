# home-config
Config files for linux home

## Setup

```bash
curl https://raw.githubusercontent.com/deuzu/home-config/master/.bashrc > ~/.bashrc
curl https://raw.githubusercontent.com/deuzu/home-config/master/.bash_aliases > ~/.bash_aliases
curl https://raw.githubusercontent.com/deuzu/home-config/master/.bash_aliases > ~/.bash_completion
curl https://raw.githubusercontent.com/deuzu/home-config/master/bin > ~/bin
curl https://raw.githubusercontent.com/deuzu/home-config/master/git/config > ~/.gitconfig

# vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
curl https://raw.githubusercontent.com/deuzu/home-config/master/.vimrc > ~/.vimrc
vim +PluginInstall +qall
```
