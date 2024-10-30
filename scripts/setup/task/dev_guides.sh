#!/bin/bash

source "${SETUP_DIR}/utils.sh"

# ガイドファイルを表示する関数
show_guide() {
    local guide_file="$1"
    local title="$2"
    if [ -f "$guide_file" ]; then
        echo -e "\n${BLUE}=== $title ===${NC}"
        
        # perlを使用してコマンドを色付け
        perl -pe 's/\${CMD}(.*?)\${CMD}/'"${YELLOW}\1${NC}"'/g' "$guide_file"
        
        echo # 空行を追加して見やすくする
    else
        error "ガイドファイルが見つかりません: $guide_file"
    fi
}

show_dev_guides() {
    local guides_dir="${SETUP_DIR}/task/dev"
    log "開発環境のセットアップガイドを表示します..."

    # Node.jsガイド
    show_guide "${guides_dir}/nodejs.txt" "Node.js インストールガイド"

    # Pythonガイド
    show_guide "${guides_dir}/python.txt" "Python インストールガイド"

    # Rustガイド
    show_guide "${guides_dir}/rust.txt" "Rust インストールガイド"

    # プラットフォームに応じたDockerガイドの表示
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case $ID in
            debian)
                show_guide "${guides_dir}/docker_debian.txt" "Docker インストールガイド (Debian)"
                ;;
            ubuntu)
                show_guide "${guides_dir}/docker_ubuntu.txt" "Docker インストールガイド (Ubuntu)"
                ;;
            *)
                show_guide "${guides_dir}/docker_general.txt" "Docker インストールガイド"
                ;;
        esac
    else
        show_guide "${guides_dir}/docker_general.txt" "Docker インストールガイド"
    fi

    echo -e "\n${GREEN}[INFO] インストール後は新しいターミナルを開くか、シェルを再読み込みしてください${NC}"
}