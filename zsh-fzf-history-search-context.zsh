THIS=$0

# do nothing if fzf is not installed
(( ! $+commands[fzf] )) && return

# Bind for fzf history search context
(( ! ${+ZSH_FZF_HISTORY_SEARCH_CONTEXT_BIND} )) &&
typeset -g ZSH_FZF_HISTORY_SEARCH_CONTEXT_BIND='^r'

# Allow specifying the height instead of using the whole screen (0 is unlimited)
(( ! ${+ZSH_FZF_HISTORY_SEARCH_CONTEXT_HEIGHT} )) &&
typeset -g ZSH_FZF_HISTORY_SEARCH_CONTEXT_HEIGHT='0'

# Allow specifying the fzf style
(( ! ${+ZSH_FZF_HISTORY_SEARCH_CONTEXT_STYLE} )) &&
typeset -g ZSH_FZF_HISTORY_SEARCH_CONTEXT_STYLE='minimal'

# Allow hiding the preview pane by default
(( ! ${+ZSH_FZF_HISTORY_SEARCH_CONTEXT_HIDE} )) &&
typeset -g ZSH_FZF_HISTORY_SEARCH_CONTEXT_HIDE=''

# Add blank lines around the selected line in the preview pane
(( ! ${+ZSH_FZF_HISTORY_SEARCH_CONTEXT_EMPHASIZE} )) &&
typeset -g ZSH_FZF_HISTORY_SEARCH_CONTEXT_EMPHASIZE='0'

fzf_history_search_context() {
  # save history to file
  TEMP_HISTFILE=$(mktemp)
  trap "{ rm -f $TEMP_HISTFILE ; }" EXIT
  fc -W $TEMP_HISTFILE

  # export env that the script will need
  export ZSH_FZF_HISTORY_SEARCH_CONTEXT_HEIGHT
  export ZSH_FZF_HISTORY_SEARCH_CONTEXT_STYLE
  export ZSH_FZF_HISTORY_SEARCH_CONTEXT_HIDE
  export ZSH_FZF_HISTORY_SEARCH_CONTEXT_EMPHASIZE

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
