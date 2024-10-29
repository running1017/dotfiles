#!/bin/bash

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_DIR="${DOTFILES_ROOT}/scripts/setup"

# 必要なスクリプトの読み込み
source "${SETUP_DIR}/config.sh"
source "${SETUP_DIR}/ui.sh"
source "${SETUP_DIR}/utils.sh"
source "${SETUP_DIR}/tasks.sh"
source "${SETUP_DIR}/post_setup.sh"

# タスクの実行順序を定義
task_order=(
    "base_packages"
    "system"
    "zsh"
    "dotfiles"
    "nodejs"
    "python"
    "docker"
    "gui_tools"
    "vscode_extensions"
    "ssh"
)

# メイン処理
main() {
    clear
    log "Debian系環境セットアップスクリプト"
    check_sudo

    if [[ "$1" == "--auto" || "$1" == "--no-interactive" ]]; then
        # デフォルトの選択状態から選択項目を決定
        selected=()
        for key in "${!DEFAULT_SELECTIONS[@]}"; do
            if [[ "${DEFAULT_SELECTIONS[$key]}" == "true" ]]; then
                selected+=("$key")
            fi
        done
    else
        # メニューの表示と選択項目の取得
        selected=($(show_interactive_menu MENU_ITEMS DEFAULT_SELECTIONS))
    fi

    # 選択された項目の実行
    for item in "${task_order[@]}"; do
        if [[ " ${selected[@]} " =~ " $item " ]]; then
            case $item in
                "base_packages") install_base_packages ;;
                "zsh") setup_zsh ;;
                "nodejs") install_nodejs ;;
                "python") setup_python ;;
                "docker") install_docker ;;
                "gui_tools") install_gui_tools ;;
                "dotfiles") setup_dotfiles ;;
                "vscode_extensions") setup_vscode ;;
                "ssh") setup_ssh ;;
                "system") setup_system ;;
            esac
        fi
    }

    post_setup

    log "セットアップが完了しました！"
    warn "変更を適用するには、システムを再起動するかログアウト/ログインし直してください。"
}

# スクリプトの実行
main "$@"
