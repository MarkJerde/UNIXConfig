export PATH=$PATH:/opt/local/bin
test -d $HOME/bin && export PATH=$HOME/bin:$PATH || true
test -s ~/.alias && . ~/.alias || true

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
  branch_prompt=$(__git_ps1)
  if [ -n "$branch_prompt" ]; then
    echo "$branch_prompt "
  fi
}

# Show character if changes are pending commit
git_pending_commit() {
  branch_prompt=$(__git_ps1)
  if [ -n "$branch_prompt" ]; then
    if current_git_status=$(git status | grep 'added to commit' 2> /dev/null)
    then
      echo '☠ '
    fi
  fi
}

# Show character if changes are pending push
git_pending_push() {
  branch_prompt=$(__git_ps1)
  if [ -n "$branch_prompt" ]; then
    if current_git_status=$(git status | grep 'Your branch is ahead of' 2> /dev/null)
    then
      echo '⇧ '
    fi
    if current_git_status=$(git status | grep 'Your branch and .* have diverged' 2> /dev/null)
    then
      echo '⇧ '
    fi
  fi
}

# Show character if changes are pending rebase
git_pending_rebase() {
  branch_prompt=$(__git_ps1)
  if [ -n "$branch_prompt" ]; then
    if current_git_status=$(git status | grep 'Your branch is behind' 2> /dev/null)
    then
      echo '⇒ '
    fi
    if current_git_status=$(git status | grep 'Your branch and .* have diverged' 2> /dev/null)
    then
      echo '⇒ '
    fi
  fi
}

# Basic prompt with Git branch name.
PS1='\h:\W$(__git_ps1 "(%s)") \u\$ '
# Basic prompt with Git branch name and colorful icons.
PS1='\h:\W$(git_prompt_info)\[\e[1;34m\]$(git_pending_rebase)\[\e[0m\]\[\e[1;33m\]$(git_pending_push)\[\e[0m\]\[\e[1;31m\]$(git_pending_commit)\[\e[0m\]\[\e[1;32m\]$(get_vpn_status)\[\e[0m\]\u\$ '
# Multi-line prompt with Git branch name and colorful icons.
PS1='\[\e[1;33m\]あなたのお母さんはハムスターであり、あなたの父親は、エルダーベリーのワカサギ。\[\e[0m\]
\h:\w$(git_prompt_info)\[\e[1;34m\]$(git_pending_rebase)\[\e[0m\]\[\e[1;33m\]$(git_pending_push)\[\e[0m\]\[\e[1;31m\]$(git_pending_commit)\[\e[0m\]\[\e[1;32m\]$(get_vpn_status)\[\e[0m\]
\u\$ '

test -s ~/.bashrc.work && . ~/.bashrc.work || true

