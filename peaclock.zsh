#!/bin/zsh

# todo
# save live settings to config file
# auto-size down to single date line

# constants
PC_CURSOR_HIDE="\x1b[?25l"
PC_CURSOR_SHOW="\x1b[?25h"

###### config

### general

# individual clock block size, overridden if auto_size is true
#g_block_x=2
#g_block_y=1

# spacing between clock blocks
#g_padding_x=0
#g_padding_y=0

# margin around terminal edges
#g_margin_x=0
#g_margin_y=0

# ratio between x and y to preserve when auto_size is true
#g_ratio_x=2
#g_ratio_y=1

# spacing between clock and dateline
#g_date_padding=1

# string used to fill clock blocks
#g_fill_active=""
#g_fill_inactive=""
#g_fill_colon=""

# locale, e.g. `en_US.utf8`
#g_locale=""

# timezone, e.g. `America/Denver`
#g_timezone=""

# formatting for date line, follows strftime expansions
g_date="%a %b %d - %r"

# can be `clock`, `timer`, or `stopwatch`
#g_mode="clock"

# can be `date`, `ascii`, `digital`, `binary`, or `icon`
g_view="date"

# set the value to adjust with the `hjkl;'` keys
# can be `block`, `padding`, `margin`, `ratio`, `active-fg`, `inactive-fg`, `colon-fg`,
# `active-bg`, `inactive-bg`, `colon-bg`, `background`, or `date`
#g_toggle="active-bg"

# stopwatch, can be `clear`, `stop`, `start`, or `##h:##m:##s`
#g_stopwatch="start"

# timer, can be `clear`, `stop`, `start`, or `##h:##m:##s`
#g_timer="10m:0s"

# command to execute when timer goes off
#g_timer_exec=""

# user input delay in milliseconds
g_rate_input=50

# refresh/redraw delay in milliseconds
g_rate_refresh=1000

# status delay in milliseconds
#g_rate_status=5000

### toggles (`set <value> <on|off>`)

# use 24-hour time
#t_hour_24=true

# display seconds
#t_seconds=false

# display date line
t_date=true

# maximize clock size, overrides `g_block`
#t_auto_size=true

# maximize clock size, preserving `ratio`, overrides `g_block` and `t_auto_size`
#t_auto_ratio=true

### styles (`style <value> <#000-#fff|#000000-#ffffff|0-255|color-name|reverse|clear>`)
### valid color names: <color> [bright], `black`, `red`, `green`, `yellow`, `blue`, `magenta`,
### `cyan`, `white`

# text color for active clock blocks, text set with `g_fill_active`
#s_active_fg="clear"

# text color for inactive clock blocks, text set with `g_fill_inactive`
#s_inactive_fg="clear"

# text color for colon clock blocks, text set with `g_fill_colon`
#s_colon_fg="clear"

# background color for active clock blocks
#s_active_bg="reverse"

# background color for inactive clock blocks
#s_inactive_bg="clear"

# background color for colon clock blocks
#s_colon_bg="clear"

# text color for the date line
#s_date="clear"

# background color
#s_background="clear"

# status text color
#s_text="clear"

# status prompt color
#s_prompt="clear"

# status success color
#s_success="green"

# status error color
#s_error="red"

###### functions

### clock core

function build_clock {
    clock[vh]=$LINES
    clock[vw]=$COLUMNS

    components=()

    if [[ $t_date || $g_view == "date" ]]; then build_date; fi

    zcurses refresh
}

function unbuild_clock {
    for name in $components; do
        zcurses delwin $name
    done

    zcurses clear stdscr redraw
}

function refresh_clock {
    for name in $components; do
        case $name in
            (date) refresh_date ;;
            (*)    return 1     ;;
        esac
    done

    zcurses refresh
}

### clock parts

function build_date {
    local date
    strftime -s date $g_date

    components+=(date)

    clock[date:h]=1
    clock[date:w]=${#date}
    clock[date:y]=$(( (clock[vh] - clock[date:h]) / 2 ))
    clock[date:x]=$(( (clock[vw] - clock[date:w]) / 2 ))

    zcurses addwin date $clock[date:h] $clock[date:w] $clock[date:y] $clock[date:x]
    zcurses timeout date $g_rate_input

    zcurses string date $date
    zcurses touch date
}

function refresh_date {
    local date
    strftime -s date $g_date

    zcurses clear date
    zcurses move date 0 0
    zcurses string date $date
    zcurses touch date
}

function resize_clock {
    LINES=
    COLUMNS=

    if (( $LINES != clock[vh] || $COLUMNS != clock[vw] )); then
        unbuild_clock
        build_clock
        return 0
    fi

    return 1
}

function run_clock {
    local epoch=$EPOCHREALTIME
    local epsilon=0

    while true; do
        zcurses input date keypress

        case $keypress in
            (q|Q) break ;;
            (*)   ;;
        esac

        resize_clock

        local duration=${$(( (EPOCHREALTIME - epoch) * 1000 ))%%.*}

        if (( duration >= (g_rate_refresh - epsilon) )); then
            refresh_clock
            epoch=$EPOCHREALTIME
            epsilon=$(( (duration - (g_rate_refresh - epsilon)) % g_rate_refresh ));
        fi
    done
}

function clock_the_thing {
    zmodload zsh/curses
    zmodload zsh/datetime

    typeset -A clock=()

    print -n $PC_CURSOR_HIDE
    zcurses init

    build_clock
    run_clock
    unbuild_clock

    zcurses end
    print -n $PC_CURSOR_SHOW

    zmodload -u zsh/curses
    zmodload -u zsh/datetime
}

clock_the_thing
