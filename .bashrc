export PATH=$PATH:/opt/local/bin
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

test -s /opt/local/etc/bash_completion.d/git-completion && . /opt/local/etc/bash_completion.d/git-completion || true

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

# Basic prompt with Git branch name.
PS1='\h:\W$(__git_ps1 "(%s)") \u\$ '
# Basic prompt with Git branch name and colorful icons.
PS1='\h:\W$(git_prompt_info)\[\e[1;34m\]$(git_pending_rebase)\[\e[0m\]\[\e[1;33m\]$(git_pending_push)\[\e[0m\]\[\e[1;31m\]$(git_pending_commit)\[\e[0m\]\[\e[1;32m\]$(get_vpn_status)\[\e[0m\]\u\$ '
# Multi-line prompt with Git branch name and colorful icons.
PS1='\[\e[1;33m\]あなたのお母さんはハムスターであり、あなたの父親は、エルダーベリーのワカサギ。\[\e[0m\]
\h:\w$(git_full_status)\[\e[0m\]\[\e[1;32m\]$(get_vpn_status)\[\e[0m\]
\u\$ '

test -s ~/.bashrc.work && . ~/.bashrc.work || true

