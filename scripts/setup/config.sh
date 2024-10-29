#!/bin/bash

# デフォルトの選択状態の設定
declare -A DEFAULT_SELECTIONS=(
    ["base_packages"]=true
    ["zsh"]=true
    ["nodejs"]=false
    ["python"]=false
    ["docker"]=false
    ["gui_tools"]=false
    ["dotfiles"]=true
    ["vscode_extensions"]=false
    ["ssh"]=false
    ["system"]=true
)

# 各項目の表示名と説明
declare -A MENU_ITEMS=(
    ["base_packages"]="基本パッケージ:基本的なコマンドラインツールをインストールします"
    ["zsh"]="Zsh設定:ZshとOh-my-zshのセットアップを行います"
    ["nodejs"]="Node.js:Node.jsとnpmをインストールします"
    ["python"]="Python環境:Python, pyenv, poetryをセットアップします"
    ["docker"]="Docker:DockerとDocker Composeをインストールします"
    ["gui_tools"]="GUIツール:VSCodeとHackGenフォントをインストールします"
    ["dotfiles"]="Dotfiles:設定ファイルのシンボリックリンクを作成します"
    ["vscode_extensions"]="VSCode拡張機能:推奨拡張機能をインストールします"
    ["ssh"]="SSH設定:SSH鍵を生成します"
    ["system"]="システム設定:タイムゾーンとロケールを設定します"
)

# スクリプトのパスを設定
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SETUP_DIR}/scripts"
