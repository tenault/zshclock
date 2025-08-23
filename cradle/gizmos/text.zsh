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
# │ ░░▒▒▓▓██  GIZMOS  ██▓▓▒▒░░ ││    TEXT    │
# └────────────────────────────┘└────────────┘

# ┌─────────────┐
# │    words    │
# └─────────────┘

function ztc:gizmo:words { # get closest word boundaries

    # ───── import ─────

    local _ztcgt_input=${(P)1}
    local _ztcgt_index=${(P)2}


    # ───── get closest word boundaries ─────

    # ╶╶╶╶╶ left ╴╴╴╴╴

    local _ztcgt_left=${(*)${_ztcgt_input:0:_ztcgt_index}/%[[:space:]]#} # trim trailing spaces in left
    local _ztcgt_word_left=${(MS)_ztcgt_left##[[:graph:]]*[[:graph:]]}  # trim all whitespace in left
    if [[ -z $_ztcgt_word_left ]]; then _ztcgt_word_left=${(MS)_ztcgt_left##[[:graph:]]}; fi

    if [[ ! $_ztcgt_left =~ ' ' ]]; then _ztcgt_left=''
    else _ztcgt_left="${_ztcgt_left%[[:space:]]*} "; fi  # remove last word in left

    # ╶╶╶╶╶ right ╴╴╴╴╴

    local _ztcgt_right=${(*)${_ztcgt_input:_ztcgt_index}/#[[:space:]]#}   # trim leading spaces in right
    local _ztcgt_word_right=${(MS)_ztcgt_right##[[:graph:]]*[[:graph:]]} # trim all whitespace in right
    if [[ -z $_ztcgt_word_right ]]; then _ztcgt_word_right=${(MS)_ztcgt_right##[[:graph:]]}; fi

    if [[ ! $_ztcgt_right =~ ' ' ]]; then _ztcgt_right=''
    else _ztcgt_right=" ${_ztcgt_right#*[[:space:]]}"; fi # remove first word in right

    # ╶╶╶╶╶ select words ╴╴╴╴╴

    _ztcgt_word_left=${_ztcgt_word_left##*[[:space:]]}   # select last word in left
    _ztcgt_word_right=${_ztcgt_word_right%%[[:space:]]*} # select first word in right


    # ───── export ─────

    case $3 in
        (left)
            if [[ -n $4 ]]; then : ${(P)4::=$_ztcgt_left}; fi
            if [[ -n $5 ]]; then : ${(P)5::=$_ztcgt_word_left}; fi
            ;;
        (right)
            if [[ -n $4 ]]; then : ${(P)4::=$_ztcgt_right}; fi
            if [[ -n $5 ]]; then : ${(P)5::=$_ztcgt_word_right}; fi
            ;;
        (both)
            if [[ -n $4 ]]; then : ${(P)4::=$_ztcgt_left}; fi
            if [[ -n $5 ]]; then : ${(P)5::=$_ztcgt_right}; fi
            if [[ -n $6 ]]; then : ${(P)6::=$_ztcgt_word_left}; fi
            if [[ -n $7 ]]; then : ${(P)7::=$_ztcgt_word_right}; fi
            ;;
    esac

}


# ┌─────────────┐
# │    shift    │
# └─────────────┘

function ztc:gizmo:shift { # transform word(s) at boundary

    # ───── import ─────

    local _ztcgt_input=${(P)1}
    local _ztcgt_index=${(P)2}
    local _ztcgt_left=${(P)4}
    local _ztcgt_right=${(P)5}
    local _ztcgt_word_left=${(P)6}
    local _ztcgt_word_right=${(P)7}

    local _ztcgt_shift=$3


    # ───── get word(s) ─────

    local _ztcgt_bound_left=$(( _ztcgt_index - ${#_ztcgt_word_left} ))
    local _ztcgt_bound_right=$(( ${#_ztcgt_word_left} + ${#_ztcgt_word_right} ))

    if [[ $_ztcgt_shift == 'T' && "$_ztcgt_word_left$_ztcgt_word_right" == "${_ztcgt_input:_ztcgt_bound_left:_ztcgt_bound_right}" ]]; then # cursor is inside word

        _ztcgt_word_right=$_ztcgt_word_left$_ztcgt_word_right

        _ztcgt_left=${(*)_ztcgt_left/%[[:space:]]#}   # retrim trailing spaces
        _ztcgt_word_left=${_ztcgt_left##*[[:space:]]} # select new last word

        if [[ ! $_ztcgt_left =~ ' ' ]]; then _ztcgt_left=''
        else _ztcgt_left="${_ztcgt_left%[[:space:]]*} "; fi # remove new last word

    elif [[ $_ztcgt_shift != 'T' && "$_ztcgt_word_left$_ztcgt_word_right" != "${_ztcgt_input:_ztcgt_bound_left:_ztcgt_bound_right}" ]]; then # cursor is between words

        _ztcgt_bound_left=$_ztcgt_index
        _ztcgt_bound_right=$(( ${#_ztcgt_word_right} + 1 ))

        _ztcgt_left="$_ztcgt_left$_ztcgt_word_left " # reattach

    fi


    # ───── shift word(s) + export ─────

    local _ztcgt_word=''

    case $_ztcgt_shift in

        # ╶╶╶╶╶ transpose ╴╴╴╴╴

        (T) if [[ -n $_ztcgt_word_left ]]; then _ztcgt_word_right="$_ztcgt_word_right "; fi
            _ztcgt_word=$_ztcgt_word_right$_ztcgt_word_left
            ;;

        # ╶╶╶╶╶ capitalize ╴╴╴╴╴

        (C) _ztcgt_word=${(MS)${(C)_ztcgt_input:_ztcgt_bound_left:_ztcgt_bound_right}##[[:graph:]]*[[:graph:]]} # trim whitespace
            if [[ -z $_ztcgt_word ]]; then _ztcgt_word=${(MS)${(C)_ztcgt_input:_ztcgt_bound_left:_ztcgt_bound_right}##[[:graph:]]}; fi
            ;;

        # ╶╶╶╶╶ lowercase ╴╴╴╴╴

        (L) _ztcgt_word=${(MS)${(L)_ztcgt_input:_ztcgt_bound_left:_ztcgt_bound_right}##[[:graph:]]*[[:graph:]]} # trim whitespace
            if [[ -z $_ztcgt_word ]]; then _ztcgt_word=${(MS)${(L)_ztcgt_input:_ztcgt_bound_left:_ztcgt_bound_right}##[[:graph:]]}; fi
            ;;

        # ╶╶╶╶╶ uppercase ╴╴╴╴╴

        (U) _ztcgt_word=${(MS)${(U)_ztcgt_input:_ztcgt_bound_left:_ztcgt_bound_right}##[[:graph:]]*[[:graph:]]} # trim whitespace
            if [[ -z $_ztcgt_word ]]; then _ztcgt_word=${(MS)${(U)_ztcgt_input:_ztcgt_bound_left:_ztcgt_bound_right}##[[:graph:]]}; fi
            ;;

    esac

    : ${(P)4::=$_ztcgt_left}
    : ${(P)5::=$_ztcgt_right}
    : ${(P)6::=$_ztcgt_word_left}
    : ${(P)7::=$_ztcgt_word_right}

    : ${(P)1::=$_ztcgt_left$_ztcgt_word$_ztcgt_right}

}
