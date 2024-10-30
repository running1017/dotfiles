#!/bin/bash

source "${SETUP_DIR}/utils.sh"

install_base_packages() {
    log "基本パッケージをインストールしています..."

    # 必要なパッケージのリスト
    local initial_packages=(
        curl
        wget
        ca-certificates
        gpg
    )

    # 最初に必要なパッケージをインストール
    sudo apt update || error "apt updateに失敗しました"
    for package in "${initial_packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            log "インストール中: $package"
            sudo apt install -y "$package" || warn "$package のインストールに失敗しました"
        else
            log "$package は既にインストールされています"
        fi
    done

    # ezaのインストール
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza

    # 残りのパッケージをインストール
    local packages=(
        vim
        wget
        git
        zsh
        unzip
        jq
    )

    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            log "インストール中: $package"
            sudo apt install -y "$package" || warn "$package のインストールに失敗しました"
        else
            log "$package は既にインストールされています"
        fi
    done

    success "基本パッケージのインストールが完了しました"
}
