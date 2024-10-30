#!/bin/bash

source "${SETUP_DIR}/utils.sh"

install_docker() {
    log "Dockerをインストールしています..."

    if ! command -v docker &> /dev/null; then
        # 古いバージョンの削除
        for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

        # 必要なパッケージのインストール
        sudo apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            lsb-release

        # Dockerの公式GPGキーとリポジトリの追加
        sudo apt-get update
        sudo apt-get install ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Dockerのインストール
        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # ユーザーをdockerグループに追加
        sudo usermod -aG docker $USER

        success "Dockerのインストールが完了しました"
    else
        warn "Dockerは既にインストールされています"
    fi
}
