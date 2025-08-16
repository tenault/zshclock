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

# ┌─────────────────────────────┐┌──────────────┐
# │ ░░▒▒▓▓██  ENGINES  ██▓▓▒▒░░ ││    PARSER    │
# └─────────────────────────────┘└──────────────┘

# ┌───────────────┐
# │    parsers    │
# └───────────────┘

function ztc:engine:parse:date {
    local _ztcpsd_format=${(j: :)@}
    ztc[:date:format]=${_ztcpsd_format:-"%a %b %d %p"}
    ztc:cassette:core:cycle date
}


# ┌─────────────┐
# │    entry    │
# └─────────────┘

function ztc:engine:parse { # delegate command to correct parser
    local -U _ztcps_commands=()
    ztc:gizmo:steal :commands _ztcps_commands

    if [[ -n $1 ]]; then
        local _ztcps_input=(${(As: :)1})
        local _ztcps_command=${(L)_ztcps_input[1]//\\/\\\\}

        case $_ztcps_command in
            (q|quit|exit)
                ztc:core:clean
                ;;
            (\?)
                # help function goes here
                ;;
            (*)
                if (( _ztcps_commands[(Ie)$_ztcps_command] )); then
                    ztc:engine:parse:$_ztcps_command ${_ztcps_input:1}
                    ztc:cassette:commander:leave
                else
                    ztc:cassette:commander:leave "@i Unknown command: ${_ztcps_command//@/@@} @r"
                fi ;;
        esac
    else
        local _ztcps_list=()

        for _ztcps_command in $_ztcps_commands; do
            _ztcps_list+=("@u$_ztcps_command@r")
        done

        ztc:cassette:commander:leave "@i Available commands: ${(j:@i, :)_ztcps_list}@i @r"
    fi
}
