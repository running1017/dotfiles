#!/bin/bash

source "${SETUP_DIR}/utils.sh"
source "${SETUP_DIR}/task/gui/vscode.sh"
source "${SETUP_DIR}/task/gui/fonts.sh"
# 将来的な他のGUIツールモジュールを読み込む
# source "${SETUP_DIR}/task/gui/browser.sh"
# source "${SETUP_DIR}/task/gui/terminal.sh"
# など

check_gui_environment() {
    if [ ! "$DISPLAY" ]; then
        warn "GUI環境が検出されませんでした"
        return 1
    fi
    return 0
}

install_gui_tools() {
    if ! check_gui_environment; then
        return 1
    fi

    log "GUIツールのインストールを開始します..."

    # VSCode
    setup_vscode

    # フォント
    setup_fonts

    # 将来的な他のGUIツール
    # setup_browser
    # setup_terminal
    # など

    success "GUIツールのインストールが完了しました"
}
