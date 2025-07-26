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


# ┌───────────────────────────────┐
# │ ░░▒▒▓▓██  CONSTANTS  ██▓▓▒▒░░ │
# └───────────────────────────────┘

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


# ┌─────────────────────────┐
# │ ░░▒▒▓▓██  ZTC  ██▓▓▒▒░░ │
# └─────────────────────────┘

function ztc:build { # set view area + build components
    ztc[vh]=$LINES
    ztc[vw]=$COLUMNS

    local _components
    ztc:steal components _components

    for _name in $_components; do "ztc:order:$_name"; done

    ztc:cycle
}

function ztc:drive { # clock go vroom vroom
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
            _epsilon=$(( ( _duration - (ztc[:rate:refresh] - _epsilon) ) % ztc[:rate:refresh] ))

        fi
    done
}

function ztc:clean { # dissolve clock + restore terminal state
    integer _code=${1:-0}
    ztc:write $ZTC_CURSOR_SHOW $ZTC_EXIT
    exit $_code
}


# ┌───────────────────────────┐
# │ ░░▒▒▓▓██  PLONK  ██▓▓▒▒░░ │
# └───────────────────────────┘

function ztc:plonk { # set config settings + register commands and components
    ztc[:date:format]="%a %b %d %p"
    ztc[:rate:input]=50
    ztc[:rate:refresh]=1000
    ztc[:rate:status]=5000

    local _commands=(date)
    ztc:stash :commands _commands

    local _components=(face:default date commander)
    ztc:stash components _components
}


# ┌───────────────────────────────┐
# │ ░░▒▒▓▓██  CASSETTES  ██▓▓▒▒░░ │
# └───────────────────────────────┘

# ───── ztc ─────

function ztc:align { # check for resizes + rebuild
    LINES=
    COLUMNS=

    if (( LINES != ztc[vh] || COLUMNS != ztc[vw] )); then ztc:build; fi
}

function ztc:cycle { # update component data + repaint
    local _components=$@
    if (( $# == 0 )); then ztc:steal components _components; fi

    for _name in $_components; do "ztc:alter:$_name"; done

    ztc:paint $@
}


# ───── commander ─────

function ztc:commander:enter {
    ztc[commander:active]=1
    ztc[commander:prefix]=${1:-:}

    ztc:cycle commander
}

function ztc:commander:leave {
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


# ┌─────────────────────────────┐
# │ ░░▒▒▓▓██  ENGINES  ██▓▓▒▒░░ │
# └─────────────────────────────┘

# ┌───────────────┐
# │    painter    │
# └───────────────┘

function ztc:paint { # translate component data for rendering

    local _components
    ztc:steal components _components

    local _touch=(${@:-$_components})


    # ───── reset bounds ─────

    ztc[paint:my]=$ztc[vh] # min-y
    ztc[paint:mx]=$ztc[vw] # min-x
    ztc[paint:ym]=0        # y-max
    ztc[paint:xm]=0        # x-max

    ztc[paint:h]=0
    ztc[paint:w]=0


    # ───── get component properties + cache ─────

    for _name in $_components; do

        # ╶╶╶╶╶ steal component data ╴╴╴╴╴

        integer _y
        integer _x
        integer _h
        integer _w

        local _data=()
        ztc:steal ${_name}:data _data

        if (( _touch[(Ie)$_name] )); then # calculate component space

            # ╶╶╶╶╶ determine component space ╴╴╴╴╴

            case $ztc[${_name}:h] in
                (:auto) # set height to number of lines
                    _h=${#_data} ;;
                (*)
                    _h=$ztc[${_name}:h] ;;
            esac

            case $ztc[${_name}:w] in
                (:auto) # set width to length of longest line
                    local _length=0
                    for _line in $_data; do if (( ${#_line} > _length )); then _length=${#_line}; fi; done
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


            # ╶╶╶╶╶ save/cache calculations ╴╴╴╴╴

            ztc[paint:${_name}:h]=$_h
            ztc[paint:${_name}:w]=$_w
            ztc[paint:${_name}:y]=$_y
            ztc[paint:${_name}:x]=$_x

            ztc:stash paint:${_name}:data _data

        else # retrieve from cache

            _h=$ztc[paint:${_name}:h]
            _w=$ztc[paint:${_name}:w]
            _y=$ztc[paint:${_name}:y]
            _x=$ztc[paint:${_name}:x]

        fi


        # ╶╶╶╶╶ update bounds ╴╴╴╴╴

        if (( ! ztc[${_name}:overlay] )); then

            (( ztc[paint:h] += $_h )) # only for layout:vertical when position:auto

            if (( _y + _h > ztc[paint:ym] )); then ztc[paint:ym]=$((_y + _h)); fi
            if (( _x + _w > ztc[paint:xm] )); then ztc[paint:xm]=$((_x + _w)); fi
            if      (( _y < ztc[paint:my] )); then ztc[paint:my]=$_y; fi
            if      (( _x < ztc[paint:mx] )); then ztc[paint:mx]=$_x; fi
        fi
    done


    # ───── declare render zone + adjust component origins ─────

    # ztc[paint:h]=$(( ztc[paint:ym] - ztc[paint:my] ))
    ztc[paint:w]=$(( ztc[paint:xm] - ztc[paint:mx] ))
    ztc[paint:my]=$(( ( (ztc[vh] - ztc[paint:h]) / 2 ) + 1 )) # override h for position:auto

    integer _dy=0

    for _name in $_components; do
        if (( ! ztc[${_name}:overlay] )); then
            ztc[paint:${_name}:y]=$(( ztc[paint:my] + _dy ))
            (( _dy += ztc[paint:${_name}:h] ))
        fi
    done


    # ───── paint component data ─────

    local _staged=()

    for _name in $_components; do
        local _matter=$ztc[paint:${_name}:data]
        local _origin="${ZTC_CSI}${ztc[paint:${_name}:y]};${ztc[paint:${_name}:x]}H"

        case $ztc[${_name}:data:format] in
            (masked)
                clear="${ZTC_COLOR_RESET} "
                active="${ZTC_COLOR_REVERSE} "

                _matter=${_matter//1/$active}
                _matter=${_matter//0/$clear}

                _matter="$_matter$ZTC_COLOR_RESET"
                ;;
        esac

        _staged+=($_origin ${_matter//@/${ZTC_CSI}E${ZTC_CSI}$(( ztc[paint:${_name}:x] - 1 ))C})
    done


    # ───── render ─────

    ztc:write $ZTC_CLEAR ${(j::)_staged}
}


# ┌─────────────────┐
# │    commander    │
# └─────────────────┘

function ztc:input { # detect user inputs + build commands

    # ───── read input ─────

    local _key
    read -s -t $(( ztc[:rate:input] / 1000.0 )) -k 1 _key


    # ───── process input ─────

    if (( ztc[commander:active] )); then # attach input to command bar
        local _input=$ztc[commander:input]
        local _cursor=$ztc[commander:cursor]

        case $_key in

            # ╶╶╶╶╶ <esc> + arrow keys ╴╴╴╴╴

            ($'\e')
                local _special
                read -st -k 2 _special

                case $_special in
                    ('[C') # <right>
                        if (( _cursor > 0 )); then (( ztc[commander:cursor]-- )); fi
                        ;;
                    ('[D') # <left>
                        if (( _cursor - ${#_input} < 0 )); then (( ztc[commander:cursor]++ )); fi
                        ;;
                    ('') ztc:commander:leave ;;
                    (*) ;;
                esac
                ;;

            # ╶╶╶╶╶ <ctrl-u> (line clearing) ╴╴╴╴╴

            ($'\x15')
                ztc[commander:input]=''
                ztc[commander:cursor]=0
                ;;

            # ╶╶╶╶╶ <ctrl-b> (<left>) ╴╴╴╴╴

            ($'\x2')
                if (( _cursor - ${#_input} < 0 )); then (( ztc[commander:cursor]++ )); fi
                ;;

            # ╶╶╶╶╶ <ctrl-f> (<right>) ╴╴╴╴╴

            ($'\x6')
                if (( _cursor > 0 )); then (( ztc[commander:cursor]-- )); fi
                ;;

            # ╶╶╶╶╶ <backspace>/<delete>/<ctrl-h> ╴╴╴╴╴

            ($'\b'|$'\x7f'|$'\x8')
                local _index=$(( ${#_input} - _cursor ))
                if (( _index != 0 )); then ztc[commander:input]=${_input:0:$(( _index - 1 ))}${_input:_index}; fi
                ;;

            # ╶╶╶╶╶ <enter>/<return> ╴╴╴╴╴

            ($'\n'|$'\r')
                if (( ${#_input} > 0 )); then ztc:parse $_input; else ztc:commander:leave; fi
                ;;

            # ╶╶╶╶╶ ignore empty keys ╴╴╴╴╴

            ('') ;;

            # ╶╶╶╶╶ insert key at cursor index ╴╴╴╴╴

            (*)
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
    local _command=${(L)_input[1]//\\/\\\\}

    local _commands
    ztc:steal :commands _commands

    case $_command in
        (q|quit|exit)
            ztc:clean
            ;;
        (*)
            if (( _commands[(Ie)$_command] )); then
                ztc:parse:$_command ${_input:1}
                ztc:commander:leave
            else
                ztc:commander:leave "$ZTC_COLOR_REVERSE Unknown command: $_command $ZTC_COLOR_RESET"
            fi
            ;;
    esac
}

function ztc:parse:date {
    local _format=${(j: :)@}
    ztc[:date:format]=${_format:-"%a %b %d %p"}
    ztc:cycle date
}


# ┌────────────────────────────────┐
# │ ░░▒▒▓▓██  COMPONENTS  ██▓▓▒▒░░ │
# └────────────────────────────────┘

# ┌─────────────┐
# │    faces    │
# └─────────────┘

# ───── default digital ─────

function ztc:order:face:default {
    # space declaration
    ztc[face:default:y]=:auto
    ztc[face:default:x]=:auto
    ztc[face:default:h]=:auto
    ztc[face:default:w]=:auto
}

function ztc:alter:face:default {
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

    # interleave + flatten and insert padding
    ztc:weave _staged
    for _i in {1..${#_staged}}; do _staged[$_i]=${_staged[$_i]//@/0}; done

    # save
    ztc[face:default:data:format]=masked
    ztc:stash face:default:data _staged
}


# ┌────────────┐
# │    date    │
# └────────────┘

function ztc:order:date {
    # space declaration
    ztc[date:y]=:auto
    ztc[date:x]=:auto
    ztc[date:h]=:auto
    ztc[date:w]=:auto
}

function ztc:alter:date {
    local _date
    strftime -s _date $ztc[:date:format]

    ztc[date:data]=${_date//\\/\\\\}
}


# ┌─────────────────┐
# │    commander    │
# └─────────────────┘

function ztc:order:commander {
    # space declaration
    ztc[commander:y]=$ztc[vh]
    ztc[commander:x]=0
    ztc[commander:h]=1
    ztc[commander:w]=$ztc[vw]

    # extended component properties
    ztc[commander:overlay]=1
    ztc[commander:cursor]=${ztc[commander:cursor]:-0}

    # commander properties
    ztc[commander:input]=${ztc[commander:input]:-}

    ztc[commander:active]=${ztc[commander:active]:-0}
    ztc[commander:status]=${ztc[commander:status]:-}
    ztc[commander:prefix]=${ztc[commander:prefix]:-:}
}

function ztc:alter:commander {

    # ───── import ─────

    local _input=$ztc[commander:input]
    local _cursor=$ztc[commander:cursor]


    # ───── truncate overflows ─────

    local _index=$(( ${#_input} - _cursor ))
    local _bound=$(( ztc[commander:w] - ${#ztc[commander:prefix]} ))

    if (( ${#_input} > _bound )); then

        # ╶╶╶╶╶ split input at cursor ╴╴╴╴╴

        local _left=${_input:0:_index}
        local _right=${_input:_index}

        # ╶╶╶╶╶ determine truncate order + trim to fit ╴╴╴╴╴

        if (( ${#_left} > ${#_right} )); then
            if (( ${#_right} > _bound / 2 )); then _right=${_right:0:$(( (_bound / 2) - 3 ))}...; fi
            if (( ${#_left} + ${#_right} > _bound )); then _left=...${_left:$(( -_bound + ${#_right} + 3 ))}; fi
        else
            if (( ${#_left} > _bound / 2 )); then _left=...${_left:$(( -(_bound / 2) + 3 ))}; fi
            if (( ${#_right} + ${#_left} > _bound )); then _right=${_right:0:$(( _bound - ${#_left} - 3 ))}...; fi
        fi

        # ╶╶╶╶╶ reassemble + adjust cursor ╴╴╴╴╴

        _input="$_left$_right"
        _cursor=${#_right}
    fi


    # ───── position cursor ─────

    local _position

    if (( _cursor > 0 )); then _position="$ZTC_CSI${_cursor}D"; fi


    # ───── export ─────

    if (( ztc[commander:active] )); then ztc[commander:data]=${ztc[commander:prefix]}${_input//\\/\\\\}$_position$ZTC_CURSOR_SHOW
    else ztc[commander:data]=$ztc[commander:status]$ZTC_CURSOR_HIDE; fi
}


# ┌─────────────────────────────┐
# │ ░░▒▒▓▓██  HELPERS  ██▓▓▒▒░░ │
# └─────────────────────────────┘

function ztc:write { print -n ${(j::)@} } # splash paint

function ztc:stash { ztc[$1]=${(Pj:@:)2} }           # (foo bar baz) -> ztc[key]="foo@bar@baz"
function ztc:steal { : ${(AP)2::=${(s:@:)ztc[$1]}} } # ztc[key]="foo@bar@baz" -> (foo bar baz)

function ztc:weave { # ((1 1 1) (2 2 2) (3 3 3)) -> ((1 2 3) (1 2 3) (1 2 3))

    # ───── import ─────

    local _array=(${(AP)1})


    # ───── determine max sub-length ─────

    local _length=0

    for _item in $_array; do
        local _sub=(${(As:@:)_item})
        if (( $#_sub > _length )); then _length=${#_sub}; fi
    done


    # ───── weave ─────

    local _weaved=()

    for _i in {1..$_length}; do
        local _select=()

        for _item in $_array; do
            local _sub=(${(As:@:)_item})
            _select+=($_sub[$_i])
        done

        _weaved+=(${(j:@:)_select})
    done


    # ───── export ─────

    : ${(AP)1::=$_weaved}
}


# ┌──────────────────────────────┐
# │ ░░▒▒▓▓██  DIRECTOR  ██▓▓▒▒░░ │
# └──────────────────────────────┘

function zsh_that_clock {
    trap 'ztc:clean 1' INT

    zmodload zsh/datetime

    typeset -A ztc=()

    ztc:plonk              # set config + init
    ztc:write $ZTC_INIT    # allocate screen space
    ztc:build && ztc:drive # zsh the clock!
    ztc:clean              # cleanup
}

zsh_that_clock
