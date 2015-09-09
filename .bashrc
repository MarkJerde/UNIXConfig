export PATH=/opt/local/bin:$PATH
test -d $HOME/bin && export PATH=$HOME/bin:$PATH || true
test -s ~/.alias && . ~/.alias || true

# For git svn / Mavericks compatibility:
#export PATH="/Applications/Xcode.app/Contents/Developer/usr/libexec/git-core":$PATH
#export PATH="/Applications/Xcode.app/Contents/Developer/usr/bin":$PATH

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

test -s /usr/share/git-core/git-prompt.sh && . /usr/share/git-core/git-prompt.sh || true
test -s /opt/local/share/git-core/contrib/completion/git-prompt.sh && . /opt/local/share/git-core/contrib/completion/git-prompt.sh || true
test -s /opt/local/etc/bash_completion.d/git-prompt.sh && . /opt/local/etc/bash_completion.d/git-prompt.sh || true
test -s /usr/share/git-core/git-completion.bash && . /usr/share/git-core/git-completion.bash || true
test -s /opt/local/share/git-core/contrib/completion/git-completion.bash && . /opt/local/share/git-core/contrib/completion/git-completion.bash || true
test -s /opt/local/etc/bash_completion.d/git-completion.bash && . /opt/local/etc/bash_completion.d/git-completion.bash || true

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

fstype ()
{
	mount |grep "^$(df .|head -2|tail -1|cut -f 1 -d ' ')"|sed 's/.*(//;s/,.*//'
}

# Reduce to one call to __git_ps1 and one to git status -uno for performance.
git_full_status ()
{
  # This stuff is slow over vboxsf, smbfs, and nfs, so skip it to save 2 seconds per prompt.
  fstype|grep -v vboxsf | grep -v smbfs | grep -v nfs | grep -q "." || return
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

picture ()
{
	first=$1
	last=$2
	curl http://www.linkedin.com/pub/dir/\?first=$first\&last=$last\&search=Search -o -|sed -n '1,/[Hh][Hg][Ss][Tt]/ p'|grep "img "|grep $last|sed 's/height="[0-9]*"//'|sed 's/width="[0-9]*"//' > ~/Downloads/picture.html 
	open ~/Downloads/picture.html
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

SSHCOLOR=0
env | grep -q SSH_CONNECTION && export SSHCOLOR=31

PSDELIM_jp='あなたのお母さんはハムスターであり、あなたの父親は、エルダーベリーのワカサギ。'
PSDELIM_gr='Η μητέρα σου ήταν ένα χάμστερ και ο πατέρας σου μύριζε κουφοξυλιάς!'
PSDELIM_marathi='तुम्हारी माँ एक हम्सटर था और अपने पिता बड़े बेर के गलाना'
PSDELIM_hindi='तुम्हारी माँ एक हम्सटर था और अपने पिता बड़े बेर के गलाना'
PSDELIM_thai='แม่ของหนูแฮมสเตอร์ของคุณaและคุณพ่อของคุณหลอมเหลวของพี่เบอร์รี่'
PSDELIM_lang="jp"
psdelim() {
	PSDELIM_var=PSDELIM_$PSDELIM_lang
	echo -n "${!PSDELIM_var}"
}
alias psLjp='export PSDELIM_lang="jp"'
alias psLgr='export PSDELIM_lang="gr"'
alias psLmarathi='export PSDELIM_lang="marathi"'
alias psLhindi='export PSDELIM_lang="hindi"'
alias psLthai='export PSDELIM_lang="thai"'

# Basic prompt with Git branch name.
PS1='\h:\W$(__git_ps1 "(%s)") \u\$ '
# Basic prompt with Git branch name and colorful icons.
PS1='\h:\W$(git_prompt_info)\[\e[1;34m\]$(git_pending_rebase)\[\e[0m\]\[\e[1;33m\]$(git_pending_push)\[\e[0m\]\[\e[1;31m\]$(git_pending_commit)\[\e[0m\]\[\e[1;32m\]$(get_vpn_status)\[\e[0m\]\u\$ '
# Multi-line prompt with Git branch name and colorful icons.
PS1='$(editmode)\[\e[1;33m\]$(psdelim)\[\e[0m\]
\[\e[1;${SSHCOLOR}m\]\h\[\e[0m\]:\w$(git_full_status)\[\e[0m\]\[\e[1;32m\]$(get_vpn_status)\[\e[0m\]
\u\$ '

test -s ~/.bashrc.work && . ~/.bashrc.work || true

