#!/bin/bash

# プロジェクトのルートディレクトリを設定
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_DIR="${DOTFILES_ROOT}/scripts/setup"

# 必要なスクリプトの読み込み
source "${SETUP_DIR}/config.sh"
source "${SETUP_DIR}/ui.sh"
source "${SETUP_DIR}/utils.sh"
source "${SETUP_DIR}/task/main.sh"
source "${SETUP_DIR}/post_setup.sh"

# メイン処理
main() {
    clear
    log "Debian系環境セットアップスクリプト"

    # rootで実行された場合の処理
    if [ "$(id -u)" = "0" ]; then
        error "このスクリプトはrootとして直接実行せず、必要な場合はsudoを使用してください"
        exit 1
    fi

    # sudoの権限をチェック
    if ! sudo -v; then
        error "このスクリプトの実行にはsudo権限が必要です"
        exit 1
    fi

    local selected_items=""
    local selected_array=()

    if [[ "$1" == "--auto" || "$1" == "--no-interactive" ]]; then
        echo "自動モードで実行します..."
        # デフォルトの選択状態から選択項目を決定
        for key in "${!DEFAULT_SELECTIONS[@]}"; do
            if [[ "${DEFAULT_SELECTIONS[$key]}" == "true" ]]; then
                selected_array+=("$key")
            fi
        done
        # デバッグ出力
        echo "選択された項目: ${selected_array[*]}"
    else
        echo "対話モードで実行します..."
        # インタラクティブな選択プロセスを実行
        if ! selected_items=$(run_interactive_selection); then
            error "選択プロセスでエラーが発生しました"
            exit 1
        fi
        # デバッグ出力
        echo "選択結果: $selected_items"
        # 文字列を配列に分割
        read -r -a selected_array <<< "$selected_items"
    fi

    if [ ${#selected_array[@]} -eq 0 ]; then
        error "選択された項目がありません"
        exit 1
    fi

    echo "選択された項目数: ${#selected_array[@]}"
    echo "選択された項目: ${selected_array[*]}"

    # 選択内容の最終確認を表示
    display_selections "$selected_items"
    echo -e "セットアップを開始します..."
    sleep 1

    # 選択されたタスクを実行
    execute_tasks "${selected_array[@]}"

    # 後処理の実行
    post_setup

    # セットアップの完了
    finish_setup
}

# エラーが発生した場合の処理を追加
trap 'error "スクリプトの実行中にエラーが発生しました"; exit 1' ERR

# スクリプトの実行
main "$@"
