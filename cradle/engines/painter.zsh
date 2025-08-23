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

# ┌─────────────────────────────┐┌───────────────┐
# │ ░░▒▒▓▓██  ENGINES  ██▓▓▒▒░░ ││    PAINTER    │
# └─────────────────────────────┘└───────────────┘

# ┌───────────────┐
# │    painter    │
# └───────────────┘

function ztc:engine:paint { # translate component data for rendering

    local -U _ztcp_components=()
    ztc:gizmo:steal components _ztcp_components

    local -U _ztcp_touch=(${@:-$_ztcp_components})


    # ───── reset bounds ─────

    ztc[paint:my]=$ztc[vh] # min-y
    ztc[paint:mx]=$ztc[vw] # min-x
    ztc[paint:ym]=0        # y-max
    ztc[paint:xm]=0        # x-max

    ztc[paint:h]=0
    ztc[paint:w]=0


    # ───── get component properties + cache ─────

    for _ztcp_name in $_ztcp_components; do

        integer _ztcp_y=0
        integer _ztcp_x=0
        integer _ztcp_h=0
        integer _ztcp_w=0

        if (( _ztcp_touch[(Ie)$_ztcp_name] )); then # flare data + calculate dimensions

            local _ztcp_data=()
            ztc:gizmo:steal ${_ztcp_name}:data _ztcp_data

            # ╶╶╶╶╶ translate data mask ╴╴╴╴╴

            if [[ $ztc[${_ztcp_name}:data:format] == 'masked' ]]; then
                local -U _ztcp_key=()
                ztc:gizmo:steal ${_ztcp_name}:data:key _ztcp_key

                for _ztcp_k in $_ztcp_key; do
                    local _ztcp_entry=(${(As:#:)_ztcp_k})
                    for _ztcp_i in {1..${#_ztcp_data}}; do _ztcp_data[$_ztcp_i]=${_ztcp_data[$_ztcp_i]//$_ztcp_entry[1]/$_ztcp_entry[2]}; done
                done
            fi

            local _ztcp_flared=()
            ztc:engine:text:flare _ztcp_data _ztcp_flared

            # ╶╶╶╶╶ component height ╴╴╴╴╴

            case $ztc[${_ztcp_name}:h] in
                (:auto) # set height to number of lines
                    _ztcp_h=${#_ztcp_flared} ;;
                (*)
                    _ztcp_h=$ztc[${_ztcp_name}:h] ;;
            esac

            # ╶╶╶╶╶ component width ╴╴╴╴╴

            case $ztc[${_ztcp_name}:w] in
                (:auto) # set width to length of longest line
                    local _ztcp_length=0

                    for _ztcp_line in $_ztcp_flared; do # strip escapes
                        _ztcp_line=${_ztcp_line//@\(@\)/@}
                        _ztcp_line=${(S)_ztcp_line//${ZTC_CSI}*(m|H|K|J|A|B|C|D|E|F|G|S|T|f|i|n|h|l|s|u)}

                        if (( ${#_ztcp_line} > _ztcp_length )); then _ztcp_length=${#_ztcp_line}; fi
                    done

                    _ztcp_w=$_ztcp_length
                    ;;
                (*)
                    _ztcp_w=$ztc[${_ztcp_name}:w]
                    ;;
            esac

            # ╶╶╶╶╶ component y-origin ╴╴╴╴╴

            case $ztc[${_ztcp_name}:y] in
                (:auto) # center component vertically
                    _ztcp_y=$(( ( (ztc[vh] - _ztcp_h) / 2 ) + 1 )) ;;
                (*)
                    _ztcp_y=$ztc[${_ztcp_name}:y] ;;
            esac

            # ╶╶╶╶╶ component x-origin ╴╴╴╴╴

            case $ztc[${_ztcp_name}:x] in
                (:auto) # center component horizontally
                    _ztcp_x=$(( ( (ztc[vw] - _ztcp_w) / 2 ) + 1 )) ;;
                (*)
                    _ztcp_x=$ztc[${_ztcp_name}:x] ;;
            esac

            # ╶╶╶╶╶ save/cache calculations ╴╴╴╴╴

            ztc[paint:${_ztcp_name}:h]=$_ztcp_h
            ztc[paint:${_ztcp_name}:w]=$_ztcp_w
            ztc[paint:${_ztcp_name}:y]=$_ztcp_y
            ztc[paint:${_ztcp_name}:x]=$_ztcp_x

            ztc:gizmo:stash paint:${_ztcp_name}:data _ztcp_flared

        else # retrieve from cache

            _ztcp_h=$ztc[paint:${_ztcp_name}:h]
            _ztcp_w=$ztc[paint:${_ztcp_name}:w]
            _ztcp_y=$ztc[paint:${_ztcp_name}:y]
            _ztcp_x=$ztc[paint:${_ztcp_name}:x]

        fi

        # ╶╶╶╶╶ update bounds ╴╴╴╴╴

        if (( ! ztc[${_ztcp_name}:overlay] )); then
            (( ztc[paint:h] += $_ztcp_h )) # only for layout:vertical when position:auto

            if (( _ztcp_y + _ztcp_h > ztc[paint:ym] )); then ztc[paint:ym]=$((_ztcp_y + _ztcp_h)); fi
            if (( _ztcp_x + _ztcp_w > ztc[paint:xm] )); then ztc[paint:xm]=$((_ztcp_x + _ztcp_w)); fi
            if (( _ztcp_y < ztc[paint:my] )); then ztc[paint:my]=$_ztcp_y; fi
            if (( _ztcp_x < ztc[paint:mx] )); then ztc[paint:mx]=$_ztcp_x; fi
        fi
    done


    # ───── declare render zone + adjust component origins ─────

    # ztc[paint:h]=$(( ztc[paint:ym] - ztc[paint:my] ))
    ztc[paint:w]=$(( ztc[paint:xm] - ztc[paint:mx] ))
    ztc[paint:my]=$(( ( (ztc[vh] - ztc[paint:h]) / 2 ) + 1 )) # override h for position:auto

    integer _ztcp_dy=0

    for _ztcp_name in $_ztcp_components; do
        if (( ! ztc[${_ztcp_name}:overlay] )); then
            ztc[paint:${_ztcp_name}:y]=$(( ztc[paint:my] + _ztcp_dy ))
            (( _ztcp_dy += ztc[paint:${_ztcp_name}:h] ))
        fi
    done


    # ───── paint component data ─────

    local _ztcp_staged=()

    for _ztcp_name in $_ztcp_components; do
        local _ztcp_matter=${ztc[paint:${_ztcp_name}:data]//@@/@\(@\)}
        local _ztcp_origin="${ZTC_CSI}${ztc[paint:${_ztcp_name}:y]};${ztc[paint:${_ztcp_name}:x]}H"

        _ztcp_matter=${_ztcp_matter//@n/${ZTC_CSI}E${ZTC_CSI}$(( ztc[paint:${_ztcp_name}:x] - 1 ))C}
        _ztcp_staged+=($_ztcp_origin ${_ztcp_matter//@\(@\)/@} $ZTC_TEXT_RESET)
    done


    # ───── render ─────

    ztc:core:write $ZTC_CLEAR ${(j::)_ztcp_staged}

}
