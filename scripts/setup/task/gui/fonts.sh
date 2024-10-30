#!/bin/bash

source "${SETUP_DIR}/utils.sh"

install_hackgen_font() {
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
        
        success "HackGenフォントのインストールが完了しました"
    else
        warn "HackGenフォントは既にインストールされています"
    fi
}

setup_fonts() {
    log "フォントのセットアップを開始します..."
    install_hackgen_font
    # 他のフォントのインストール関数をここに追加
    success "フォントのセットアップが完了しました"
}
