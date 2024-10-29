#!/bin/bash

# 汎用的なログ関連の関数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

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

# 汎用的なシステム関連の関数
check_sudo() {
    if ! sudo -v; then
        error "このスクリプトの実行にはsudo権限が必要です"
    fi
}

mkdir_recursive() {
    [ ! -e "$1" ] && mkdir -p "$1" && echo "mkdir: \"$1\"" >&2
}
