#!/bin/bash

source "${SETUP_DIR}/utils.sh"

remove_linklist_comment() {
    sed -e 's/\s*#.*//' \
        -e '/^\s*$/d' \
        "$1"
}

dotfiles_to_abs_path() {
    local path="$1"
    if [[ "$path" = /* ]]; then
        echo "$path"
    else
        echo "${DOTFILES_ROOT}/dotfiles/$path"
    fi
}

ln_file() {
    local target="$1"
    local link="$2"

    if [ -e "$link" ]; then
        if [ -L "$link" ]; then
            unlink "$link"
        else
            mv "$link" "${link}.backup"
            warn "既存のファイルをバックアップしました: ${link}.backup"
        fi
    fi

    ln -s "$target" "$link" && log "リンクを作成: $target -> $link"
}

setup_dotfiles() {
    log "dotfilesのリンクを作成しています..."

    cd "${DOTFILES_ROOT}/dotfiles" || exit 1

    for linklist in "linklist.Unix.txt" "linklist.$(uname).txt"; do
        [ ! -r "${linklist}" ] && continue
        log "リンクリストを処理中: ${linklist}"

        remove_linklist_comment "$linklist" | while read -r target link; do
            target=$(dotfiles_to_abs_path "$target")
            link=$(eval echo "$link")

            mkdir_recursive "$(dirname "$link")"
            ln_file "$target" "$link"
        done
    done

    success "dotfilesのリンク作成が完了しました"
}
