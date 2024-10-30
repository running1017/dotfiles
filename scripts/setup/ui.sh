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
    "zsh"
    "nodejs"
    "python"
    "docker"
    "gui_tools"
    "dotfiles"
    "vscode_extensions"
    "ssh"
)

# 確実に標準出力に出力する関数
print_stdout() {
    echo -e "$1" > /dev/tty
}

# yes/noの入力を処理する関数
ask_yes_no() {
    local prompt="$1"
    local default="$2"
    local answer

    while true; do
        # デフォルト値に基づいてプロンプトを調整
        if [ "$default" = "y" ]; then
            printf "%s [Y/n] " "$prompt" > /dev/tty
        else
            printf "%s [y/N] " "$prompt" > /dev/tty
        fi

        # 入力を読み取り
        read -r answer < /dev/tty

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
                print_stdout "yまたはnを入力してください"
                ;;
        esac
    done
}

# 選択内容を表示する関数
display_selections() {
    print_stdout "\n${BOLD}選択された項目:${NC}"
    print_stdout "${BLUE}----------------------------------------${NC}"
    
    for key in "${MENU_ORDER[@]}"; do
        local item="${MENU_ITEMS[$key]}"
        local name="${item%%:*}"
        local description="${item#*:}"
        local status="[ ]"
        
        if [[ " $1 " =~ " ${key} " ]]; then
            status="${GREEN}[×]${NC}"
        fi
        
        printf "%-4s %-20s - %s\n" "$status" "$name" "$description" > /dev/tty
    done
    
    print_stdout "${BLUE}----------------------------------------${NC}\n"
}

# インタラクティブな選択プロセスを実行
run_interactive_selection() {
    local selected_items=""

    print_stdout "\n各項目をインストールするか選択してください（Enterでデフォルト値を選択）\n"

    # 定義された順序で項目を処理
    for key in "${MENU_ORDER[@]}"; do
        local item="${MENU_ITEMS[$key]}"
        if [ -z "$item" ]; then
            continue
        fi

        local name="${item%%:*}"
        local description="${item#*:}"
        local default="${DEFAULT_SELECTIONS[$key]}"
        
        # デフォルト値をy/nに変換
        local default_yn="n"
        if [ "$default" = "true" ]; then
            default_yn="y"
        fi

        print_stdout "\n${BLUE}${name}${NC}"
        print_stdout "説明: ${description}"
        
        if ask_yes_no "インストールしますか？" "$default_yn"; then
            selected_items="$selected_items $key"
        fi

        # 選択後、現在までの選択状況を表示
        clear > /dev/tty
        display_selections "$selected_items"
    done

    echo "$selected_items"
}
