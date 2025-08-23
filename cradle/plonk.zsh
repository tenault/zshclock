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

# ┌───────────────────────────┐
# │ ░░▒▒▓▓██  PLONK  ██▓▓▒▒░░ │
# └───────────────────────────┘

# ┌─────────────┐
# │    entry    │
# └─────────────┘

function ztc:plonk { # set config settings + register parts

    # ───── set defaults ─────

    ztc[:date:format]="%a %b %d %p"
    ztc[:rate:input]=50
    ztc[:rate:refresh]=1000
    ztc[:rate:status]=5000


    # ───── register ─────

    ztc:plonk:flares
    ztc:plonk:commands
    ztc:plonk:components

}


# ┌────────────────┐
# │    commands    │
# └────────────────┘

function ztc:plonk:commands {

    # ───── register commands ─────

    local -U _ztcpl_commands=(date)
    ztc:gizmo:stash :commands _ztcpl_commands

}


# ┌──────────────────┐
# │    components    │
# └──────────────────┘

function ztc:plonk:components {

    # ───── register components ─────

    local -U _ztcpl_components=(face:digital date commander)
    ztc:gizmo:stash components _ztcpl_components

}


# ┌──────────────┐
# │    flares    │
# └──────────────┘

function ztc:plonk:flares {

    # ───── register flares ─────

    local -U _ztcpl_flares=(newline reset bold underline invert)
    local -A _ztcpl_guide=()

    # ╶╶╶╶╶ generate short flares ╴╴╴╴╴

    local -A _ztcpl_route=()

    for _ztcpl_i in {1..${#_ztcpl_flares}}; do # loop through all flares
        local _ztcpl_length=${#_ztcpl_flares[$_ztcpl_i]}
        _ztcpl_route[$_ztcpl_length]="$_ztcpl_route[$_ztcpl_length]@$_ztcpl_flares[$_ztcpl_i]"

        for _ztcpl_j in {1..$_ztcpl_length}; do # loop through each letter of flare
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

    ztc:gizmo:stash flares:guide _ztcpl_flat

    # ╶╶╶╶╶ rebuild flare array + sort descending ╴╴╴╴╴

    _ztcpl_flares=()
    for _ztcpl_key in ${(Ok)_ztcpl_route}; do _ztcpl_flares+=(${(As:@:)_ztcpl_route[$_ztcpl_key]}); done

    ztc:gizmo:stash flares _ztcpl_flares

}
