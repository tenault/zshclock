#!/usr/bin/env zsh

#                      dP                dP                   dP
#                      88                88                   88
#    d888888b .d8888b. 88d888b. .d8888b. 88 .d8888b. .d8888b. 88  .dP
#       .d8P' Y8ooooo. 88'  `88 88'  `"" 88 88'  `88 88'  `"" 88888"
#     .Y8P          88 88    88 88.  ... 88 88.  .88 88.  ... 88  `8b.
#    d888888P `88888P' dP    dP `88888P' dP `88888P' `88888P' dP   `YP
#
# ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
# O                                                                     O
# O             copyright (c) 2025 Malakai Smith (@tenault)             O
# O             originally forked from @octobanana/peaclock             O
# O                                                                     O
# ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
#
#   This Source Code Form is subject to the terms of the Mozilla Public
#   License, v. 2.0. If a copy of the MPL was not distributed with this
#   file, you can obtain one at https://mozilla.org/MPL/2.0


###### constants

ZTC_ESC="\x1b"
ZTC_CSI=${ZTC_ESC}[

ZTC_CLEAR=${ZTC_CSI}2J
ZTC_CLEAR_LINE=${ZTC_CSI}2K

ZTC_INIT=${ZTC_CSI}?1049h
ZTC_EXIT=${ZTC_CSI}?1049l

ZTC_CURSOR_HOME=${ZTC_CSI}H
ZTC_CURSOR_SHOW=${ZTC_CSI}?25h
ZTC_CURSOR_HIDE=${ZTC_CSI}?25l

ZTC_COLOR_RESET=${ZTC_CSI}0m
ZTC_COLOR_REVERSE=${ZTC_CSI}7m

###### ztc

function ztc:build { # set view area + build components
    ztc[vh]=$LINES
    ztc[vw]=$COLUMNS

    local _components
    ztc:unpack components _components

    for _name in $_components; do "ztc:add:$_name"; done

    ztc:paint
}

function ztc:drive { # run clock
    float _epoch=$EPOCHREALTIME
    integer _epsilon=0

    while true; do
        ztc:input # handle inputs
        ztc:align # check for resizes

        # clear stale statuses
        if [[ ztc[commander:status] != '' && ${$(( (EPOCHREALTIME - ztc[commander:epoch]) * 1000 ))%%.*} -gt ztc[:rate:status] ]]; then ztc:commander:clear; fi

        # repaint clock
        integer _duration=${$(( (EPOCHREALTIME - _epoch) * 1000 ))%%.*}
        if (( _duration >= ( ztc[:rate:refresh] - _epsilon ) )); then

            ztc:cycle # update component data + repaint

            _epoch=$EPOCHREALTIME
            _epsilon=$(( (_duration - (ztc[:rate:refresh] - _epsilon)) % ztc[:rate:refresh] ))

        fi
    done
}

function ztc:clean { # dissolve clock + restore terminal state
    integer _code=${1:-0}
    ztc:write $ZTC_CURSOR_SHOW $ZTC_EXIT
    exit $_code
}


###### plonk

function ztc:plonk { # set config settings + register commands and components
    ztc[:date]="%a %b %d %p"
    ztc[:rate:input]=50
    ztc[:rate:refresh]=1000
    ztc[:rate:status]=5000

    local _commands=(date)
    ztc:pack :commands _commands

    local _components=(face:default date commander)
    ztc:pack components _components
}


###### facades

function ztc:align { # check for resizes + rebuild
    LINES=
    COLUMNS=

    if (( LINES != ztc[vh] || COLUMNS != ztc[vw] )); then ztc:build; fi
}

function ztc:cycle { # update component data + repaint
    local _components=$@
    if (( $# == 0 )); then ztc:unpack components _components; fi

    for _name in $_components; do "ztc:set:$_name"; done

    ztc:paint $@
}

function ztc:commander:enter {
    ztc[commander:active]=1
    ztc:cycle commander
}

function ztc:commander:exit {
    ztc[commander:status]=$1
    ztc[commander:epoch]=$EPOCHREALTIME

    ztc[commander:active]=0
    ztc[commander:input]=''
    ztc[commander:cursor]=0
}

function ztc:commander:clear {
    ztc[commander:status]=''
    ztc:cycle commander
}


###### engines

### painter

function ztc:paint { # translate component data for rendering

    local _clear=$ZTC_CLEAR

    local _components=$@

    if (( $# == 0 )); then
        ztc:unpack components _components
    else
        _clear=$ZTC_CLEAR_LINE # find a way to make this clear window only, or skip
    fi


    # reset bounds

    ztc[paint:my]=$ztc[vh] # min-y
    ztc[paint:mx]=$ztc[vw] # min-x
    ztc[paint:ym]=0       # y-max
    ztc[paint:xm]=0       # x-max

    ztc[paint:h]=0
    ztc[paint:w]=0


    # get component properties

    for _name in $_components; do

        # unpack component data

        integer _y
        integer _x
        integer _h
        integer _w

        local _array=()
        ztc:unpack ${_name}:data _array


        # determine component areas

        case $ztc[${_name}:h] in
            (:auto) # set height to number of lines
                _h=${#_array} ;;
            (*)
                _h=$ztc[${_name}:h] ;;
        esac

        case $ztc[${_name}:w] in
            (:auto) # set width to length of longest line
                local _length=0
                for _item in $_array; do if (( ${#_item} > _length )); then _length=${#_item}; fi; done
                _w=$_length
                ;;
            (*)
                _w=$ztc[${_name}:w]
                ;;
        esac

        case $ztc[${_name}:y] in
            (:auto) # center component vertically
                _y=$(( ( (ztc[vh] - _h) / 2 ) + 1 )) ;;
            (*)
                _y=$ztc[${_name}:y] ;;
        esac

        case $ztc[${_name}:x] in
            (:auto) # center component horizontally
                _x=$(( ( (ztc[vw] - _w) / 2 ) + 1 )) ;;
            (*)
                _x=$ztc[${_name}:x] ;;
        esac


        # save calculation + update bounds

        ztc[paint:${_name}:h]=$_h
        ztc[paint:${_name}:w]=$_w
        ztc[paint:${_name}:y]=$_y
        ztc[paint:${_name}:x]=$_x

        if (( ! ztc[${_name}:overlay] )); then

            (( ztc[paint:h] += $_h )) # only for layout:vertical when position:auto

            if (( _y + _h > ztc[paint:ym] )); then ztc[paint:ym]=$((_y + _h)); fi
            if (( _x + _w > ztc[paint:xm] )); then ztc[paint:xm]=$((_x + _w)); fi
            if      (( _y < ztc[paint:my] )); then ztc[paint:my]=$_y; fi
            if      (( _x < ztc[paint:mx] )); then ztc[paint:mx]=$_x; fi
        fi
    done


    # declare render zone + adjust origins

    # ztc[paint:h]=$(( ztc[paint:ym] - ztc[paint:my] ))
    ztc[paint:w]=$(( ztc[paint:xm] - ztc[paint:mx] ))
    ztc[paint:my]=$(( ( ( ztc[vh] - ztc[paint:h] ) / 2 ) + 1 )) # override h for position:auto

    integer _dy=0

    for _name in $_components; do
        if (( ! ztc[${_name}:overlay] )); then
            ztc[paint:${_name}:y]=$(( ztc[paint:my] + _dy ))
            (( _dy += ztc[paint:${_name}:h] ))
        fi
    done


    # paint component data

    local _staged=()

    for _name in $_components; do
        local _data=$ztc[${_name}:data]

        local _origin=${ztc[${_name}:origin]:-${ZTC_CSI}${ztc[paint:${_name}:y]};${ztc[paint:${_name}:x]}H}

        case $ztc[${_name}:data:format] in
            (masked)
                clear="${ZTC_COLOR_RESET} "
                active="${ZTC_COLOR_REVERSE} "

                _data=${_data//1/$active}
                _data=${_data//0/$clear}

                _data="$_data$ZTC_COLOR_RESET"
                ;;
        esac

        # export
        _staged+=($_origin ${_data//@/${ZTC_CSI}E${ZTC_CSI}$(( ztc[paint:${_name}:x] - 1 ))C})
    done


    # render

    ztc:write $_clear ${(j::)_staged}
}


### commander

function ztc:input { # detect user inputs + build commands

    # get input

    local _key
    read -s -t $(( ztc[:rate:input] / 1000.0 )) -k 1 _key


    # process input

    if (( ztc[commander:active] )); then # attach input to command bar
        local _input=$ztc[commander:input]
        local _cursor=$ztc[commander:cursor]

        case $_key in
            ($'\e') # detect special keys or exit
                local _special
                read -st -k 2 _special

                case $_special in
                    ('[C') # <right>
                        if (( _cursor > 0 )); then (( ztc[commander:cursor]-- )); fi
                        ;;
                    ('[D') # <left>
                        if (( _cursor - ${#_input} < 0 )); then (( ztc[commander:cursor]++ )); fi
                        ;;
                    (*) ztc:commander:exit ;;
                esac
                ;;
            ($'\x15') # <ctrl-u> for line clearing
                ztc[commander:input]=''
                ztc[commander:cursor]=0
                ;;
            ($'\x2') # <ctrl-b> (<left>)
                if (( _cursor - ${#_input} < 0 )); then (( ztc[commander:cursor]++ )); fi
                ;;
            ($'\x6') # <ctrl-f> (<right>)
                if (( _cursor > 0 )); then (( ztc[commander:cursor]-- )); fi
                ;;
            ($'\b'|$'\x7f'|$'\x8') # <backspace>/<delete>/<ctrl-h>
                local _index=$(( ${#_input} - _cursor ))
                if (( ${#_input} > 0 )); then ztc[commander:input]=${_input:0:$(( _index - 1 ))}${_input:_index}; fi
                ;;
            ($'\n'|$'\r') # <enter>
                if (( ${#_input} > 0 )); then ztc:parse $_input; else ztc:commander:exit; fi
                ;;
            ('') # ignore empty keys
                ;;
            (*) # insert key at cursor index
                local _index=$(( ${#_input} - _cursor ))
                ztc[commander:input]=${_input:0:_index}$_key${_input:_index}
                ;;
        esac

        ztc:cycle commander
    else # input is a shortcut
        case $_key in
            ($'\e')         ztc:commander:clear ;;
            (q|Q)           ztc:clean ;;
            (:|$'\n'|$'\r') ztc:commander:enter ;;
        esac
    fi
}

function ztc:parse { # delegate command to correct parser
    local _input=(${(As: :)1})
    local _commands
    ztc:unpack :commands _commands

    case ${(L)_input[1]} in
        (q|quit|exit)
            ztc:clean
            ;;
        (*)
            if (( _commands[(Ie)${(L)_input[1]}] )); then
                ztc:parse:${(L)_input[1]} ${_input:1}
                ztc:commander:exit
            else
                ztc:commander:exit "${ZTC_COLOR_REVERSE} Unknown command: ${(L)_input[1]} $ZTC_COLOR_RESET"
            fi
            ;;
    esac
}

function ztc:parse:date {

    ztc:write $1; sleep 5; ztc:clean

}


###### components

function ztc:add:face:default {
    ztc[face:default:y]=:auto
    ztc[face:default:x]=:auto
    ztc[face:default:h]=:auto
    ztc[face:default:w]=:auto

    ztc:set:face:default
}

function ztc:set:face:default {
    local _time
    strftime -s _time "%l:%M:%S"

    local _mask=()
    local _staged=()

    # mask character
    for _character in ${(s::)_time}; do
        case $_character in
            (0) _mask=(111 101 101 101 111) ;;
            (1) _mask=(110 010 010 010 111) ;;
            (2) _mask=(111 001 111 100 111) ;;
            (3) _mask=(111 001 111 001 111) ;;
            (4) _mask=(101 101 111 001 001) ;;
            (5) _mask=(111 100 111 001 111) ;;
            (6) _mask=(111 100 111 101 111) ;;
            (7) _mask=(111 001 001 001 001) ;;
            (8) _mask=(111 101 111 101 111) ;;
            (9) _mask=(111 101 111 001 111) ;;
            (:) _mask=(  0   1   0   1   0) ;;
        esac

        _staged+=(${(j:@:)_mask})
    done

    # interleave+flatten and insert padding
    ztc:interleave _staged
    for _i in {1..${#_staged}}; do _staged[$_i]=${_staged[$_i]//@/0}; done

    # save
    ztc[face:default:data:format]=masked
    ztc:pack face:default:data _staged
}

function ztc:add:date {
    ztc[date:y]=:auto
    ztc[date:x]=:auto
    ztc[date:h]=:auto
    ztc[date:w]=:auto

    ztc:set:date
}

function ztc:set:date {
    local _date
    strftime -s _date $ztc[:date]

    ztc[date:data]=$_date
}

function ztc:add:commander {
    ztc[commander:y]=$ztc[vh]
    ztc[commander:x]=0
    ztc[commander:h]=1
    ztc[commander:w]=$ztc[vw]

    ztc[commander:overlay]=1

    ztc[commander:active]=${ztc[commander:active]:-0}
    ztc[commander:status]=${ztc[commander:status]:-}
    ztc[commander:input]=${ztc[commander:input]:-}

    ztc[commander:cursor]=${ztc[commander:cursor]:-0}

    ztc:set:commander
}

function ztc:set:commander {
    # import
    local _input=$ztc[commander:input]

    # truncate overflows
    if (( ${#_input} >= ztc[commander:w] )); then _input=...${_input:$(( -ztc[commander:w] + 4 ))}; fi

    # position cursor
    local _cursor
    if (( ztc[commander:cursor] > 0 )); then _cursor="$ZTC_CSI${ztc[commander:cursor]}D";fi

    # escape backslashes + export
    if (( ztc[commander:active] )); then ztc[commander:data]=:${_input//\\/\\\\}$_cursor$ZTC_CURSOR_SHOW
    else ztc[commander:data]=$ztc[commander:status]$ZTC_CURSOR_HIDE; fi
}


###### helpers

function ztc:write { print -n ${(j::)@} } # splash paint

function ztc:pack   { ztc[$1]=${(Pj:@:)2} }           # (foo bar baz) -> ztc[key]="foo@bar@baz"
function ztc:unpack { : ${(AP)2::=${(s:@:)ztc[$1]}} } # ztc[key]="foo@bar@baz" -> (foo bar baz)

function ztc:interleave { # ((1 1 1) (2 2 2) (3 3 3)) -> ((1 2 3) (1 2 3) (1 2 3))

    # import

    local _array=(${(AP)1})


    # determine max sub-length

    local _length=0

    for _item in $_array; do
        local _sub=(${(As:@:)_item})
        if (( $#_sub > _length )); then _length=${#_sub}; fi
    done


    # interleave

    local _interleaved=()

    for _i in {1..$_length}; do
        local _select=()

        for _item in $_array; do
            local _sub=(${(As:@:)_item})
            _select+=($_sub[$_i])
        done

        _interleaved+=(${(j:@:)_select})
    done


    # export

    : ${(AP)1::=$_interleaved}
}


###### director

function zsh_that_clock {
    trap 'ztc:clean 1' INT

    zmodload zsh/datetime

    typeset -A ztc=()

    ztc:plonk              # set config + init
    ztc:write $ZTC_INIT    # allocate space
    ztc:build && ztc:drive # zsh the clock!
    ztc:clean              # cleanup
}

zsh_that_clock
