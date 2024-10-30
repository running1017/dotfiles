FROM debian:latest

# 最小限必要なパッケージのインストール（sudo）
RUN apt-get update && apt-get install -y \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# テストユーザーの作成とsudo権限の付与
RUN useradd -m -s /bin/bash testuser && \
    usermod -aG sudo testuser && \
    echo "testuser:testpass" | chpasswd && \
    echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# 作業ディレクトリの設定
WORKDIR /home/testuser

# デフォルトユーザーをtestuserに設定
USER testuser

CMD ["/bin/bash"]
