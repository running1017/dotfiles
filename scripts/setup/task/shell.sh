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

# oh-my-zshのインストール関数
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log "oh-my-zshをインストールしています..."
        
        # インストールスクリプトの実行
        run_command 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended' \
            "oh-my-zshのインストール"

        # プラグインのインストール
        local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
        mkdir -p "$plugins_dir"

        # zsh-autosuggestions
        if [ ! -d "$plugins_dir/zsh-autosuggestions" ]; then
            run_command "git clone https://github.com/zsh-users/zsh-autosuggestions ${plugins_dir}/zsh-autosuggestions" \
                "zsh-autosuggestionsのインストール"
        fi

        # zsh-syntax-highlighting
        if [ ! -d "$plugins_dir/zsh-syntax-highlighting" ]; then
            run_command "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${plugins_dir}/zsh-syntax-highlighting" \
                "zsh-syntax-highlightingのインストール"
        fi

        success "oh-my-zshのインストールが完了しました"
    else
        warn "oh-my-zshは既にインストールされています"
    fi
}

setup_zsh() {
    log "Zshの設定を行っています..."

    # 実際のユーザー名を取得
    local current_user
    if [ -n "$SUDO_USER" ]; then
        current_user="$SUDO_USER"
    else
        current_user="$(whoami)"
    fi

    # Zshのインストール
    run_apt "install" "zsh" "Zshのインストール"

    # oh-my-zshのインストール
    install_oh_my_zsh

    # ezaのインストール
    install_eza

    # デフォルトシェルの変更
    if [ "$SHELL" != "$(which zsh)" ]; then
        log "デフォルトシェルをZshに変更しています..."
        run_command "sudo chsh -s $(which zsh) $current_user" \
            "デフォルトシェルの変更"
    else
        warn "Zshは既にデフォルトシェルとして設定されています"
    fi

    success "Zshの設定が完了しました"
}
