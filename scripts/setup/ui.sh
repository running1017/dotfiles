#!/bin/bash

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

# メニュー項目の順序を定義
MENU_ORDER=(
    "base_packages"
    "shell"
    "nodejs"
    "python"
    "docker"
    "gui_tools"
    "dotfiles"
    "ssh"
)

# yes/noの入力を処理する関数
ask_yes_no() {
    local prompt="$1"
    local default="$2"
    local answer

    while true; do
        # デフォルト値に基づいてプロンプトを調整
        if [ "$default" = "y" ]; then
            printf "\n%s [Y/n] " "$prompt" >&3
        else
            printf "\n%s [y/N] " "$prompt" >&3
        fi

        # 入力を読み取り
        read -r answer

        # 入力が空の場合はデフォルト値を使用
        if [ -z "$answer" ]; then
            answer=$default
        fi

        # 小文字に変換
        answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

        case "$answer" in
            y|yes)
                return 0
                ;;
            n|no)
                return 1
                ;;
            *)
                echo -e "yまたはnを入力してください" >&3
                ;;
        esac
    done
}

# 選択内容を表示する関数
display_selections() {
    echo -e "${BOLD}設定項目${NC}" >&3
    echo -e "${BLUE}----------------------------------------${NC}" >&3
    
    local selected_items="$1"
    
    for key in "${MENU_ORDER[@]}"; do
        local item="${MENU_ITEMS[$key]}"
        [ -z "$item" ] && continue
        
        local name="${item%%:*}"
        local description="${item#*:}"
        local status="[ ]"
        
        if [[ " $selected_items " =~ " ${key} " ]]; then
            status="${GREEN}[×]${NC}"
        fi
        
        printf "%-3b %-20s %s\n" "$status" "$name" "- $description" >&3
    done
    
    echo -e "${BLUE}----------------------------------------${NC}" >&3
}

# 現在の選択項目を表示する関数
display_current_selection() {
    local item="$1"
    local name="${MENU_ITEMS[$item]%%:*}"
    local description="${MENU_ITEMS[$item]#*:}"

    echo -e "\n${BLUE}現在の選択項目: ${name}${NC}" >&3
    echo -e "説明: ${description}" >&3
}

# インタラクティブな選択プロセスを実行
run_interactive_selection() {
    local selected_items=""

    # 初期画面表示
    clear >&3
    display_selections ""

    # 定義された順序で項目を処理
    for key in "${MENU_ORDER[@]}"; do
        local item="${MENU_ITEMS[$key]}"
        [ -z "$item" ] && continue

        local default="${DEFAULT_SELECTIONS[$key]}"
        
        # デフォルト値をy/nに変換
        local default_yn="n"
        if [ "$default" = "true" ]; then
            default_yn="y"
        fi

        # 現在の選択項目を表示
        display_current_selection "$key"
        
        if ask_yes_no "インストールしますか？" "$default_yn"; then
            selected_items="$selected_items $key"
        fi

        # 選択後、画面をクリアして選択状況を更新
        clear >&3
        display_selections "$selected_items"
    done

    # 最終確認画面
    clear >&3
    echo -e "${BOLD}選択が完了しました${NC}" >&3
    display_selections "$selected_items"
    echo -e "\nセットアップを開始します..." >&3
}
