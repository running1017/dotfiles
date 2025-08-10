#!/bin/bash

# プロジェクトのルートディレクトリを設定
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_DIR="${DOTFILES_ROOT}/scripts/setup"

# 必要なスクリプトの読み込み
source "${SETUP_DIR}/config.sh"
source "${SETUP_DIR}/utils.sh"
source "${SETUP_DIR}/task/main.sh"

# sudo権限が必要なタスクかどうかを判定する関数
needs_sudo_permission() {
    local selected=("$@")
    local sudo_required_tasks=("base_packages" "shell" "gui_tools" "ssh" "dotfiles")
    
    for task in "${selected[@]}"; do
        if [[ " ${sudo_required_tasks[@]} " =~ " $task " ]]; then
            return 0  # sudo権限が必要
        fi
    done
    return 1  # sudo権限不要
}

# メイン処理
main() {
    # 標準出力とエラー出力を保持
    exec 3>&1
    exec 4>&2

    # rootで実行された場合の処理
    if [ "$(id -u)" = "0" ]; then
        echo -e "\033[0;31m[ERROR] このスクリプトはrootとして直接実行せず、必要な場合はsudoを使用してください\033[0m" >&4
        exit 1
    fi

    local selected_array=()
    local show_help=false

    # 引数の解析
    if [[ $# -eq 0 ]]; then
        # デフォルトの選択状態から選択項目を決定
        for key in "${!DEFAULT_SELECTIONS[@]}"; do
            if [[ "${DEFAULT_SELECTIONS[$key]}" == "true" ]]; then
                selected_array+=("$key")
            fi
        done
    else
        # コマンドライン引数の処理
        while [[ $# -gt 0 ]]; do
            case "$1" in
                --base_packages)
                    selected_array+=("base_packages")
                    shift
                    ;;
                --shell)
                    selected_array+=("shell")
                    shift
                    ;;
                --dev_guides)
                    selected_array+=("dev_guides")
                    shift
                    ;;
                --gui_tools)
                    selected_array+=("gui_tools")
                    shift
                    ;;
                --dotfiles)
                    selected_array+=("dotfiles")
                    shift
                    ;;
                --ssh)
                    selected_array+=("ssh")
                    shift
                    ;;
                --all)
                    selected_array=()
                    for key in "${!MENU_ITEMS[@]}"; do
                        selected_array+=("$key")
                    done
                    shift
                    ;;
                --help|-h)
                    display_help
                    exit 0
                    ;;
                *)
                    echo -e "\033[0;31m[ERROR] 不明なオプション: $1\033[0m" >&2
                    display_help
                    exit 1
                    ;;
            esac
        done
    fi

    # sudo権限が必要なタスクがある場合のみ権限チェック
    if needs_sudo_permission "${selected_array[@]}"; then
        if ! sudo -v >&4 2>&1; then
            echo -e "\033[0;31m[ERROR] 選択されたタスクの実行にはsudo権限が必要です\033[0m" >&4
            echo -e "\033[0;33m[INFO] sudo権限が不要なタスク: dev_guides\033[0m" >&4
            exit 1
        fi
    fi

    # 実際のセットアップタスクが実行される場合のみコンソールをクリア
    local has_setup_tasks=false
    for task in "${selected_array[@]}"; do
        if [[ "$task" != "dev_guides" ]]; then
            has_setup_tasks=true
            break
        fi
    done

    if [[ "$has_setup_tasks" == "true" ]] || [[ ${#selected_array[@]} -eq 0 ]]; then
        clear >&3
        echo -e "\033[0;34m[$(date +'%Y-%m-%d %H:%M:%S')]\033[0m Debian系環境セットアップスクリプト" >&3
        if [[ ${#selected_array[@]} -eq 0 ]]; then
            echo "引数が指定されていないため、デフォルトの選択状態を使用します..." >&3
        fi
    fi

    # sudo権限不要タスクのみの場合の情報表示
    if ! needs_sudo_permission "${selected_array[@]}" && [[ ${#selected_array[@]} -gt 0 ]]; then
        echo -e "\033[0;32m[INFO] 選択されたタスクはsudo権限を必要としません\033[0m" >&3
    fi

    if [ ${#selected_array[@]} -eq 0 ]; then
        echo -e "\033[0;31m[ERROR] 選択された項目がありません\033[0m" >&4
        exit 1
    fi

    # 選択内容を表示
    display_selections "${selected_array[@]}"

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

# スクリプトの実行
main "$@"
