#!/bin/bash

source "${SETUP_DIR}/utils.sh"

# VSCode専用のシンボリックリンク作成関数
setup_vscode_symlinks() {
    log "VSCode設定ファイルのシンボリックリンクを作成しています..."

    # プラットフォームに応じてVSCodeの設定ディレクトリを決定
    local vscode_config_dir
    case "$(uname)" in
        "Darwin")
            vscode_config_dir="$HOME/Library/Application Support/Code/User"
            ;;
        "Linux")
            vscode_config_dir="$HOME/.config/Code/User"
            ;;
        *)
            warn "未対応のプラットフォームです: $(uname)"
            return 1
            ;;
    esac

    # 設定ディレクトリの作成
    mkdir -p "$vscode_config_dir"

    # リンクを作成する設定ファイルのリスト
    local config_files=(
        "settings.json"
        "keybindings.json"
        "locale.json"
        "snippets"
    )

    # dotfilesのVSCode設定ディレクトリ
    local dotfiles_vscode_dir="${DOTFILES_ROOT}/dotfiles/tools/vscode/User"

    # 各設定ファイルのシンボリックリンクを作成
    for file in "${config_files[@]}"; do
        local target="${dotfiles_vscode_dir}/${file}"
        local link="${vscode_config_dir}/${file}"

        # ターゲットが存在する場合のみリンクを作成
        if [ -e "$target" ]; then
            # 既存のファイル/リンクの処理
            if [ -e "$link" ]; then
                if [ -L "$link" ]; then
                    unlink "$link"
                else
                    mv "$link" "${link}.backup"
                    log "既存の設定ファイルをバックアップしました: ${link}.backup"
                fi
            fi

            # シンボリックリンクの作成
            ln -s "$target" "$link"
            log "リンクを作成: $target -> $link"
        fi
    done

    success "VSCode設定ファイルのリンク作成が完了しました"
}

install_vscode() {
    if ! command -v code &> /dev/null; then
        log "Visual Studio Codeをインストールしています..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg

        sudo apt-get update
        sudo apt-get install -y code
        
        success "Visual Studio Codeのインストールが完了しました"
    else
        warn "VSCodeは既にインストールされています"
    fi
}

setup_vscode_extensions() {
    log "VSCode拡張機能をインストールしています..."

    if ! command -v code &> /dev/null; then
        warn "VSCodeがインストールされていません"
        return 1
    fi

    local extensions_file="${DOTFILES_ROOT}/dotfiles/tools/vscode/User/extensions.json"
    if [ ! -f "$extensions_file" ]; then
        error "extensions.jsonが見つかりません: $extensions_file"
        return 1
    fi

    if command -v jq &> /dev/null; then
        log "推奨拡張機能をインストールしています..."
        local extensions
        extensions=$(jq -r '.recommendations[]' "$extensions_file")
        
        echo "$extensions" | while read -r extension; do
            if [ ! -z "$extension" ]; then
                log "インストール中: $extension"
                code --install-extension "$extension" || warn "$extensionのインストールに失敗しました"
            fi
        done
    else
        error "jqコマンドが見つかりません。パッケージのインストールを確認してください。"
        return 1
    fi

    success "VSCode拡張機能のインストールが完了しました"
}

setup_vscode() {
    # VSCodeのインストール
    install_vscode

    # 設定ファイルのシンボリックリンクを作成
    setup_vscode_symlinks

    # 拡張機能のインストール
    setup_vscode_extensions
}
