export PATH=/opt/local/bin:$PATH
test -d $HOME/bin && export PATH=$HOME/bin:$PATH || true
test -s ~/.alias && . ~/.alias || true

# Mono Development:
export MONO_IOMAP=all
export MONO_LOG_MASK=all # asm,dll,cfg,type,gc
export MONO_LOG_LEVEL= # debug

# Also for Mono but not exclusive:
export DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH:=${HOME}/lib:/usr/local/lib:/lib:/usr/lib}
export DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH:/opt/local/lib

export SSH_ASKPASS=~/bin/get-ssh-password.sh

set -o emacs
bind '"\C-xv": vi-editing-mode'
set -o vi
bind '"\C-xp": emacs-editing-mode'
set -o emacs

test -s /opt/local/etc/bash_completion.d/git-completion && . /opt/local/etc/bash_completion.d/git-completion || true

editmode() {
	set -o | grep 'emacs.*on' >/dev/null 2>&1 && echo -ne '\033[32mE\033[39m' || echo -ne '\033[31mV\033[39m'
}

pidtree() {
	CUR=$$
	if [ ! -z "$1" ]
	then
		CUR=$1
	fi
	while [ "0" != "$CUR" ]
	do
		ps -p $CUR -o pid,user,command|tail -1
		CUR=$(ps uxwwww -o ppid -p $CUR|sed 's/.* //'|tail -1)
	done
}

# Show character if VPN is ready
get_vpn_status() {
  if [ -f /tmp/vpn.ready ]
  then
    echo -n "D"
    if [ -f /tmp/vpnon ]
    then
      echo -n "CT"
    fi
    echo -n " "
  fi
}

# Get the name of the branch we are on
git_prompt_info() {
  branch_prompt="$1"
  if [ -n "$branch_prompt" ]; then
    echo -n "$branch_prompt "
  else
    branch_prompt=$(__git_ps1)
    if [ -n "$branch_prompt" ]; then
      echo -n "$branch_prompt "
    fi
  fi
}

# Show character if changes are pending commit
git_pending_commit() {
  gso="$1"
  if [ ! -n "$gso" ]; then
    branch_prompt=$(__git_ps1)
    if [ -n "$branch_prompt" ]; then
      gso=$(git status -uno)
    fi
  fi
  if [ -n "$gso" ]; then
    if ! current_git_status=$(echo $gso | grep 'nothing to commit' 2> /dev/null)
    then
      echo -ne '\033[31m☠ '
    fi
  fi
}

# Show character if changes are pending push
git_pending_push() {
  gso="$1"
  if [ ! -n "$gso" ]; then
    branch_prompt=$(__git_ps1)
    if [ -n "$branch_prompt" ]; then
      gso=$(git status -uno)
    fi
  fi
  if [ -n "$gso" ]; then
    if current_git_status=$(echo $gso | grep 'Your branch is ahead of' 2> /dev/null)
    then
      echo -ne '\033[33m⇧ '
    else
      if current_git_status=$(echo $gso | grep 'Your branch and .* have diverged' 2> /dev/null)
      then
        echo -ne '\033[33m⇧ '
      fi
    fi
  fi
}

# Show character if changes are pending rebase
git_pending_rebase() {
  gso="$1"
  if [ ! -n "$gso" ]; then
    branch_prompt=$(__git_ps1)
    if [ -n "$branch_prompt" ]; then
      gso=$(git status -uno)
    fi
  fi
  if [ -n "$gso" ]; then
    if current_git_status=$(echo $gso | grep 'Your branch is behind' 2> /dev/null)
    then
      echo -ne '\033[34m⇒ '
    else
      if current_git_status=$(echo $gso | grep 'Your branch and .* have diverged' 2> /dev/null)
      then
        echo -ne '\033[34m⇒ '
      fi
    fi
  fi
}

# Reduce to one call to __git_ps1 and one to git status -uno for performance.
git_full_status ()
{
  branch_prompt=$(__git_ps1)
  if [ -n "$branch_prompt" ]; then
    gso=$(git status -uno)
    git_prompt_info "$branch_prompt"
    git_pending_rebase "$gso"
    git_pending_push "$gso"
    git_pending_commit "$gso"
  fi
}

dufind() {
	for i in `ls -a */*/Users/mjerde/"$1"|sort |uniq |grep -v "^\.*$"|grep -v "Macintosh HD/Users"|grep -v "^ *$"`;do du -ks */*/Users/mjerde/"$1"/"$i";done|sort -n
}

tmdel() {
	for i in */*/Users/mjerde/"$1";do if [ -d "$i" ];then echo ""|chmod -R -E "$i";sudo rm -rfv "$i";fi;done
}

md5dir ()
{
	echo `find "$1" -type f -exec md5 "{}" \; |sed 's/.* = //'| sort| md5` "$1"
}

# Translate Tour de France coverage to be correctly pronounced by the 'say' command.
tdfspeak ()
{
	if [ -e ~/bin/tdfspeak.sh ]
	then
		~/bin/tdfspeak.sh
	else
		cat
	fi
}

# Basic prompt with Git branch name.
PS1='\h:\W$(__git_ps1 "(%s)") \u\$ '
# Basic prompt with Git branch name and colorful icons.
PS1='\h:\W$(git_prompt_info)\[\e[1;34m\]$(git_pending_rebase)\[\e[0m\]\[\e[1;33m\]$(git_pending_push)\[\e[0m\]\[\e[1;31m\]$(git_pending_commit)\[\e[0m\]\[\e[1;32m\]$(get_vpn_status)\[\e[0m\]\u\$ '
# Multi-line prompt with Git branch name and colorful icons.
PS1='$(editmode)\[\e[1;33m\]あなたのお母さんはハムスターであり、あなたの父親は、エルダーベリーのワカサギ。\[\e[0m\]
\h:\w$(git_full_status)\[\e[0m\]\[\e[1;32m\]$(get_vpn_status)\[\e[0m\]
\u\$ '

test -s ~/.bashrc.work && . ~/.bashrc.work || true

