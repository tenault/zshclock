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

# ───── general ─────

ZTC_ESC="\x1b"
ZTC_CSI=${ZTC_ESC}[

ZTC_INIT=${ZTC_CSI}?1049h
ZTC_EXIT=${ZTC_CSI}?1049l

ZTC_CLEAR=${ZTC_CSI}2J
ZTC_CLEAR_LINE=${ZTC_CSI}2K


# ───── cursor ─────

ZTC_CURSOR_HOME=${ZTC_CSI}H
ZTC_CURSOR_SHOW=${ZTC_CSI}?25h
ZTC_CURSOR_HIDE=${ZTC_CSI}?25l


# ───── text ─────

ZTC_TEXT_RESET=${ZTC_CSI}0m
ZTC_TEXT_BOLD=${ZTC_CSI}1m
ZTC_TEXT_INVERT=${ZTC_CSI}7m


# ┌─────────────────────────┐
# │ ░░▒▒▓▓██  ZTC  ██▓▓▒▒░░ │
# └─────────────────────────┘

function ztc:build { # set view area + build components
    ztc[vh]=$LINES
    ztc[vw]=$COLUMNS

    local _components=()
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

    stty dsusp '^Y' # restore delayed suspend

    exit $_code
}


# ┌───────────────────────────┐
# │ ░░▒▒▓▓██  PLONK  ██▓▓▒▒░░ │
# └───────────────────────────┘

function ztc:plonk { # set config settings + register parts

    # ───── set defaults ─────

    ztc[:date:format]="%a %b %d %p"
    ztc[:rate:input]=50
    ztc[:rate:refresh]=1000
    ztc[:rate:status]=5000


    # ───── register flares ─────

    local -U _flares=(newline reset bold invert)
    local -A _guide=()

    # ╶╶╶╶╶ generate short flares ╴╴╴╴╴

    local -A _route=()

    for _i in {1..${#_flares}}; do
        local _length=${#_flares[$_i]}
        _route[$_length]="$_route[$_length]@$_flares[$_i]"

        for _j in {1..$_length}; do
            local _abbr=${_flares[$_i]:0:$_j}

            if (( ! _flares[(Ie)$_abbr] )); then
                _flares+=($_abbr)
                _guide[$_abbr]=$_flares[$_i]
                _route[$_j]="$_route[$_j]@$_abbr"
                break
            fi
        done
    done

    # ╶╶╶╶╶ flatten guide ╴╴╴╴╴

    local -U _flat=()
    for _key _value in ${(kv)_guide}; do _flat+=("$_key#$_value"); done

    ztc:stash flares:guide _flat

    # ╶╶╶╶╶ rebuild flare array + sort descending ╴╴╴╴╴

    _flares=()
    for _key in ${(Ok)_route}; do _flares+=(${(As:@:)_route[$_key]}); done

    ztc:stash flares _flares


    # ───── register commands ─────

    local -U _commands=(date)
    ztc:stash :commands _commands


    # ───── register components ─────

    local -U _components=(face:digital date commander)
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
    local -U _components=$@
    if (( $# == 0 )); then ztc:steal components _components; fi

    for _name in $_components; do ztc:alter:$_name; done

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

    local -U _components=()
    ztc:steal components _components

    local -U _touch=(${@:-$_components})


    # ───── reset bounds ─────

    ztc[paint:my]=$ztc[vh] # min-y
    ztc[paint:mx]=$ztc[vw] # min-x
    ztc[paint:ym]=0        # y-max
    ztc[paint:xm]=0        # x-max

    ztc[paint:h]=0
    ztc[paint:w]=0


    # ───── get component properties + cache ─────

    for _name in $_components; do

        integer _y=0
        integer _x=0
        integer _h=0
        integer _w=0

        if (( _touch[(Ie)$_name] )); then # flare data + calculate dimensions

            local _data=()
            ztc:steal ${_name}:data _data

            # ╶╶╶╶╶ translate data mask ╴╴╴╴╴

            if [[ $ztc[${_name}:data:format] == 'masked' ]]; then
                local -U _key=()
                ztc:steal ${_name}:data:key _key

                for _k in $_key; do
                    local _entry=(${(As:#:)_k})
                    for _i in {1..${#_data}}; do _data[$_i]=${_data[$_i]//$_entry[1]/$_entry[2]}; done
                done
            fi

            local _flared=()
            ztc:flare _data _flared

            # ╶╶╶╶╶ component height ╴╴╴╴╴

            case $ztc[${_name}:h] in
                (:auto) # set height to number of lines
                    _h=${#_flared} ;;
                (*)
                    _h=$ztc[${_name}:h] ;;
            esac

            # ╶╶╶╶╶ component width ╴╴╴╴╴

            case $ztc[${_name}:w] in
                (:auto) # set width to length of longest line
                    local _length=0

                    for _line in $_flared; do
                        # strip escapes
                        _line=${_line//@\(@\)/@}
                        _line=${(S)_line//${ZTC_CSI}*(m|H|K|J|A|B|C|D|E|F|G|S|T|f|i|n|h|l|s|u)}

                        if (( ${#_line} > _length )); then _length=${#_line}; fi
                    done

                    _w=$_length
                    ;;
                (*)
                    _w=$ztc[${_name}:w]
                    ;;
            esac

            # ╶╶╶╶╶ component y-origin ╴╴╴╴╴

            case $ztc[${_name}:y] in
                (:auto) # center component vertically
                    _y=$(( ( (ztc[vh] - _h) / 2 ) + 1 )) ;;
                (*)
                    _y=$ztc[${_name}:y] ;;
            esac

            # ╶╶╶╶╶ component x-origin ╴╴╴╴╴

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

            ztc:stash paint:${_name}:data _flared

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
        local _matter=${ztc[paint:${_name}:data]//@@/@\(@\)}
        local _origin="${ZTC_CSI}${ztc[paint:${_name}:y]};${ztc[paint:${_name}:x]}H"

        _matter=${_matter//@n/${ZTC_CSI}E${ZTC_CSI}$(( ztc[paint:${_name}:x] - 1 ))C}
        _staged+=($_origin ${_matter//@\(@\)/@} $ZTC_TEXT_RESET)
    done


    # ───── render ─────

    ztc:write $ZTC_CLEAR ${(j::)_staged}
}

# ┌╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴┐
# ╎    flaring    ╎
# └╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶┘

function ztc:flare { # expand `@` flares + calc width

    # ───── import + setup ─────

    local _input=${(Pj:@n:)1//@@/@\(@\)} # escape `@@`

    local _flares=()
    ztc:steal flares _flares

    # ╶╶╶╶╶ retrieve guide ╴╴╴╴╴

    local -U _flat=()
    local -A _guide=()
    ztc:steal flares:guide _flat

    for _item in $_flat; do
        local -U _entry=(${(As:#:)_item})
        _guide[$_entry[1]]=$_entry[2]
    done


    # ───── delegate flare to correct expander ─────

    for _flare in $_flares; do

        # ╶╶╶╶╶ skip flaring if out of flares ╴╴╴╴╴

        if [[ ! $_input =~ @ ]]; then break; fi

        # ╶╶╶╶╶ link alias ╴╴╴╴╴

        local _alias=$_flare
        if (( ${${(k)_guide}[(Ie)$_flare]} )); then _alias=$_guide[$_flare]; fi

        # ╶╶╶╶╶ wrap flare + expand ╴╴╴╴╴

        _input=${_input//@$_flare/@\($_flare\)}
        ztc:flare:$_alias _input $_flare

    done


    # ───── export ─────

    : ${(AP)2::=${(s:@n:)_input}}
}

function ztc:flare:newline   { : ${(P)1::=${(P)1//@\($2\)/@n}}               }
function ztc:flare:reset     { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_RESET}}  }
function ztc:flare:bold      { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_BOLD}}   }
function ztc:flare:invert    { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_INVERT}} }


# ┌─────────────────┐
# │    commander    │
# └─────────────────┘

function ztc:input { # detect user inputs + build commands

    # ───── read input ─────

    local _key=''
    read -s -t $(( ztc[:rate:input] / 1000.0 )) -k 1 _key


    # ───── process input ─────

    if (( ztc[commander:active] )); then # attach input to command bar
        local _input=$ztc[commander:input]
        integer _cursor=$ztc[commander:cursor]
        integer _index=$(( ${#_input} - _cursor ))

        case $_key in

            # ╶╶╶╶╶ <esc> + arrow keys ╴╴╴╴╴

            ($'\e')
                local _special=''
                read -st -k 2 _special

                case $_special in
                    ('[A') ;; # <up>
                    ('[B') ;; # <down>
                    ('[C') # <right>
                        if (( _cursor > 0 )); then (( ztc[commander:cursor]-- )); fi
                        ;;
                    ('[D') # <left>
                        if (( _index > 0 )); then (( ztc[commander:cursor]++ )); fi
                        ;;
                    ('') ztc:commander:leave ;;
                    (*) ;;
                esac
                ;;

            # ╶╶╶╶╶ <ctrl-a> (move cursor to beginning) ╴╴╴╴╴

            ($'\x1') ztc[commander:cursor]=${#_input} ;;

            # ╶╶╶╶╶ <ctrl-b> (<left>) ╴╴╴╴╴

            ($'\x2') if (( _index > 0 )); then (( ztc[commander:cursor]++ )); fi ;;

            # ╶╶╶╶╶ <ctrl-d> (forward delete) ╴╴╴╴╴

            ($'\x4')
                if (( ${#_input} == 0 )); then ztc:commander:leave
                else
                    if (( _index != ${#_input} )); then
                        ztc[commander:input]=${_input:0:_index}${_input:$(( _index + 1 ))}
                        (( ztc[commander:cursor]-- ))
                    fi
                fi
                ;;

            # ╶╶╶╶╶ <ctrl-e> (move cursor to end) ╴╴╴╴╴

            ($'\x5') ztc[commander:cursor]=0 ;;

            # ╶╶╶╶╶ <ctrl-f> (<right>) ╴╴╴╴╴

            ($'\x6') if (( _cursor > 0 )); then (( ztc[commander:cursor]-- )); fi ;;

            # ╶╶╶╶╶ <ctrl-g> (<esc>) ╴╴╴╴╴

            ($'\x7') ztc:commander:leave ;;

            # ╶╶╶╶╶ <ctrl-h>/<backspace>/<delete> ╴╴╴╴╴

            ($'\x8'|$'\b'|$'\x7f')
                if (( _index != 0 )); then ztc[commander:input]=${_input:0:$(( _index - 1 ))}${_input:_index}; fi
                ;;

            # ╶╶╶╶╶ <ctrl-i> (<tab>) ╴╴╴╴╴

            ($'\x9'|$'\t') ;; # autocomplete stuff goes here

            # ╶╶╶╶╶ <ctrl-j>/<ctrl-m>/<enter>/<return> ╴╴╴╴╴

            ($'\xA'|$'\xD'|$'\n'|$'\r')
                if (( ${#_input} > 0 )); then
                    local _parse=${(MS)_input##[[:graph:]]*[[:graph:]]} # trim whitespace
                    if [[ -z $_parse ]]; then _parse=${(MS)_input##[[:graph:]]}; fi

                    ztc:parse $_parse
                else
                    ztc:commander:leave
                fi
                ;;

            # ╶╶╶╶╶ <ctrl-k> (delete from cursor to end) ╴╴╴╴╴

            ($'\xB')
                ztc[commander:yank]=${_input:_index}
                ztc[commander:input]=${_input:0:_index}
                ztc[commander:cursor]=0
                ;;

            # ╶╶╶╶╶ <ctrl-l> (clear the input) ╴╴╴╴╴

            ($'\xC')
                ztc[commander:input]=''
                ztc[commander:cursor]=0
                ;;

            # ╶╶╶╶╶ <ctrl-n> (<down>) ╴╴╴╴╴

            ($'\xE') ;; # next line in history

            # ╶╶╶╶╶ <ctrl-o> (<enter> + next line in history) ╴╴╴╴╴

            ($'\xF') ;; # enter + next line in history

            # ╶╶╶╶╶ <ctrl-p> (<up>) ╴╴╴╴╴

            ($'\x10') ;; # previous line in history

            # ╶╶╶╶╶ <ctrl-q> (pause transmission) ╴╴╴╴╴

            ($'\x11') ;; # pause

            # ╶╶╶╶╶ <ctrl-r> (display/search history) ╴╴╴╴╴

            ($'\x12') ;; # display/search history

            # ╶╶╶╶╶ <ctrl-s> (resume transmission) ╴╴╴╴╴

            ($'\x13') ;; # resume

            # ╶╶╶╶╶ <ctrl-t> (swap characters around cursor) ╴╴╴╴╴

            ($'\x14')
                if (( _cursor > 0 && _index > 0 )); then
                    local _a=${_input:$(( _index - 1 )):1}
                    local _b=${_input:_index:1}

                    ztc[commander:input]=${_input:0:$(( _index - 1 ))}$_b$_a${_input:$(( _index + 1 ))}
                fi
                ;;

            # ╶╶╶╶╶ <ctrl-u> (delete from beginning to cursor) ╴╴╴╴╴

            ($'\x15')
                ztc[commander:yank]=${_input:0:_index}
                ztc[commander:input]=${_input:_index}
                ;;

            # ╶╶╶╶╶ <ctrl-v> (literal insert) ╴╴╴╴╴

            ($'\x16') ;; # disabled

            # ╶╶╶╶╶ <ctrl-w> (delete word) ╴╴╴╴╴

            ($'\x17')
                if (( _index != 0 )); then
                    local _erase=${(*)${_input:0:_index}/%[[:space:]]#} # trim trailing spaces
                    local _trim=${(MS)_erase##[[:graph:]]*[[:graph:]]}  # trim all whitespace

                    if [[ -z $_trim ]]; then _trim=${(MS)_erase##[[:graph:]]}; fi

                    if [[ ! $_erase =~ ' ' ]]; then _erase=''
                    else _erase="${_erase%[[:space:]]*} "; fi  # remove last word

                    ztc[commander:yank]=${_trim##*[[:space:]]} # select last word
                    ztc[commander:input]=$_erase${_input:_index}
                fi
                ;;

            # ╶╶╶╶╶ <ctrl-x> (alternate between cursor and beginning) ╴╴╴╴╴

            ($'\x18')
                if (( _index != 0 )); then
                    ztc[commander:cursor:last]=$_cursor
                    ztc[commander:cursor]=${#_input}
                else
                    ztc[commander:cursor]=$ztc[commander:cursor:last]
                fi
                ;;

            # ╶╶╶╶╶ <ctrl-y> (paste) ╴╴╴╴╴

            ($'\x19') ztc[commander:input]=${_input:0:_index}$ztc[commander:yank]${_input:_index} ;;

            # ╶╶╶╶╶ ignore empty keys ╴╴╴╴╴

            ('') ;;

            # ╶╶╶╶╶ insert key at cursor index ╴╴╴╴╴

            (*)
                integer _index=$(( ${#_input} - _cursor ))
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

# ┌╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴┐
# ╎    parsing    ╎
# └╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶┘

function ztc:parse { # delegate command to correct parser
    local _input=(${(As: :)1})
    local _command=${(L)_input[1]//\\/\\\\}

    local -U _commands=()
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
                ztc:commander:leave "@i Unknown command: ${_command//@/@@} @r"
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

# ┌╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴┐
# ╎    digital    ╎
# └╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶┘

function ztc:order:face:digital {
    ztc[face:digital:y]=:auto
    ztc[face:digital:x]=:auto
    ztc[face:digital:h]=:auto
    ztc[face:digital:w]=:auto

    ztc[face:digital:data:format]=masked
}

function ztc:alter:face:digital {
    local _time=''
    strftime -s _time "%l:%M:%S"

    local _mask=()
    local _staged=()


    # ───── create mask ─────

    for _character in ${(s::)_time}; do
        case $_character in
            (0) _mask=(111 101 101 101 111) ;;
            (1) _mask=(001 001 001 001 001) ;;
            (2) _mask=(111 001 111 100 111) ;;
            (3) _mask=(111 001 111 001 111) ;;
            (4) _mask=(101 101 111 001 001) ;;
            (5) _mask=(111 100 111 001 111) ;;
            (6) _mask=(111 100 111 101 111) ;;
            (7) _mask=(111 001 001 001 001) ;;
            (8) _mask=(111 101 111 101 111) ;;
            (9) _mask=(111 101 111 001 111) ;;
            (:) _mask=( 0   1   0   1   0 ) ;;
        esac

        _staged+=(${(j:@n:)_mask})
    done


    # ───── set mask key ─────

    local -U _key=()

    _key+=('0#@r  ')
    _key+=('1#@i  ')
    _key+=('.#@r ')

    ztc:stash face:digital:data:key _key


    # ───── interleave + flatten (with padding) ─────

    ztc:weave _staged
    for _i in {1..${#_staged}}; do _staged[$_i]=${_staged[$_i]//@n/.}; done


    # ───── save ─────

    ztc:stash face:digital:data _staged
}


# ┌────────────┐
# │    date    │
# └────────────┘

function ztc:order:date {
    ztc[date:y]=:auto
    ztc[date:x]=:auto
    ztc[date:h]=:auto
    ztc[date:w]=:auto
}

function ztc:alter:date {
    local _date=''
    strftime -s _date ${ztc[:date:format]//\%n/@n} # capture newlines

    ztc:stash date:data _date
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

    # commander properties
    ztc[commander:active]=${ztc[commander:active]:-0}

    ztc[commander:prefix]=${ztc[commander:prefix]:-:}
    ztc[commander:status]=${ztc[commander:status]:-}
    ztc[commander:input]=${ztc[commander:input]:-}

    ztc[commander:yank]=${ztc[commander:yank]:-}
    ztc[commander:cursor]=${ztc[commander:cursor]:-0}
    ztc[commander:cursor:last]=${ztc[commander:cursor:last]:-0}
}

function ztc:alter:commander {

    # ───── import ─────

    local _input=$ztc[commander:input]
    integer _cursor=$ztc[commander:cursor]


    # ───── truncate overflows ─────

    integer _index=$(( ${#_input} - _cursor ))
    integer _bound=$(( ztc[commander:w] - ${#ztc[commander:prefix]} ))

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

    local _data=()

    if (( ztc[commander:active] )); then _data=${ztc[commander:prefix]}${_input//@/@@}$_position$ZTC_CURSOR_SHOW
    else _data=$ztc[commander:status]$ZTC_CURSOR_HIDE; fi

    ztc:stash commander:data _data
}


# ┌─────────────────────────────┐
# │ ░░▒▒▓▓██  HELPERS  ██▓▓▒▒░░ │
# └─────────────────────────────┘

function ztc:write { print -n ${(j::)@} } # splash paint


# ┌─────────────────────┐
# │    stash + steal    │
# └─────────────────────┘

function ztc:stash { # escape flares + flatten array for storage

    # ───── import ─────

    local _pouch=(${(AP)2})


    # ───── build stash ─────

    local _stash=()

    for _jewel in $_pouch; do

        # ╶╶╶╶╶ escape `@@` + split by `@n` ╴╴╴╴╴

        local _shiny=(${(As:@n:)_jewel//@@/@\(@\)})

        # ╶╶╶╶╶ escape `@` + add to stash ╴╴╴╴╴

        for _i in {1..${#_shiny}}; do _shiny[$_i]=${_shiny[$_i]//@/@@}; done

        _stash+=($_shiny)
    done


    # ───── export ─────

    ztc[$1]=${(j:@n:)_stash//@@\(@@\)/@\(@\)} # reduce `@@(@@)` into `@(@)`
}

function ztc:steal { # retrieve flattened array + undo flare escapement

    # ───── import ─────

    local _stash=(${(As:@@:)ztc[$1]})


    # ───── steal stash ─────

    local _theft=()
    local _prior=''

    if [[ ${ztc[$1]:0:2} == '@@' ]]; then _prior='@ '; fi # preserve leading `@`

    for _jewel in $_stash; do

        # ╶╶╶╶╶ split by `@n` ╴╴╴╴╴

        local _shiny=(${(As:@n:)_jewel})

        # ╶╶╶╶╶ insert escaped `@` ╴╴╴╴╴

        _prior=${_prior:+${_prior}@}
        _shiny[1]=${_prior/#@ }$_shiny[1] # compress `@ @` into `@`

        # ╶╶╶╶╶ prep for next jewel + add to theft ╴╴╴╴╴

        _prior=$_shiny[-1]
        shift -p _shiny

        _theft+=($_shiny)
    done


    # ───── export ─────

    _theft+=($_prior)
    : ${(AP)2::=$_theft}
}


# ┌──────────────┐
# │    weaver    │
# └──────────────┘

function ztc:weave { # ((1 1 1) (2 2 2) (3 3 3)) -> ((1 2 3) (1 2 3) (1 2 3))

    # ───── import ─────

    local _array=(${(AP)1})


    # ───── determine max sub-length ─────

    integer _length=0

    for _item in $_array; do
        local _sub=(${(As:@n:)_item})
        if (( $#_sub > _length )); then _length=${#_sub}; fi
    done


    # ───── weave ─────

    local _weaved=()

    for _i in {1..$_length}; do
        local _select=()

        for _item in $_array; do
            local _sub=(${(As:@n:)_item})
            _select+=($_sub[$_i])
        done

        _weaved+=(${(j:@n:)_select})
    done


    # ───── export ─────

    : ${(AP)1::=$_weaved}
}


# ┌──────────────────────────────┐
# │ ░░▒▒▓▓██  DIRECTOR  ██▓▓▒▒░░ │
# └──────────────────────────────┘

function zsh_that_clock {
    trap 'ztc:clean 1' INT

    stty dsusp undef # disable delayed suspend (frees ^Y for paste)

    zmodload zsh/datetime

    typeset -A ztc=()

    ztc:plonk              # set config + init
    ztc:write $ZTC_INIT    # allocate screen space
    ztc:build && ztc:drive # zsh the clock!
    ztc:clean              # cleanup
}

zsh_that_clock
