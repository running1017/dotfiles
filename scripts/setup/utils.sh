#!/bin/bash

# ログ関連の関数
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

# sudo権限の確認
check_sudo() {
    if ! sudo -v; then
        error "このスクリプトの実行にはsudo権限が必要です"
    fi
}
