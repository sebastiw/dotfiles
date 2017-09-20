# Set up the prompt
autoload -Uz promptinit
promptinit
prompt adam1

#######
# Keybindings
###

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Bash-like navigation
autoload -Uz select-word-style
select-word-style bash
WORDCHARS=''

#######
# History
###

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Allow multiple terminal sessions to all append to one zsh command history
#setopt append_history

# save timestamp of command and duration
setopt extendedhistory

# Add comamnds as they are typed, don't wait until shell exit
setopt incappendhistory

# when trimming history, lose oldest duplicates first
setopt histexpiredupsfirst

# When searching history don't display results already cycled through twice
setopt histfindnodups

# Remove extra blanks from each command line being added to history
setopt histreduceblanks

# don't execute, just expand history
setopt histverify

# Ignore duplicates
setopt histignorealldups

# Share history between zsh processes
setopt sharehistory


#######
# Completion
###

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'

zstyle ':completion:*' menu select=1 _complete _ignored _approximate
#zstyle ':completion:*' menu select=2
#zstyle ':completion:*' menu select=long

eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Fallback to built in ls colors
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
#zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'

# Make the selection prompt friendly when there are a lot of choices
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' use-compctl false

# formatting and messages
zstyle ':completion:*' verbose yes
#zstyle ':completion:*' verbose true
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
#zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''

# Add simple colors to kill
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
#zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# list of completers to use
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate
#zstyle ':completion:*' completer _expand _complete _correct _approximate

# ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:scp:*' tag-order files users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:scp:*' group-order files all-files users hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:ssh:*' group-order hosts-domain hosts-host users hosts-ipaddr
zstyle '*' single-ignored show


#######
# zim
###

if [[ -s ${ZDOTDIR:-${HOME}/lib/zim}/init.zsh ]]; then
  source ${ZDOTDIR:-${HOME}/lib/zim}/init.zsh
fi


#######
# Exports
###

# Setup terminal, and turn on colors
export TERM=xterm-256color
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad

# Add Emacs
export PATH="/opt/emacs/25.2/bin:${PATH}"
# Add Erlang
export PATH="/opt/erlang/19.3.4/bin:${PATH}"
# Add Android
export PATH="/home/esebwed/lib/android-sdk/Sdk/platform-tools:${PATH}"

# Add user bin
export PATH="${HOME}/bin:${PATH}"

# Enable color in grep
#export GREP_OPTIONS='--color=auto'
#export GREP_COLOR='3;33'

# Less
export PAGER='less'
export LESS='--ignore-case --status-column --long-prompt --raw-control-chars'

# Set colors for less. Borrowed from https://wiki.archlinux.org/index.php/Color_output_in_console#less .
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# Emacs
export EDITOR='ec'

#######
# Ssh-agent
####

if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > ~/.ssh-agent-thing
fi
if [[ "$SSH_AGENT_PID" == "" ]]; then
    eval "$(<~/.ssh-agent-thing)"
fi


#######
# Git prompt (experimental)
# from https://gist.github.com/joshdick/4415470
###

setopt prompt_subst
autoload -U colors && colors # Enable colors in prompt

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_SYMBOL="%{$fg[blue]%}±"
GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg[magenta]%}⚡︎%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg[red]%}●%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg[yellow]%}●%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg[green]%}●%{$reset_color%}"

# Show Git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states
parse_git_state() {

  # Compose this value via multiple conditional appends.
  local GIT_STATE=""

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
  fi

  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
  fi

  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi

}

# If inside a Git repository, print its branch and state
git_prompt_string() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "$GIT_PROMPT_SYMBOL$(parse_git_state)$GIT_PROMPT_PREFIX%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX"
}

# Set the right-hand prompt
RPS1='$(git_prompt_string)'

# only show the rprompt on the current prompt
setopt transient_rprompt

# ng autocompletion
#ng completion 1


#######
# Alias
###
source $HOME/.aliases

#######
# Functions
###

# If different Erlang releases are installed, you can set the current
# release with this function.
function erlang() {
    ERLINSTPATH="/opt/erlang/"
    VERSION=${1:-"19.3.4"}

    # Use globbing when searching for version. I.e. "erlang 19" is
    # enough for selecting erlang 19.3.4 if it is the only available
    # version for 19.
    IFS=$'\n' dirs=($(find ${ERLINSTPATH} -maxdepth 1 -name "${VERSION}*" -type d -print))

    if test -n "${dirs}" && [[ "1" -eq ${#dirs} ]]
    then
        version=`basename ${dirs[1]}`
        echo "Setting Erlang ${version} as default"
        export PATH=${dirs[1]}/bin:$PATH
    else
        echo "Invalid version. Available versions:"
        ls $ERLINSTPATH
    fi
}

#######
# AWS, s3, kubernetes
###

# Completion
source /usr/bin/aws_zsh_completer.sh
source <(kubectl completion zsh)

