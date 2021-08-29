#!/bin/bash
IFS=$'\t' read -ra tags <<< "$(herbstclient tag_status $monitor)"
tag_count=$(echo $(herbstclient tag_status $monitor) | wc -w)

for i in `seq 0 $(($tag_count-1))`; do
  if [ ${tags[$i]:0:1} == '#' ]; then
    tag=${tags[$i]:1}
  fi
done



herbstclient rename $tag $(echo -e "skype\nff\nobs" | dmenu)
