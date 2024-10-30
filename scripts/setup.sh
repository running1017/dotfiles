#!/bin/bash

# プロジェクトのルートディレクトリを設定
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_DIR="${DOTFILES_ROOT}/scripts/setup"

# 必要なスクリプトの読み込み
source "${SETUP_DIR}/config.sh"
source "${SETUP_DIR}/ui.sh"
source "${SETUP_DIR}/utils.sh"
source "${SETUP_DIR}/task/main.sh"

# メイン処理
main() {
    # 標準出力とエラー出力を保持
    exec 3>&1
    exec 4>&2

    clear >&3
    echo -e "\033[0;34m[$(date +'%Y-%m-%d %H:%M:%S')]\033[0m Debian系環境セットアップスクリプト" >&3

    # rootで実行された場合の処理
    if [ "$(id -u)" = "0" ]; then
        echo -e "\033[0;31m[ERROR] このスクリプトはrootとして直接実行せず、必要な場合はsudoを使用してください\033[0m" >&4
        exit 1
    fi

    # sudoの権限をチェック
    if ! sudo -v >&4 2>&1; then
        echo -e "\033[0;31m[ERROR] このスクリプトの実行にはsudo権限が必要です\033[0m" >&4
        exit 1
    fi

    local selected_items=""
    local selected_array=()

    if [[ "$1" == "--auto" || "$1" == "--no-interactive" ]]; then
        echo "自動モードで実行します..." >&3
        # デフォルトの選択状態から選択項目を決定
        for key in "${!DEFAULT_SELECTIONS[@]}"; do
            if [[ "${DEFAULT_SELECTIONS[$key]}" == "true" ]]; then
                selected_array+=("$key")
            fi
        done
    else
        echo "対話モードで実行します..." >&3
        # インタラクティブな選択プロセスを実行
        selected_items=$(run_interactive_selection)
        if [ $? -ne 0 ]; then
            echo -e "\033[0;31m[ERROR] 選択プロセスでエラーが発生しました\033[0m" >&4
            exit 1
        fi
        read -r -a selected_array <<< "$selected_items"
    fi

    if [ ${#selected_array[@]} -eq 0 ]; then
        echo -e "\033[0;31m[ERROR] 選択された項目がありません\033[0m" >&4
        exit 1
    fi

    # 選択内容の最終確認を表示
    display_selections "$selected_items" >&3
    echo -e "セットアップを開始します..." >&3
    sleep 1

    # 選択されたタスクを実行
    execute_tasks "${selected_array[@]}"

    # セットアップの完了
    finish_setup

    # 標準出力とエラー出力を復元
    exec 1>&3
    exec 2>&4
    exec 3>&-
    exec 4>&-
}

# エラーが発生した場合の処理を追加
trap 'echo -e "\033[0;31m[ERROR] スクリプトの実行中にエラーが発生しました\033[0m" >&4; exit 1' ERR

# スクリプトの実行
main "$@"
