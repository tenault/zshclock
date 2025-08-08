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
ZTC_TEXT_UNDERLINE=${ZTC_CSI}4m
ZTC_TEXT_INVERT=${ZTC_CSI}7m


# ┌─────────────────────────┐
# │ ░░▒▒▓▓██  ZTC  ██▓▓▒▒░░ │
# └─────────────────────────┘

function ztc:build { # set view area + build components
    ztc[vh]=$LINES
    ztc[vw]=$COLUMNS

    local _ztcb_components=()
    ztc:steal components _ztcb_components

    for _ztcb_name in $_ztcb_components; do "ztc:order:$_ztcb_name"; done

    ztc:cycle
}

function ztc:drive { # clock go vroom vroom
    float _ztcd_epoch=$EPOCHREALTIME
    integer _ztcd_epsilon=0

    while true; do
        ztc:input # handle inputs
        ztc:align # check for resizes

        # clear stale statuses
        if [[ -n ztc[commander:status] && ${$(( (EPOCHREALTIME - ztc[commander:status:epoch]) * 1000 ))%%.*} -gt ztc[:rate:status] ]]; then ztc:commander:clear; fi

        # repaint clock
        integer _ztcd_duration=${$(( (EPOCHREALTIME - _ztcd_epoch) * 1000 ))%%.*}
        if (( _ztcd_duration >= ( ztc[:rate:refresh] - _ztcd_epsilon ) )); then

            ztc:cycle # update component data + repaint

            _ztcd_epoch=$EPOCHREALTIME
            _ztcd_epsilon=$(( ( _ztcd_duration - (ztc[:rate:refresh] - _ztcd_epsilon) ) % ztc[:rate:refresh] ))

        fi
    done
}

function ztc:clean { # dissolve clock + restore terminal state
    integer _ztcc_code=${1:-0}
    ztc:write $ZTC_CURSOR_SHOW $ZTC_EXIT

    stty dsusp '^Y'   # restore delayed suspend
    stty discard '^O' # restore discard

    exit $_ztcc_code
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

    local -U _ztcpl_flares=(newline reset bold underline invert)
    local -A _ztcpl_guide=()

    # ╶╶╶╶╶ generate short flares ╴╴╴╴╴

    local -A _ztcpl_route=()

    for _ztcpl_i in {1..${#_ztcpl_flares}}; do # loop through all flares
        local _ztcpl_length=${#_ztcpl_flares[$_ztcpl_i]}
        _ztcpl_route[$_ztcpl_length]="$_ztcpl_route[$_ztcpl_length]@$_ztcpl_flares[$_ztcpl_i]"

        for _ztcpl_j in {1..$_ztcpl_length}; do # loop through each letter
            local _ztcpl_abbr=${_ztcpl_flares[$_ztcpl_i]:0:$_ztcpl_j}

            if (( ! _ztcpl_flares[(Ie)$_ztcpl_abbr] )); then # add short flare if not already assigned
                _ztcpl_flares+=($_ztcpl_abbr)
                _ztcpl_guide[$_ztcpl_abbr]=$_ztcpl_flares[$_ztcpl_i]
                _ztcpl_route[$_ztcpl_j]="$_ztcpl_route[$_ztcpl_j]@$_ztcpl_abbr"
                break
            fi
        done
    done

    # ╶╶╶╶╶ flatten guide ╴╴╴╴╴

    local -U _ztcpl_flat=()
    for _ztcpl_key _ztcpl_value in ${(kv)_ztcpl_guide}; do _ztcpl_flat+=("$_ztcpl_key#$_ztcpl_value"); done

    ztc:stash flares:guide _ztcpl_flat

    # ╶╶╶╶╶ rebuild flare array + sort descending ╴╴╴╴╴

    _ztcpl_flares=()
    for _ztcpl_key in ${(Ok)_ztcpl_route}; do _ztcpl_flares+=(${(As:@:)_ztcpl_route[$_ztcpl_key]}); done

    ztc:stash flares _ztcpl_flares


    # ───── register commands ─────

    local -U _ztcpl_commands=(date)
    ztc:stash :commands _ztcpl_commands


    # ───── register components ─────

    local -U _ztcpl_components=(face:digital date commander)
    ztc:stash components _ztcpl_components

}


# ┌───────────────────────────────┐
# │ ░░▒▒▓▓██  CASSETTES  ██▓▓▒▒░░ │
# └───────────────────────────────┘

# ┌───────────┐
# │    ztc    │
# └───────────┘

function ztc:align { # check for resizes + rebuild
    LINES=
    COLUMNS=

    if (( LINES != ztc[vh] || COLUMNS != ztc[vw] )); then ztc:build; fi
}

function ztc:cycle { # update component data + repaint
    local -U _ztczc_components=$@
    if (( $# == 0 )); then ztc:steal components _ztczc_components; fi

    for _ztczc_name in $_ztczc_components; do ztc:alter:$_ztczc_name; done

    ztc:paint $@
}


# ┌─────────────────┐
# │    commander    │
# └─────────────────┘

function ztc:commander:enter {
    ztc[commander:active]=1
    ztc[commander:prefix]=${1:-:}

    ztc:cycle commander
}

function ztc:commander:leave {
    ztc[commander:status]=$1
    ztc[commander:status:epoch]=$EPOCHREALTIME

    ztc[commander:active]=0
    ztc[commander:help]=0

    ztc[commander:history:index]=0
    ztc[commander:history:filter]=''

    ztc[commander:input]=''
    ztc[commander:cursor]=0
}

function ztc:commander:clear {
    ztc[commander:status]=''
    ztc:cycle commander
}

function ztc:commander:shift { # transform closest word
    local _ztccs_input=${(P)1}
    local _ztccs_index=${(P)2}

    local _ztccs_left=''
    local _ztccs_right=''
    local _ztccs_word_left=''
    local _ztccs_word_right=''

    ztc:words _ztccs_input _ztccs_index both _ztccs_left _ztccs_right _ztccs_word_left _ztccs_word_right
    ztc:shift _ztccs_input _ztccs_index $3 _ztccs_left _ztccs_right _ztccs_word_left _ztccs_word_right

    ztc[commander:input]=$_ztccs_input
    ztc[commander:cursor]=${#_ztccs_right}
}

function ztc:commander:serve { # roll through history

    # ───── import + setup ─────

    local _ztccsr_direction=$1
    local _ztccsr_filter=${2:+${ztc[commander:history:filter]:-$2}} # retrieve previous filter if set
    ztc[commander:history:filter]=$_ztccsr_filter

    integer _ztccsr_history_index=$ztc[commander:history:index]
    local -U _ztccsr_history=()
    ztc:steal commander:history _ztccsr_history


    # ───── reset cursor + retrieve entry ─────

    ztc[commander:cursor]=0

    if (( ${#_ztccsr_history} > 0 )); then
        integer _ztccsr_index=0
        local _ztccsr_entry=''

        # ╶╶╶╶╶ check entry(s) against filter ╴╴╴╴╴

        while true; do
            case $_ztccsr_direction in
                (previous) if (( _ztccsr_history_index < ${#_ztccsr_history} )); then (( _ztccsr_history_index++ )); fi ;;
                (next)     if (( _ztccsr_history_index > 0 )); then (( _ztccsr_history_index-- )); fi ;;
                (first)    _ztccsr_history_index=${#_ztccsr_history} ;;
                (last)     _ztccsr_history_index=1 ;;
            esac

            _ztccsr_index=$(( ${#_ztccsr_history} - _ztccsr_history_index + 1 ))
            _ztccsr_entry=$_ztccsr_history[$_ztccsr_index]

            [[ -n $_ztccsr_filter && $_ztccsr_history_index -ne ${#_ztccsr_history} && $_ztccsr_history_index -ne 0 ]] || break # exit loop if not filtering or no matches at bounds
            if [[ $_ztccsr_entry =~ $_ztccsr_filter ]]; then _ztccsr_filter=''; break; fi # entry matches filter
        done

        # ╶╶╶╶╶ export ╴╴╴╴╴

        if (( $_ztccsr_history_index == 0 )); then
            ztc[commander:input]=$_ztccsr_filter
            ztc[commander:history:index]=0
            ztc[commander:history:filter]=''
        fi

        if [[ -z $_ztccsr_filter ]]; then
            ztc[commander:input]=$_ztccsr_entry
            ztc[commander:history:index]=$_ztccsr_history_index
        fi
    fi

}

function ztc:commander:yield { # submit and process input

    # ───── import + setup ─────

    local _ztccy_input=$1
    local _ztccy_history_index=$ztc[commander:history:index]

    local -U _ztccy_history=()
    ztc:steal commander:history _ztccy_history


    # ───── write to history ─────

    local _ztccy_entry_index=$_ztccy_history[(I)$_ztccy_input]
    if (( _ztccy_entry_index != 0 )); then _ztccy_history[$_ztccy_entry_index]=(); fi # remove old entry
    _ztccy_history+=($_ztccy_input) # append new entry

    ztc:stash commander:history _ztccy_history


    # ───── trim whitespace + parse ─────

    local _ztccy_parse=${(MS)_ztccy_input##[[:graph:]]*[[:graph:]]}
    if [[ -z $_ztccy_parse ]]; then _ztccy_parse=${(MS)_ztccy_input##[[:graph:]]}; fi

    ztc:parse $_ztccy_parse

}


# ┌─────────────────────────────┐
# │ ░░▒▒▓▓██  ENGINES  ██▓▓▒▒░░ │
# └─────────────────────────────┘

# ┌───────────────┐
# │    painter    │
# └───────────────┘

function ztc:paint { # translate component data for rendering

    local -U _ztcp_components=()
    ztc:steal components _ztcp_components

    local -U _ztcp_touch=(${@:-$_ztcp_components})


    # ───── reset bounds ─────

    ztc[paint:my]=$ztc[vh] # min-y
    ztc[paint:mx]=$ztc[vw] # min-x
    ztc[paint:ym]=0        # y-max
    ztc[paint:xm]=0        # x-max

    ztc[paint:h]=0
    ztc[paint:w]=0


    # ───── get component properties + cache ─────

    for _ztcp_name in $_ztcp_components; do

        integer _ztcp_y=0
        integer _ztcp_x=0
        integer _ztcp_h=0
        integer _ztcp_w=0

        if (( _ztcp_touch[(Ie)$_ztcp_name] )); then # flare data + calculate dimensions

            local _ztcp_data=()
            ztc:steal ${_ztcp_name}:data _ztcp_data

            # ╶╶╶╶╶ translate data mask ╴╴╴╴╴

            if [[ $ztc[${_ztcp_name}:data:format] == 'masked' ]]; then
                local -U _ztcp_key=()
                ztc:steal ${_ztcp_name}:data:key _ztcp_key

                for _ztcp_k in $_ztcp_key; do
                    local _ztcp_entry=(${(As:#:)_ztcp_k})
                    for _ztcp_i in {1..${#_ztcp_data}}; do _ztcp_data[$_ztcp_i]=${_ztcp_data[$_ztcp_i]//$_ztcp_entry[1]/$_ztcp_entry[2]}; done
                done
            fi

            local _ztcp_flared=()
            ztc:flare _ztcp_data _ztcp_flared

            # ╶╶╶╶╶ component height ╴╴╴╴╴

            case $ztc[${_ztcp_name}:h] in
                (:auto) # set height to number of lines
                    _ztcp_h=${#_ztcp_flared} ;;
                (*)
                    _ztcp_h=$ztc[${_ztcp_name}:h] ;;
            esac

            # ╶╶╶╶╶ component width ╴╴╴╴╴

            case $ztc[${_ztcp_name}:w] in
                (:auto) # set width to length of longest line
                    local _ztcp_length=0

                    for _ztcp_line in $_ztcp_flared; do # strip escapes
                        _ztcp_line=${_ztcp_line//@\(@\)/@}
                        _ztcp_line=${(S)_ztcp_line//${ZTC_CSI}*(m|H|K|J|A|B|C|D|E|F|G|S|T|f|i|n|h|l|s|u)}

                        if (( ${#_ztcp_line} > _ztcp_length )); then _ztcp_length=${#_ztcp_line}; fi
                    done

                    _ztcp_w=$_ztcp_length
                    ;;
                (*)
                    _ztcp_w=$ztc[${_ztcp_name}:w]
                    ;;
            esac

            # ╶╶╶╶╶ component y-origin ╴╴╴╴╴

            case $ztc[${_ztcp_name}:y] in
                (:auto) # center component vertically
                    _ztcp_y=$(( ( (ztc[vh] - _ztcp_h) / 2 ) + 1 )) ;;
                (*)
                    _ztcp_y=$ztc[${_ztcp_name}:y] ;;
            esac

            # ╶╶╶╶╶ component x-origin ╴╴╴╴╴

            case $ztc[${_ztcp_name}:x] in
                (:auto) # center component horizontally
                    _ztcp_x=$(( ( (ztc[vw] - _ztcp_w) / 2 ) + 1 )) ;;
                (*)
                    _ztcp_x=$ztc[${_ztcp_name}:x] ;;
            esac

            # ╶╶╶╶╶ save/cache calculations ╴╴╴╴╴

            ztc[paint:${_ztcp_name}:h]=$_ztcp_h
            ztc[paint:${_ztcp_name}:w]=$_ztcp_w
            ztc[paint:${_ztcp_name}:y]=$_ztcp_y
            ztc[paint:${_ztcp_name}:x]=$_ztcp_x

            ztc:stash paint:${_ztcp_name}:data _ztcp_flared

        else # retrieve from cache

            _ztcp_h=$ztc[paint:${_ztcp_name}:h]
            _ztcp_w=$ztc[paint:${_ztcp_name}:w]
            _ztcp_y=$ztc[paint:${_ztcp_name}:y]
            _ztcp_x=$ztc[paint:${_ztcp_name}:x]

        fi

        # ╶╶╶╶╶ update bounds ╴╴╴╴╴

        if (( ! ztc[${_ztcp_name}:overlay] )); then
            (( ztc[paint:h] += $_ztcp_h )) # only for layout:vertical when position:auto

            if (( _ztcp_y + _ztcp_h > ztc[paint:ym] )); then ztc[paint:ym]=$((_ztcp_y + _ztcp_h)); fi
            if (( _ztcp_x + _ztcp_w > ztc[paint:xm] )); then ztc[paint:xm]=$((_ztcp_x + _ztcp_w)); fi
            if (( _ztcp_y < ztc[paint:my] )); then ztc[paint:my]=$_ztcp_y; fi
            if (( _ztcp_x < ztc[paint:mx] )); then ztc[paint:mx]=$_ztcp_x; fi
        fi
    done


    # ───── declare render zone + adjust component origins ─────

    # ztc[paint:h]=$(( ztc[paint:ym] - ztc[paint:my] ))
    ztc[paint:w]=$(( ztc[paint:xm] - ztc[paint:mx] ))
    ztc[paint:my]=$(( ( (ztc[vh] - ztc[paint:h]) / 2 ) + 1 )) # override h for position:auto

    integer _ztcp_dy=0

    for _ztcp_name in $_ztcp_components; do
        if (( ! ztc[${_ztcp_name}:overlay] )); then
            ztc[paint:${_ztcp_name}:y]=$(( ztc[paint:my] + _ztcp_dy ))
            (( _ztcp_dy += ztc[paint:${_ztcp_name}:h] ))
        fi
    done


    # ───── paint component data ─────

    local _ztcp_staged=()

    for _ztcp_name in $_ztcp_components; do
        local _ztcp_matter=${ztc[paint:${_ztcp_name}:data]//@@/@\(@\)}
        local _ztcp_origin="${ZTC_CSI}${ztc[paint:${_ztcp_name}:y]};${ztc[paint:${_ztcp_name}:x]}H"

        _ztcp_matter=${_ztcp_matter//@n/${ZTC_CSI}E${ZTC_CSI}$(( ztc[paint:${_ztcp_name}:x] - 1 ))C}
        _ztcp_staged+=($_ztcp_origin ${_ztcp_matter//@\(@\)/@} $ZTC_TEXT_RESET)
    done


    # ───── render ─────

    ztc:write $ZTC_CLEAR ${(j::)_ztcp_staged}

}

# ┌╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴┐
# ╎    flaring    ╎
# └╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶┘

function ztc:flare { # expand `@` flares + calc width

    # ───── import + setup ─────

    local _ztcf_input=${(Pj:@n:)1//@@/@\(@\)} # escape `@@`

    local _ztcf_flares=()
    ztc:steal flares _ztcf_flares

    # ╶╶╶╶╶ retrieve guide ╴╴╴╴╴

    local -U _ztcf_flat=()
    local -A _ztcf_guide=()
    ztc:steal flares:guide _ztcf_flat

    for _ztcf_item in $_ztcf_flat; do
        local -U _ztcf_entry=(${(As:#:)_ztcf_item})
        _ztcf_guide[$_ztcf_entry[1]]=$_ztcf_entry[2]
    done


    # ───── delegate flare to correct expander ─────

    for _ztcf_flare in $_ztcf_flares; do

        # ╶╶╶╶╶ skip flaring if out of flares ╴╴╴╴╴

        if [[ ! $_ztcf_input =~ @ ]]; then break; fi

        # ╶╶╶╶╶ link alias ╴╴╴╴╴

        local _ztcf_alias=$_ztcf_flare
        if (( ${${(k)_ztcf_guide}[(Ie)$_ztcf_flare]} )); then _ztcf_alias=$_ztcf_guide[$_ztcf_flare]; fi

        # ╶╶╶╶╶ wrap flare + expand ╴╴╴╴╴

        _ztcf_input=${_ztcf_input//@$_ztcf_flare/@\($_ztcf_flare\)}
        ztc:flare:$_ztcf_alias _ztcf_input $_ztcf_flare

    done


    # ───── export ─────

    : ${(AP)2::=${(s:@n:)_ztcf_input}}

}

function ztc:flare:newline   { : ${(P)1::=${(P)1//@\($2\)/@n}}                  }
function ztc:flare:reset     { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_RESET}}     }
function ztc:flare:bold      { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_BOLD}}      }
function ztc:flare:underline { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_UNDERLINE}} }
function ztc:flare:invert    { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_INVERT}}    }


# ┌─────────────────┐
# │    commander    │
# └─────────────────┘

function ztc:input { # detect user inputs + build commands

    # ───── read input ─────

    local _ztci_key=''
    read -s -t $(( ztc[:rate:input] / 1000.0 )) -k 1 _ztci_key


    # ───── process input ─────

    if (( ztc[commander:active] )); then # attach input to command bar

        local _ztci_input=$ztc[commander:input]
        integer _ztci_cursor=$ztc[commander:cursor]
        integer _ztci_index=$(( ${#_ztci_input} - _ztci_cursor ))

        case $_ztci_key in

            # ╶╶╶╶╶ ignore empty keys ╴╴╴╴╴

            ('') ;;

            # ╶╶╶╶╶ <esc> + special keys ╴╴╴╴╴

            ($'\e')
                local _ztci_s1=''
                local _ztci_s2=''
                local _ztci_s3=''
                local _ztci_s4=''
                local _ztci_s5=''

                read -st -k 1 _ztci_s1
                read -st -k 1 _ztci_s2
                read -st -k 1 _ztci_s3
                read -st -k 1 _ztci_s4
                read -st -k 1 _ztci_s5

                local _ztci_special=$_ztci_s1$_ztci_s2$_ztci_s3$_ztci_s4$_ztci_s5

                case $_ztci_special in

                    # ╶╶╶╶╶ <esc> ╴╴╴╴╴

                    ('') ztc:commander:leave ;;

                    # ╶╶╶╶╶ <up> (previous line in history) ╴╴╴╴╴

                    ('[A') if (( ! ztc[commander:help] )); then ztc:commander:serve previous; fi ;;

                    # ╶╶╶╶╶ <down> (next line in history) ╴╴╴╴╴

                    ('[B') if (( ! ztc[commander:help] )); then ztc:commander:serve next; fi ;;

                    # ╶╶╶╶╶ <right> (move cursor right) ╴╴╴╴╴

                    ('[C') if (( _ztci_cursor > 0 )); then (( ztc[commander:cursor]-- )); fi ;;

                    # ╶╶╶╶╶ <left> (move cursor left) ╴╴╴╴╴

                    ('[D') if (( _ztci_index > 0 )); then (( ztc[commander:cursor]++ )); fi ;;

                    # ╶╶╶╶╶ <alt-delete> (delete word) ╴╴╴╴╴

                    ($'\x7f')
                        if (( _ztci_index != 0 )); then
                            local _ztci_left=''
                            local _ztci_word=''
                            ztc:words _ztci_input _ztci_index left _ztci_left _ztci_word

                            ztc[commander:yank]=$_ztci_word
                            ztc[commander:input]=$_ztci_left${_ztci_input:_ztci_index}
                        fi ;;

                    # ╶╶╶╶╶ <alt-<> (first line in history) ╴╴╴╴╴

                    ('<') if (( ! ztc[commander:help] )); then ztc:commander:serve first; fi ;;

                    # ╶╶╶╶╶ <alt->> (last line in history) ╴╴╴╴╴

                    ('>') if (( ! ztc[commander:help] )); then ztc:commander:serve last; fi ;;

                    # ╶╶╶╶╶ <alt-b>/<alt-left> (move cursor one word left) ╴╴╴╴╴

                    ('b'|'[1;3D')
                        if (( _ztci_index != 0 )); then
                            local _ztci_left=''
                            ztc:words _ztci_input _ztci_index left _ztci_left

                            ztc[commander:cursor]=$(( ${#_ztci_input} - ${#_ztci_left} ))
                        fi ;;

                    # ╶╶╶╶╶ <alt-c> (capitalize word) ╴╴╴╴╴

                    ('c') ztc:commander:shift _ztci_input _ztci_index C ;;

                    # ╶╶╶╶╶ <alt-d> (forward delete word) ╴╴╴╴╴

                    ('d')
                        if (( _ztci_cursor != 0 )); then
                            local _ztci_right=''
                            local _ztci_word=''
                            ztc:words _ztci_input _ztci_index right _ztci_right _ztci_word

                            ztc[commander:yank]=$_ztci_word
                            ztc[commander:input]=${_ztci_input:0:_ztci_index}$_ztci_right
                            ztc[commander:cursor]=${#_ztci_right}
                        fi ;;

                    # ╶╶╶╶╶ <alt-f>/<alt-right> (move cursor one word right) ╴╴╴╴╴

                    ('f'|'[1;3C')
                        if (( _ztci_cursor != 0 )); then
                            local ztci_right=''
                            ztc:words _ztci_input _ztci_index right _ztci_right

                            ztc[commander:cursor]=${#_ztci_right}
                        fi ;;

                    # ╶╶╶╶╶ <alt-l> (lowercase word) ╴╴╴╴╴

                    ('l') ztc:commander:shift _ztci_input _ztci_index L ;;

                    # ╶╶╶╶╶ <alt-n>/<alt-down> (next line in history based on input) ╴╴╴╴╴

                    ('n'|'[1;3B') if [[ -n $_ztci_input && $ztc[commander:help] -eq 0 ]]; then ztc:commander:serve next $_ztci_input; fi ;;

                    # ╶╶╶╶╶ <alt-p>/<alt-up> (previous line in history based on input) ╴╴╴╴╴

                    ('p'|'[1;3A') if [[ -n $_ztci_input && $ztc[commander:help] -eq 0 ]]; then ztc:commander:serve previous $_ztci_input; fi ;;

                    # ╶╶╶╶╶ <alt-t> (swap words around cursor) ╴╴╴╴╴

                    ('t') ztc:commander:shift _ztci_input _ztci_index T ;;

                    # ╶╶╶╶╶ <alt-u> (uppercase word) ╴╴╴╴╴

                    ('u') ztc:commander:shift _ztci_input _ztci_index U ;;

                    # ╶╶╶╶╶ ignore all other special keys ╴╴╴╴╴

                    (*) ;;

                esac ;;

            # ╶╶╶╶╶ <ctrl-a> (move cursor to beginning) ╴╴╴╴╴

            ($'\x1') ztc[commander:cursor]=${#_ztci_input} ;;

            # ╶╶╶╶╶ <ctrl-b> (move cursor left) ╴╴╴╴╴

            ($'\x2') if (( _ztci_index > 0 )); then (( ztc[commander:cursor]++ )); fi ;;

            # ╶╶╶╶╶ <ctrl-d> (forward delete) ╴╴╴╴╴

            ($'\x4')
                if (( ${#_ztci_input} == 0 )); then
                    ztc:commander:leave
                else
                    if (( _ztci_index != ${#_ztci_input} )); then
                        ztc[commander:input]=${_ztci_input:0:_ztci_index}${_ztci_input:$(( _ztci_index + 1 ))}
                        (( ztc[commander:cursor]-- ))
                    fi
                fi ;;

            # ╶╶╶╶╶ <ctrl-e> (move cursor to end) ╴╴╴╴╴

            ($'\x5') ztc[commander:cursor]=0 ;;

            # ╶╶╶╶╶ <ctrl-f> (move cursor) ╴╴╴╴╴

            ($'\x6') if (( _ztci_cursor > 0 )); then (( ztc[commander:cursor]-- )); fi ;;

            # ╶╶╶╶╶ <ctrl-g> (<esc>) ╴╴╴╴╴

            ($'\x7') ztc:commander:leave ;;

            # ╶╶╶╶╶ <ctrl-h>/<backspace>/<delete> ╴╴╴╴╴

            ($'\x8'|$'\b'|$'\x7f') if (( _ztci_index != 0 )); then ztc[commander:input]=${_ztci_input:0:$(( _ztci_index - 1 ))}${_ztci_input:_ztci_index}; fi ;;

            # ╶╶╶╶╶ <ctrl-i> (<tab>) ╴╴╴╴╴

            ($'\x9'|$'\t') ;; # autocomplete stuff goes here

            # ╶╶╶╶╶ <ctrl-j>/<ctrl-m>/<enter>/<return> ╴╴╴╴╴

            ($'\xA'|$'\xD'|$'\n'|$'\r')
                if (( ! ztc[commander:help] )); then
                    if (( ${#_ztci_input} > 0 )); then ztc:commander:yield $_ztci_input
                    else ztc:commander:leave; fi
                else
                    local _ztci_parse=${(MS)_ztci_input##[[:graph:]]*[[:graph:]]}
                    if [[ -z $_ztci_parse ]]; then _ztci_parse=${(MS)_ztci_input##[[:graph:]]}; fi

                    ztc:parse $_ztci_parse
                fi ;;

            # ╶╶╶╶╶ <ctrl-k> (delete from cursor to end) ╴╴╴╴╴

            ($'\xB')
                ztc[commander:yank]=${_ztci_input:_ztci_index}
                ztc[commander:input]=${_ztci_input:0:_ztci_index}
                ztc[commander:cursor]=0
                ;;

            # ╶╶╶╶╶ <ctrl-l> (clear the input) ╴╴╴╴╴

            ($'\xC')
                ztc[commander:input]=''
                ztc[commander:cursor]=0
                ztc[commander:history:index]=0
                ;;

            # ╶╶╶╶╶ <ctrl-n> (next line in history) ╴╴╴╴╴

            ($'\xE') if (( ! ztc[commander:help] )); then ztc:commander:serve next; fi ;;

            # ╶╶╶╶╶ <ctrl-o> (<enter> + next line in history) ╴╴╴╴╴

            ($'\xF')
                if (( ! ztc[commander:help] )); then
                    local _ztci_history_index=$ztc[commander:history:index]
                    local _ztci_history_filter=$ztc[commander:history:filter]

                    if (( ${#_ztci_input} > 0 )); then ztc:commander:yield $_ztci_input
                    else ztc:commander:leave; fi

                    ztc:commander:enter
                    ztc[commander:history:index]=$(( _ztci_history_index + 1 )) # adjust for dup removal
                    ztc[commander:history:filter]=$_ztci_history_filter
                    ztc:commander:serve next
                fi ;;

            # ╶╶╶╶╶ <ctrl-p> (previous line in history) ╴╴╴╴╴

            ($'\x10') if (( ! ztc[commander:help] )); then ztc:commander:serve previous; fi ;;

            # ╶╶╶╶╶ <ctrl-q> (literal insert) ╴╴╴╴╴

            ($'\x11') ;; # disabled

            # ╶╶╶╶╶ <ctrl-r> (search backward in history) ╴╴╴╴╴

            ($'\x12') ;;

            # ╶╶╶╶╶ <ctrl-s> (search forward in history) ╴╴╴╴╴

            ($'\x13') ;;

            # ╶╶╶╶╶ <ctrl-t> (swap characters around cursor) ╴╴╴╴╴

            ($'\x14')
                if (( _ztci_index > 0 )); then
                    if (( _ztci_cursor == 0 )); then (( _ztci_index -= 1 )); fi

                    local _ztci_left=${_ztci_input:0:$(( _ztci_index - 1 ))}
                    local _ztci_right=${_ztci_input:$(( _ztci_index + 1 ))}
                    local _ztci_a=${_ztci_input:$(( _ztci_index - 1 )):1}
                    local _ztci_b=${_ztci_input:_ztci_index:1}

                    ztc[commander:input]=$_ztci_left$_ztci_b$_ztci_a$_ztci_right
                fi

                if (( _ztci_cursor > 0 )); then (( ztc[commander:cursor]-- )); fi
                ;;

            # ╶╶╶╶╶ <ctrl-u> (delete from beginning to cursor) ╴╴╴╴╴

            ($'\x15')
                ztc[commander:yank]=${_ztci_input:0:_ztci_index}
                ztc[commander:input]=${_ztci_input:_ztci_index}
                ;;

            # ╶╶╶╶╶ <ctrl-v> (literal insert) ╴╴╴╴╴

            ($'\x16') ;; # disabled

            # ╶╶╶╶╶ <ctrl-w> (delete word) ╴╴╴╴╴

            ($'\x17')
                if (( _ztci_index != 0 )); then
                    local _ztci_left=''
                    local _ztci_word=''
                    ztc:words _ztci_input _ztci_index left _ztci_left _ztci_word

                    ztc[commander:yank]=$_ztci_word
                    ztc[commander:input]=$_ztci_left${_ztci_input:_ztci_index}
                fi ;;

            # ╶╶╶╶╶ <ctrl-x> (alternate between cursor and beginning) ╴╴╴╴╴

            ($'\x18')
                if (( _ztci_index != 0 )); then
                    ztc[commander:cursor:last]=$_ztci_cursor
                    ztc[commander:cursor]=${#_ztci_input}
                else
                    ztc[commander:cursor]=$ztc[commander:cursor:last]
                fi ;;

            # ╶╶╶╶╶ <ctrl-y> (paste) ╴╴╴╴╴

            ($'\x19') ztc[commander:input]=${_ztci_input:0:_ztci_index}$ztc[commander:yank]${_ztci_input:_ztci_index} ;;

            # ╶╶╶╶╶ insert key at cursor index ╴╴╴╴╴

            (*) ztc[commander:input]=${_ztci_input:0:_ztci_index}$_ztci_key${_ztci_input:_ztci_index} ;;

        esac

        ztc:cycle commander


    else # input is a shortcut

        case $_ztci_key in

            # ╶╶╶╶╶ clear status ╴╴╴╴╴

            ($'\e') ztc:commander:clear ;;

            # ╶╶╶╶╶ quit ╴╴╴╴╴

            (q|Q) ztc:clean ;;

            # ╶╶╶╶╶ command bar ╴╴╴╴╴

            (:|$'\n'|$'\r'|$'\xA'|$'\xD') ztc:commander:enter ;;

            # ╶╶╶╶╶ helper ╴╴╴╴╴

            (\?) ztc[commander:help]=1
                ztc:commander:enter '? '
                ;;
        esac

    fi

}

# ┌╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴┐
# ╎    parsing    ╎
# └╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶┘

function ztc:parse { # delegate command to correct parser
    local -U _ztcps_commands=()
    ztc:steal :commands _ztcps_commands

    if [[ -n $1 ]]; then
        local _ztcps_input=(${(As: :)1})
        local _ztcps_command=${(L)_ztcps_input[1]//\\/\\\\}

        case $_ztcps_command in
            (q|quit|exit)
                ztc:clean
                ;;
            (\?)

                ;;
            (*)
                if (( _ztcps_commands[(Ie)$_ztcps_command] )); then
                    ztc:parse:$_ztcps_command ${_ztcps_input:1}
                    ztc:commander:leave
                else
                    ztc:commander:leave "@i Unknown command: ${_ztcps_command//@/@@} @r"
                fi ;;
        esac
    else
        local _ztcps_list=()

        for _ztcps_command in $_ztcps_commands; do
            _ztcps_list+=("@u$_ztcps_command@r")
        done

        ztc:commander:leave "@i Available commands: ${(j:@i, :)_ztcps_list}@i @r"
    fi
}

function ztc:parse:date {
    local _ztcpsd_format=${(j: :)@}
    ztc[:date:format]=${_ztcpsd_format:-"%a %b %d %p"}
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
    local _ztcafd_time=''
    strftime -s _ztcafd_time "%l:%M:%S"

    local _ztcafd_mask=()
    local _ztcafd_staged=()


    # ───── create mask ─────

    for _ztcafd_character in ${(s::)_ztcafd_time}; do
        case $_ztcafd_character in
            (0) _ztcafd_mask=(111 101 101 101 111) ;;
            (1) _ztcafd_mask=(001 001 001 001 001) ;;
            (2) _ztcafd_mask=(111 001 111 100 111) ;;
            (3) _ztcafd_mask=(111 001 111 001 111) ;;
            (4) _ztcafd_mask=(101 101 111 001 001) ;;
            (5) _ztcafd_mask=(111 100 111 001 111) ;;
            (6) _ztcafd_mask=(111 100 111 101 111) ;;
            (7) _ztcafd_mask=(111 001 001 001 001) ;;
            (8) _ztcafd_mask=(111 101 111 101 111) ;;
            (9) _ztcafd_mask=(111 101 111 001 111) ;;
            (:) _ztcafd_mask=( 0   1   0   1   0 ) ;;
        esac

        _ztcafd_staged+=(${(j:@n:)_ztcafd_mask})
    done


    # ───── set mask key ─────

    local -U _ztcafd_key=()

    _ztcafd_key+=('0#@r  ')
    _ztcafd_key+=('1#@i  ')
    _ztcafd_key+=('.#@r ')

    ztc:stash face:digital:data:key _ztcafd_key


    # ───── interleave + flatten (with padding) ─────

    ztc:weave _ztcafd_staged
    for _ztcafd_i in {1..${#_ztcafd_staged}}; do _ztcafd_staged[$_ztcafd_i]=${_ztcafd_staged[$_ztcafd_i]//@n/.}; done


    # ───── save ─────

    ztc:stash face:digital:data _ztcafd_staged
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
    local _ztcad_date=''
    strftime -s _ztcad_date ${ztc[:date:format]//\%n/@n} # capture newlines

    ztc:stash date:data _ztcad_date
}


# ┌─────────────────┐
# │    commander    │
# └─────────────────┘

function ztc:order:commander {

    # ───── space declaration ─────

    ztc[commander:y]=$ztc[vh]
    ztc[commander:x]=0
    ztc[commander:h]=1
    ztc[commander:w]=$ztc[vw]


    # ───── extended properties ─────

    ztc[commander:overlay]=1


    # ───── custom properties ─────

    ztc[commander:active]=${ztc[commander:active]:-0}
    ztc[commander:help]=${ztc[commander:help]:-0}

    ztc[commander:prefix]=${ztc[commander:prefix]:-:}
    ztc[commander:status]=${ztc[commander:status]:-}
    ztc[commander:input]=${ztc[commander:input]:-}

    ztc[commander:history]=${ztc[commander:history]:-}
    ztc[commander:history:index]=${ztc[commander:history:index]:-0}
    ztc[commander:history:filter]=${ztc[commander:history:filter]:-}

    ztc[commander:yank]=${ztc[commander:yank]:-}
    ztc[commander:cursor]=${ztc[commander:cursor]:-0}
    ztc[commander:cursor:last]=${ztc[commander:cursor:last]:-0}

}

function ztc:alter:commander {

    # ───── import ─────

    local _ztcac_input=$ztc[commander:input]
    integer _ztcac_cursor=$ztc[commander:cursor]


    # ───── truncate overflows ─────

    integer _ztcac_index=$(( ${#_ztcac_input} - _ztcac_cursor ))
    integer _ztcac_bound=$(( ztc[commander:w] - ${#ztc[commander:prefix]} ))

    if (( ${#_ztcac_input} > _ztcac_bound )); then

        # ╶╶╶╶╶ split input at cursor ╴╴╴╴╴

        local _ztcac_left=${_ztcac_input:0:_ztcac_index}
        local _ztcac_right=${_ztcac_input:_ztcac_index}

        # ╶╶╶╶╶ determine truncate order + trim to fit ╴╴╴╴╴

        if (( ${#_ztcac_left} > ${#_ztcac_right} )); then
            if (( ${#_ztcac_right} > _ztcac_bound / 2 )); then _ztcac_right=${_ztcac_right:0:$(( (_ztcac_bound / 2) - 3 ))}...; fi
            if (( ${#_ztcac_left} + ${#_ztcac_right} > _ztcac_bound )); then _ztcac_left=...${_ztcac_left:$(( -_ztcac_bound + ${#_ztcac_right} + 3 ))}; fi
        else
            if (( ${#_ztcac_left} > _ztcac_bound / 2 )); then _ztcac_left=...${_ztcac_left:$(( -(_ztcac_bound / 2) + 3 ))}; fi
            if (( ${#_ztcac_right} + ${#_ztcac_left} > _ztcac_bound )); then _ztcac_right=${_ztcac_right:0:$(( _ztcac_bound - ${#_ztcac_left} - 3 ))}...; fi
        fi

        # ╶╶╶╶╶ reassemble + adjust cursor ╴╴╴╴╴

        _ztcac_input="$_ztcac_left$_ztcac_right"
        _ztcac_cursor=${#_ztcac_right}

    fi


    # ───── position cursor ─────

    local _ztcac_position

    if (( _ztcac_cursor > 0 )); then _ztcac_position="$ZTC_CSI${_ztcac_cursor}D"; fi


    # ───── export ─────

    local _ztcac_data=()

    if (( ztc[commander:active] )); then _ztcac_data=${ztc[commander:prefix]}${_ztcac_input//@/@@}$_ztcac_position$ZTC_CURSOR_SHOW
    else _ztcac_data=$ztc[commander:status]$ZTC_CURSOR_HIDE; fi

    ztc:stash commander:data _ztcac_data

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

    local _ztcsth_pouch=(${(AP)2})


    # ───── build stash ─────

    local _ztcsth_stash=()

    for _ztcsth_jewel in $_ztcsth_pouch; do

        # ╶╶╶╶╶ escape `@@` + split by `@n` ╴╴╴╴╴

        local _ztcsth_shiny=(${(As:@n:)_ztcsth_jewel//@@/@\(@\)})

        # ╶╶╶╶╶ escape `@` + add to stash ╴╴╴╴╴

        for _ztcsth_i in {1..${#_ztcsth_shiny}}; do _ztcsth_shiny[$_ztcsth_i]=${_ztcsth_shiny[$_ztcsth_i]//@/@@}; done

        _ztcsth_stash+=($_ztcsth_shiny)

    done


    # ───── export ─────

    ztc[$1]=${(j:@n:)_ztcsth_stash//@@\(@@\)/@\(@\)} # reduce `@@(@@)` into `@(@)`

}

function ztc:steal { # retrieve flattened array + undo flare escapement

    # ───── import ─────

    local _ztcstl_stash=(${(As:@@:)ztc[$1]})


    # ───── steal stash ─────

    local _ztcstl_theft=()
    local _ztcstl_prior=''

    if [[ ${ztc[$1]:0:2} == '@@' ]]; then _ztcstl_prior='@ '; fi # preserve leading `@`

    for _ztcstl_jewel in $_ztcstl_stash; do

        # ╶╶╶╶╶ split by `@n` ╴╴╴╴╴

        local _ztcstl_shiny=(${(As:@n:)_ztcstl_jewel})

        # ╶╶╶╶╶ insert escaped `@` ╴╴╴╴╴

        _ztcstl_prior=${_ztcstl_prior:+${_ztcstl_prior}@}
        _ztcstl_shiny[1]=${_ztcstl_prior/#@ }$_ztcstl_shiny[1] # compress `@ @` into `@`

        # ╶╶╶╶╶ prep for next jewel + add to theft ╴╴╴╴╴

        _ztcstl_prior=$_ztcstl_shiny[-1]
        shift -p _ztcstl_shiny

        _ztcstl_theft+=($_ztcstl_shiny)

    done


    # ───── export ─────

    _ztcstl_theft+=($_ztcstl_prior)
    : ${(AP)2::=$_ztcstl_theft}

}


# ┌──────────────┐
# │    weaver    │
# └──────────────┘

function ztc:weave { # ((1 1 1) (2 2 2) (3 3 3)) -> ((1 2 3) (1 2 3) (1 2 3))

    # ───── import ─────

    local _ztcwv_array=(${(AP)1})


    # ───── determine max sub-length ─────

    integer _ztcwv_length=0

    for _ztcwv_item in $_ztcwv_array; do
        local _ztcwv_sub=(${(As:@n:)_ztcwv_item})
        if (( $#_ztcwv_sub > _ztcwv_length )); then _ztcwv_length=${#_ztcwv_sub}; fi
    done


    # ───── weave ─────

    local _ztcwv_weaved=()

    for _ztcwv_i in {1..$_ztcwv_length}; do
        local _ztcwv_select=()

        for _ztcwv_item in $_ztcwv_array; do
            local _ztcwv_sub=(${(As:@n:)_ztcwv_item})
            _ztcwv_select+=($_ztcwv_sub[$_ztcwv_i])
        done

        _ztcwv_weaved+=(${(j:@n:)_ztcwv_select})
    done


    # ───── export ─────

    : ${(AP)1::=$_ztcwv_weaved}

}


# ┌─────────────┐
# │    words    │
# └─────────────┘

function ztc:words { # get closest word boundaries (ztc:words _input _index both _left _right _lword _rword)

    # ───── import ─────

    local _ztcw_input=${(P)1}
    local _ztcw_index=${(P)2}


    # ───── get closest word boundaries ─────

    # ╶╶╶╶╶ left ╴╴╴╴╴

    local _ztcw_left=${(*)${_ztcw_input:0:_ztcw_index}/%[[:space:]]#} # trim trailing spaces in left
    local _ztcw_word_left=${(MS)_ztcw_left##[[:graph:]]*[[:graph:]]}  # trim all whitespace in left
    if [[ -z $_ztcw_word_left ]]; then _ztcw_word_left=${(MS)_ztcw_left##[[:graph:]]}; fi

    if [[ ! $_ztcw_left =~ ' ' ]]; then _ztcw_left=''
    else _ztcw_left="${_ztcw_left%[[:space:]]*} "; fi  # remove last word in left

    # ╶╶╶╶╶ right ╴╴╴╴╴

    local _ztcw_right=${(*)${_ztcw_input:_ztcw_index}/#[[:space:]]#}   # trim leading spaces in right
    local _ztcw_word_right=${(MS)_ztcw_right##[[:graph:]]*[[:graph:]]} # trim all whitespace in right
    if [[ -z $_ztcw_word_right ]]; then _ztcw_word_right=${(MS)_ztcw_right##[[:graph:]]}; fi

    if [[ ! $_ztcw_right =~ ' ' ]]; then _ztcw_right=''
    else _ztcw_right=" ${_ztcw_right#*[[:space:]]}"; fi # remove first word in right

    # ╶╶╶╶╶ select words ╴╴╴╴╴

    _ztcw_word_left=${_ztcw_word_left##*[[:space:]]}   # select last word in left
    _ztcw_word_right=${_ztcw_word_right%%[[:space:]]*} # select first word in right


    # ───── export ─────

    case $3 in
        (left)
            if [[ -n $4 ]]; then : ${(P)4::=$_ztcw_left}; fi
            if [[ -n $5 ]]; then : ${(P)5::=$_ztcw_word_left}; fi
            ;;
        (right)
            if [[ -n $4 ]]; then : ${(P)4::=$_ztcw_right}; fi
            if [[ -n $5 ]]; then : ${(P)5::=$_ztcw_word_right}; fi
            ;;
        (both)
            if [[ -n $4 ]]; then : ${(P)4::=$_ztcw_left}; fi
            if [[ -n $5 ]]; then : ${(P)5::=$_ztcw_right}; fi
            if [[ -n $6 ]]; then : ${(P)6::=$_ztcw_word_left}; fi
            if [[ -n $7 ]]; then : ${(P)7::=$_ztcw_word_right}; fi
            ;;
    esac

}

function ztc:shift { # transform word at boundary (ztc:shift _input _index (T|C|L|U) _left _right _lword _rword)

    # ───── import ─────

    local _ztcws_input=${(P)1}
    local _ztcws_index=${(P)2}
    local _ztcws_left=${(P)4}
    local _ztcws_right=${(P)5}
    local _ztcws_word_left=${(P)6}
    local _ztcws_word_right=${(P)7}

    local _ztcws_shift=$3


    # ───── get word(s) ─────

    local _ztcws_bound_left=$(( _ztcws_index - ${#_ztcws_word_left} ))
    local _ztcws_bound_right=$(( ${#_ztcws_word_left} + ${#_ztcws_word_right} ))

    if [[ $_ztcws_shift == 'T' && "$_ztcws_word_left$_ztcws_word_right" == "${_ztcws_input:_ztcws_bound_left:_ztcws_bound_right}" ]]; then # cursor is inside word

        _ztcws_word_right=$_ztcws_word_left$_ztcws_word_right

        _ztcws_left=${(*)_ztcws_left/%[[:space:]]#}   # retrim trailing spaces
        _ztcws_word_left=${_ztcws_left##*[[:space:]]} # select new last word

        if [[ ! $_ztcws_left =~ ' ' ]]; then _ztcws_left=''
        else _ztcws_left="${_ztcws_left%[[:space:]]*} "; fi # remove new last word

    elif [[ $_ztcws_shift != 'T' && "$_ztcws_word_left$_ztcws_word_right" != "${_ztcws_input:_ztcws_bound_left:_ztcws_bound_right}" ]]; then # cursor is between words

        _ztcws_bound_left=$_ztcws_index
        _ztcws_bound_right=$(( ${#_ztcws_word_right} + 1 ))

        _ztcws_left="$_ztcws_left$_ztcws_word_left " # reattach

    fi


    # ───── shift word(s) + export ─────

    local _ztcws_word=''

    case $_ztcws_shift in

        # ╶╶╶╶╶ transpose ╴╴╴╴╴

        (T) if [[ -n $_ztcws_word_left ]]; then _ztcws_word_right="$_ztcws_word_right "; fi
            _ztcws_word=$_ztcws_word_right$_ztcws_word_left
            ;;

        # ╶╶╶╶╶ capitalize ╴╴╴╴╴

        (C) _ztcws_word=${(MS)${(C)_ztcws_input:_ztcws_bound_left:_ztcws_bound_right}##[[:graph:]]*[[:graph:]]} # trim whitespace
            if [[ -z $_ztcws_word ]]; then _ztcws_word=${(MS)${(C)_ztcws_input:_ztcws_bound_left:_ztcws_bound_right}##[[:graph:]]}; fi
            ;;

        # ╶╶╶╶╶ lowercase ╴╴╴╴╴

        (L) _ztcws_word=${(MS)${(L)_ztcws_input:_ztcws_bound_left:_ztcws_bound_right}##[[:graph:]]*[[:graph:]]} # trim whitespace
            if [[ -z $_ztcws_word ]]; then _ztcws_word=${(MS)${(L)_ztcws_input:_ztcws_bound_left:_ztcws_bound_right}##[[:graph:]]}; fi
            ;;

        # ╶╶╶╶╶ uppercase ╴╴╴╴╴

        (U) _ztcws_word=${(MS)${(U)_ztcws_input:_ztcws_bound_left:_ztcws_bound_right}##[[:graph:]]*[[:graph:]]} # trim whitespace
            if [[ -z $_ztcws_word ]]; then _ztcws_word=${(MS)${(U)_ztcws_input:_ztcws_bound_left:_ztcws_bound_right}##[[:graph:]]}; fi
            ;;

    esac

    : ${(P)4::=$_ztcws_left}
    : ${(P)5::=$_ztcws_right}
    : ${(P)6::=$_ztcws_word_left}
    : ${(P)7::=$_ztcws_word_right}

    : ${(P)1::=$_ztcws_left$_ztcws_word$_ztcws_right}

}


# ┌──────────────────────────────┐
# │ ░░▒▒▓▓██  DIRECTOR  ██▓▓▒▒░░ │
# └──────────────────────────────┘

function zsh_that_clock {
    trap 'ztc:clean 1' INT

    stty dsusp undef   # frees ^Y
    stty discard undef # frees ^O

    zmodload zsh/datetime

    typeset -A ztc=()

    ztc:plonk              # set config + init
    ztc:write $ZTC_INIT    # allocate screen space
    ztc:build && ztc:drive # zsh the clock!
    ztc:clean              # cleanup
}

zsh_that_clock
