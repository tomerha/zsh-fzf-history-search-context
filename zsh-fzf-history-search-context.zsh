THIS=$0

# do nothing if fzf is not installed
(( ! $+commands[fzf] )) && return

# Bind for fzf history search context
(( ! ${+ZSH_FZF_HISTORY_SEARCH_CONTEXT_BIND} )) &&
typeset -g ZSH_FZF_HISTORY_SEARCH_CONTEXT_BIND='^r'

fzf_history_search_context() {
  # save history to file
  TEMP_HISTFILE=$(mktemp)
  trap "{ rm -f $TEMP_HISTFILE ; }" EXIT
  fc -W $TEMP_HISTFILE

  # run fzf
  SCRIPT=${THIS:A:h}/zsh-fzf-history-search-context-run.zsh
  selected=$($SCRIPT $TEMP_HISTFILE "$BUFFER")

  # replace BUFFER with selected line content
  if [ -n "$selected" ]; then
    BUFFER="$selected"
    CURSOR=${#BUFFER}
  fi

  zle reset-prompt
  return $ret
}

autoload fzf_history_search_context
zle -N fzf_history_search_context

bindkey $ZSH_FZF_HISTORY_SEARCH_CONTEXT_BIND fzf_history_search_context
