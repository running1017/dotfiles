#!/bin/bash

source "${SETUP_DIR}/utils.sh"
source "${SETUP_DIR}/task/gui/vscode.sh"
source "${SETUP_DIR}/task/gui/fonts.sh"
# 将来的な他のGUIツールモジュールを読み込む
# source "${SETUP_DIR}/task/gui/browser.sh"
# source "${SETUP_DIR}/task/gui/terminal.sh"
# など

install_gui_tools() {
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
