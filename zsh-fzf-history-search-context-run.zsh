#!/usr/bin/env zsh

TEMP_HISTFILE="$1"
QUERY="$2"
SELECTED="$3"

HISTORY_CMD="fc -l -r 0"
FZF_ARGS="+m -x -e --sync"
FZF_ARGS="$FZF_ARGS +s"  # do not sort

PREVIEW_CMD='(fc -li $(($(echo {1} | sed "s/\*//") - ($FZF_PREVIEW_LINES / 2))) $(($(echo {1} | sed "s/\*//") - 1)) 2>/dev/null | sed -EH "s/^\s*\d+\*?\s*/  /";
fc -li {1} {1} | sed -EH "s/^\s*\d+\*?\s*/> /";
fc -li $(($(echo {1} | sed "s/\*//") + 1)) $(($(echo {1} | sed "s/\*//") + ($FZF_PREVIEW_LINES / 2) - 1)) 2>/dev/null | sed -EH "s/^\s*\d+\*?\s*/  /") |
cut -c1-$FZF_PREVIEW_COLUMNS'
PREVIEW_CMD="fc -R $TEMP_HISTFILE; $PREVIEW_CMD"

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
