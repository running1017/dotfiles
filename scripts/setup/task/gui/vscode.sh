#!/bin/bash

source "${SETUP_DIR}/utils.sh"

# VSCodeのリポジトリとパッケージをインストール
install_vscode() {
    if command -v code &> /dev/null; then
        warn "Visual Studio Codeは既にインストールされています"
        return 0
    fi

    log "Visual Studio Codeをインストールしています..."

    # キーリングディレクトリの作成
    run_command "sudo install -m 0755 -d /etc/apt/keyrings" \
        "キーリングディレクトリの作成"

    # GPGキーの取得と保存
    run_command "curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg" \
        "MicrosoftのGPGキーを取得"

    # リポジトリの追加
    local vscode_repo="deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main"
    add_apt_repository "$vscode_repo" "" "Visual Studio Codeリポジトリの追加"

    # VSCodeのインストール
    run_apt "install" "code" "Visual Studio Codeのインストール"

    success "Visual Studio Codeのインストールが完了しました"
}

# VSCode設定ディレクトリのパスを取得
get_vscode_config_dir() {
    local config_dir

    case "$(uname)" in
        "Darwin")
            config_dir="$HOME/Library/Application Support/Code/User"
            ;;
        "Linux")
            config_dir="$HOME/.config/Code/User"
            ;;
        *)
            error "未対応のプラットフォームです: $(uname)"
            return 1
            ;;
    esac

    echo "$config_dir"
}

# 設定ファイルのシンボリックリンクを作成
setup_vscode_symlinks() {
    log "VSCode設定ファイルのシンボリックリンクを作成しています..."

    local config_dir=$(get_vscode_config_dir)
    if [ $? -ne 0 ]; then
        return 1
    fi

    # 設定ディレクトリの作成
    run_command "mkdir -p \"$config_dir\"" \
        "設定ディレクトリの作成"

    # dotfilesのVSCode設定ディレクトリ
    local dotfiles_vscode_dir="${DOTFILES_ROOT}/dotfiles/tools/vscode/User"

    # リンクを作成する設定ファイルのリスト
    local config_files=(
        "settings.json"
        "keybindings.json"
        "locale.json"
        "snippets"
    )

    # 各設定ファイルのシンボリックリンクを作成
    for file in "${config_files[@]}"; do
        local target="${dotfiles_vscode_dir}/${file}"
        local link="${config_dir}/${file}"

        if [ -e "$target" ]; then
            # 既存のファイル/リンクの処理
            if [ -e "$link" ]; then
                if [ -L "$link" ]; then
                    run_command "unlink \"$link\"" \
                        "既存のシンボリックリンクを削除: $file"
                else
                    run_command "mv \"$link\" \"${link}.backup\"" \
                        "既存の設定ファイルをバックアップ: $file"
                fi
            fi

            # シンボリックリンクの作成
            run_command "ln -s \"$target\" \"$link\"" \
                "シンボリックリンクを作成: $file"
        fi
    done

    success "VSCode設定ファイルのリンク作成が完了しました"
}

# 拡張機能をインストール
install_vscode_extensions() {
    if ! command -v code &> /dev/null; then
        error "VSCodeが見つかりません"
        return 1
    fi

    if ! command -v jq &> /dev/null; then
        error "jqコマンドが見つかりません"
        return 1
    }

    log "VSCode拡張機能をインストールしています..."

    local extensions_file="${DOTFILES_ROOT}/dotfiles/tools/vscode/User/extensions.json"
    if [ ! -f "$extensions_file" ]; then
        error "extensions.jsonが見つかりません: $extensions_file"
        return 1
    }

    # 現在インストールされている拡張機能のリストを取得
    local installed_extensions
    installed_extensions=$(code --list-extensions 2>/dev/null)

    # 推奨拡張機能をインストール
    while read -r extension; do
        if [ -n "$extension" ]; then
            if echo "$installed_extensions" | grep -q "^${extension}$"; then
                warn "拡張機能は既にインストールされています: $extension"
            else
                run_command "code --install-extension \"$extension\"" \
                    "拡張機能をインストール: $extension"
            fi
        fi
    done < <(jq -r '.recommendations[]' "$extensions_file")

    success "VSCode拡張機能のインストールが完了しました"
}

# インストールされたバージョンを確認
check_vscode_version() {
    if command -v code &> /dev/null; then
        log "インストールされたVSCodeのバージョン:"
        run_command "code --version | head -n1" "VSCodeバージョンの確認" true
    else
        warn "VSCodeが見つかりません"
    fi
}

# メインのセットアップ関数
setup_vscode() {
    log "Visual Studio Codeのセットアップを開始します..."

    # GUIが利用可能か確認
    if [ ! "$DISPLAY" ]; then
        error "GUI環境が検出されませんでした"
        return 1
    fi

    # VSCodeのインストール
    install_vscode

    # 設定ファイルのシンボリックリンクを作成
    setup_vscode_symlinks

    # 拡張機能のインストール
    install_vscode_extensions

    # バージョン確認
    check_vscode_version

    success "Visual Studio Codeのセットアップが完了しました"
}
