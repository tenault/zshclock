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

function zc_build { # set view area + build components
    zc[vh]=$LINES
    zc[vw]=$COLUMNS

    local _components
    zc_unpack components _components

    for _name in $_components; do "zc_add_$_name"; done

    zc_paint
}

function zc_drive { # run clock
    float _epoch=$EPOCHREALTIME
    integer _epsilon=0

    while true; do
        zc_input # handle inputs
        zc_align # check for resizes

        # repaint clock
        integer _duration=${$(( (EPOCHREALTIME - _epoch) * 1000 ))%%.*}
        if (( _duration >= ( zc[:rate:refresh] - _epsilon ) )); then

            zc_cycle # update component data + repaint

            _epoch=$EPOCHREALTIME
            _epsilon=$(( (_duration - (zc[:rate:refresh] - _epsilon)) % zc[:rate:refresh] ))

        fi
    done
}

function zc_clean { # dissolve clock + restore terminal state
    integer _code=${1:-0}
    zc_write $ZC_CURSOR_SHOW $ZC_EXIT
    exit $_code
}


###### plonk

function zc_plonk { # set config settings + register components
    zc[:date]="%a %b %d %p"
    zc[:rate:input]=50
    zc[:rate:refresh]=1000

    local _components=(face:default date commander)
    zc_pack components _components
}


###### facades

function zc_align { # check for resizes + rebuild
    LINES=
    COLUMNS=

    if (( LINES != zc[vh] || COLUMNS != zc[vw] )); then zc_build; fi
}

function zc_cycle { # update component data + repaint
    local _components=$@
    if (( $# == 0 )); then zc_unpack components _components; fi

    for _name in $_components; do "zc_set_$_name"; done

    zc_paint $1
}


###### engines

function zc_paint { # translate component data for rendering

    local _clear=$ZC_CLEAR

    local _components=$@

    if (( $# == 0 )); then
        zc_unpack components _components
    else
        _clear=$ZC_CLEAR_LINE # find a way to make this clear window only, or skip
    fi


    # reset bounds

    zc[paint:my]=$zc[vh] # min-y
    zc[paint:mx]=$zc[vw] # min-x
    zc[paint:ym]=0       # y-max
    zc[paint:xm]=0       # x-max

    zc[paint:h]=0
    zc[paint:w]=0


    # get component properties

    for _name in $_components; do

        # unpack component data

        integer _y
        integer _x
        integer _h
        integer _w

        local _array=()
        zc_unpack ${_name}:data _array


        # determine component areas

        case $zc[${_name}:h] in
            (:auto) # set height to number of lines
                _h=${#_array} ;;
            (*)
                _h=$zc[${_name}:h] ;;
        esac

        case $zc[${_name}:w] in
            (:auto) # set width to length of longest line
                local _length=0
                for _item in $_array; do if (( ${#_item} > _length )); then _length=${#_item}; fi; done
                _w=$_length
                ;;
            (*)
                _w=$zc[${_name}:w]
                ;;
        esac

        case $zc[${_name}:y] in
            (:auto) # center component vertically
                _y=$(( ( (zc[vh] - _h) / 2 ) + 1 )) ;;
            (*)
                _y=$zc[${_name}:y] ;;
        esac

        case $zc[${_name}:x] in
            (:auto) # center component horizontally
                _x=$(( ( (zc[vw] - _w) / 2 ) + 1 )) ;;
            (*)
                _x=$zc[${_name}:x] ;;
        esac


        # save calculation + update bounds

        zc[paint:${_name}:h]=$_h
        zc[paint:${_name}:w]=$_w
        zc[paint:${_name}:y]=$_y
        zc[paint:${_name}:x]=$_x

        if (( ! zc[${_name}:overlay] )); then

            (( zc[paint:h] += $_h )) # only for layout:vertical when position:auto

            if (( _y + _h > zc[paint:ym] )); then zc[paint:ym]=$((_y + _h)); fi
            if (( _x + _w > zc[paint:xm] )); then zc[paint:xm]=$((_x + _w)); fi
            if      (( _y < zc[paint:my] )); then zc[paint:my]=$_y; fi
            if      (( _x < zc[paint:mx] )); then zc[paint:mx]=$_x; fi
        fi
    done


    # declare render zone + adjust origins

    # zc[paint:h]=$(( zc[paint:ym] - zc[paint:my] ))
    zc[paint:w]=$(( zc[paint:xm] - zc[paint:mx] ))
    zc[paint:my]=$(( ( ( zc[vh] - zc[paint:h] ) / 2 ) + 1 )) # override h for position:auto

    integer _dy=0

    for _name in $_components; do
        if (( ! zc[${_name}:overlay] )); then
            zc[paint:${_name}:y]=$(( zc[paint:my] + _dy ))
            (( _dy += zc[paint:${_name}:h] ))
        fi
    done


    # paint component data

    local _staged=()

    for _name in $_components; do
        local _data=$zc[${_name}:data]

        local _origin="${ZC_CSI}${zc[paint:${_name}:y]};${zc[paint:${_name}:x]}H"

        case $zc[${_name}:data:format] in
            (masked)
                clear="${ZC_CSI}0m "
                active="${ZC_CSI}7m "

                _data=${_data//1/$active}
                _data=${_data//0/$clear}

                _data="$_data${ZC_CSI}0m"
                ;;
        esac

        # export
        _staged+=($_origin ${_data//@/${ZC_CSI}E${ZC_CSI}$(( zc[paint:${_name}:x] - 1 ))C})
    done


    # render

    zc_write $_clear ${(j::)_staged}
}

function zc_input { # detect user inputs + build commands
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
        esac
    fi
}

function zc_parse {

}


###### components

function zc_add_face:default {
    zc[face:default:y]=:auto
    zc[face:default:x]=:auto
    zc[face:default:h]=:auto
    zc[face:default:w]=:auto

    zc_set_face:default
}

function zc_set_face:default {
    local _time
    strftime -s _time "%l:%M"

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
    zc_interleave _staged
    for _i in {1..${#_staged}}; do _staged[$_i]=${_staged[$_i]//@/0}; done

    # save
    zc[face:default:data:format]=masked
    zc_pack face:default:data _staged
}

function zc_add_date {
    zc[date:y]=:auto
    zc[date:x]=:auto
    zc[date:h]=:auto
    zc[date:w]=:auto

    zc_set_date
}

function zc_set_date {
    local _date
    strftime -s _date $zc[:date]

    zc[date:data]=$_date
}

function zc_add_commander {
    zc[commander:y]=$zc[vh]
    zc[commander:x]=0
    zc[commander:h]=1
    zc[commander:w]=$zc[vw]

    zc[commander:overlay]=1

    zc[commander]=${zc[commander]:-0}
    zc[:command]=${zc[:command]:-}

    zc_set_commander
}

function zc_set_commander {
    local _command=$zc[:command]

    # truncate overflows
    if (( ${#_command} >= zc[commander:w] )); then _command=...${_command:$(( -zc[commander:w] + 4 ))}; fi

    if (( zc[commander] )); then zc[commander:data]=:${_command//\\/\\\\}$ZC_CURSOR_SHOW; else zc[commander:data]=$ZC_CURSOR_HIDE; fi
}


###### helpers

function zc_write { print -n ${(j::)@} } # render clock paints

function zc_pack   { zc[$1]=${(Pj:@:)2} }           # (foo bar baz) -> zc[key]="foo@bar@baz"
function zc_unpack { : ${(AP)2::=${(s:@:)zc[$1]}} } # zc[key]="foo@bar@baz" -> (foo bar baz)

function zc_interleave { # ((1 1 1) (2 2 2) (3 3 3)) -> ((1 2 3) (1 2 3) (1 2 3))

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
