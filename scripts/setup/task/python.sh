#!/bin/bash

source "${SETUP_DIR}/utils.sh"

# Pythonの基本パッケージをインストール
install_python_packages() {
    log "Pythonの基本パッケージをインストールしています..."
    
    local python_packages=(
        python3
        python3-pip
        python3-venv
        python3-distutils  # ryeに必要
        git  # ryeのインストールに必要
    )

    for package in "${python_packages[@]}"; do
        run_apt "install" "$package" "$package のインストール"
    done

    success "Pythonパッケージのインストールが完了しました"
}

# ryeをインストール
install_rye() {
    if command -v rye &> /dev/null; then
        warn "ryeは既にインストールされています"
        return 0
    fi

    log "ryeをインストールしています..."

    # インストールスクリプトの取得と実行
    run_command "curl -sSf https://rye-up.com/get | bash" \
        "ryeインストールスクリプトの実行"

    # 環境変数の設定を確認
    if [ -f "$HOME/.rye/env" ]; then
        source "$HOME/.rye/env"
    else
        error "ryeの環境ファイルが見つかりません"
    fi

    success "ryeのインストールが完了しました"
}

# ryeの環境変数を設定
configure_rye_env() {
    log "ryeの環境変数を設定しています..."
    
    local zshrc="$HOME/.zsh.d/.zshrc"
    local rye_env='source "$HOME/.rye/env"'

    if [ -f "$zshrc" ]; then
        if ! grep -q "source.*rye/env" "$zshrc"; then
            {
                echo ""
                echo "# rye"
                echo "$rye_env"
            } >> "$zshrc"
            success "ryeの環境変数を.zshrcに追加しました"
        else
            warn "ryeの環境変数は既に設定されています"
        fi
    else
        warn ".zshrcが見つかりません"
    fi
}

# ryeの初期設定を実行
configure_rye() {
    log "ryeの初期設定を行っています..."

    if ! command -v rye &> /dev/null; then
        error "ryeが見つかりません。先にインストールしてください"
        return 1
    fi

    # uvを使用するように設定
    run_command "rye config --set-bool behavior.use-uv true" \
        "uvの有効化"

    # グローバルPythonを有効化
    run_command "rye config --set-bool behavior.global-python true" \
        "グローバルPythonの有効化"

    # 最新のPythonをフェッチ
    run_command "rye fetch" \
        "最新のPythonバージョンをフェッチ"

    success "ryeの設定が完了しました"
}

# インストールされたバージョンを確認
check_versions() {
    log "インストールされたバージョンを確認しています..."

    if command -v python3 &> /dev/null; then
        log "Pythonバージョン:"
        run_command "python3 --version" "Pythonバージョンの確認" true
    fi

    if command -v rye &> /dev/null; then
        log "ryeバージョン:"
        run_command "rye --version" "ryeバージョンの確認" true
    fi

    if command -v pip3 &> /dev/null; then
        log "pipバージョン:"
        run_command "pip3 --version" "pipバージョンの確認" true
    fi
}

# メインのセットアップ関数
setup_python() {
    log "Python開発環境をセットアップしています..."

    # Python関連パッケージのインストール
    install_python_packages

    # ryeのインストールと設定
    install_rye
    if [ $? -eq 0 ]; then
        configure_rye_env
        configure_rye
    fi

    # バージョン確認
    check_versions

    success "Python開発環境のセットアップが完了しました"
    
    if [ -n "$SUDO_USER" ]; then
        warn "環境変数を適用するために、新しいシェルセッションを開始してください"
    fi
}
