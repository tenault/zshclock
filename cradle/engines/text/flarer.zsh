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

# ┌─────────────────────────────┐┌────────────┐┌╴╴╴╴╴╴╴╴╴╴╴╴╴╴┐
# │ ░░▒▒▓▓██  ENGINES  ██▓▓▒▒░░ ││    TEXT    │╎    FLARES    ╎
# └─────────────────────────────┘└────────────┘└╶╶╶╶╶╶╶╶╶╶╶╶╶╶┘

# ┌─────────────┐
# │    entry    │
# └─────────────┘

function ztc:engine:text:flare { # expand `@` flares

    # ───── import + setup ─────

    local _ztctf_input=${(Pj:@n:)1//@@/@\(@\)} # escape `@@`

    local _ztctf_flares=()
    ztc:gizmo:steal flares _ztctf_flares

    # ╶╶╶╶╶ retrieve guide ╴╴╴╴╴

    local -U _ztctf_flat=()
    local -A _ztctf_guide=()
    ztc:gizmo:steal flares:guide _ztctf_flat

    for _ztctf_item in $_ztctf_flat; do
        local -U _ztctf_entry=(${(As:#:)_ztctf_item})
        _ztctf_guide[$_ztctf_entry[1]]=$_ztctf_entry[2]
    done


    # ───── delegate flare to correct expander ─────

    for _ztctf_flare in $_ztctf_flares; do

        # ╶╶╶╶╶ skip flaring if out of flares ╴╴╴╴╴

        if [[ ! $_ztctf_input =~ @ ]]; then break; fi

        # ╶╶╶╶╶ link alias ╴╴╴╴╴

        local _ztctf_alias=$_ztctf_flare
        if (( ${${(k)_ztctf_guide}[(Ie)$_ztctf_flare]} )); then _ztctf_alias=$_ztctf_guide[$_ztctf_flare]; fi

        # ╶╶╶╶╶ wrap flare + expand ╴╴╴╴╴

        _ztctf_input=${_ztctf_input//@$_ztctf_flare/@\($_ztctf_flare\)}
        ztc:engine:text:flare:$_ztctf_alias _ztctf_input $_ztctf_flare

    done


    # ───── export ─────

    : ${(AP)2::=${(s:@n:)_ztctf_input}}

}


# ┌──────────────┐
# │    flares    │
# └──────────────┘

function ztc:engine:text:flare:newline   { : ${(P)1::=${(P)1//@\($2\)/@n}}                  }
function ztc:engine:text:flare:reset     { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_RESET}}     }
function ztc:engine:text:flare:bold      { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_BOLD}}      }
function ztc:engine:text:flare:underline { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_UNDERLINE}} }
function ztc:engine:text:flare:invert    { : ${(P)1::=${(P)1//@\($2\)/$ZTC_TEXT_INVERT}}    }
