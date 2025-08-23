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

function ztc:engine:text:parse:date {
    local _ztctp_format=${(j: :)@}
    ztc[:date:format]=${_ztctp_format:-"%a %b %d %p"}
    ztc:cassette:paint:cycle date
}


# ┌─────────────┐
# │    entry    │
# └─────────────┘

function ztc:engine:text:parse { # delegate command to correct parser
    local -U _ztctp_commands=()
    ztc:gizmo:steal :commands _ztctp_commands

    if [[ -n $1 ]]; then
        local _ztctp_input=(${(As: :)1})
        local _ztctp_command=${(L)_ztctp_input[1]//\\/\\\\}

        case $_ztctp_command in
            (q|quit|exit)
                ztc:core:clean
                ;;
            (\?)
                # help function goes here
                ;;
            (*)
                if (( _ztctp_commands[(Ie)$_ztctp_command] )); then
                    ztc:engine:text:parse:$_ztctp_command ${_ztctp_input:1}
                    ztc:cassette:commander:leave
                else
                    ztc:cassette:commander:leave "@i Unknown command: ${_ztctp_command//@/@@} @r"
                fi ;;
        esac
    else
        local _ztctp_list=()

        for _ztctp_command in $_ztctp_commands; do
            _ztctp_list+=("@u$_ztctp_command@r")
        done

        ztc:cassette:commander:leave "@i Available commands: ${(j:@i, :)_ztctp_list}@i @r"
    fi
}
