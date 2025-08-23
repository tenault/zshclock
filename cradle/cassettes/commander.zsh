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
    ztc:cassette:paint:cycle commander
}


# ┌─────────────┐
# │    enter    │
# └─────────────┘

function ztc:cassette:commander:enter {
    ztc[commander:active]=1
    ztc[commander:prefix]=${1:-:}

    ztc:cassette:paint:cycle commander
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

    local _ztccc_direction=$1
    local _ztccc_filter=${2:+${ztc[commander:history:filter]:-$2}} # retrieve previous filter if set
    ztc[commander:history:filter]=$_ztccc_filter

    integer _ztccc_history_index=$ztc[commander:history:index]
    local -U _ztccc_history=()
    ztc:gizmo:steal commander:history _ztccc_history


    # ───── reset cursor + retrieve entry ─────

    ztc[commander:cursor]=0

    if (( ${#_ztccc_history} > 0 )); then
        integer _ztccc_index=0
        local _ztccc_entry=''

        # ╶╶╶╶╶ check entry(s) against filter ╴╴╴╴╴

        while true; do
            case $_ztccc_direction in
                (previous) if (( _ztccc_history_index < ${#_ztccc_history} )); then (( _ztccc_history_index++ )); fi ;;
                (next)     if (( _ztccc_history_index > 0 )); then (( _ztccc_history_index-- )); fi ;;
                (first)    _ztccc_history_index=${#_ztccc_history} ;;
                (last)     _ztccc_history_index=1 ;;
            esac

            _ztccc_index=$(( ${#_ztccc_history} - _ztccc_history_index + 1 ))
            _ztccc_entry=$_ztccc_history[$_ztccc_index]

            [[ -n $_ztccc_filter && $_ztccc_history_index -ne ${#_ztccc_history} && $_ztccc_history_index -ne 0 ]] || break # exit loop if not filtering or no matches at bounds
            if [[ $_ztccc_entry =~ $_ztccc_filter ]]; then _ztccc_filter=''; break; fi # entry matches filter
        done

        # ╶╶╶╶╶ export ╴╴╴╴╴

        if (( $_ztccc_history_index == 0 )); then
            ztc[commander:input]=$_ztccc_filter
            ztc[commander:history:index]=0
            ztc[commander:history:filter]=''
        fi

        if [[ -z $_ztccc_filter ]]; then
            ztc[commander:input]=$_ztccc_entry
            ztc[commander:history:index]=$_ztccc_history_index
        fi
    fi

}
