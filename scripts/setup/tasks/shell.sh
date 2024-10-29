#!/bin/bash

source "${SETUP_DIR}/utils.sh"

setup_zsh() {
    log "Zshの設定を行っています..."

    # oh-my-zshのインストール
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log "oh-my-zshをインストールしています..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || error "oh-my-zshのインストールに失敗しました"

        # プラグインのインストール
        local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"

        # zsh-autosuggestions
        if [ ! -d "$plugins_dir/zsh-autosuggestions" ]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
        fi

        # zsh-syntax-highlighting
        if [ ! -d "$plugins_dir/zsh-syntax-highlighting" ]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
        fi
    else
        warn "oh-my-zshは既にインストールされています"
    fi

    # デフォルトシェルの変更
    if [ "$SHELL" != "$(which zsh)" ]; then
        log "デフォルトシェルをZshに変更しています..."
        sudo chsh -s "$(which zsh)" "$USER" || warn "デフォルトシェルの変更に失敗しました"
    fi

    success "Zshの設定が完了しました"
}
