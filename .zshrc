#!/bin/zsh

# Configure oh-my-zsh
ZSH=$HOME/.oh-my-zsh
if [[ -n $ZSH ]]; then
    # Case-sensitive completion
    #CASE_SENSITIVE="true"
    COMPLETION_WAITING_DOTS="true"
    #DISABLE_AUTO_TITLE="true"
    #DISABLE_LS_COLORS="true"
    # Disable bi-weekly auto-update checks
    DISABLE_AUTO_UPDATE="true"
    #export UPDATE_ZSH_DAYS=13
    plugins=(git)
    source $ZSH/oh-my-zsh.sh
    # Don't auto-correct commands
    unsetopt correct_all
fi

PROMPT="\
%{$fg[cyan]%}%m%{$reset_color%}:\
%{$fg_bold[cyan]%}%~\
\$(git_prompt_info)%{$reset_color%}
\$ "

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[white]%} <%{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[white]%}"
# Do nothing if the branch is clean (no changes).
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[white]%}>"
# Add a yellow ✗ if the branch is dirty
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[white]%}> %{$fg[yellow]%}✗"

# Bind <c-x><c-e> to "edit command line"
autoload edit-command-line

# OS X bindings
bindkey '^[[1;9C' forward-word  # Meta-left
bindkey '^[[1;9D' backward-word  # Meta-right

# Legacy
[[ -f ~/.bash_common ]] && mv ~/.bash_common ~/.sh_common
[[ -f ~/.bash_local ]] && mv ~/.bash_local ~/.sh_local

# Source stuff shared between bash and zsh
[[ -f ~/.sh_common ]] && source ~/.sh_common
[[ -f ~/.sh_local ]] && source ~/.sh_local
