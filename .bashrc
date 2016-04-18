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

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# If this is an xterm set the title to user@host:dir
if [[ "$TERM" = xterm* || "$TERM" = rxvt* ]]; then
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
fi

# enable color support of ls and also add handy aliases
if [[ "$TERM" != dumb ]]; then
    # A color prompt
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

    if [[ $OSTYPE != darwin* ]]; then
        which dircolors >/dev/null && eval "$(dircolors -b)"
        ls_color_option="--color=auto"
    fi
    export GREP_OPTIONS='--color=auto'
fi
alias ls="ls -F $ls_color_option"

# enable programmable completion features (you don't need to enable this if
# it's already enabled in /etc/bash.bashrc and /etc/profile sources
# /etc/bash.bashrc).
[[ -f /etc/bash_completion ]] && source /etc/bash_completion

# Legacy
[[ -f ~/.bash_common ]] && mv ~/.bash_common ~/.sh_common
[[ -f ~/.bash_local ]] && mv ~/.bash_local ~/.sh_local

# Source stuff shared between bash and zsh
[[ -f ~/.sh_common ]] && source ~/.sh_common
[[ -f ~/.sh_local ]] && source ~/.sh_local

VISUAL=vim # Used by c-x c-e binding
