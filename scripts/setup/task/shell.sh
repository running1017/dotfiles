#!/bin/bash

source "${SETUP_DIR}/utils.sh"

# ezaのインストール関数
install_eza() {
    log "ezaをインストールしています..."
    
    # 必要なディレクトリの作成
    sudo mkdir -p /etc/apt/keyrings

    # GPGキーの取得と変換を一つのコマンドで実行
    run_command "curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg" \
        "ezaのGPGキーを取得しています"
    
    # キーリングファイルのパーミッション設定
    run_command "sudo chmod 644 /etc/apt/keyrings/gierens.gpg" \
        "GPGキーファイルの権限を設定"

    # sources.listの追加
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
        sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
    run_command "sudo chmod 644 /etc/apt/sources.list.d/gierens.list" \
        "リポジトリリストファイルの権限を設定"

    # パッケージリストの更新とezaのインストール
    run_apt "update" "" "パッケージリストの更新"
    run_apt "install" "eza" "ezaのインストール"

    success "ezaのインストールが完了しました"
}

# starshipのインストール関数
install_starship() {
    if command -v starship &> /dev/null; then
        warn "starshipは既にインストールされています"
        return 0
    fi

    log "starshipをインストールしています..."
    
    # インストールスクリプトの実行
    run_command 'curl -sS https://starship.rs/install.sh | sh -s -- --yes' \
        "starshipのインストール"

    success "starshipのインストールが完了しました"
}

setup_zsh() {
    log "zshの設定を行っています..."

    # 実際のユーザー名を取得
    local current_user
    if [ -n "$SUDO_USER" ]; then
        current_user="$SUDO_USER"
    else
        current_user="$(whoami)"
    fi

    # zshのインストール
    run_apt "install" "zsh" "zshのインストール"

    # starshipのインストール
    install_starship

    # ezaのインストール
    install_eza

    # デフォルトシェルの変更
    if [ "$SHELL" != "$(which zsh)" ]; then
        log "デフォルトシェルをzshに変更しています..."
        run_command "sudo chsh -s $(which zsh) $current_user" \
            "デフォルトシェルの変更"
    else
        warn "zshは既にデフォルトシェルとして設定されています"
    fi

    success "zshの設定が完了しました"
}
