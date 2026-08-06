#!/bin/zsh

# Keep PATH ordered and free of duplicate entries as startup files add tools.
typeset -U path PATH

# History
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=10000000
SAVEHIST=10000000

setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt share_history

# Completion
autoload -Uz compinit
compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"

unsetopt menu_complete
unsetopt flowcontrol
setopt auto_menu
setopt complete_in_word
setopt always_to_end

WORDCHARS=''
zmodload -i zsh/complist
zstyle ':completion:*' matcher-list \
    'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' \
    'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*:cd:*' tag-order \
    local-directories directory-stack path-directories

# Shell behavior formerly supplied by Oh My Zsh.
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_minus
setopt multios

# Prompt
setopt prompt_subst

function git_prompt_info() {
    local ref git_status

    ref=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) || \
        ref=$(command git rev-parse --short HEAD 2>/dev/null) || return
    git_status=$(command git status --porcelain --ignore-submodules=dirty 2>/dev/null)

    # Git permits percent signs in branch names, but Zsh interprets them as
    # prompt escapes.
    ref=${ref//\%/%%}

    print -nr -- "%F{white} <%F{13}${ref}%F{white}>"
    [[ -z $git_status ]] || print -nr -- ' %F{yellow}✗'
}

PROMPT='%F{cyan}%m%f:%B%F{cyan}%~%f%b$(git_prompt_info)%f
$ '

# Colored directory listings on BSD/macOS and GNU systems.
export LSCOLORS='Gxfxcxdxbxegedabagacad'
if [[ $OSTYPE == darwin* ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi

# Key bindings
bindkey -e
bindkey '^R' history-incremental-search-backward
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;9C' forward-word
bindkey '^[[1;9D' backward-word

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

[[ -z ${terminfo[kcbt]} ]] || \
    bindkey "${terminfo[kcbt]}" reverse-menu-complete

# Source general-purpose and private configuration last so local definitions
# can override these defaults.
[[ -f ~/.sh_common ]] && source ~/.sh_common
[[ -f ~/.sh_local ]] && source ~/.sh_local
