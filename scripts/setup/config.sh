#!/bin/bash

# デフォルトの選択状態の設定
declare -A DEFAULT_SELECTIONS=(
    ["base_packages"]=true
    ["shell"]=true
    ["dev_guides"]=false
    ["gui_tools"]=false
    ["dotfiles"]=true
    ["ssh"]=false
)

# 各項目の表示名と説明
declare -A MENU_ITEMS=(
    ["base_packages"]="base_packages:基本的なコマンドラインツールをインストールします"
    ["shell"]="shell:zsh, eza, starshipのセットアップを行います"
    ["dev_guides"]="Development:Node.js, Python, Rust, Dockerのセットアップガイドを表示します"
    ["gui_tools"]="GUI:VSCodeとHackGenフォントをインストールします"
    ["dotfiles"]="Dotfiles:設定ファイルのシンボリックリンクを作成します"
    ["ssh"]="SSH:SSH鍵を生成します"
)

# スクリプトのパスを設定
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SETUP_DIR}/scripts"
