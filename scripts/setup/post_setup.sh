#!/bin/bash

# セットアップ後の最終確認と必要な処理を実行

source "${SETUP_DIR}/utils.sh"

post_setup() {
    log "セットアップ後の確認を行っています..."

    # 実際のホームディレクトリを取得
    local real_home
    if [ -n "$SUDO_USER" ]; then
        real_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    else
        real_home=$HOME
    fi

    # シェルの確認
    if [ "$SHELL" != "$(which zsh)" ]; then
        warn "デフォルトシェルがzshに変更されていません"
        warn "デフォルトシェル: $SHELL"
        warn "以下のコマンドを実行してください:"
        warn "chsh -s $(which zsh)"
    fi

    # 各種パスの確認
    local check_paths=(
        "${real_home}/.aliases.d"
        "${real_home}/.zshrc"
    )

    for path in "${check_paths[@]}"; do
        if [ ! -d "$path" ]; then
            warn "$path が存在しません"
        fi
    done

    success "セットアップ後の確認が完了しました"
}
