#!/bin/bash

source "${SETUP_DIR}/utils.sh"

setup_ssh() {
    log "SSH鍵の生成を行います..."

    if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
        # .sshディレクトリの作成と権限設定
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"

        # メールアドレスの入力
        read -p "メールアドレスを入力してください: " email

        # SSH鍵の生成
        ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519" || error "SSH鍵の生成に失敗しました"

        # ssh-agentの起動と鍵の追加
        eval "$(ssh-agent -s)"
        ssh-add "$HOME/.ssh/id_ed25519"

        echo -e "\nSSH公開鍵:"
        cat "$HOME/.ssh/id_ed25519.pub"

        success "SSH鍵の生成が完了しました"
    else
        warn "SSH鍵は既に存在します"
    fi
}
