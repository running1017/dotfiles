#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 既存のテストコンテナがあれば削除
if docker ps -a --format '{{.Names}}' | grep -q '^dotfiles-test-container$'; then
    echo "既存のテストコンテナを削除します..."
    docker rm -f dotfiles-test-container
fi

# テスト用コンテナをビルド
echo "テストコンテナをビルドしています..."
docker build -t dotfiles-test tests/

# テストでインストールする項目を指定
SETUP_OPTIONS="--all"

# コンテナを起動し、セットアップスクリプトを実行
echo "テストコンテナを起動してセットアップを実行します..."
docker run -it \
    -v "${PROJECT_ROOT}:/home/testuser/.dotfiles" \
    --name dotfiles-test-container \
    dotfiles-test \
    bash -c "cd ~/.dotfiles && ./scripts/setup.sh $SETUP_OPTIONS"

# コンテナの状態を確認
CONTAINER_ID=$(docker ps -q -f name=dotfiles-test-container)
CONTAINER_STATE=$(docker inspect -f '{{.State.Status}}' dotfiles-test-container)

echo -e "\nテスト環境に接続するには以下のコマンドをコピー＆ペーストしてください:"

if [ "$CONTAINER_STATE" = "exited" ]; then
    echo -e "\nコンテナ名を使用する場合:"
    echo -e "\033[36mdocker start dotfiles-test-container && docker exec -it dotfiles-test-container bash -c \"\$SHELL\"\033[0m"

    if [ -n "$CONTAINER_ID" ]; then
        echo -e "\nまたは、コンテナIDを使用する場合:"
        echo -e "\033[36mdocker start $CONTAINER_ID && docker exec -it $CONTAINER_ID bash -c \"\$SHELL\"\033[0m"
    fi
else
    echo -e "\nコンテナ名を使用する場合:"
    echo -e "\033[36mdocker exec -it dotfiles-test-container bash -c \"\$SHELL\"\033[0m"

    if [ -n "$CONTAINER_ID" ]; then
        echo -e "\nまたは、コンテナIDを使用する場合:"
        echo -e "\033[36mdocker exec -it $CONTAINER_ID bash -c \"\$SHELL\"\033[0m"
    fi
fi

# 現在のコンテナの状態を表示
echo -e "\n現在のコンテナの状態: \033[33m$CONTAINER_STATE\033[0m"
