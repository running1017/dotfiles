#!/bin/bash

# デフォルトの選択状態の設定
declare -A DEFAULT_SELECTIONS=(
    ["base_packages"]=true
    ["shell"]=true
    ["dotfiles"]=true
    ["ssh"]=false
    ["gui_tools"]=false
)

# 各項目の表示名と説明
declare -A MENU_ITEMS=(
    ["base_packages"]="base_packages:基本的なコマンドラインツールをインストールします"
    ["shell"]="shell:zsh, eza, starshipのセットアップを行います"
    ["dotfiles"]="dotfiles:設定ファイルのシンボリックリンクを作成します"
    ["ssh"]="ssh:SSH鍵を生成します"
    ["gui_tools"]="gui_tools:GUIツールの設定を行います"
)

# メニュー項目の順序を定義
MENU_ORDER=(
    "base_packages"
    "shell"
    "dotfiles"
    "ssh"
    "gui_tools"
)
