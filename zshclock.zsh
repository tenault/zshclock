#!/usr/bin/env zsh

#                    dP                dP                   dP
#                    88                88                   88
#  d888888b .d8888b. 88d888b. .d8888b. 88 .d8888b. .d8888b. 88  .dP
#     .d8P' Y8ooooo. 88'  `88 88'  `"" 88 88'  `88 88'  `"" 88888"
#   .Y8P          88 88    88 88.  ... 88 88.  .88 88.  ... 88  `8b.
#  d888888P `88888P' dP    dP `88888P' dP `88888P' `88888P' dP   `YP
# ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
#
# copyright (c) 2025 Malakai Smith (@tenault)
# originally forked from @octobanana/peaclock
#
# ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, you can obtain one at https://mozilla.org/MPL/2.0


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
    float _epoch=$EPOCHREALTIME
    integer _epsilon=0

    while true; do
        # handle inputs
        zc_input

        # check for resizes
        zc_align

        # repaint clock
        integer _duration=${$(( (EPOCHREALTIME - _epoch) * 1000 ))%%.*}

        if (( _duration >= ( zc[:rate:refresh] - _epsilon ) )); then
            zc_cycle

            _epoch=$EPOCHREALTIME
            _epsilon=$(( (_duration - (zc[:rate:refresh] - _epsilon)) % zc[:rate:refresh] ))
        fi
    done
}

function zc_clean {
    integer _code=${1:-0}
    zc_write $ZC_CURSOR_SHOW $ZC_EXIT
    exit $_code
}


###### plonk

function zc_plonk {
    zc[:date]="%a %b %d - %r"
    zc[:rate:input]=50
    zc[:rate:refresh]=1000

    local _components=(date commander)
    zc_pack components _components
}


###### facades

function zc_align {
    LINES=
    COLUMNS=

    if (( LINES != zc[vh] || COLUMNS != zc[vw] )); then zc_build; fi
}

function zc_cycle {
    local _components=$@
    if (( $# == 0 )); then zc_unpack components _components; fi

    for name in $_components; do "zc_set_$name"; done

    zc_paint $1
}


###### engines

function zc_paint {
    integer _y
    integer _x
    integer _h
    integer _w

    local _data

    local _staged=()
    local _clear=$ZC_CLEAR
    local _origin

    local _components=$@

    if (( $# == 0 )); then
        zc_unpack components _components
    else
        _clear=$ZC_CLEAR_LINE
    fi

    for name in $_components; do
        _h=$zc[$name:h]

        case $zc[$name:w] in
            (:auto) _w=${#zc[$name:data]} ;;
            (*)     _w=$zc[$name:w]       ;;
        esac

        case $zc[$name:y] in
            (:auto) _y=$(( ( (zc[vh] - _h) / 2 ) + zc[vh] % 2 )) ;;
            (*)     _y=$zc[$name:y] ;;
        esac

        case $zc[$name:x] in
            (:auto) _x=$(( ( (zc[vw] - _w) / 2 ) + zc[vw] % 2 )) ;;
            (*)     _x=$zc[$name:x] ;;
        esac

        _origin="${ZC_CSI}${_y};${_x}H"
        _data=$zc[$name:data]

        _staged+=($_origin $_data)
    done


    zc_write $_clear ${(j::)_staged}
}

function zc_input {
    local _key
    read -s -t $(( zc[:rate:input] / 1000.0 )) -k 1 _key

    if (( zc[commander] )); then
        case $_key in
            ($'\e')
                zc[:command]=""
                zc[commander]=0
                ;;
            ($'\b'|$'\x7f')
                zc[:command]=${zc[:command]%?}
                ;;
            ($'\n'|$'\r')
                # parse command
                zc[:command]=""
                zc[commander]=0
                ;;
            (*)
                zc[:command]+=$_key
                ;;
        esac

        zc_cycle commander
    else
        case $_key in
            (q|Q) break ;;
            (:)   zc[commander]=1; zc_cycle commander ;;
            (*)   ;;
        esac
    fi
}

function zc_parse {

}


###### components

function zc_add_date {
    zc[date:y]=:auto
    zc[date:x]=:auto
    zc[date:h]=1
    zc[date:w]=:auto

    zc_set_date
}

function zc_set_date {
    local _date
    strftime -s _date $zc[:date]

    zc[date:data]=$_date
}

function zc_add_commander {
    zc[:command]=${zc[:command]:-}

    zc[commander:y]=$zc[vh]
    zc[commander:x]=0
    zc[commander:h]=1
    zc[commander:w]=$zc[vw]

    zc[commander]=${zc[commander]:-0}

    zc_set_commander
}

function zc_set_commander {
    local _command=$zc[:command]

    # truncate overflows
    if (( ${#_command} >= zc[commander:w] )); then _command=...${_command:$(( -zc[commander:w] + 4 ))}; fi

    if (( zc[commander] )); then zc[commander:data]=:${_command//\\/\\\\}$ZC_CURSOR_SHOW; else zc[commander:data]=$ZC_CURSOR_HIDE; fi
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
    zc_write $ZC_INIT

    # ztc
    zc_build && zc_drive

    # clean
    zc_clean
}

zsh_that_clock
