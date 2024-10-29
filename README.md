# dotfiles

## 概要

このリポジトリは、Unix/Linux/macOS環境向けの設定ファイル（dotfiles）と環境セットアップスクリプトを提供します。主にDebian系Linux環境をターゲットとしていますが、macOSでも使用可能です。

## 主な機能

- 対話式のセットアップスクリプト
- クロスプラットフォーム対応の設定ファイル管理
- 開発環境の自動セットアップ
- VSCode設定とおすすめ拡張機能の管理

## セットアップ内容

- 基本パッケージのインストール（vim, curl, git, eza など）
- Zshとoh-my-zshのセットアップ
- Node.js開発環境（nvm経由）
- Python開発環境（rye経由）
- Docker環境
- VSCodeとHackGenフォント
- システム設定（タイムゾーン、ロケールなど）

## ディレクトリ構造

```text
.
├── dotfiles/           # 設定ファイル本体
│   ├── bin/            # カスタムコマンド
│   ├── shell/          # シェル関連の設定
│   └── tools/          # 各種ツールの設定
├── scripts/            # セットアップスクリプト
│   ├── setup/          # セットアップモジュール
│   ├── setup.sh        # メインセットアップスクリプト
│   └── tools/          # ツール固有のセットアップ
```

## 使い方

1. リポジトリのクローン:

```bash
git clone https://github.com/running1017/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

1. セットアップスクリプトの実行:

```bash
./scripts/setup.sh
```

1. インストールしたい項目を選択:

- スペースキー: 項目の選択/解除
- エンターキー: インストール開始
- q: 終了

## カスタマイズ

### 除外パターンの設定

`~/.config/dir_output/config`で`dir_output`コマンドの除外パターンを設定できます。

### エイリアスの追加

`dotfiles/shell/.aliases.d/`以下に新しいエイリアスファイルを作成し、
`loader.sh`に読み込み処理を追加します。

### 設定ファイルの追加

1. 設定ファイルを`dotfiles/`以下の適切な場所に配置
2. `dotfiles/linklist.{Unix,Darwin,Linux}.txt`に設定ファイルとリンク先を追加

## 同梱ツール

### dir_output

ディレクトリ構造をMarkdownファイルとして出力するツール。

```bash
dir_output         # 現在のディレクトリの構造を出力
dir_output -e      # 除外パターンを編集
dir_output -h      # ヘルプを表示
```

## システム要件

- Debian系Linux（Ubuntu推奨）またはmacOS
- sudo権限
- 基本的なコマンドラインツール（curl, git）

## 注意事項

- セットアップ前に既存の設定ファイルのバックアップを推奨
- 既存の設定ファイルは`.backup`拡張子付きで自動バックアップされます
- システム設定の変更にはsudo権限が必要です
