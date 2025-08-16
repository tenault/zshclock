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
# │ ░░▒▒▓▓██  GIZMOS  ██▓▓▒▒░░ ││    POET    │
# └────────────────────────────┘└────────────┘

# ┌─────────────┐
# │    words    │
# └─────────────┘

function ztc:gizmo:words { # get closest word boundaries

    # ───── import ─────

    local _ztcwd_input=${(P)1}
    local _ztcwd_index=${(P)2}


    # ───── get closest word boundaries ─────

    # ╶╶╶╶╶ left ╴╴╴╴╴

    local _ztcwd_left=${(*)${_ztcwd_input:0:_ztcwd_index}/%[[:space:]]#} # trim trailing spaces in left
    local _ztcwd_word_left=${(MS)_ztcwd_left##[[:graph:]]*[[:graph:]]}  # trim all whitespace in left
    if [[ -z $_ztcwd_word_left ]]; then _ztcwd_word_left=${(MS)_ztcwd_left##[[:graph:]]}; fi

    if [[ ! $_ztcwd_left =~ ' ' ]]; then _ztcwd_left=''
    else _ztcwd_left="${_ztcwd_left%[[:space:]]*} "; fi  # remove last word in left

    # ╶╶╶╶╶ right ╴╴╴╴╴

    local _ztcwd_right=${(*)${_ztcwd_input:_ztcwd_index}/#[[:space:]]#}   # trim leading spaces in right
    local _ztcwd_word_right=${(MS)_ztcwd_right##[[:graph:]]*[[:graph:]]} # trim all whitespace in right
    if [[ -z $_ztcwd_word_right ]]; then _ztcwd_word_right=${(MS)_ztcwd_right##[[:graph:]]}; fi

    if [[ ! $_ztcwd_right =~ ' ' ]]; then _ztcwd_right=''
    else _ztcwd_right=" ${_ztcwd_right#*[[:space:]]}"; fi # remove first word in right

    # ╶╶╶╶╶ select words ╴╴╴╴╴

    _ztcwd_word_left=${_ztcwd_word_left##*[[:space:]]}   # select last word in left
    _ztcwd_word_right=${_ztcwd_word_right%%[[:space:]]*} # select first word in right


    # ───── export ─────

    case $3 in
        (left)
            if [[ -n $4 ]]; then : ${(P)4::=$_ztcwd_left}; fi
            if [[ -n $5 ]]; then : ${(P)5::=$_ztcwd_word_left}; fi
            ;;
        (right)
            if [[ -n $4 ]]; then : ${(P)4::=$_ztcwd_right}; fi
            if [[ -n $5 ]]; then : ${(P)5::=$_ztcwd_word_right}; fi
            ;;
        (both)
            if [[ -n $4 ]]; then : ${(P)4::=$_ztcwd_left}; fi
            if [[ -n $5 ]]; then : ${(P)5::=$_ztcwd_right}; fi
            if [[ -n $6 ]]; then : ${(P)6::=$_ztcwd_word_left}; fi
            if [[ -n $7 ]]; then : ${(P)7::=$_ztcwd_word_right}; fi
            ;;
    esac

}


# ┌─────────────┐
# │    shift    │
# └─────────────┘

function ztc:gizmo:shift { # transform word(s) at boundary

    # ───── import ─────

    local _ztcwd_input=${(P)1}
    local _ztcwd_index=${(P)2}
    local _ztcwd_left=${(P)4}
    local _ztcwd_right=${(P)5}
    local _ztcwd_word_left=${(P)6}
    local _ztcwd_word_right=${(P)7}

    local _ztcwd_shift=$3


    # ───── get word(s) ─────

    local _ztcwd_bound_left=$(( _ztcwd_index - ${#_ztcwd_word_left} ))
    local _ztcwd_bound_right=$(( ${#_ztcwd_word_left} + ${#_ztcwd_word_right} ))

    if [[ $_ztcwd_shift == 'T' && "$_ztcwd_word_left$_ztcwd_word_right" == "${_ztcwd_input:_ztcwd_bound_left:_ztcwd_bound_right}" ]]; then # cursor is inside word

        _ztcwd_word_right=$_ztcwd_word_left$_ztcwd_word_right

        _ztcwd_left=${(*)_ztcwd_left/%[[:space:]]#}   # retrim trailing spaces
        _ztcwd_word_left=${_ztcwd_left##*[[:space:]]} # select new last word

        if [[ ! $_ztcwd_left =~ ' ' ]]; then _ztcwd_left=''
        else _ztcwd_left="${_ztcwd_left%[[:space:]]*} "; fi # remove new last word

    elif [[ $_ztcwd_shift != 'T' && "$_ztcwd_word_left$_ztcwd_word_right" != "${_ztcwd_input:_ztcwd_bound_left:_ztcwd_bound_right}" ]]; then # cursor is between words

        _ztcwd_bound_left=$_ztcwd_index
        _ztcwd_bound_right=$(( ${#_ztcwd_word_right} + 1 ))

        _ztcwd_left="$_ztcwd_left$_ztcwd_word_left " # reattach

    fi


    # ───── shift word(s) + export ─────

    local _ztcwd_word=''

    case $_ztcwd_shift in

        # ╶╶╶╶╶ transpose ╴╴╴╴╴

        (T) if [[ -n $_ztcwd_word_left ]]; then _ztcwd_word_right="$_ztcwd_word_right "; fi
            _ztcwd_word=$_ztcwd_word_right$_ztcwd_word_left
            ;;

        # ╶╶╶╶╶ capitalize ╴╴╴╴╴

        (C) _ztcwd_word=${(MS)${(C)_ztcwd_input:_ztcwd_bound_left:_ztcwd_bound_right}##[[:graph:]]*[[:graph:]]} # trim whitespace
            if [[ -z $_ztcwd_word ]]; then _ztcwd_word=${(MS)${(C)_ztcwd_input:_ztcwd_bound_left:_ztcwd_bound_right}##[[:graph:]]}; fi
            ;;

        # ╶╶╶╶╶ lowercase ╴╴╴╴╴

        (L) _ztcwd_word=${(MS)${(L)_ztcwd_input:_ztcwd_bound_left:_ztcwd_bound_right}##[[:graph:]]*[[:graph:]]} # trim whitespace
            if [[ -z $_ztcwd_word ]]; then _ztcwd_word=${(MS)${(L)_ztcwd_input:_ztcwd_bound_left:_ztcwd_bound_right}##[[:graph:]]}; fi
            ;;

        # ╶╶╶╶╶ uppercase ╴╴╴╴╴

        (U) _ztcwd_word=${(MS)${(U)_ztcwd_input:_ztcwd_bound_left:_ztcwd_bound_right}##[[:graph:]]*[[:graph:]]} # trim whitespace
            if [[ -z $_ztcwd_word ]]; then _ztcwd_word=${(MS)${(U)_ztcwd_input:_ztcwd_bound_left:_ztcwd_bound_right}##[[:graph:]]}; fi
            ;;

    esac

    : ${(P)4::=$_ztcwd_left}
    : ${(P)5::=$_ztcwd_right}
    : ${(P)6::=$_ztcwd_word_left}
    : ${(P)7::=$_ztcwd_word_right}

    : ${(P)1::=$_ztcwd_left$_ztcwd_word$_ztcwd_right}

}
