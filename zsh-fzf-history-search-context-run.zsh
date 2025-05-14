#!/usr/bin/env zsh

TEMP_HISTFILE="$1"
QUERY="$2"
SELECTED="$3"

HISTORY_CMD="fc -l -r 0"
FZF_ARGS="+m -x -e --sync --height $ZSH_FZF_HISTORY_SEARCH_CONTEXT_HEIGHT "
FZF_ARGS="$FZF_ARGS --style $ZSH_FZF_HISTORY_SEARCH_CONTEXT_STYLE --bind=ctrl-/:toggle-preview"
FZF_ARGS="$FZF_ARGS --bind change:top"
FZF_ARGS="$FZF_ARGS +s"  # do not sort

if [ -n "$ZSH_FZF_HISTORY_SEARCH_CONTEXT_HIDE" ]; then
  FZF_ARGS="$FZF_ARGS --preview-window=hidden"
fi

REMOVE_NUMBERING_CMD='sed -EH "s/^\s*\d+\*?\s*//"'
CUR_LINE_PREVIEW_CMD='fc -li {1} {1} | '"$REMOVE_NUMBERING_CMD"' | fold -$(($FZF_PREVIEW_COLUMNS - 2))'

PREVIEW_CMD='fc -R '"$TEMP_HISTFILE"';
fc -li $(($(echo {1} | sed "s/\*//") - ($FZF_PREVIEW_LINES / 2))) $(($(echo {1} | sed "s/\*//") - 1)) 2>/dev/null | '"$REMOVE_NUMBERING_CMD"' | cut -c1-$FZF_PREVIEW_COLUMNS;
'"$CUR_LINE_PREVIEW_CMD"' | sed "s/^/> /";
fc -li $(($(echo {1} | sed "s/\*//") + 1)) $(($(echo {1} | sed "s/\*//") + ($FZF_PREVIEW_LINES / 2) - $('"$CUR_LINE_PREVIEW_CMD"' | wc -l))) 2>/dev/null | '"$REMOVE_NUMBERING_CMD"' | cut -c1-$FZF_PREVIEW_COLUMNS;'

BIND="tab:become($0 $1 '' {1})"

fc -R $TEMP_HISTFILE

if [ -n "$QUERY" ]; then
  line=$(eval $HISTORY_CMD | fzf ${=FZF_ARGS} --bind "$BIND" --preview "$PREVIEW_CMD" -q "$QUERY")
elif [ -n "$SELECTED" ]; then
  line=$(eval $HISTORY_CMD | fzf ${=FZF_ARGS} --bind "$BIND" --preview "$PREVIEW_CMD" --bind "load:pos(-$SELECTED)+offset-middle")
else
  line=$(eval $HISTORY_CMD | fzf ${=FZF_ARGS} --bind "$BIND" --preview "$PREVIEW_CMD")
fi

echo "$line" | sed -EH 's/^\s*\d+\*?\s*//'
