#!/usr/bin/env zsh

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃ ┌────────────────────────────────────────────────────────────────────────────────────────────┐ ┃
# ┃ ├────────────────────────────────────────────────────────────────────────────────────────────┤ ┃
# ┃ ├──────────┐                     dP                dP                   dP        ┌──────────┤ ┃
# ┃ ├──────────┤                     88                88                   88        ├──────────┤ ┃
# ┃ ├──────────┤   d888888b .d8888b. 88d888b. .d8888b. 88 .d8888b. .d8888b. 88  .dP   ├──────────┤ ┃
# ┃ ├──────────┤      .d8P' Y8ooooo. 88'  `88 88'  `"" 88 88'  `88 88'  `"" 88888"    ├──────────┤ ┃
# ┃ ├──────────┤    .Y8P          88 88    88 88.  ... 88 88.  .88 88.  ... 88 `8b.   ├──────────┤ ┃
# ┃ ├──────────┤   d888888P `88888P' dP    dP `88888P' dP `88888P' `88888P' dP  `YP   ├──────────┤ ┃
# ┃ ├──────────┘                                                                      └──────────┤ ┃
# ┃ ├────────────────────────────────────────────────────────────────────────────────────────────┤ ┃
# ┃ ├────────────────────────────────────────────────────────────────────────────────────────────┤ ┃
# ┃ ├────────────────────┐                                                 ┌─────────────────────┤ ┃
# ┃ ├────────────────────┤   copyright (c) 2025 Malakai Smith (@tenault)   ├─────────────────────┤ ┃
# ┃ ├────────────────────┤   originally forked from @octobanana/peaclock   ├─────────────────────┤ ┃
# ┃ ├────────────────────┘                                                 └─────────────────────┤ ┃
# ┃ ├────────────────────────────────────────────────────────────────────────────────────────────┤ ┃
# ┃ ├────────────────────────────────────────────────────────────────────────────────────────────┤ ┃
# ┃ ├────────┐                                                                         ┌─────────┤ ┃
# ┃ ├────────┤   This Source Code Form is subject to the terms of the Mozilla Public   ├─────────┤ ┃
# ┃ ├────────┤   License, v. 2.0. If a copy of the MPL was not distributed with this   ├─────────┤ ┃
# ┃ ├────────┤   file, you can obtain one at https://mozilla.org/MPL/2.0               ├─────────┤ ┃
# ┃ ├────────┘                                                                         └─────────┤ ┃
# ┃ ├────────────────────────────────────────────────────────────────────────────────────────────┤ ┃
# ┃ └────────────────────────────────────────────────────────────────────────────────────────────┘ ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

# ┌───────────────────────────────┐┌─────────────────┐
# │ ░░▒▒▓▓██  CASSETTES  ██▓▓▒▒░░ ││    COMMANDER    │
# └───────────────────────────────┘└─────────────────┘

# ┌─────────────┐
# │    clear    │
# └─────────────┘

function ztc:cassette:commander:clear {
    ztc[commander:status]=''
    ztc:cassette:core:cycle commander
}


# ┌─────────────┐
# │    enter    │
# └─────────────┘

function ztc:cassette:commander:enter {
    ztc[commander:active]=1
    ztc[commander:prefix]=${1:-:}

    ztc:cassette:core:cycle commander
}

# ┌─────────────┐
# │    leave    │
# └─────────────┘

function ztc:cassette:commander:leave {
    ztc[commander:status]=$1
    ztc[commander:status:epoch]=$EPOCHREALTIME

    ztc[commander:active]=0
    ztc[commander:help]=0

    ztc[commander:history:index]=0
    ztc[commander:history:filter]=''

    ztc[commander:input]=''
    ztc[commander:cursor]=0
}


# ┌─────────────┐
# │    serve    │
# └─────────────┘

function ztc:cassette:commander:serve { # roll through history

    # ───── import + setup ─────

    local _ztccmd_direction=$1
    local _ztccmd_filter=${2:+${ztc[commander:history:filter]:-$2}} # retrieve previous filter if set
    ztc[commander:history:filter]=$_ztccmd_filter

    integer _ztccmd_history_index=$ztc[commander:history:index]
    local -U _ztccmd_history=()
    ztc:gizmo:steal commander:history _ztccmd_history


    # ───── reset cursor + retrieve entry ─────

    ztc[commander:cursor]=0

    if (( ${#_ztccmd_history} > 0 )); then
        integer _ztccmd_index=0
        local _ztccmd_entry=''

        # ╶╶╶╶╶ check entry(s) against filter ╴╴╴╴╴

        while true; do
            case $_ztccmd_direction in
                (previous) if (( _ztccmd_history_index < ${#_ztccmd_history} )); then (( _ztccmd_history_index++ )); fi ;;
                (next)     if (( _ztccmd_history_index > 0 )); then (( _ztccmd_history_index-- )); fi ;;
                (first)    _ztccmd_history_index=${#_ztccmd_history} ;;
                (last)     _ztccmd_history_index=1 ;;
            esac

            _ztccmd_index=$(( ${#_ztccmd_history} - _ztccmd_history_index + 1 ))
            _ztccmd_entry=$_ztccmd_history[$_ztccmd_index]

            [[ -n $_ztccmd_filter && $_ztccmd_history_index -ne ${#_ztccmd_history} && $_ztccmd_history_index -ne 0 ]] || break # exit loop if not filtering or no matches at bounds
            if [[ $_ztccmd_entry =~ $_ztccmd_filter ]]; then _ztccmd_filter=''; break; fi # entry matches filter
        done

        # ╶╶╶╶╶ export ╴╴╴╴╴

        if (( $_ztccmd_history_index == 0 )); then
            ztc[commander:input]=$_ztccmd_filter
            ztc[commander:history:index]=0
            ztc[commander:history:filter]=''
        fi

        if [[ -z $_ztccmd_filter ]]; then
            ztc[commander:input]=$_ztccmd_entry
            ztc[commander:history:index]=$_ztccmd_history_index
        fi
    fi

}


# ┌─────────────┐
# │    shift    │
# └─────────────┘

function ztc:cassette:commander:shift { # transform closest word
    local _ztccmd_input=${(P)1}
    local _ztccmd_index=${(P)2}

    local _ztccmd_left=''
    local _ztccmd_right=''
    local _ztccmd_word_left=''
    local _ztccmd_word_right=''

    ztc:gizmo:words _ztccmd_input _ztccmd_index both _ztccmd_left _ztccmd_right _ztccmd_word_left _ztccmd_word_right
    ztc:gizmo:shift _ztccmd_input _ztccmd_index $3 _ztccmd_left _ztccmd_right _ztccmd_word_left _ztccmd_word_right

    ztc[commander:input]=$_ztccmd_input
    ztc[commander:cursor]=${#_ztccmd_right}
}


# ┌─────────────┐
# │    yield    │
# └─────────────┘

function ztc:cassette:commander:yield { # submit and process input

    # ───── import + setup ─────

    local _ztccmd_input=$1
    local _ztccmd_history_index=$ztc[commander:history:index]

    local -U _ztccmd_history=()
    ztc:gizmo:steal commander:history _ztccmd_history


    # ───── write to history ─────

    local _ztccmd_entry_index=$_ztccmd_history[(I)$_ztccmd_input]
    if (( _ztccmd_entry_index != 0 )); then _ztccmd_history[$_ztccmd_entry_index]=(); fi # remove old entry
    _ztccmd_history+=($_ztccmd_input) # append new entry

    ztc:gizmo:stash commander:history _ztccmd_history


    # ───── trim whitespace + parse ─────

    local _ztccmd_parse=${(MS)_ztccmd_input##[[:graph:]]*[[:graph:]]}
    if [[ -z $_ztccmd_parse ]]; then _ztccmd_parse=${(MS)_ztccmd_input##[[:graph:]]}; fi

    ztc:parse $_ztccmd_parse

}
