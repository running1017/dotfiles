#!/bin/bash

source "${SETUP_DIR}/utils.sh"

# 各タスクモジュールの読み込み
source "${SETUP_DIR}/task/package.sh"
source "${SETUP_DIR}/task/shell.sh"
source "${SETUP_DIR}/task/dev_guides.sh"
source "${SETUP_DIR}/task/dotfiles.sh"
source "${SETUP_DIR}/task/gui/main.sh"
source "${SETUP_DIR}/task/ssh.sh"

# タスク実行の制御関数
execute_tasks() {
    local selected=("$@")

    # タスクの実行順序を定義
    local task_order=(
        "base_packages"  # 基本パッケージを最初にインストール
        "shell"          # シェル環境の設定
        "dotfiles"       # 設定ファイルの配置
        "ssh"           # SSH鍵の生成
        "gui_tools"     # GUIツールの設定
    )

    # 選択されたタスクの実行
    for task in "${task_order[@]}"; do
        if [[ " ${selected[@]} " =~ " $task " ]]; then
            case $task in
                "base_packages") install_base_packages ;;
                "shell") setup_zsh ;;
                "dotfiles") setup_dotfiles ;;
                "ssh") setup_ssh ;;
                "gui_tools") install_gui_tools ;;
            esac
        fi
    done

    # セットアップ完了後、開発環境のセットアップガイドを表示
    echo -e "\n${BLUE}=== 開発環境のセットアップガイド ===${NC}"
    echo -e "以下は開発環境をセットアップするための手順です。必要に応じて実行してください。\n"
    show_dev_guides
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
