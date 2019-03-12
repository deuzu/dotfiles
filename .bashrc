# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color) color_prompt=yes;;
esac

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
  eval "`dircolors -b`"
  alias ls='ls --color=auto'
fi

# Color mapping
grey='\[\033[1;30m\]'
red='\[\033[0;31m\]'
RED='\[\033[1;31m\]'
green='\[\033[0;32m\]'
GREEN='\[\033[1;32m\]'
yellow='\[\033[0;33m\]'
YELLOW='\[\033[1;33m\]'
purple='\[\033[0;35m\]'
PURPLE='\[\033[1;35m\]'
white='\[\033[0;37m\]'
WHITE='\[\033[1;37m\]'
blue='\[\033[0;34m\]'
BLUE='\[\033[1;34m\]'
cyan='\[\033[0;36m\]'
CYAN='\[\033[1;36m\]'
NC='\[\033[0m\]'

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Get Git current branch
parse_git_branch () {
    echo git::$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
}

# Get Kubernetes current config if on a git project
parse_k8s_current_config () {
    echo k8s::$(kubectl config current-context)
}

PS1_PWD="$RED\w$NC"
PS1_EXTRAS="$CYAN\$(parse_git_branch) $WHITE| $PURPLE\$(parse_k8s_current_config)$NC"
PS1="$PS1_PWD\n$PS1_EXTRAS\n${debian_chroot:+($debian_chroot)}\$ "

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

extract () {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)   tar xjf $1        ;;
           *.tar.gz)    tar xzf $1     ;;
           *.bz2)       bunzip2 $1       ;;
           *.rar)       rar x $1     ;;
           *.gz)        gunzip $1     ;;
           *.tar)       tar xf $1        ;;
           *.tbz2)      tar xjf $1      ;;
           *.tgz)       tar xzf $1       ;;
           *.zip)       unzip $1     ;;
           *.Z)         uncompress $1  ;;
           *.7z)        7z x $1    ;;
           *)           echo "'$1' cannot be extracted via extract()" ;;
       esac
   else
       echo "'$1' is not a valid file"
   fi
}

#netinfo - shows network information for your system
netinfo () {
  echo "--------------- Network Information ---------------"
  /sbin/ifconfig | awk /'inet addr/ {print $2}'
  /sbin/ifconfig | awk /'Bcast/ {print $3}'
  /sbin/ifconfig | awk /'inet addr/ {print $4}'
  /sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'
  myip=`lynx -dump -hiddenlinks=ignore -nolist http://checkip.dyndns.org:8245/ | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g' `
  echo "${myip}"
  echo "---------------------------------------------------"
}

#dirsize - finds directory sizes and lists them for the current directory
dirsize () {
  du -shx * .[a-zA-Z0-9_]* 2> /dev/null | \
  egrep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
  egrep '^ *[0-9.]*M' /tmp/list
  egrep '^ *[0-9.]*G' /tmp/list
  rm -rf /tmp/list
}

#copy and go to dir
cpg () {
  if [ -d "$2" ];then
    cp $1 $2 && cd $2
  else
    cp $1 $2
  fi
}

#move and go to dir
mvg () {
  if [ -d "$2" ];then
    mv $1 $2 && cd $2
  else
    mv $1 $2
  fi
}

# Samuel Maftoul Ninjatism
up() {
  local x='';
  for i in $(seq ${1:-1});
    do x="$x../";
  done;
  cd $x;
}

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Alias definitions.
if [ -f ~/.bash_exports ]; then
    . ~/.bash_exports
fi

# The fuck
eval $(thefuck --alias)

# kubectl
source <(kubectl completion bash)
source <(k completion bash)

# AWS
complete -C '/usr/bin/aws_completer' aws
