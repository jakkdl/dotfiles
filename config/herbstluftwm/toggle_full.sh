alias hc=herbstclient
hc emit_hook togglehidepanel
if [[ $(herbstclient attr theme.border_width) -eq 3 ]]; then
  hc attr theme.border_width 0
  hc attr theme.inner_width 0
else
  hc attr theme.border_width 3
  hc attr theme.inner_width 1
fi

