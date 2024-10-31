#!/bin/bash

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

# 必要な設定を読み込み
source "${SETUP_DIR}/config.sh"

# 基本的なログ関数
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}" >&2
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

# コマンドを実行し、出力を表示する関数
run_command() {
    local command_str="$1"
    local description="${2:-実行中のコマンド: $command_str}"
    local show_output=${3:-true}
    local error_message="${4:-コマンドの実行に失敗しました}"

    log "$description"
    if [ "$show_output" = true ]; then
        echo -e "${GRAY}$ $command_str${NC}"
    fi

    # コマンドの実行結果を一時ファイルに保存
    local temp_file
    temp_file=$(mktemp)
    local exit_status=0

    if eval "$command_str" > "$temp_file" 2>&1; then
        if [ "$show_output" = true ] && [ -s "$temp_file" ]; then
            echo -e "${GRAY}$(cat "$temp_file")${NC}"
        fi
        success "$description が完了しました"
    else
        exit_status=$?
        if [ -s "$temp_file" ]; then
            echo -e "${GRAY}$(cat "$temp_file")${NC}"
        fi
        error "$error_message (exit code: $exit_status)"
    fi

    rm -f "$temp_file"
    return $exit_status
}

# aptコマンド専用の実行関数
run_apt() {
    local command="$1"
    local package="$2"
    local description="$3"

    case "$command" in
        "install")
            if dpkg -l | grep -q "^ii  $package "; then
                warn "$package は既にインストールされています"
                return 0
            fi
            run_command "sudo apt-get install -y $package" "$description"
            ;;
        "update")
            run_command "sudo apt-get update" "パッケージリストの更新"
            ;;
        "upgrade")
            run_command "sudo apt-get upgrade -y" "パッケージのアップグレード"
            ;;
        *)
            run_command "sudo apt-get $command $package" "$description"
            ;;
    esac
}

# 汎用的なシステム関数
check_sudo() {
    if ! sudo -v; then
        error "このスクリプトの実行にはsudo権限が必要です"
    fi
}

mkdir_recursive() {
    if [ ! -e "$1" ]; then
        if [ -n "$SUDO_USER" ]; then
            # sudoで実行されている場合は、実際のユーザーの権限で作成
            sudo -u "$SUDO_USER" mkdir -p "$1"
        else
            mkdir -p "$1"
        fi
        echo "mkdir: \"$1\"" >&2
    fi
}

# ヘルプを表示する関数
display_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "オプション:"
    echo "  --all              すべての項目を選択します"
    echo "  --base_packages    基本的なコマンドラインツールをインストールします"
    echo "  --shell            zsh, eza, starshipのセットアップを行います"
    echo "  --dev_guides       Node.js, Python, Rust, Dockerのセットアップガイドを表示します"
    echo "  --gui_tools        VSCodeとHackGenフォントをインストールします"
    echo "  --dotfiles         設定ファイルのシンボリックリンクを作成します"
    echo "  --ssh              SSH鍵を生成します"
    echo "  -h, --help         このヘルプを表示します"
    echo ""
    echo "引数を指定しない場合、デフォルトの選択状態が使用されます。"
}

# 選択された項目を表示する関数
display_selections() {
    local selected_items=("$@")

    echo -e "${BOLD}選択された項目:${NC}" >&3
    echo -e "${BLUE}----------------------------------------${NC}" >&3

    for key in "${MENU_ORDER[@]}"; do
        local item="${MENU_ITEMS[$key]}"
        [ -z "$item" ] && continue

        local name="${item%%:*}"
        local description="${item#*:}"
        local status="[ ]"

        if [[ " ${selected_items[*]} " =~ " ${key} " ]]; then
            status="${GREEN}[×]${NC}"
        fi

        printf "%-3b %-20s %s\n" "$status" "$name" "- $description" >&3
    done

    echo -e "${BLUE}----------------------------------------${NC}" >&3
}
