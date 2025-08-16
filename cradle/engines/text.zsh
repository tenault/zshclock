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

# ┌─────────────────────────────┐┌────────────┐
# │ ░░▒▒▓▓██  ENGINES  ██▓▓▒▒░░ ││    TEXT    │
# └─────────────────────────────┘└────────────┘

# ┌──────────────┐
# │    flares    │
# └──────────────┘

function ztc:engine:flare:newline   { : ${(P)1::=${(P)1//@\($2\)/@n}}                  }
function ztc:engine:flare:reset     { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_RESET}}     }
function ztc:engine:flare:bold      { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_BOLD}}      }
function ztc:engine:flare:underline { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_UNDERLINE}} }
function ztc:engine:flare:invert    { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_INVERT}}    }


# ┌─────────────┐
# │    entry    │
# └─────────────┘

function ztc:engine:flare { # expand `@` flares

    # ───── import + setup ─────

    local _ztcf_input=${(Pj:@n:)1//@@/@\(@\)} # escape `@@`

    local _ztcf_flares=()
    ztc:gizmo:steal flares _ztcf_flares

    # ╶╶╶╶╶ retrieve guide ╴╴╴╴╴

    local -U _ztcf_flat=()
    local -A _ztcf_guide=()
    ztc:gizmo:steal flares:guide _ztcf_flat

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
        ztc:engine:flare:$_ztcf_alias _ztcf_input $_ztcf_flare

    done


    # ───── export ─────

    : ${(AP)2::=${(s:@n:)_ztcf_input}}

}
