#!/bin/bash

source "${SETUP_DIR}/utils.sh"

install_docker() {
    log "Dockerをインストールしています..."

    if command -v docker &> /dev/null; then
        warn "Dockerは既にインストールされています"
        return 0
    fi

    # 古いバージョンの削除
    log "古いバージョンのDockerを削除しています..."
    local old_packages=(
        docker.io
        docker-doc
        docker-compose
        podman-docker
        containerd
        runc
    )
    
    for package in "${old_packages[@]}"; do
        if dpkg -l | grep -q "^ii  $package "; then
            run_apt "remove" "$package" "古いパッケージの削除: $package"
        fi
    done

    # 必要なパッケージのインストール
    log "依存パッケージをインストールしています..."
    local deps=(
        apt-transport-https
        ca-certificates
        curl
        gnupg
        lsb-release
    )

    run_apt "update" "" "パッケージリストの更新"
    for package in "${deps[@]}"; do
        run_apt "install" "$package" "$package のインストール"
    done

    # Dockerの公式GPGキーとリポジトリの追加
    log "Dockerリポジトリを設定しています..."
    
    # キーリングディレクトリの作成
    run_command "sudo install -m 0755 -d /etc/apt/keyrings" \
        "キーリングディレクトリの作成"

    # GPGキーの取得と保存
    run_command "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.asc" \
        "DockerのGPGキーを取得"
    
    run_command "sudo chmod a+r /etc/apt/keyrings/docker.asc" \
        "GPGキーファイルの権限を設定"

    # リポジトリの追加
    local docker_repo="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable"
    
    add_apt_repository "$docker_repo" "" "Dockerリポジトリの追加"

    # Dockerパッケージのインストール
    log "Dockerパッケージをインストールしています..."
    local docker_packages=(
        docker-ce
        docker-ce-cli
        containerd.io
        docker-buildx-plugin
        docker-compose-plugin
    )

    for package in "${docker_packages[@]}"; do
        run_apt "install" "$package" "$package のインストール"
    done

    # ユーザーをdockerグループに追加
    local current_user
    if [ -n "$SUDO_USER" ]; then
        current_user="$SUDO_USER"
    else
        current_user="$(whoami)"
    fi

    log "ユーザーをdockerグループに追加しています..."
    run_command "sudo usermod -aG docker $current_user" \
        "ユーザー $current_user をdockerグループに追加"

    # Dockerサービスが動作していることを確認
    if ! systemctl is-active --quiet docker; then
        run_command "sudo systemctl start docker" "Dockerサービスを開始"
        run_command "sudo systemctl enable docker" "Dockerサービスを有効化"
    fi

    success "Dockerのインストールが完了しました"
    warn "Dockerを使用するには、システムからログアウトして再度ログインする必要があります"
}
