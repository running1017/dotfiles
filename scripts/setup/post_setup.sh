#!/bin/bash

# セットアップ後の最終確認と必要な処理を実行

source "${SETUP_DIR}/utils.sh"

post_setup() {
    log "セットアップ後の確認を行っています..."

    # シェルの確認
    if [ "$SHELL" != "$(which zsh)" ]; then
        warn "デフォルトシェルがZshに変更されていません"
        echo "以下のコマンドを実行してください:"
        echo "chsh -s $(which zsh)"
    fi

    # 各種パスの確認
    local check_paths=(
        "$HOME/.oh-my-zsh"
        "$HOME/.aliases"
        "$HOME/.zsh.d"
    )

    for path in "${check_paths[@]}"; do
        if [ ! -d "$path" ]; then
            warn "$path が存在しません"
        fi
    done

    success "セットアップ後の確認が完了しました"
}
