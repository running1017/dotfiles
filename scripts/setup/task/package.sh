#!/bin/bash

source "${SETUP_DIR}/utils.sh"

install_base_packages() {
    log "基本パッケージをインストールしています..."

    local packages=(
        curl
        wget
        ca-certificates
        gpg
        vim
        git
        unzip
        jq
    )

    run_apt "update" "" "パッケージリストの更新"
    for package in "${packages[@]}"; do
        run_apt "install" "$package" "$package のインストール"
    done

    success "基本パッケージのインストールが完了しました"
}
