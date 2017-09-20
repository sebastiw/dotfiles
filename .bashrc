#
# ~/.bashrc
#

PATH="/opt/erlang/19.3.4/bin:${PATH}"
PATH="/opt/emacs/25.2/bin:${PATH}"
PATH="${HOME}/bin:${PATH}"
export PATH

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source ${HOME}/.aliases
PS1='[\u@\h \W]\$ '

