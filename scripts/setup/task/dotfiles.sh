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

    # sudoで実行されている場合は、実際のユーザーの権限で実行
    if [ -n "$SUDO_USER" ]; then
        # リンク先のディレクトリの所有者を変更
        sudo -u "$SUDO_USER" mkdir -p "$(dirname "$link")"
        sudo chown "$SUDO_USER:$SUDO_USER" "$(dirname "$link")"

        if [ -e "$link" ]; then
            if [ -L "$link" ]; then
                sudo -u "$SUDO_USER" unlink "$link"
            else
                sudo -u "$SUDO_USER" mv "$link" "${link}.backup"
                warn "既存のファイルをバックアップしました: ${link}.backup"
            fi
        fi

        # シンボリックリンクを実際のユーザーの権限で作成
        sudo -u "$SUDO_USER" ln -s "$target" "$link"
    else
        # 通常のユーザーとして実行
        mkdir -p "$(dirname "$link")"
        
        if [ -e "$link" ]; then
            if [ -L "$link" ]; then
                unlink "$link"
            else
                mv "$link" "${link}.backup"
                warn "既存のファイルをバックアップしました: ${link}.backup"
            fi
        fi

        ln -s "$target" "$link"
    fi

    log "リンクを作成: $target -> $link"
}

setup_dotfiles() {
    log "dotfilesのリンクを作成しています..."

    # 実際のホームディレクトリを取得
    local real_home
    if [ -n "$SUDO_USER" ]; then
        real_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    else
        real_home=$HOME
    fi

    cd "${DOTFILES_ROOT}/dotfiles" || exit 1

    for linklist in "linklist.Unix.txt" "linklist.$(uname).txt"; do
        [ ! -r "${linklist}" ] && continue
        log "リンクリストを処理中: ${linklist}"

        # HOME環境変数を一時的に上書き
        local original_home=$HOME
        export HOME=$real_home

        # リンクリストの各行を処理
        while read -r target link; do
            [ -z "$target" ] && continue
            target=$(dotfiles_to_abs_path "$target")
            link=$(eval echo "$link")
            ln_file "$target" "$link"
        done < <(remove_linklist_comment "$linklist")

        # HOME環境変数を元に戻す
        export HOME=$original_home
    done

    success "dotfilesのリンク作成が完了しました"
}
