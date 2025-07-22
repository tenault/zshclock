#!/usr/bin/env zsh

# todo
# save live settings to config file
# auto-size down to single date line
# add alarm mode
# tab cycles modes?
# tab in cmdr autocompletes command
# register custom components?
# support non-fullscreen mode
# zc_paint: auto-sizing from content, auto-position alignments, scrolling, wrapping, content alignments, and z-index
# error handling (use -q|--quiet for disabling error messages)
# background mode? pause repaints? (disables input and only updates every minute)
# custom expansions for bold, italic, underline, colors, etc

###### functions

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

###### EVERYTHING ABOVE THIS LINE SUBJECT TO DELETION ######


###### constants

ZC_ESC="\x1b"
ZC_CSI=${ZC_ESC}[

ZC_CLEAR=${ZC_CSI}2J
ZC_CLEAR_LINE=${ZC_CSI}2K

ZC_INIT=${ZC_CSI}?1049h
ZC_EXIT=${ZC_CSI}?1049l

ZC_CURSOR_HOME=${ZC_CSI}H
ZC_CURSOR_SHOW=${ZC_CSI}?25h
ZC_CURSOR_HIDE=${ZC_CSI}?25l


###### ztc

function zc_build {
    zc[vh]=$LINES
    zc[vw]=$COLUMNS

    local _components
    zc_unpack components _components

    for name in $_components; do "zc_add_$name"; done

    zc_paint
}

function zc_drive {
    local _epoch=$EPOCHREALTIME
    local _epsilon=0

    while true; do
        # handle inputs
        zc_input

        # check for resizes
        zc_align

        # repaint clock
        local _duration=${$(( (EPOCHREALTIME - _epoch) * 1000 ))%%.*}

        if (( _duration >= ( zc[:rate:refresh] - _epsilon ) )); then
            zc_cycle

            _epoch=$EPOCHREALTIME
            _epsilon=$(( (_duration - (zc[:rate:refresh] - _epsilon)) % zc[:rate:refresh] ))
        fi
    done
}

function zc_clean {
    local _code=${1:-0}
    zc_write $ZC_CURSOR_SHOW $ZC_EXIT
    exit $_code
}


###### facades

function zc_align {
    LINES=
    COLUMNS=

    if (( LINES != zc[vh] || COLUMNS != zc[vw] )); then zc_build; fi
}

function zc_cycle {
    local _components
    zc_unpack components _components

    for name in $_components; do "zc_set_$name"; done

    zc_paint
}


###### plonkers

function zc_plonk {
    zc[:date]="%a %b %d - %r"
    zc[:rate:input]=50
    zc[:rate:refresh]=2000

    local _components=(date)
    zc_pack components _components
}


###### engines

function zc_paint {
    local _h
    local _w
    local _y
    local _x

    local _data

    local _origin
    local _staged=()

    local _components
    zc_unpack components _components

    for name in $_components; do
        _h=$zc[$name:h]
        _w=$zc[$name:w]
        _y=$zc[$name:y]
        _x=$zc[$name:x]

        _origin="${ZC_CSI}${_y};${_x}H"
        _data=$zc[$name:data]

        _staged+=($_origin $_data)
    done

    zc_write $ZC_CLEAR ${(j::)_staged} $2
}

function zc_input {
    local _key
    read -rs -t $(( zc[:rate:input] / 1000.0 )) -k 1 _key

    case $_key in
        (q|Q) break ;;
        (*)   ;;
    esac
}

function zc_parse {

}


###### components

function zc_add_date {
    local _date
    strftime -s _date $zc[:date]

    zc[date:h]=1
    zc[date:w]=${#_date}
    zc[date:y]=$(( ((zc[vh] - zc[date:h]) / 2) + zc[vh] % 2 ))
    zc[date:x]=$(( ((zc[vw] - zc[date:w]) / 2) + zc[vw] % 2 ))

    zc[date:data]=$_date
}

function zc_set_date {
    local _date
    strftime -s _date $zc[:date]
    zc[date:data]=$_date
}


###### helpers

function zc_write { print -n ${(j::)@} }

function zc_pack   { zc[$1]=${(Pj.:.)2} }
function zc_unpack { : ${(AP)2::=${(s.:.)zc[$1]}} }


###### director

function zsh_that_clock {
    trap 'zc_clean 1' INT

    zmodload zsh/datetime

    typeset -A zc=()

    # config
    zc_plonk

    # init
    zc_write $ZC_INIT $ZC_CURSOR_HIDE

    # ztc
    zc_build && zc_drive

    # clean
    zc_clean
}

zsh_that_clock
