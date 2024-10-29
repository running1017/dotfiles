FROM debian:latest

# 必要なパッケージのインストール
RUN apt update && apt install -y git sudo \
    && rm -rf /var/lib/apt/lists/*

# テストユーザーの作成
RUN useradd -m -s /bin/bash testuser && \
    usermod -aG sudo testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# テストユーザーとしてセットアップを実行
USER testuser
WORKDIR /home/testuser

# ローカルのdotfilesをマウントするためのディレクトリを作成
RUN mkdir -p /home/testuser/.dotfiles

# コンテナ起動時のデフォルトコマンド
CMD ["bash"]
