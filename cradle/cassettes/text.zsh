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

# ┌───────────────────────────────┐┌────────────┐
# │ ░░▒▒▓▓██  CASSETTES  ██▓▓▒▒░░ ││    TEXT    │
# └───────────────────────────────┘└────────────┘

# ┌─────────────┐
# │    shift    │
# └─────────────┘

function ztc:cassette:text:shift { # transform closest word
    local _ztcct_input=${(P)1}
    local _ztcct_index=${(P)2}

    local _ztcct_left=''
    local _ztcct_right=''
    local _ztcct_word_left=''
    local _ztcct_word_right=''

    ztc:gizmo:words _ztcct_input _ztcct_index both _ztcct_left _ztcct_right _ztcct_word_left _ztcct_word_right
    ztc:gizmo:shift _ztcct_input _ztcct_index $3 _ztcct_left _ztcct_right _ztcct_word_left _ztcct_word_right

    ztc[commander:input]=$_ztcct_input
    ztc[commander:cursor]=${#_ztcct_right}
}


# ┌─────────────┐
# │    yield    │
# └─────────────┘

function ztc:cassette:text:yield { # submit and process input

    # ───── import + setup ─────

    local _ztcct_input=$1
    local _ztcct_history_index=$ztc[commander:history:index]

    local -U _ztcct_history=()
    ztc:gizmo:steal commander:history _ztcct_history


    # ───── write to history ─────

    local _ztcct_entry_index=$_ztcct_history[(I)$_ztcct_input]
    if (( _ztcct_entry_index != 0 )); then _ztcct_history[$_ztcct_entry_index]=(); fi # remove old entry
    _ztcct_history+=($_ztcct_input) # append new entry

    ztc:gizmo:stash commander:history _ztcct_history


    # ───── trim whitespace + parse ─────

    local _ztcct_parse=${(MS)_ztcct_input##[[:graph:]]*[[:graph:]]}
    if [[ -z $_ztcct_parse ]]; then _ztcct_parse=${(MS)_ztcct_input##[[:graph:]]}; fi

    ztc:engine:text:parse $_ztcct_parse

}
