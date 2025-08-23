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

# ┌─────────────────────────────┐┌────────────┐┌╴╴╴╴╴╴╴╴╴╴╴╴╴┐
# │ ░░▒▒▓▓██  ENGINES  ██▓▓▒▒░░ ││    TEXT    │╎    INPUT    ╎
# └─────────────────────────────┘└────────────┘└╶╶╶╶╶╶╶╶╶╶╶╶╶┘

# ┌─────────────┐
# │    input    │
# └─────────────┘

function ztc:engine:text:input { # detect user inputs + build commands

    # ───── read input ─────

    local _ztcti_key=''
    read -s -t $(( ztc[:rate:input] / 1000.0 )) -k 1 _ztcti_key


    # ───── process input ─────

    if (( ztc[commander:active] )); then # attach input to command bar

        local _ztcti_input=$ztc[commander:input]
        integer _ztcti_cursor=$ztc[commander:cursor]
        integer _ztcti_index=$(( ${#_ztcti_input} - _ztcti_cursor ))

        case $_ztcti_key in

            # ╶╶╶╶╶ ignore empty keys ╴╴╴╴╴

            ('') ;;

            # ╶╶╶╶╶ <esc> + special keys ╴╴╴╴╴

            ($'\e')
                local _ztcti_s1=''
                local _ztcti_s2=''
                local _ztcti_s3=''
                local _ztcti_s4=''
                local _ztcti_s5=''

                read -st -k 1 _ztcti_s1
                read -st -k 1 _ztcti_s2
                read -st -k 1 _ztcti_s3
                read -st -k 1 _ztcti_s4
                read -st -k 1 _ztcti_s5

                local _ztcti_special=$_ztcti_s1$_ztcti_s2$_ztcti_s3$_ztcti_s4$_ztcti_s5

                case $_ztcti_special in

                    # ╶╶╶╶╶ <esc> ╴╴╴╴╴

                    ('') ztc:cassette:commander:leave ;;

                    # ╶╶╶╶╶ <up> (previous line in history) ╴╴╴╴╴

                    ('[A') if (( ! ztc[commander:help] )); then ztc:cassette:commander:serve previous; fi ;;

                    # ╶╶╶╶╶ <down> (next line in history) ╴╴╴╴╴

                    ('[B') if (( ! ztc[commander:help] )); then ztc:cassette:commander:serve next; fi ;;

                    # ╶╶╶╶╶ <right> (move cursor right) ╴╴╴╴╴

                    ('[C') if (( _ztcti_cursor > 0 )); then (( ztc[commander:cursor]-- )); fi ;;

                    # ╶╶╶╶╶ <left> (move cursor left) ╴╴╴╴╴

                    ('[D') if (( _ztcti_index > 0 )); then (( ztc[commander:cursor]++ )); fi ;;

                    # ╶╶╶╶╶ <alt-delete> (delete word) ╴╴╴╴╴

                    ($'\x7f')
                        if (( _ztcti_index != 0 )); then
                            local _ztcti_left=''
                            local _ztcti_word=''
                            ztc:gizmo:words _ztcti_input _ztcti_index left _ztcti_left _ztcti_word

                            ztc[commander:yank]=$_ztcti_word
                            ztc[commander:input]=$_ztcti_left${_ztcti_input:_ztcti_index}
                        fi ;;

                    # ╶╶╶╶╶ <alt-<> (first line in history) ╴╴╴╴╴

                    ('<') if (( ! ztc[commander:help] )); then ztc:cassette:commander:serve first; fi ;;

                    # ╶╶╶╶╶ <alt->> (last line in history) ╴╴╴╴╴

                    ('>') if (( ! ztc[commander:help] )); then ztc:cassette:commander:serve last; fi ;;

                    # ╶╶╶╶╶ <alt-b>/<alt-left> (move cursor one word left) ╴╴╴╴╴

                    ('b'|'[1;3D')
                        if (( _ztcti_index != 0 )); then
                            local _ztcti_left=''
                            ztc:gizmo:words _ztcti_input _ztcti_index left _ztcti_left

                            ztc[commander:cursor]=$(( ${#_ztcti_input} - ${#_ztcti_left} ))
                        fi ;;

                    # ╶╶╶╶╶ <alt-c> (capitalize word) ╴╴╴╴╴

                    ('c') ztc:cassette:text:shift _ztcti_input _ztcti_index C ;;

                    # ╶╶╶╶╶ <alt-d> (forward delete word) ╴╴╴╴╴

                    ('d')
                        if (( _ztcti_cursor != 0 )); then
                            local _ztcti_right=''
                            local _ztcti_word=''
                            ztc:gizmo:words _ztcti_input _ztcti_index right _ztcti_right _ztcti_word

                            ztc[commander:yank]=$_ztcti_word
                            ztc[commander:input]=${_ztcti_input:0:_ztcti_index}$_ztcti_right
                            ztc[commander:cursor]=${#_ztcti_right}
                        fi ;;

                    # ╶╶╶╶╶ <alt-f>/<alt-right> (move cursor one word right) ╴╴╴╴╴

                    ('f'|'[1;3C')
                        if (( _ztcti_cursor != 0 )); then
                            local ztcti_right=''
                            ztc:gizmo:words _ztcti_input _ztcti_index right _ztcti_right

                            ztc[commander:cursor]=${#_ztcti_right}
                        fi ;;

                    # ╶╶╶╶╶ <alt-l> (lowercase word) ╴╴╴╴╴

                    ('l') ztc:cassette:text:shift _ztcti_input _ztcti_index L ;;

                    # ╶╶╶╶╶ <alt-n>/<alt-down> (next line in history based on input) ╴╴╴╴╴

                    ('n'|'[1;3B') if [[ -n $_ztcti_input && $ztc[commander:help] -eq 0 ]]; then ztc:cassette:commander:serve next $_ztcti_input; fi ;;

                    # ╶╶╶╶╶ <alt-p>/<alt-up> (previous line in history based on input) ╴╴╴╴╴

                    ('p'|'[1;3A') if [[ -n $_ztcti_input && $ztc[commander:help] -eq 0 ]]; then ztc:cassette:commander:serve previous $_ztcti_input; fi ;;

                    # ╶╶╶╶╶ <alt-t> (swap words around cursor) ╴╴╴╴╴

                    ('t') ztc:cassette:text:shift _ztcti_input _ztcti_index T ;;

                    # ╶╶╶╶╶ <alt-u> (uppercase word) ╴╴╴╴╴

                    ('u') ztc:cassette:text:shift _ztcti_input _ztcti_index U ;;

                    # ╶╶╶╶╶ ignore all other special keys ╴╴╴╴╴

                    (*) ;;

                esac ;;

            # ╶╶╶╶╶ <ctrl-a> (move cursor to beginning) ╴╴╴╴╴

            ($'\x1') ztc[commander:cursor]=${#_ztcti_input} ;;

            # ╶╶╶╶╶ <ctrl-b> (move cursor left) ╴╴╴╴╴

            ($'\x2') if (( _ztcti_index > 0 )); then (( ztc[commander:cursor]++ )); fi ;;

            # ╶╶╶╶╶ <ctrl-d> (forward delete) ╴╴╴╴╴

            ($'\x4')
                if (( ${#_ztcti_input} == 0 )); then
                    ztc:cassette:commander:leave
                else
                    if (( _ztcti_index != ${#_ztcti_input} )); then
                        ztc[commander:input]=${_ztcti_input:0:_ztcti_index}${_ztcti_input:$(( _ztcti_index + 1 ))}
                        (( ztc[commander:cursor]-- ))
                    fi
                fi ;;

            # ╶╶╶╶╶ <ctrl-e> (move cursor to end) ╴╴╴╴╴

            ($'\x5') ztc[commander:cursor]=0 ;;

            # ╶╶╶╶╶ <ctrl-f> (move cursor) ╴╴╴╴╴

            ($'\x6') if (( _ztcti_cursor > 0 )); then (( ztc[commander:cursor]-- )); fi ;;

            # ╶╶╶╶╶ <ctrl-g> (<esc>) ╴╴╴╴╴

            ($'\x7') ztc:cassette:commander:leave ;;

            # ╶╶╶╶╶ <ctrl-h>/<backspace>/<delete> ╴╴╴╴╴

            ($'\x8'|$'\b'|$'\x7f') if (( _ztcti_index != 0 )); then ztc[commander:input]=${_ztcti_input:0:$(( _ztcti_index - 1 ))}${_ztcti_input:_ztcti_index}; fi ;;

            # ╶╶╶╶╶ <ctrl-i> (<tab>) ╴╴╴╴╴

            ($'\x9'|$'\t') ;; # autocomplete stuff goes here

            # ╶╶╶╶╶ <ctrl-j>/<ctrl-m>/<enter>/<return> ╴╴╴╴╴

            ($'\xA'|$'\xD'|$'\n'|$'\r')
                if (( ! ztc[commander:help] )); then
                    if (( ${#_ztcti_input} > 0 )); then ztc:cassette:text:yield $_ztcti_input
                    else ztc:cassette:commander:leave; fi
                else
                    local _ztcti_parse=${(MS)_ztcti_input##[[:graph:]]*[[:graph:]]}
                    if [[ -z $_ztcti_parse ]]; then _ztcti_parse=${(MS)_ztcti_input##[[:graph:]]}; fi

                    ztc:engine:text:parse $_ztcti_parse
                fi ;;

            # ╶╶╶╶╶ <ctrl-k> (delete from cursor to end) ╴╴╴╴╴

            ($'\xB')
                ztc[commander:yank]=${_ztcti_input:_ztcti_index}
                ztc[commander:input]=${_ztcti_input:0:_ztcti_index}
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
                    local _ztcti_history_index=$ztc[commander:history:index]
                    local _ztcti_history_filter=$ztc[commander:history:filter]

                    if (( ${#_ztcti_input} > 0 )); then ztc:cassette:text:yield $_ztcti_input
                    else ztc:cassette:commander:leave; fi

                    ztc:cassette:commander:enter
                    ztc[commander:history:index]=$(( _ztcti_history_index + 1 )) # adjust for dup removal
                    ztc[commander:history:filter]=$_ztcti_history_filter
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
                if (( _ztcti_index > 0 )); then
                    if (( _ztcti_cursor == 0 )); then (( _ztcti_index -= 1 )); fi

                    local _ztcti_left=${_ztcti_input:0:$(( _ztcti_index - 1 ))}
                    local _ztcti_right=${_ztcti_input:$(( _ztcti_index + 1 ))}
                    local _ztcti_a=${_ztcti_input:$(( _ztcti_index - 1 )):1}
                    local _ztcti_b=${_ztcti_input:_ztcti_index:1}

                    ztc[commander:input]=$_ztcti_left$_ztcti_b$_ztcti_a$_ztcti_right
                fi

                if (( _ztcti_cursor > 0 )); then (( ztc[commander:cursor]-- )); fi
                ;;

            # ╶╶╶╶╶ <ctrl-u> (delete from beginning to cursor) ╴╴╴╴╴

            ($'\x15')
                ztc[commander:yank]=${_ztcti_input:0:_ztcti_index}
                ztc[commander:input]=${_ztcti_input:_ztcti_index}
                ;;

            # ╶╶╶╶╶ <ctrl-v> (literal insert) ╴╴╴╴╴

            ($'\x16') ;; # disabled

            # ╶╶╶╶╶ <ctrl-w> (delete word) ╴╴╴╴╴

            ($'\x17')
                if (( _ztcti_index != 0 )); then
                    local _ztcti_left=''
                    local _ztcti_word=''
                    ztc:gizmo:words _ztcti_input _ztcti_index left _ztcti_left _ztcti_word

                    ztc[commander:yank]=$_ztcti_word
                    ztc[commander:input]=$_ztcti_left${_ztcti_input:_ztcti_index}
                fi ;;

            # ╶╶╶╶╶ <ctrl-x> (alternate between cursor and beginning) ╴╴╴╴╴

            ($'\x18')
                if (( _ztcti_index != 0 )); then
                    ztc[commander:cursor:last]=$_ztcti_cursor
                    ztc[commander:cursor]=${#_ztcti_input}
                else
                    ztc[commander:cursor]=$ztc[commander:cursor:last]
                fi ;;

            # ╶╶╶╶╶ <ctrl-y> (paste) ╴╴╴╴╴

            ($'\x19') ztc[commander:input]=${_ztcti_input:0:_ztcti_index}$ztc[commander:yank]${_ztcti_input:_ztcti_index} ;;

            # ╶╶╶╶╶ insert key at cursor index ╴╴╴╴╴

            (*) ztc[commander:input]=${_ztcti_input:0:_ztcti_index}$_ztcti_key${_ztcti_input:_ztcti_index} ;;

        esac

        ztc:cassette:paint:cycle commander


    else # input is a shortcut

        case $_ztcti_key in

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
