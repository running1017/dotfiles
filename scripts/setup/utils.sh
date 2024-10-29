#!/bin/bash

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# ログ関連の関数
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

# sudo権限の確認
check_sudo() {
    if ! sudo -v; then
        error "このスクリプトの実行にはsudo権限が必要です"
    fi
}

# パスの絶対パス化
dotfiles_to_abs_path() {
    local path="$1"
    if [[ "$path" = /* ]]; then
        echo "$path"
    else
        echo "${DOTFILES_ROOT}/dotfiles/$path"
    fi
}

# シンボリックリンクを作成
ln_file() {
    local target="$1"
    local link="$2"

    # 既存のリンクや通常ファイルのバックアップ
    if [ -e "$link" ]; then
        if [ -L "$link" ]; then
            unlink "$link"
        else
            mv "$link" "${link}.backup"
            warn "既存のファイルをバックアップしました: ${link}.backup"
        fi
    fi

    # シンボリックリンクを作成
    ln -s "$target" "$link" && log "リンクを作成: $target -> $link"
}

# シンボリックリンクを削除
unlink_file() {
    unlink "$1" && echo "unlink: \"$1\""
}

# ディレクトリを再帰的に作成
mkdir_recursive() {
    [ ! -e "$1" ] && mkdir -p "$1" && echo "mkdir: \"$1\"" >&2
}

# linklist.txtのコメントを削除
remove_linklist_comment() {
    # '#'以降と空行を削除
    sed -e 's/\s*#.*//' \
        -e '/^\s*$/d' \
        "$1"
}
