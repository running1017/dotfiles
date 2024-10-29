#!/bin/bash

# プロジェクトのルートディレクトリの絶対パスを取得
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Dockerイメージをビルド
docker build -t dotfiles-test tests/

# テスト用コンテナを起動
docker run -it \
    -v "${PROJECT_ROOT}:/home/testuser/.dotfiles" \
    --name dotfiles-test-container \
    dotfiles-test \
    bash -c "cd ~/.dotfiles && sudo ./scripts/setup.sh"

# テスト完了後、コンテナを削除
# (エラー時のデバッグのため--rmオプションではなく明示的に削除)
docker rm dotfiles-test-container
