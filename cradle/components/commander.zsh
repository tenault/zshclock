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

# ┌────────────────────────────────┐┌─────────────────┐
# │ ░░▒▒▓▓██  COMPONENTS  ██▓▓▒▒░░ ││    COMMANDER    │
# └────────────────────────────────┘└─────────────────┘

# ┌─────────────┐
# │    order    │
# └─────────────┘

function ztc:component:commander:order {

    # ───── space declaration ─────

    ztc[commander:y]=$ztc[vh]
    ztc[commander:x]=0
    ztc[commander:h]=1
    ztc[commander:w]=$ztc[vw]


    # ───── extended properties ─────

    ztc[commander:overlay]=1


    # ───── custom properties ─────

    ztc[commander:active]=${ztc[commander:active]:-0}
    ztc[commander:help]=${ztc[commander:help]:-0}

    ztc[commander:prefix]=${ztc[commander:prefix]:-:}
    ztc[commander:status]=${ztc[commander:status]:-}
    ztc[commander:input]=${ztc[commander:input]:-}

    ztc[commander:history]=${ztc[commander:history]:-}
    ztc[commander:history:index]=${ztc[commander:history:index]:-0}
    ztc[commander:history:filter]=${ztc[commander:history:filter]:-}

    ztc[commander:yank]=${ztc[commander:yank]:-}
    ztc[commander:cursor]=${ztc[commander:cursor]:-0}
    ztc[commander:cursor:last]=${ztc[commander:cursor:last]:-0}

}


# ┌─────────────┐
# │    alter    │
# └─────────────┘

function ztc:component:commander:alter {

    # ───── import ─────

    local _ztcac_input=$ztc[commander:input]
    integer _ztcac_cursor=$ztc[commander:cursor]


    # ───── truncate overflows ─────

    integer _ztcac_index=$(( ${#_ztcac_input} - _ztcac_cursor ))
    integer _ztcac_bound=$(( ztc[commander:w] - ${#ztc[commander:prefix]} ))

    if (( ${#_ztcac_input} > _ztcac_bound )); then

        # ╶╶╶╶╶ split input at cursor ╴╴╴╴╴

        local _ztcac_left=${_ztcac_input:0:_ztcac_index}
        local _ztcac_right=${_ztcac_input:_ztcac_index}

        # ╶╶╶╶╶ determine truncate order + trim to fit ╴╴╴╴╴

        if (( ${#_ztcac_left} > ${#_ztcac_right} )); then
            if (( ${#_ztcac_right} > _ztcac_bound / 2 )); then _ztcac_right=${_ztcac_right:0:$(( (_ztcac_bound / 2) - 3 ))}...; fi
            if (( ${#_ztcac_left} + ${#_ztcac_right} > _ztcac_bound )); then _ztcac_left=...${_ztcac_left:$(( -_ztcac_bound + ${#_ztcac_right} + 3 ))}; fi
        else
            if (( ${#_ztcac_left} > _ztcac_bound / 2 )); then _ztcac_left=...${_ztcac_left:$(( -(_ztcac_bound / 2) + 3 ))}; fi
            if (( ${#_ztcac_right} + ${#_ztcac_left} > _ztcac_bound )); then _ztcac_right=${_ztcac_right:0:$(( _ztcac_bound - ${#_ztcac_left} - 3 ))}...; fi
        fi

        # ╶╶╶╶╶ reassemble + adjust cursor ╴╴╴╴╴

        _ztcac_input="$_ztcac_left$_ztcac_right"
        _ztcac_cursor=${#_ztcac_right}

    fi


    # ───── position cursor ─────

    local _ztcac_position=''
    if (( _ztcac_cursor > 0 )); then _ztcac_position="$ZTC_CSI${_ztcac_cursor}D"; fi


    # ───── export ─────

    local _ztcac_data=()

    if (( ztc[commander:active] )); then _ztcac_data=${ztc[commander:prefix]}${_ztcac_input//@/@@}$_ztcac_position$ZTC_CURSOR_SHOW
    else _ztcac_data=$ztc[commander:status]$ZTC_CURSOR_HIDE; fi

    ztc:gizmo:stash commander:data _ztcac_data

}
