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

# ┌──────────────────────────┐
# │ ░░▒▒▓▓██  CORE  ██▓▓▒▒░░ │
# └──────────────────────────┘

# ┌─────────────┐
# │    build    │
# └─────────────┘

function ztc:core:build { # set view area + build components
    ztc[vh]=$LINES
    ztc[vw]=$COLUMNS

    local _ztcz_components=()
    ztc:gizmo:steal components _ztcz_components

    for _ztcz_name in $_ztcz_components; do "ztc:component:${_ztcz_name}:order"; done

    ztc:cassette:core:cycle
}


# ┌─────────────┐
# │    clean    │
# └─────────────┘

function ztc:core:clean { # dissolve clock + restore terminal state
    integer _ztcz_code=${1:-0}
    ztc:core:write $ZTC_CURSOR_SHOW $ZTC_EXIT

    stty dsusp '^Y'   # restore delayed suspend
    stty discard '^O' # restore discard

    exit $_ztcz_code
}


# ┌─────────────┐
# │    drive    │
# └─────────────┘

function ztc:core:drive { # clock go vroom vroom
    float _ztcz_epoch=$EPOCHREALTIME
    integer _ztcz_epsilon=0

    while true; do
        ztc:engine:text:input # handle inputs
        ztc:cassette:core:align # check for resizes

        # clear stale statuses
        if [[ -n ztc[commander:status] && ${$(( (EPOCHREALTIME - ztc[commander:status:epoch]) * 1000 ))%%.*} -gt ztc[:rate:status] ]]; then ztc:cassette:commander:clear; fi

        # repaint clock
        integer _ztcz_duration=${$(( (EPOCHREALTIME - _ztcz_epoch) * 1000 ))%%.*}
        if (( _ztcz_duration >= ( ztc[:rate:refresh] - _ztcz_epsilon ) )); then

            ztc:cassette:core:cycle # update component data + repaint

            _ztcz_epoch=$EPOCHREALTIME
            _ztcz_epsilon=$(( ( _ztcz_duration - (ztc[:rate:refresh] - _ztcz_epsilon) ) % ztc[:rate:refresh] ))

        fi
    done
}


# ┌─────────────┐
# │    write    │
# └─────────────┘

function ztc:core:write { print -n ${(j::)@} } # output to terminal
