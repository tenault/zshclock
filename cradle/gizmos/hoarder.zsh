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

# ┌────────────────────────────┐┌───────────────┐
# │ ░░▒▒▓▓██  GIZMOS  ██▓▓▒▒░░ ││    HOARDER    │
# └────────────────────────────┘└───────────────┘

# ┌─────────────┐
# │    stash    │
# └─────────────┘

function ztc:gizmo:stash { # escape flares + flatten array for storage

    # ───── import ─────

    local _ztcst_pouch=(${(AP)2})


    # ───── build stash ─────

    local _ztcst_stash=()

    for _ztcst_jewel in $_ztcst_pouch; do

        # ╶╶╶╶╶ escape `@@` + split by `@n` ╴╴╴╴╴

        local _ztcst_shiny=(${(As:@n:)_ztcst_jewel//@@/@\(@\)})

        # ╶╶╶╶╶ escape `@` + add to stash ╴╴╴╴╴

        for _ztcst_i in {1..${#_ztcst_shiny}}; do _ztcst_shiny[$_ztcst_i]=${_ztcst_shiny[$_ztcst_i]//@/@@}; done

        _ztcst_stash+=($_ztcst_shiny)

    done


    # ───── export ─────

    ztc[$1]=${(j:@n:)_ztcst_stash//@@\(@@\)/@\(@\)} # reduce `@@(@@)` into `@(@)`

}


# ┌─────────────┐
# │    steal    │
# └─────────────┘

function ztc:gizmo:steal { # retrieve flattened array + undo flare escapement

    # ───── import ─────

    local _ztcst_stash=(${(As:@@:)ztc[$1]})


    # ───── steal stash ─────

    local _ztcst_theft=()
    local _ztcst_prior=''

    if [[ ${ztc[$1]:0:2} == '@@' ]]; then _ztcst_prior='@ '; fi # preserve leading `@`

    for _ztcst_jewel in $_ztcst_stash; do

        # ╶╶╶╶╶ split by `@n` ╴╴╴╴╴

        local _ztcst_shiny=(${(As:@n:)_ztcst_jewel})

        # ╶╶╶╶╶ insert escaped `@` ╴╴╴╴╴

        _ztcst_prior=${_ztcst_prior:+${_ztcst_prior}@}
        _ztcst_shiny[1]=${_ztcst_prior/#@ }$_ztcst_shiny[1] # compress `@ @` into `@`

        # ╶╶╶╶╶ prep for next jewel + add to theft ╴╴╴╴╴

        _ztcst_prior=$_ztcst_shiny[-1]
        shift -p _ztcst_shiny

        _ztcst_theft+=($_ztcst_shiny)

    done


    # ───── export ─────

    _ztcst_theft+=($_ztcst_prior)
    : ${(AP)2::=$_ztcst_theft}

}
