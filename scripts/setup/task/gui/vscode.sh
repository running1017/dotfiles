#!/bin/bash

source "${SETUP_DIR}/utils.sh"

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
        "extensions.json"
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

# メインのセットアップ関数
setup_vscode() {
    log "Visual Studio Code設定ファイルのセットアップを開始します..."

    if ! setup_vscode_symlinks; then
        error "VSCode設定ファイルのセットアップに失敗しました"
        return 1
    fi

    success "Visual Studio Code設定ファイルのセットアップが完了しました"
}
