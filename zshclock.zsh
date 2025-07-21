#!/bin/zsh

# todo
# save live settings to config file
# auto-size down to single date line
# add alarm mode
# tab cycles modes?
# tab in cmdr autocompletes command
# register custom components?

###### functions

### clock core

#function build_clock {
#    clock[vh]=$(( LINES - 1 ))
#    clock[vw]=$(( COLUMNS - 1 ))
#
#    components=()
#
#    if [[ $t_date || $g_view == "date" ]]; then build_date; fi
#    build_cmdr
#}

#function unbuild_clock {
#    for name in $components; do zcurses delwin $name; done
#
#    zcurses clear stdscr redraw
#    zcurses refresh
#}

#function refresh_clock {
#    for name in $components; do
#        case $name in
#            (date) refresh_date ;;
#            (*)    ;;
#        esac
#    done
#}

#function resize_clock {
#    LINES=
#    COLUMNS=
#
#    if (( (LINES - 1) != clock[vh] || (COLUMNS - 1) != clock[vw] )); then
#        unbuild_clock
#        build_clock
#    fi
#}

#function run_clock {
#    local epoch=$EPOCHREALTIME
#    local epsilon=0
#
#    while true; do
#        get_input
#        resize_clock
#
#        local duration=${$(( (EPOCHREALTIME - epoch) * 1000 ))%%.*}
#
#        if (( duration >= (g_rate_refresh - epsilon) )); then
#            refresh_clock
#            epoch=$EPOCHREALTIME
#            epsilon=$(( (duration - (g_rate_refresh - epsilon)) % g_rate_refresh ));
#        fi
#    done
#}

### clock interaction

#function enter_cmd_mode {
#    clock[mode:cmd]=1
#
#    print -n $PC_CURSOR_SHOW
#
#    refresh_cmdr
#}

#function exit_cmd_mode {
#    clock[mode:cmd]=0
#    clock[cmd]=""
#
#    print -n $PC_CURSOR_HIDE
#
#    zcurses clear cmdr
#    zcurses refresh cmdr
#}

#function get_input {
#    local keypress
#    local special
#
#    zcurses input cmdr keypress special
#
#    if [[ -n $special ]]; then
#        case $special in
#            (BACKSPACE) if (( $clock[mode:cmd] )); then clock[cmd]=${clock[cmd]%?}; refresh_cmdr; fi ;;
#            (*)         ;;
#        esac
#    elif (( ! $clock[mode:cmd] )); then
#        case $keypress in
#            (q|Q) break ;;
#            (:)   enter_cmd_mode ;;
#            (*)   ;;
#        esac
#    else
#        case $keypress in
#            ('')          ;;
#            ($'\e')       exit_cmd_mode ;;
#            ($'\n'|$'\r') exit_cmd_mode ;; # process $clock[cmd]
#            ($'\t')       clock[cmd]+="    "; refresh_cmdr    ;;
#            (*)           clock[cmd]+=$keypress; refresh_cmdr ;;
#        esac
#    fi
#}

### clock components

#function refresh_date {
#    local date
#    strftime -s date $g_date
#
#    zcurses clear date
#    zcurses move date 0 0
#    zcurses string date $date
#    zcurses refresh date
#}

#function build_cmdr {
#    components+=(cmdr)
#
#    clock[cmdr:h]=1
#    clock[cmdr:w]=$clock[vw]
#    clock[cmdr:y]=$clock[vh]
#    clock[cmdr:x]=0
#
#    zcurses addwin cmdr $clock[cmdr:h] $clock[cmdr:w] $clock[cmdr:y] $clock[cmdr:x]
#    zcurses timeout cmdr $g_rate_input
#
#    if (( clock[mode:cmd] )); then refresh_cmdr; fi
#}

#function refresh_cmdr {
#    local cmd=":$clock[cmd]"
#
#    if (( ${#clock[cmd]} >= clock[cmdr:w] )); then cmd=":...${clock[cmd]:$(( -clock[cmdr:w] + 4 ))}"; fi
#
#    zcurses clear cmdr
#    zcurses move cmdr 0 0
#    zcurses string cmdr $cmd
#    zcurses refresh cmdr
#}

### director

#function clock_the_thing {
#    trap 'break' INT
#
#    zmodload zsh/curses
#    zmodload zsh/datetime
#
#    typeset -A clock=()
#
#    clock[mode:cmd]=0
#    clock[cmd]=""
#
#    print -n $PC_CURSOR_HIDE
#    zcurses init
#
#    build_clock
#    run_clock
#    unbuild_clock
#
#    zcurses end
#    print -n $PC_CURSOR_SHOW
#
#    zmodload -u zsh/curses
#    zmodload -u zsh/datetime
#}

#clock_the_thing

###### EVERYTHING ABOVE THIS LINE SUBJECT TO DELETION ######


###### constants

ZC_ESC="\x1b"
ZC_CSI=${ZC_ESC}[

ZC_CLEAR=${ZC_CSI}2J
ZC_CLEAR_LINE=${ZC_CSI}2K

ZC_INIT=${ZC_CSI}?1049h
ZC_EXIT=${ZC_CSI}?1049l

ZC_HOME=${ZC_CSI}H
ZC_SHOW=${ZC_CSI}?25h
ZC_HIDE=${ZC_CSI}?25l


###### core

function zc_build {
    zc[vh]=$LINES
    zc[vw]=$COLUMNS

    local _components
    zc_unpack components _components

    for name in $_components; do
        case $name in
            (date) zc_add_date ;;
            (*)    ;;
        esac
    done
}

function zc_drive {
    local _epoch=$EPOCHREALTIME
    local _epsilon=0

    while true; do
        
    done
}


###### plonkers

function zc_plonk {
    zc[:date]="%a %b %d - %r"
    zc[:rate:input]=50
    zc[:rate:refresh]=1000

    local _components=(date)
    zc_pack components _components
}


###### engines

function zc_paint {
    local _h=$zc[$1:h]
    local _w=$zc[$1:w]
    local _y=$zc[$1:y]
    local _x=$zc[$1:x]

    local _origin="${ZC_CSI}${_y};${_x}H"

    zc_display $ZC_HOME $_origin $2
}


###### components

function zc_add_date {
    local _date
    strftime -s _date $zc[:date]

    zc[date:h]=1
    zc[date:w]=${#_date}
    zc[date:y]=$(( ((zc[vh] - zc[date:h]) / 2) + zc[vh] % 2 ))
    zc[date:x]=$(( ((zc[vw] - zc[date:w]) / 2) + zc[vw] % 2 ))

    zc_paint date $_date
}


###### helpers

function zc_display { print -n ${(j::)@} }

function zc_pack   { zc[$1]=${(Pj.:.)2} }
function zc_unpack { : ${(AP)2::=${(s.:.)zc[$1]}} }


###### director

function zsh_that_clock {
    zmodload zsh/datetime

    typeset -A zc=()

    # config
    zc_plonk

    # init
    zc_display $ZC_INIT $ZC_HIDE

    zc_build
    sleep 5
    #zc_drive

    # cleanup
    zc_display $ZC_SHOW $ZC_EXIT
}

zsh_that_clock
