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

# ┌─────────────────────────────┐┌─────────────────┐
# │ ░░▒▒▓▓██  ENGINES  ██▓▓▒▒░░ ││    COMMANDER    │
# └─────────────────────────────┘└─────────────────┘

# ┌─────────────┐
# │    input    │
# └─────────────┘

function ztc:engine:input { # detect user inputs + build commands

    # ───── read input ─────

    local _ztci_key=''
    read -s -t $(( ztc[:rate:input] / 1000.0 )) -k 1 _ztci_key


    # ───── process input ─────

    if (( ztc[commander:active] )); then # attach input to command bar

        local _ztci_input=$ztc[commander:input]
        integer _ztci_cursor=$ztc[commander:cursor]
        integer _ztci_index=$(( ${#_ztci_input} - _ztci_cursor ))

        case $_ztci_key in

            # ╶╶╶╶╶ ignore empty keys ╴╴╴╴╴

            ('') ;;

            # ╶╶╶╶╶ <esc> + special keys ╴╴╴╴╴

            ($'\e')
                local _ztci_s1=''
                local _ztci_s2=''
                local _ztci_s3=''
                local _ztci_s4=''
                local _ztci_s5=''

                read -st -k 1 _ztci_s1
                read -st -k 1 _ztci_s2
                read -st -k 1 _ztci_s3
                read -st -k 1 _ztci_s4
                read -st -k 1 _ztci_s5

                local _ztci_special=$_ztci_s1$_ztci_s2$_ztci_s3$_ztci_s4$_ztci_s5

                case $_ztci_special in

                    # ╶╶╶╶╶ <esc> ╴╴╴╴╴

                    ('') ztc:cassette:commander:leave ;;

                    # ╶╶╶╶╶ <up> (previous line in history) ╴╴╴╴╴

                    ('[A') if (( ! ztc[commander:help] )); then ztc:cassette:commander:serve previous; fi ;;

                    # ╶╶╶╶╶ <down> (next line in history) ╴╴╴╴╴

                    ('[B') if (( ! ztc[commander:help] )); then ztc:cassette:commander:serve next; fi ;;

                    # ╶╶╶╶╶ <right> (move cursor right) ╴╴╴╴╴

                    ('[C') if (( _ztci_cursor > 0 )); then (( ztc[commander:cursor]-- )); fi ;;

                    # ╶╶╶╶╶ <left> (move cursor left) ╴╴╴╴╴

                    ('[D') if (( _ztci_index > 0 )); then (( ztc[commander:cursor]++ )); fi ;;

                    # ╶╶╶╶╶ <alt-delete> (delete word) ╴╴╴╴╴

                    ($'\x7f')
                        if (( _ztci_index != 0 )); then
                            local _ztci_left=''
                            local _ztci_word=''
                            ztc:gizmo:words _ztci_input _ztci_index left _ztci_left _ztci_word

                            ztc[commander:yank]=$_ztci_word
                            ztc[commander:input]=$_ztci_left${_ztci_input:_ztci_index}
                        fi ;;

                    # ╶╶╶╶╶ <alt-<> (first line in history) ╴╴╴╴╴

                    ('<') if (( ! ztc[commander:help] )); then ztc:cassette:commander:serve first; fi ;;

                    # ╶╶╶╶╶ <alt->> (last line in history) ╴╴╴╴╴

                    ('>') if (( ! ztc[commander:help] )); then ztc:cassette:commander:serve last; fi ;;

                    # ╶╶╶╶╶ <alt-b>/<alt-left> (move cursor one word left) ╴╴╴╴╴

                    ('b'|'[1;3D')
                        if (( _ztci_index != 0 )); then
                            local _ztci_left=''
                            ztc:gizmo:words _ztci_input _ztci_index left _ztci_left

                            ztc[commander:cursor]=$(( ${#_ztci_input} - ${#_ztci_left} ))
                        fi ;;

                    # ╶╶╶╶╶ <alt-c> (capitalize word) ╴╴╴╴╴

                    ('c') ztc:cassette:commander:shift _ztci_input _ztci_index C ;;

                    # ╶╶╶╶╶ <alt-d> (forward delete word) ╴╴╴╴╴

                    ('d')
                        if (( _ztci_cursor != 0 )); then
                            local _ztci_right=''
                            local _ztci_word=''
                            ztc:gizmo:words _ztci_input _ztci_index right _ztci_right _ztci_word

                            ztc[commander:yank]=$_ztci_word
                            ztc[commander:input]=${_ztci_input:0:_ztci_index}$_ztci_right
                            ztc[commander:cursor]=${#_ztci_right}
                        fi ;;

                    # ╶╶╶╶╶ <alt-f>/<alt-right> (move cursor one word right) ╴╴╴╴╴

                    ('f'|'[1;3C')
                        if (( _ztci_cursor != 0 )); then
                            local ztci_right=''
                            ztc:gizmo:words _ztci_input _ztci_index right _ztci_right

                            ztc[commander:cursor]=${#_ztci_right}
                        fi ;;

                    # ╶╶╶╶╶ <alt-l> (lowercase word) ╴╴╴╴╴

                    ('l') ztc:cassette:commander:shift _ztci_input _ztci_index L ;;

                    # ╶╶╶╶╶ <alt-n>/<alt-down> (next line in history based on input) ╴╴╴╴╴

                    ('n'|'[1;3B') if [[ -n $_ztci_input && $ztc[commander:help] -eq 0 ]]; then ztc:cassette:commander:serve next $_ztci_input; fi ;;

                    # ╶╶╶╶╶ <alt-p>/<alt-up> (previous line in history based on input) ╴╴╴╴╴

                    ('p'|'[1;3A') if [[ -n $_ztci_input && $ztc[commander:help] -eq 0 ]]; then ztc:cassette:commander:serve previous $_ztci_input; fi ;;

                    # ╶╶╶╶╶ <alt-t> (swap words around cursor) ╴╴╴╴╴

                    ('t') ztc:cassette:commander:shift _ztci_input _ztci_index T ;;

                    # ╶╶╶╶╶ <alt-u> (uppercase word) ╴╴╴╴╴

                    ('u') ztc:cassette:commander:shift _ztci_input _ztci_index U ;;

                    # ╶╶╶╶╶ ignore all other special keys ╴╴╴╴╴

                    (*) ;;

                esac ;;

            # ╶╶╶╶╶ <ctrl-a> (move cursor to beginning) ╴╴╴╴╴

            ($'\x1') ztc[commander:cursor]=${#_ztci_input} ;;

            # ╶╶╶╶╶ <ctrl-b> (move cursor left) ╴╴╴╴╴

            ($'\x2') if (( _ztci_index > 0 )); then (( ztc[commander:cursor]++ )); fi ;;

            # ╶╶╶╶╶ <ctrl-d> (forward delete) ╴╴╴╴╴

            ($'\x4')
                if (( ${#_ztci_input} == 0 )); then
                    ztc:cassette:commander:leave
                else
                    if (( _ztci_index != ${#_ztci_input} )); then
                        ztc[commander:input]=${_ztci_input:0:_ztci_index}${_ztci_input:$(( _ztci_index + 1 ))}
                        (( ztc[commander:cursor]-- ))
                    fi
                fi ;;

            # ╶╶╶╶╶ <ctrl-e> (move cursor to end) ╴╴╴╴╴

            ($'\x5') ztc[commander:cursor]=0 ;;

            # ╶╶╶╶╶ <ctrl-f> (move cursor) ╴╴╴╴╴

            ($'\x6') if (( _ztci_cursor > 0 )); then (( ztc[commander:cursor]-- )); fi ;;

            # ╶╶╶╶╶ <ctrl-g> (<esc>) ╴╴╴╴╴

            ($'\x7') ztc:cassette:commander:leave ;;

            # ╶╶╶╶╶ <ctrl-h>/<backspace>/<delete> ╴╴╴╴╴

            ($'\x8'|$'\b'|$'\x7f') if (( _ztci_index != 0 )); then ztc[commander:input]=${_ztci_input:0:$(( _ztci_index - 1 ))}${_ztci_input:_ztci_index}; fi ;;

            # ╶╶╶╶╶ <ctrl-i> (<tab>) ╴╴╴╴╴

            ($'\x9'|$'\t') ;; # autocomplete stuff goes here

            # ╶╶╶╶╶ <ctrl-j>/<ctrl-m>/<enter>/<return> ╴╴╴╴╴

            ($'\xA'|$'\xD'|$'\n'|$'\r')
                if (( ! ztc[commander:help] )); then
                    if (( ${#_ztci_input} > 0 )); then ztc:cassette:commander:yield $_ztci_input
                    else ztc:cassette:commander:leave; fi
                else
                    local _ztci_parse=${(MS)_ztci_input##[[:graph:]]*[[:graph:]]}
                    if [[ -z $_ztci_parse ]]; then _ztci_parse=${(MS)_ztci_input##[[:graph:]]}; fi

                    ztc:parse $_ztci_parse
                fi ;;

            # ╶╶╶╶╶ <ctrl-k> (delete from cursor to end) ╴╴╴╴╴

            ($'\xB')
                ztc[commander:yank]=${_ztci_input:_ztci_index}
                ztc[commander:input]=${_ztci_input:0:_ztci_index}
                ztc[commander:cursor]=0
                ;;

            # ╶╶╶╶╶ <ctrl-l> (clear the input) ╴╴╴╴╴

            ($'\xC')
                ztc[commander:input]=''
                ztc[commander:cursor]=0
                ztc[commander:history:index]=0
                ;;

            # ╶╶╶╶╶ <ctrl-n> (next line in history) ╴╴╴╴╴

            ($'\xE') if (( ! ztc[commander:help] )); then ztc:cassette:commander:serve next; fi ;;

            # ╶╶╶╶╶ <ctrl-o> (<enter> + next line in history) ╴╴╴╴╴

            ($'\xF')
                if (( ! ztc[commander:help] )); then
                    local _ztci_history_index=$ztc[commander:history:index]
                    local _ztci_history_filter=$ztc[commander:history:filter]

                    if (( ${#_ztci_input} > 0 )); then ztc:cassette:commander:yield $_ztci_input
                    else ztc:cassette:commander:leave; fi

                    ztc:cassette:commander:enter
                    ztc[commander:history:index]=$(( _ztci_history_index + 1 )) # adjust for dup removal
                    ztc[commander:history:filter]=$_ztci_history_filter
                    ztc:cassette:commander:serve next
                fi ;;

            # ╶╶╶╶╶ <ctrl-p> (previous line in history) ╴╴╴╴╴

            ($'\x10') if (( ! ztc[commander:help] )); then ztc:cassette:commander:serve previous; fi ;;

            # ╶╶╶╶╶ <ctrl-q> (literal insert) ╴╴╴╴╴

            ($'\x11') ;; # disabled

            # ╶╶╶╶╶ <ctrl-r> (search backward in history) ╴╴╴╴╴

            ($'\x12') ;;

            # ╶╶╶╶╶ <ctrl-s> (search forward in history) ╴╴╴╴╴

            ($'\x13') ;;

            # ╶╶╶╶╶ <ctrl-t> (swap characters around cursor) ╴╴╴╴╴

            ($'\x14')
                if (( _ztci_index > 0 )); then
                    if (( _ztci_cursor == 0 )); then (( _ztci_index -= 1 )); fi

                    local _ztci_left=${_ztci_input:0:$(( _ztci_index - 1 ))}
                    local _ztci_right=${_ztci_input:$(( _ztci_index + 1 ))}
                    local _ztci_a=${_ztci_input:$(( _ztci_index - 1 )):1}
                    local _ztci_b=${_ztci_input:_ztci_index:1}

                    ztc[commander:input]=$_ztci_left$_ztci_b$_ztci_a$_ztci_right
                fi

                if (( _ztci_cursor > 0 )); then (( ztc[commander:cursor]-- )); fi
                ;;

            # ╶╶╶╶╶ <ctrl-u> (delete from beginning to cursor) ╴╴╴╴╴

            ($'\x15')
                ztc[commander:yank]=${_ztci_input:0:_ztci_index}
                ztc[commander:input]=${_ztci_input:_ztci_index}
                ;;

            # ╶╶╶╶╶ <ctrl-v> (literal insert) ╴╴╴╴╴

            ($'\x16') ;; # disabled

            # ╶╶╶╶╶ <ctrl-w> (delete word) ╴╴╴╴╴

            ($'\x17')
                if (( _ztci_index != 0 )); then
                    local _ztci_left=''
                    local _ztci_word=''
                    ztc:gizmo:words _ztci_input _ztci_index left _ztci_left _ztci_word

                    ztc[commander:yank]=$_ztci_word
                    ztc[commander:input]=$_ztci_left${_ztci_input:_ztci_index}
                fi ;;

            # ╶╶╶╶╶ <ctrl-x> (alternate between cursor and beginning) ╴╴╴╴╴

            ($'\x18')
                if (( _ztci_index != 0 )); then
                    ztc[commander:cursor:last]=$_ztci_cursor
                    ztc[commander:cursor]=${#_ztci_input}
                else
                    ztc[commander:cursor]=$ztc[commander:cursor:last]
                fi ;;

            # ╶╶╶╶╶ <ctrl-y> (paste) ╴╴╴╴╴

            ($'\x19') ztc[commander:input]=${_ztci_input:0:_ztci_index}$ztc[commander:yank]${_ztci_input:_ztci_index} ;;

            # ╶╶╶╶╶ insert key at cursor index ╴╴╴╴╴

            (*) ztc[commander:input]=${_ztci_input:0:_ztci_index}$_ztci_key${_ztci_input:_ztci_index} ;;

        esac

        ztc:cassette:core:cycle commander


    else # input is a shortcut

        case $_ztci_key in

            # ╶╶╶╶╶ clear status ╴╴╴╴╴

            ($'\e') ztc:cassette:commander:clear ;;

            # ╶╶╶╶╶ quit ╴╴╴╴╴

            (q|Q) ztc:core:clean ;;

            # ╶╶╶╶╶ command bar ╴╴╴╴╴

            (:|$'\n'|$'\r'|$'\xA'|$'\xD') ztc:cassette:commander:enter ;;

            # ╶╶╶╶╶ helper ╴╴╴╴╴

            (\?)
                ztc[commander:help]=1
                ztc:cassette:commander:enter '? '
                ;;
        esac

    fi

}
