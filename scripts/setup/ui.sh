#!/bin/bash

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

# カーソル位置の保存と復元
save_cursor() {
    tput sc
}

restore_cursor() {
    tput rc
}

# 画面クリア
clear_screen() {
    tput clear
}

# カーソルを非表示/表示
hide_cursor() {
    tput civis
}

show_cursor() {
    tput cnorm
}

# キー入力の取得
read_key() {
    local key
    read -s -n1 key 2>/dev/null >&2
    if [[ $key = "" ]]; then
        echo Space
    elif [[ $key = $'\x1b' ]]; then
        read -s -n2 key 2>/dev/null >&2
        if [[ $key = "[A" ]]; then echo Up
        elif [[ $key = "[B" ]]; then echo Down
        fi
    elif [[ $key = "q" ]]; then
        echo Quit
    elif [[ $key = "" ]]; then
        echo Enter
    fi
}

# メニューの表示
draw_menu() {
    local -n items=$1
    local -n current_index=$2
    local -n selected_items=$3

    clear_screen
    echo -e "${BOLD}=== セットアップメニュー ===${NC}\n"
    echo -e "${YELLOW}[スペース]${NC}で選択/解除、${YELLOW}[Enter]${NC}で実行開始、${YELLOW}[q]${NC}で終了\n"

    local i=0
    for key in "${!items[@]}"; do
        local item="${items[$key]}"
        local name="${item%%:*}"
        local description="${item#*:}"

        if [ $i -eq $current_index ]; then
            echo -en "${BLUE}>"
        else
            echo -en " "
        fi

        if [[ "${selected_items[$key]}" == "true" ]]; then
            echo -en " [${GREEN}×${NC}]"
        else
            echo -en " [ ]"
        fi

        if [ $i -eq $current_index ]; then
            echo -e " ${BOLD}${name}${NC}"
            echo -e "   ${description}"
        else
            echo -e " ${name}"
        fi

        ((i++))
    done
}

# インタラクティブメニュー
show_interactive_menu() {
    local -n menu_items=$1
    local -n default_selections=$2
    declare -A SELECTED_ITEMS

    # デフォルト値の設定
    for key in "${!menu_items[@]}"; do
        SELECTED_ITEMS[$key]=${default_selections[$key]}
    done

    local current_index=0
    local items_count=${#menu_items[@]}

    hide_cursor
    trap show_cursor EXIT

    while true; do
        draw_menu menu_items current_index SELECTED_ITEMS

        case $(read_key) in
            Space)
                local keys=(${!menu_items[@]})
                local key=${keys[$current_index]}
                if [[ "${SELECTED_ITEMS[$key]}" == "true" ]]; then
                    SELECTED_ITEMS[$key]="false"
                else
                    SELECTED_ITEMS[$key]="true"
                fi
                ;;
            Up)
                ((current_index--))
                [ $current_index -lt 0 ] && current_index=$((items_count - 1))
                ;;
            Down)
                ((current_index++))
                [ $current_index -ge $items_count ] && current_index=0
                ;;
            Enter)
                show_cursor
                local selected=()
                for key in "${!SELECTED_ITEMS[@]}"; do
                    [[ "${SELECTED_ITEMS[$key]}" == "true" ]] && selected+=("$key")
                done
                echo "${selected[@]}"
                return
                ;;
            Quit)
                show_cursor
                exit 0
                ;;
        esac
    done
}
