# this file is executed by bash(1) for non-login shells.

[ -z "$PS1" ] && return

# Share history between sessions
shopt -s histappend

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Source stuff shared between bash and zsh
[[ -f ~/.sh_common ]] && source ~/.sh_common
[[ -f ~/.sh_local ]] && source ~/.sh_local

VISUAL=nvim # Used by c-x c-e binding
