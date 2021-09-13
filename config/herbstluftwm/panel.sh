#!/usr/bin/env bash

hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}
monitor=${1:-0}
geometry=( $(herbstclient monitor_rect "$monitor") )
if [ -z "$geometry" ] ;then
    echo "Invalid monitor $monitor"
    exit 1
fi
# geometry has the format W H X Y
x=${geometry[0]}
y=${geometry[1]}
panel_width=${geometry[2]}
panel_height=16
font="-*-fixed-medium-*-*-*-12-*-*-*-*-*-*-*"
#font="-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso10646-1"
#font="-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-?"
#font="fixed"
bgcolor=$(hc get frame_border_normal_color)
selbg=$(hc get window_border_active_color)
selfg='#101010'

####
# Try to find textwidth binary.
# In e.g. Ubuntu, this is named dzen2-textwidth.
if which textwidth &> /dev/null ; then
    textwidth="textwidth";
elif which dzen2-textwidth &> /dev/null ; then
    textwidth="dzen2-textwidth";
else
    echo "This script requires the textwidth tool of the dzen2 project."
    exit 1
fi
####
# true if we are using the svn version of dzen2
# depending on version/distribution, this seems to have version strings like
# "dzen-" or "dzen-x.x.x-svn"
if dzen2 -v 2>&1 | head -n 1 | grep -q '^dzen-\([^,]*-svn\|\),'; then
    dzen2_svn="true"
else
    dzen2_svn=""
fi

if awk -Wv 2>/dev/null | head -1 | grep -q '^mawk'; then
    # mawk needs "-W interactive" to line-buffer stdout correctly
    # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=593504
    uniq_linebuffered() {
      awk -W interactive '$0 != l { print ; l=$0 ; fflush(); }' "$@"
    }
else
    # other awk versions (e.g. gawk) issue a warning with "-W interactive", so
    # we don't want to use it there.
    uniq_linebuffered() {
      awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
    }
fi

hc pad $monitor $panel_height

{
    ### Event generator ###
    # based on different input data (mpc, date, hlwm hooks, ...) this generates events, formed like this:
    #   <eventname>\t<data> [...]
    # e.g.
    #   date    ^fg(#efefef)18:33^fg(#909090), 2013-10-^fg(#efefef)29
    while true ; do
        /home/h/.config/herbstluftwm/ram.py
        sleep 10s || break
    done > >(uniq_linebuffered) &

    while true ; do
        /home/h/.config/herbstluftwm/mpc_state.py || sleep 30s
    done > >(uniq_linebuffered) &

    if [ -d /sys/class/power_supply/Bat0 ]; then
        while true ; do
            # battery status is checked once a minute, but an event is only
            # generated if the output changed compared to the previous run.
            /home/h/.config/herbstluftwm/bat.py
            sleep 1m || break
        done > >(uniq_linebuffered) &
    fi

    tail -f /home/h/.config/herbstluftwm/mpc_volume_monitor 2>/dev/null | while true ; do
        if read line; then
            echo -e "mpc_volume\tMPC $line "
        fi
    done  > >(uniq_linebuffered) &

    tail -f /home/h/.config/herbstluftwm/volume_monitor 2>/dev/null | while true ; do
        if read line; then
            volvol="^fg(#00ff00)VOL "$(pactl get-sink-volume @DEFAULT_SINK@ | xargs | cut -d ' ' -f 5)
            echo -e "volume\t$volvol"
        fi
    done  > >(uniq_linebuffered) &


    mpc idleloop player > >(uniq_linebuffered) &
    while true ; do
        # "date" output is checked once a minute, but an event is only
        # generated if the output changed compared to the previous run.
        date +$'date\t^fg(#909090)%Y-%m-^fg(#efefef)%d'
        sleep 1m || break
    done > >(uniq_linebuffered) &
    childpid=$!
    hc --idle
    kill $childpid
} 2> /dev/null | {
    IFS=$'\t' read -ra tags <<< "$(hc tag_status $monitor)"
    tag_count=$(echo $(hc tag_status $monitor) | wc -w)
    visible=true
    date=""
    windowtitle=""
    while true ; do

        ### Output ###
        # This part prints dzen data based on the _previous_ data handling run,
        # and then waits for the next event to happen.

        bordercolor="#26221C"
        separator="^bg()^fg($selbg)|"
        # draw tags
        #for i in "${tags[@]}" ; do
        for i in `seq 0 $(($tag_count-1))`; do
            #case ${i:0:1} in
            case ${tags[$i]:0:1} in
                '#'|'+')
                    echo -n "^bg($selbg)^fg($selfg)"
                    ;;
                '-'|'%')
                    echo -n "^bg(#D00000)^fg(#141414)"
                    ;;
                ':')
                    echo -n "^bg()^fg(#ffffff)"
                    ;;
                '!')
                    echo -n "^bg(#FF0675)^fg(#141414)"
                    ;;
                *)
                    echo -n "^bg()^fg(#ababab)"
                    ;;
            esac
#           if false; then # [ ! -z "$dzen2_svn" ] ; then
#               # clickable tags if using SVN dzen
#               echo -n "^ca(1,\"${herbstclient_command[@]:-herbstclient}\" "
#               echo -n "focus_monitor \"$monitor\" && "
#               echo -n "\"${herbstclient_command[@]:-herbstclient}\" "
#               echo -n "use \"${i:1}\") ${i:1} ^ca()"
#           else
            # non-clickable tags if using older dzen
            if (($i+1 == ${tags[$i]:1})) || (($i+1-10 == ${tags[$i]:1})); then
                echo -n " ${tags[$i]:1} "
            else
                echo -n " $((i+1)):${tags[$i]:1} "
                #echo -n " ${i:1} "
            fi
        done
        echo -n "$separator"
        #echo -n "^bg()^fg() ${windowtitle//^/^^}"
        current_monitor=$(herbstclient list_monitors | grep FOCUS | cut -c 1)
        if [ $current_monitor -eq $monitor ]; then
          #echo -n "^bg(#9fbc00)^fg(#000000) ${windowtitle//^/^^}"
          printf " %-80s" "^bg(#9fbc00)^fg(#000000) ${windowtitle//^/^^}^bg()"
        fi

        # small adjustments
        #right="$separator^bg() $date $separator"
        right="$volume $mpc_volume$mpc_state$separator $ram $separator $bat^bg() $date $separator"
        right_text_only=$(echo -n "$right" | sed 's.\^[^(]*([^)]*)..g')
        # get width of right aligned text.. and add some space..
        width=$($textwidth "$font" "$right_text_only    ")

        if [[ "$right" == *">"* ]]; then
            let width+=$($textwidth "$font" ">")
            let width+=2
            #width=$(($width + 20))
        fi
        echo -n "^pa($(($panel_width - $width)))$right"
        echo

        ### Data handling ###
        # This part handles the events generated in the event loop, and sets
        # internal variables based on them. The event and its arguments are
        # read into the array cmd, then action is taken depending on the event
        # name.
        # "Special" events (quit_panel/togglehidepanel/reload) are also handled
        # here.

        # wait for next event
        IFS=$'\t' read -ra cmd || break
        # find out event origin
        case "${cmd[0]}" in
            tag*)
                #echo "resetting tags" >&2
                IFS=$'\t' read -ra tags <<< "$(hc tag_status $monitor)"
                ;;
            date)
                #echo "resetting date" >&2
                date="${cmd[@]:1}"
                ;;
            quit_panel)
                pkill -f "bash /home/h/.config/herbstluftwm/panel.sh 0"
                exit
                ;;
            togglehidepanel)
                currentmonidx=$(hc list_monitors | sed -n '/\[FOCUS\]$/s/:.*//p')
                if [ "${cmd[1]}" -ne "$monitor" ] ; then
                    continue
                fi
                if [ "${cmd[1]}" = "current" ] && [ "$currentmonidx" -ne "$monitor" ] ; then
                    continue
                fi
                echo "^togglehide()"
                if $visible ; then
                    visible=false
                    hc pad $monitor 0
                else
                    visible=true
                    hc pad $monitor $panel_height
                fi
                ;;
            reload)
                pkill -f "bash /home/h/.config/herbstluftwm/panel.sh"
                exit
                ;;
            focus_changed|window_title_changed)
                windowtitle="${cmd[@]:2}"
                ;;
            battery)
                bat="${cmd[@]:1}"
                ;;
            ram)
                ram="${cmd[@]:1}"
                ;;
            volume)
                volume="${cmd[@]:1}"
                ;;
            mpc_volume)
                mpc_volume="${cmd[@]:1}"
                ;;
            mpc_state)
                mpc_state="${cmd[@]:1}"
        esac
    done

    ### dzen2 ###
    # After the data is gathered and processed, the output of the previous block
    # gets piped to dzen2.
    #-e 'button3=;button4=exec:herbstclient use_index -1;button5=exec:herbstclient use_index +1' \

} | dzen2 -w $panel_width -x $x -y $y -fn "$font" -h $panel_height \
    -e 'button3=;button4=;button5=' \
    -ta l -bg "$bgcolor" -fg '#efefef'
