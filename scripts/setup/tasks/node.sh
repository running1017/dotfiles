#!/bin/bash

source "${SETUP_DIR}/utils.sh"

install_nodejs() {
    log "Node.jsをインストールしています..."

    if ! command -v node &> /dev/null; then
        # nvmのインストール
        if [ ! -d "$HOME/.nvm" ]; then
            log "nvmをインストールしています..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

            # シェル設定の追加
            {
                echo '# nvm'
                echo 'export NVM_DIR="$HOME/.nvm"'
                echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
                echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
            } >> "$HOME/.zshrc"

            # 環境変数の読み込み
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        else
            warn "nvmは既にインストールされています"
        fi

        # Node.jsのインストールと設定
        log "Node.js LTSをインストールしています..."
        nvm install --lts
        nvm use --lts
        nvm alias default 'lts/*'

        # npmパッケージのインストール
        log "npmを更新しています..."
        npm install -g npm@latest

        local packages=(
            yarn
            typescript
            ts-node
            gitmoji-cli
        )

        for package in "${packages[@]}"; do
            log "インストール中: $package"
            npm install -g "$package"
        done

        success "Node.jsのインストールが完了しました"
    else
        warn "Node.jsは既にインストールされています"
    fi
}
