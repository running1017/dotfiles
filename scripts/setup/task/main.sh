#!/bin/bash

source "${SETUP_DIR}/utils.sh"

# 各タスクモジュールの読み込み
source "${SETUP_DIR}/task/package.sh"
source "${SETUP_DIR}/task/shell.sh"
source "${SETUP_DIR}/task/node.sh"
source "${SETUP_DIR}/task/python.sh"
source "${SETUP_DIR}/task/docker.sh"
source "${SETUP_DIR}/task/dotfiles.sh"
source "${SETUP_DIR}/task/gui/main.sh"
source "${SETUP_DIR}/task/ssh.sh"

# タスク実行の制御関数
execute_tasks() {
    local selected=("$@")

    # タスクの実行順序を定義
    local task_order=(
        "base_packages"
        "zsh"
        "dotfiles"
        "nodejs"
        "python"
        "docker"
        "gui_tools"
        "vscode_extensions"
        "ssh"
    )

    # 選択されたタスクの実行
    for task in "${task_order[@]}"; do
        if [[ " ${selected[@]} " =~ " $task " ]]; then
            case $task in
                "base_packages") install_base_packages ;;
                "zsh") setup_zsh ;;
                "dotfiles") setup_dotfiles ;;
                "nodejs") install_nodejs ;;
                "python") setup_python ;;
                "docker") install_docker ;;
                "gui_tools") install_gui_tools ;;
                "vscode_extensions") setup_vscode ;;
                "ssh") setup_ssh ;;
            esac
        fi
    done
}

# メインの初期化関数
init_setup() {
    log "セットアップを初期化しています..."
    check_sudo
}

# セットアップの完了処理
finish_setup() {
    log "セットアップが完了しました！"
    warn "変更を適用するには、システムを再起動するかログアウト/ログインし直してください。"
}
