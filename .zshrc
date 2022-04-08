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

HISTSIZE=10000000
SAVEHIST=10000000

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

_bikeshed_completion() {
    local -a completions
    local -a completions_with_descriptions
    local -a response
    response=("${(@f)$( env COMP_WORDS="${words[*]}" \
                        COMP_CWORD=$((CURRENT-1)) \
                        _BIKESHED_COMPLETE="complete_zsh" \
                        bikeshed )}")

    for key descr in ${(kv)response}; do
      if [[ "$descr" == "_" ]]; then
          completions+=("$key")
      else
          completions_with_descriptions+=("$key":"$descr")
      fi
    done

    if [ -n "$completions_with_descriptions" ]; then
        _describe -V unsorted completions_with_descriptions -U -Q
    fi

    if [ -n "$completions" ]; then
        compadd -U -V unsorted -Q -a completions
    fi
    compstate[insert]="automenu"
}

compdef _bikeshed_completion bikeshed;

_vampire_completion() {
    local -a completions
    local -a completions_with_descriptions
    local -a response
    # use vampire -> ./vampire to test completions
    response=("${(@f)$( env COMP_WORDS="${words[*]}" \
                        COMP_CWORD=$((CURRENT-1)) \
                        _VAMPIRE_COMPLETE="complete_zsh" \
                        vampire)}")

    for key descr in ${(kv)response}; do
      if [[ "$descr" == "_" ]]; then
          completions+=("$key")
      else
          completions_with_descriptions+=("$key":"$descr")
      fi
    done

    if [ -n "$completions_with_descriptions" ]; then
        _describe -V unsorted completions_with_descriptions -U -Q
    fi

    if [ -n "$completions" ]; then
        compadd -U -V unsorted -Q -a completions
    fi
    compstate[insert]="automenu"
}

compdef _vampire_completion vampire;

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
