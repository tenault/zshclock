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

# ┌────────────────────────────┐┌────────────┐
# │ ░░▒▒▓▓██  GIZMOS  ██▓▓▒▒░░ ││    CORE    │
# └────────────────────────────┘└────────────┘

# ┌─────────────┐
# │    stash    │
# └─────────────┘

function ztc:gizmo:stash { # escape flares + flatten array for storage

    # ───── import ─────

    local _ztcgz_pouch=(${(AP)2})


    # ───── build stash ─────

    local _ztcgz_stash=()

    for _ztcgz_jewel in $_ztcgz_pouch; do

        # ╶╶╶╶╶ escape `@@` + split by `@n` ╴╴╴╴╴

        local _ztcgz_shiny=(${(As:@n:)_ztcgz_jewel//@@/@\(@\)})

        # ╶╶╶╶╶ escape `@` + add to stash ╴╴╴╴╴

        for _ztcgz_i in {1..${#_ztcgz_shiny}}; do _ztcgz_shiny[$_ztcgz_i]=${_ztcgz_shiny[$_ztcgz_i]//@/@@}; done

        _ztcgz_stash+=($_ztcgz_shiny)

    done


    # ───── export ─────

    ztc[$1]=${(j:@n:)_ztcgz_stash//@@\(@@\)/@\(@\)} # reduce `@@(@@)` into `@(@)`

}


# ┌─────────────┐
# │    steal    │
# └─────────────┘

function ztc:gizmo:steal { # retrieve flattened array + undo flare escapement

    # ───── import ─────

    local _ztcgz_stash=(${(As:@@:)ztc[$1]})


    # ───── steal stash ─────

    local _ztcgz_theft=()
    local _ztcgz_prior=''

    if [[ ${ztc[$1]:0:2} == '@@' ]]; then _ztcgz_prior='@ '; fi # preserve leading `@`

    for _ztcgz_jewel in $_ztcgz_stash; do

        # ╶╶╶╶╶ split by `@n` ╴╴╴╴╴

        local _ztcgz_shiny=(${(As:@n:)_ztcgz_jewel})

        # ╶╶╶╶╶ insert escaped `@` ╴╴╴╴╴

        _ztcgz_prior=${_ztcgz_prior:+${_ztcgz_prior}@}
        _ztcgz_shiny[1]=${_ztcgz_prior/#@ }$_ztcgz_shiny[1] # compress `@ @` into `@`

        # ╶╶╶╶╶ prep for next jewel + add to theft ╴╴╴╴╴

        _ztcgz_prior=$_ztcgz_shiny[-1]
        shift -p _ztcgz_shiny

        _ztcgz_theft+=($_ztcgz_shiny)

    done


    # ───── export ─────

    _ztcgz_theft+=($_ztcgz_prior)
    : ${(AP)2::=$_ztcgz_theft}

}


# ┌─────────────┐
# │    weave    │
# └─────────────┘

function ztc:gizmo:weave { # ((1 1 1) (2 2 2) (3 3 3)) -> ((1 2 3) (1 2 3) (1 2 3))

    # ───── import ─────

    local _ztcgz_array=(${(AP)1})


    # ───── determine max sub-length ─────

    integer _ztcgz_length=0

    for _ztcgz_item in $_ztcgz_array; do
        local _ztcgz_sub=(${(As:@n:)_ztcgz_item})
        if (( $#_ztcgz_sub > _ztcgz_length )); then _ztcgz_length=${#_ztcgz_sub}; fi
    done


    # ───── weave ─────

    local _ztcgz_weaved=()

    for _ztcgz_i in {1..$_ztcgz_length}; do
        local _ztcgz_select=()

        for _ztcgz_item in $_ztcgz_array; do
            local _ztcgz_sub=(${(As:@n:)_ztcgz_item})
            _ztcgz_select+=($_ztcgz_sub[$_ztcgz_i])
        done

        _ztcgz_weaved+=(${(j:@n:)_ztcgz_select})
    done


    # ───── export ─────

    : ${(AP)1::=$_ztcgz_weaved}

}
