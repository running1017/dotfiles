#!/bin/bash

# デフォルトの選択状態の設定
declare -A DEFAULT_SELECTIONS=(
    ["base_packages"]=true
    ["shell"]=true
    ["nodejs"]=false
    ["python"]=false
    ["docker"]=false
    ["gui_tools"]=false
    ["dotfiles"]=true
    ["ssh"]=false
)

# 各項目の表示名と説明
declare -A MENU_ITEMS=(
    ["base_packages"]="基本パッケージ:基本的なコマンドラインツールをインストールします"
    ["shell"]="shell設定:zsh, eza, starshipのセットアップを行います"
    ["nodejs"]="Node.js:Node.jsとnpmをインストールします"
    ["python"]="Python環境:Python, ryeをセットアップします"
    ["docker"]="Docker:DockerとDocker Composeをインストールします"
    ["gui_tools"]="GUIツール:VSCodeとHackGenフォントをインストールします"
    ["dotfiles"]="Dotfiles:設定ファイルのシンボリックリンクを作成します"
    ["ssh"]="SSH設定:SSH鍵を生成します"
)

# スクリプトのパスを設定
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SETUP_DIR}/scripts"
