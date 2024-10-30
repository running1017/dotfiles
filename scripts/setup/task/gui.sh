#!/bin/bash

source "${SETUP_DIR}/utils.sh"

install_gui_tools() {
    if [ "$DISPLAY" ]; then
        log "GUIツールをインストールしています..."

        # VSCodeのインストール
        if ! command -v code &> /dev/null; then
            log "Visual Studio Codeをインストールしています..."
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
            rm -f packages.microsoft.gpg

            sudo apt-get update
            sudo apt-get install -y code
        else
            warn "VSCodeは既にインストールされています"
        fi

        # HackGen フォントのインストール
        log "HackGen フォントをインストールしています..."
        HACKGEN_VERSION="v2.9.0"
        FONT_DIR="$HOME/.local/share/fonts"

        if [ ! -f "$FONT_DIR/HackGenConsoleNF-Regular.ttf" ]; then
            mkdir -p "$FONT_DIR"
            wget -q "https://github.com/yuru7/HackGen/releases/download/${HACKGEN_VERSION}/HackGen_NF_${HACKGEN_VERSION}.zip"
            unzip -q "HackGen_NF_${HACKGEN_VERSION}.zip" -d hackgen
            cp hackgen/HackGen_NF_${HACKGEN_VERSION}/*.ttf "$FONT_DIR/"
            rm -rf hackgen "HackGen_NF_${HACKGEN_VERSION}.zip"
            fc-cache -f
        else
            warn "HackGenフォントは既にインストールされています"
        fi

        success "GUIツールのインストールが完了しました"
    else
        warn "GUI環境が検出されませんでした"
    fi
}

setup_vscode() {
    local VSCODE_SCRIPT="${DOTFILES_ROOT}/scripts/tools/vscode/setup.sh"
    if command -v code &> /dev/null; then
        log "VSCode拡張機能をインストールしています..."

        if [ -f "$VSCODE_SCRIPT" ]; then
            bash "$VSCODE_SCRIPT"
            success "VSCode拡張機能のインストールが完了しました"
        else
            error "setup.shスクリプトが見つかりません: $VSCODE_SCRIPT"
        fi
    else
        warn "VSCodeがインストールされていません"
    fi
}
