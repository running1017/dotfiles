#!/bin/sh

# パスの絶対パス化
__dotfiles_to_abs_path() {
    local path="$1"
    if [[ "$path" = /* ]]; then
        echo "$path"
    else
        echo "${DOTFILES_ROOT}/dotfiles/$path"
    fi
}

# シンボリックリンクを作成
__ln() {
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
__unlink() {(
    unlink "$1" && echo "unlink: \"$1\""
)}

# ディレクトリを再帰的に作成
__mkdir() {(
    [ ! -e "$1" ] && mkdir -p "$1" && echo "mkdir: \"$1\"" >&2
)}

# linklist.txtのコメントを削除
__remove_linklist_comment() {(
    # '#'以降と空行を削除
    sed -e 's/\s*#.*//' \
        -e '/^\s*$/d' \
        $1
)}
