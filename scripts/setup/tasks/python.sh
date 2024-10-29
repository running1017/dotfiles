#!/bin/bash

source "${SETUP_DIR}/utils.sh"

setup_python() {
    log "Python開発環境をセットアップしています..."

    # 必要なパッケージのインストール
    sudo apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        || error "Pythonパッケージのインストールに失敗しました"

    # ryeのインストール
    if ! command -v rye &> /dev/null; then
        log "ryeをインストールしています..."
        curl -sSf https://rye-up.com/get | bash

        # シェル設定の追加
        {
            echo '# rye'
            echo 'source "$HOME/.rye/env"'
        } >> "$HOME/.zshrc"

        # PATHを更新
        source "$HOME/.rye/env"

        # ryeの初期設定と最新Pythonのインストール
        rye config --set-bool behavior.use-uv true
        rye config --set-bool behavior.global-python true
        rye fetch

        success "ryeのインストールが完了しました"
    else
        warn "ryeは既にインストールされています"
    fi

    success "Python開発環境のセットアップが完了しました"
}
