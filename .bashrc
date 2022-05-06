# Source the default .bashrc if present.
test -s ~/.bashrc.default && . ~/.bashrc.default || true

export PATH=/opt/local/bin:$PATH
test -d $HOME/bin && export PATH=$HOME/bin:$PATH || true
# Add the bin for scripts contained in the UNIXConfig repository:
test -d $HOME/bin/ucbin && export PATH=$HOME/bin/ucbin:$PATH || true
# For systems with a secondary home, such as WSL:
test -d $HOME/home/bin && export PATH=$HOME/home/bin:$PATH || true

test -s ~/.alias && . ~/.alias || true

export EDITOR=vi

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

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

set -o emacs
bind '"\C-xv": vi-editing-mode'
set -o vi
bind '"\C-xp": emacs-editing-mode'
set -o emacs

# Look for our Git scripts
for gitCompletion in /usr/share/git-core /opt/local/share/git-core/contrib/completion /opt/local/etc/bash_completion.d /opt/local/share/git/contrib/completion /Applications/Xcode.app/Contents/Developer/usr/share/git-core
do
	for gitScript in git-completion.bash git-prompt.sh
	do
		test -s "$gitCompletion/$gitScript" && . "$gitCompletion/$gitScript" || true
	done
done

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
    if ! current_git_status=$(echo "$gso" | grep 'nothing to commit' 2> /dev/null)
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
    if current_git_status=$(echo "$gso" | grep 'Your branch is ahead of' 2> /dev/null)
    then
      echo -ne '\033[33m⇧ '
    else
      if current_git_status=$(echo "$gso" | grep 'Your branch and .* have diverged' 2> /dev/null)
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
    if current_git_status=$(echo "$gso" | grep 'Your branch is behind' 2> /dev/null)
    then
      echo -ne '\033[34m⇒ '
    else
      if current_git_status=$(echo "$gso" | grep 'Your branch and .* have diverged' 2> /dev/null)
      then
        echo -ne '\033[34m⇒ '
      fi
    fi
  fi
}

fstype ()
{
	uname | grep -q -e CYGWIN -e MINGW
	if [ 0 -eq $? ]
	then
		echo slowOS
		return
	fi

	result="$(df -T .)" 2> /dev/null > /dev/null
	if [ 0 -eq $? ]
	then
		echo "$result"|head -2|tail -1|sed 's/  */ /g'|cut -f 2 -d ' '
	else
		mount |grep "^$(df .|head -2|tail -1|cut -f 1 -d ' ')"|sed 's/.*(//;s/,.*//'
	fi
}

git_full_status_disabled ()
{
	# This stuff is slow over various slow systems, so skip it to save 2 seconds per prompt.
	fstype|grep -q -e slowOS
}

# Reduce to one call to __git_ps1 and one to git status -uno for performance.
git_full_status ()
{
  # This stuff is slow over vboxsf, smbfs, nfs, and other slow systems, so skip it to save 2 seconds per prompt.
  fstype|grep -q -e vboxsf -e nfs -e smb -e cifs -e slowOS
  if [ 0 -eq $? ]
  then
  	return
  fi

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

# Traverse test results ("ms") directories.
export LMSDIR="$HOME/Data/Test Results"
lms ()
{
	export lums="$LMSDIR/$(ls -tr "$LMSDIR" | tail -1)"
	wlmsclast=0
	lums
}

plms ()
{
	lums="$(echo "$lums"|sed 's/.*\///g')"
	export lums="$LMSDIR/$(ls -tr "$LMSDIR" | sed '/'"$lums"'/,$ d' | tail -1)"
	wlmsclast=0
	lums
}

nlms ()
{
	lums="$(echo "$lums"|sed 's/.*\///g')"
	export lums="$LMSDIR/$(ls -tr "$LMSDIR" | sed '1,/'"$lums"'/ d' | head -1)"
	wlmsclast=0
	lums
}

lums ()
{
	echo "$lums"
}

lmsc ()
{
	export lumsc="$lums/$(ls -tr "$lums" | grep -v [^0-9] | sort -n | tail -1)"
	lumsc
}

lumsc ()
{
	echo "$lumsc"
}

wlmsc ()
{
	olumsc="$(lumsc)"
	adj=100
	start=$(date "+%s")
	if [ "" != "$wlmsclast" ]
	then
		echo -n "_($wlmsclast)" 1>&2
		sleep $wlmsclast
		adj=75
	fi
	lmsc > /dev/null
	while [ "$(lumsc)" == "$olumsc" ]
	do
		echo -n "." 1>&2
		sleep 1
		lmsc > /dev/null
		adj=100
	done
	echo 1>&2
	wlmsclast=$(date "+%s")
	wlmsclast=$((wlmsclast-$start))
	wlmsclast=$((wlmsclast*$adj/100))
	echo wlmsclast is $wlmsclast 1>&2
	lumsc
}

olms ()
{
	echo "$lumsc"
	open "$lumsc"
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

readlink -f ~/.bashrc 2> /dev/null > /dev/null
if [ 0 -ne $? ]
then
	# Not all readlink implementations include the -f/--canonicalize option, so we much provide that capability.
	readlinkf ()
	{
		TARGET_FILE="$1"
		RETURN_DIR="$(pwd)"

		cd "`dirname "$TARGET_FILE"`"
		cd "`pwd -P`"
		TARGET_FILE=`basename "$TARGET_FILE"`

		# Iterate down a (possible) chain of symlinks
		while [ -L "$TARGET_FILE" ]
		do
			TARGET_FILE=`readlink "$TARGET_FILE"`
			cd `dirname "$TARGET_FILE"`
			TARGET_FILE=`basename "$TARGET_FILE"`
		done

		# Compute the canonicalized name by finding the physical path 
		# for the directory we're in and appending the target file.
		PHYS_DIR=`pwd -P`
		RESULT="$PHYS_DIR/$TARGET_FILE"
		cd "$RETURN_DIR"
		echo $RESULT
	}
else
	readlinkf ()
	{
		readlink -f "$1"
	}
fi

if [ -d /media/sf_$USER ] ; then
	WINHOME=/media/sf_$USER
elif [ -d /mnt/c/Users/$USER ] ; then
	WINHOME=/mnt/c/Users/$USER
else
	WINHOME=/dev/null
fi

which -a open > /dev/null 2> /dev/null
if [ 0 -ne $? ]
then
	if [ -f /mnt/c/Windows/System32/cmd.exe ]
	then
		alias open='/mnt/c/Windows/System32/cmd.exe /c start'
	elif [ -f /c/windows/system32/cmd ]
	then
		alias open='/c/windows/system32/cmd //c start'
	else
		open ()
		{
			actual=$(readlinkf "$1")
			echo "$actual" | grep "^$WINHOME"
			if [ 0 -eq $? ]
			then
				echo "$actual" | sed 's|'"$WINHOME"'|"C:\\Users\\'"$USER"'|;s|/|\\|g;s/$/"/'|sed 's/^/start "" /' > "$WINHOME"/opencmd.bat
			else
				$(which open|head -1) "$actual"
			fi
		}
	fi
fi

topen ()
{
	actual=$(readlinkf "$1")
	echo "$actual" | grep "^$WINHOME"
	if [ 0 -eq $? ]
	then
		echo "$actual" | sed 's|'"$WINHOME"'|"C:\\Users\\'"$USER"'|;s|/|\\|g;s/$/"/'|sed 's/^/start "" /'
	else
		echo "$actual is not on $WINHOME"
	fi
}

gcb ()
	{
	input="$1"
	repo="$(echo "$input"|sed 's/=.*//')"
	branch="$(echo "$input"|sed 's/.*=//')"
	shortRepo="$(echo "$repo"|sed 's|.*/||;s/\.git$//')"
	git clone --single-branch --branch "$branch" "$repo" "$shortRepo-$branch.git"
}

# Do a git format-patch to a Patch Store to save changes outside of git in case of mistakes.
gifp () {
	DIR=~/Developer/Patch\ Store
	NAME=`date +"%Y-%m-%d_%H-%M-%S"`

	if [ "" != "$1" ]
	then
		git log -1 "$1" 2> /dev/null > /dev/null
		if [ 0 -eq $? ]
		then
			parent="$1"
		else
			echo "Unrecognized reference '$1'."
			return -1
		fi
	else
		girbr
		parent="$GIRBR"
	fi

	git format-patch -o "$DIR/$NAME" "$parent"
	pushd "$DIR"
		rm -f previous
		mv latest previous
		ln -s $NAME latest
	popd
}

# Push branch in parameter or pbasteboard and open PR.
gipopr () {
	branch="$1"

	if [ "" == "$branch" ]
	then
		branch=$(pbpaste)
	fi

	count=$(git branch --list "$branch"|wc -l)
	if [ "0" == "$count" ]
	then
		echo "Not a branch: '$branch'."
		return -1
	fi

	git push origin "$branch":"$branch"
	open https://$(git remote get-url origin|sed 's/^git@//;s|:|/|;s/\.git$//')/pull/new/"$branch"
}

dindent () {
	input=$(cat -)
	prefix=$(echo "$input"|grep -v "^$"|perl -pe 's/\S.*//'|sort|head -1)
	if [ "$(echo "$input"|grep -v "^$"|grep "^$prefix"|wc -l)" == "$(echo "$input"|grep -v "^$"|wc -l)" ]
	then
		echo "$input"|sed "s/^$prefix//"
	else
		echo "$input"
	fi
}

girmco () {
	for file in "$@"
	do
		if [ -f "$file" ]
		then
			rm "$file"
			git checkout "$file"
		else
			echo "Not a file: $file" >&2
		fi
	done

	echo
	git status
}

SSHCOLOR=0
env | grep -q SSH_CONNECTION && export SSHCOLOR=31

#PSDELIM_jp='あなたのお母さんはハムスターであり、あなたの父親は、エルダーベリーのワカサギ。'
#PSDELIM_gr='Η μητέρα σου ήταν ένα χάμστερ και ο πατέρας σου μύριζε κουφοξυλιάς!'
#PSDELIM_marathi='तुम्हारी माँ एक हम्सटर था और अपने पिता बड़े बेर के गलाना'
#PSDELIM_hindi='तुम्हारी माँ एक हम्सटर था और अपने पिता बड़े बेर के गलाना'
#PSDELIM_thai='แม่ของหนูแฮมสเตอร์ของคุณaและคุณพ่อของคุณหลอมเหลวของพี่เบอร์รี่'
PSDELIM_jp='人生はかなり速く動く。 いったん停止してしばらく回って見ないと、それを逃すことができます。'
PSDELIM_gr='Η ζωή κινείται αρκετά γρήγορα. Αν δεν σταματήσετε και κοιτάξετε γύρω από μια φορά, θα μπορούσατε να το χάσετε.'
PSDELIM_marathi='जीवन तेही जलद चालते. आपण थांबा आणि काहीवेळा एकदा दिसत नसल्यास, आपण ते चुकवू शकता.'
PSDELIM_hindi='जीवन बहुत तेजी से चलता है यदि आप कुछ समय में एक बार रुकते और न दिखते हैं, तो आप इसे याद कर सकते हैं।'
PSDELIM_thai='ชีวิตเคลื่อนไหวเร็วมาก ถ้าคุณไม่หยุดและมองไปรอบ ๆ ครู่หนึ่งคุณก็อาจพลาดได้'
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

# For non-root users, log commands.
# See: https://spin.atomicobject.com/2016/05/28/log-bash-history/
function log_bash_history
{
	if [ "$log_bash_history_non_first" == 1 ]
	then
		TS="$(date "+%Y-%m-%d.%H:%M:%S")"
		echo "$TS	$LOG_BASH_HISTORY_HOSTNAME:$LOG_BASH_HISTORY_PID:$(pwd)$(git branch 2> /dev/null|grep "^\*"|sed 's/^. */:/')	$(history 1)" >> ~/.logs/bash-history-${TS::10}.log
	else
		log_bash_history_non_first=1
	fi
}

# If this is an interactive shell of non-root user.
# Could use 'if [ "$(id -u)" -ne 0 ]' but this is fancier.
if [[ $- = *i* ]] && (( EUID != 0 ))
then
	[[ -d ~/.logs ]] || mkdir ~/.logs
	export LOG_BASH_HISTORY_HOSTNAME="$(hostname)"
	export LOG_BASH_HISTORY_PID=$$
	# This format is reported to preserve functionality of terminals being
	# opened in the correct directory.
	# But of course it results in accumulation of log_bash_history in Linux
	# Subsystem for Windows so filter those out.
	TEMP_PROMPT_COMMAND=$(echo "$PROMPT_COMMAND"|sed 's/log_bash_history; *//g;s/; *$//')
	export PROMPT_COMMAND="log_bash_history; $TEMP_PROMPT_COMMAND"
fi

[[ -d ~/.used ]] || mkdir ~/.used
function used
{
	TS="$(date "+%Y-%m-%d.%H:%M:%S")"
	prefix=$(echo "$1"|tr '[A-Z]' '[a-z]'|sed 's/\+\+/plusplus/;s/#/sharp/;s/[^a-z0-9]//')
	echo "$TS	$LOG_BASH_HISTORY_HOSTNAME:$LOG_BASH_HISTORY_PID:$(pwd)	$@" >> ~/.used/$prefix-${TS::10}.log
}

# Paste from Flycut. History index as parameter. Defaults to zero.
function fcpaste
{
	index="$1"
	if [ "" == "$index" ]
	then
		index=0
	fi
	/usr/libexec/PlistBuddy -c "Print store:jcList:$index:Contents" /Users/mjerde/Library/Preferences/-X95R6W2D.com.mark-a-jerde.Flycut-macOS.plist
}

# Basic prompt with Git branch name.
PS1='\h:\W$(__git_ps1 "(%s)") \u\$ '
# Basic prompt with Git branch name and colorful icons.
PS1='\h:\W$(git_prompt_info)\[\e[1;34m\]$(git_pending_rebase)\[\e[0m\]\[\e[1;33m\]$(git_pending_push)\[\e[0m\]\[\e[1;31m\]$(git_pending_commit)\[\e[0m\]\[\e[1;32m\]$(get_vpn_status)\[\e[0m\]\u\$ '
# Multi-line prompt with Git branch name and colorful icons.
PS1='$(editmode)\[\e[1;33m\]$(psdelim)\[\e[0m\]
\[\e[1;${SSHCOLOR}m\]\h\[\e[0m\]:\w$(git_full_status)\[\e[0m\]\[\e[1;32m\]$(get_vpn_status)\[\e[0m\]
\u\$                \[\e[1;94m\]\[\e[2m\]__________________________________________________\[\e[0m\]\[\e[65D\]'
PS1='$(editmode)\[\e[1;33m\]$(psdelim)\[\e[0m\]
\[\e[1;${SSHCOLOR}m\]\h\[\e[0m\]:\w$(git_full_status)\[\e[0m\]\[\e[1;32m\]$(get_vpn_status)\[\e[0m\]
\u\$ \[\e7\]               \[\e[1;94m\]\[\e[2m\]__________________________________________________
                                                                       _\[\e[0m\]\[\e8\]'
PS1='$(editmode)\[\e[1;33m\]$(psdelim)\[\e[0m\]
\[\e[1;${SSHCOLOR}m\]\h\[\e[0m\]:\w$(git_full_status)\[\e[0m\]\[\e[1;32m\]$(get_vpn_status)\[\e[0m\]
\u\$ \[\e7\]               \[\e[1;94m\]\[\e[2m\]__________________________________________________
                                                                         _\[\e[0m\]\[\e[2A\]
\u\$ '
PS1='$(editmode)\[\e[1;33m\]$(psdelim)\[\e[0m\]
\[\e[1;${SSHCOLOR}m\]\h\[\e[0m\]:\w$(git_full_status)\[\e[0m\]\[\e[1;32m\]$(get_vpn_status)\[\e[0m\]
\u\$ \[\e7\]               \[\e[1;94m\]\[\e[2m\]_________________________________________________|\[\e[1A\]
\[\e[73C\]\[\e[1;37m\]_\[\e[0m\]\[\e[1A\]
\u\$ '
# Git 50/72 rule
# or 94 (blue) -> 37 (gray)

# Disable a few things on slow systems
git_full_status_disabled
if [ $? -eq 0 ]
then
	export PS1="$(echo "$PS1"|sed 's/\$(editmode)//g;s/\$(git_full_status)//g;s/\$(get_vpn_status)//g')"
fi

test -s ~/.bashrc.work && . ~/.bashrc.work || true

