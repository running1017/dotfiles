#!/bin/bash

# プロジェクトのルートディレクトリを設定
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_DIR="${DOTFILES_ROOT}/scripts/setup"

# 必要なスクリプトの読み込み
source "${SETUP_DIR}/config.sh"
source "${SETUP_DIR}/ui.sh"
source "${SETUP_DIR}/task/main.sh"
source "${SETUP_DIR}/post_setup.sh"

# メイン処理
main() {
    clear
    log "Debian系環境セットアップスクリプト"
    init_setup

    local selected=()
    if [[ "$1" == "--auto" || "$1" == "--no-interactive" ]]; then
        # デフォルトの選択状態から選択項目を決定
        for key in "${!DEFAULT_SELECTIONS[@]}"; do
            if [[ "${DEFAULT_SELECTIONS[$key]}" == "true" ]]; then
                selected+=("$key")
            fi
        done
    else
        # メニューの表示と選択項目の取得
        selected=($(show_interactive_menu MENU_ITEMS DEFAULT_SELECTIONS))
    fi

    # 選択されたタスクを実行
    execute_tasks "${selected[@]}"

    # 後処理の実行
    post_setup

    # セットアップの完了
    finish_setup
}

# スクリプトの実行
main "$@"
