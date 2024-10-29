#!/bin/bash

source "${SETUP_DIR}/utils.sh"

# 基本パッケージのインストール
install_base_packages() {
    log "基本パッケージをインストールしています..."
    
    # 必要なパッケージのリスト
    local packages=(
        vim
        curl
        wget
        git
        zsh
        build-essential
        pkg-config
        htop
        tree
        unzip
        jq
        language-pack-ja
        fonts-noto-cjk
    )

    # ezaのリポジトリ追加（Ubuntuの場合）
    if [ ! -f /etc/apt/sources.list.d/gierens.list ]; then
        log "ezaリポジトリを追加しています..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/gierens/eza-deb/main/KEY.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg
        sudo apt update
    fi
    packages+=(eza)

    # パッケージのインストール
    sudo apt-get update || error "apt-get updateに失敗しました"
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            log "インストール中: $package"
            sudo apt-get install -y "$package" || warn "$package のインストールに失敗しました"
        else
            log "$package は既にインストールされています"
        fi
    done

    success "基本パッケージのインストールが完了しました"
}

# Zshの設定
setup_zsh() {
    log "Zshの設定を行っています..."
    
    # oh-my-zshのインストール
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log "oh-my-zshをインストールしています..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || error "oh-my-zshのインストールに失敗しました"
        
        # プラグインのインストール
        local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
        
        # zsh-autosuggestions
        if [ ! -d "$plugins_dir/zsh-autosuggestions" ]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
        fi
        
        # zsh-syntax-highlighting
        if [ ! -d "$plugins_dir/zsh-syntax-highlighting" ]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
        fi
    else
        warn "oh-my-zshは既にインストールされています"
    fi
    
    # デフォルトシェルの変更
    if [ "$SHELL" != "$(which zsh)" ]; then
        log "デフォルトシェルをZshに変更しています..."
        chsh -s $(which zsh) || warn "デフォルトシェルの変更に失敗しました"
    fi

    success "Zshの設定が完了しました"
}

# Node.jsのインストール
install_nodejs() {
    log "Node.jsをインストールしています..."
    
    if ! command -v node &> /dev/null; then
        # nvmのインストール
        if [ ! -d "$HOME/.nvm" ]; then
            log "nvmをインストールしています..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

            # シェル設定の追加
            {
                echo '# nvm'
                echo 'export NVM_DIR="$HOME/.nvm"'
                echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm'
                echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion'
            } >> "$HOME/.zshrc"
            
            # 環境変数の読み込み
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        else
            warn "nvmは既にインストールされています"
        fi
        
        # Node.jsの最新LTSバージョンをインストール
        log "Node.js LTSをインストールしています..."
        nvm install --lts
        nvm use --lts
        
        # デフォルトバージョンの設定
        nvm alias default 'lts/*'
        
        # 最新のnpmをインストール
        log "npmを更新しています..."
        npm install -g npm@latest
        
        # よく使うグローバルパッケージのインストール
        local packages=(
            yarn
            typescript
            ts-node
            gitmoji-cli
        )
        
        for package in "${packages[@]}"; do
            log "インストール中: $package"
            npm install -g "$package"
        done
        
        success "Node.jsのインストールが完了しました"
    else
        warn "Node.jsは既にインストールされています"
    fi
}

# Python開発環境のセットアップ
setup_python() {
    log "Python開発環境をセットアップしています..."
    
    # 必要なパッケージのインストール
    sudo apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        || error "Pythonパッケージのインストールに失敗しました"

    # ryeのインストール
    if ! command -v rye &> /dev/null; then
        log "ryeをインストールしています..."
        curl -sSf https://rye-up.com/get | bash
        
        # シェル設定の追加
        {
            echo '# rye'
            echo 'source "$HOME/.rye/env"'
        } >> "$HOME/.zshrc"
        
        # PATHを更新
        source "$HOME/.rye/env"
        
        # ryeの初期設定
        rye config --set-bool behavior.use-uv true
        rye config --set-bool behavior.global-python true
        
        # 最新の安定版Pythonをインストール
        log "最新の安定版Pythonをインストールしています..."
        rye fetch
        
        success "ryeのインストールが完了しました"
    else
        warn "ryeは既にインストールされています"
    fi

    success "Python開発環境のセットアップが完了しました"
}

# Dockerのインストール
install_docker() {
    log "Dockerをインストールしています..."
    
    if ! command -v docker &> /dev/null; then
        # 古いバージョンの削除
        for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
        
        # 必要なパッケージのインストール
        sudo apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            lsb-release

        # Dockerの公式GPGキーを追加
        sudo apt-get update
        sudo apt-get install ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # リポジトリの設定
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update

        # Dockerのインストール
        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # 現在のユーザーをdockerグループに追加
        sudo usermod -aG docker $USER

        success "Dockerのインストールが完了しました"
    else
        warn "Dockerは既にインストールされています"
    fi
}

# GUIツールのインストール
install_gui_tools() {
    if [ "$DISPLAY" ]; then
        log "GUIツールをインストールしています..."
        
        # VSCodeのインストール
        if ! command -v code &> /dev/null; then
            log "Visual Studio Codeをインストールしています..."
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
            rm -f packages.microsoft.gpg
            
            sudo apt-get update
            sudo apt-get install -y code
        else
            warn "VSCodeは既にインストールされています"
        fi
        
        # HackGen フォントのインストール
        log "HackGen フォントをインストールしています..."
        HACKGEN_VERSION="v2.9.0"
        FONT_DIR="$HOME/.local/share/fonts"
        
        if [ ! -f "$FONT_DIR/HackGenConsoleNF-Regular.ttf" ]; then
            mkdir -p "$FONT_DIR"
            wget -q "https://github.com/yuru7/HackGen/releases/download/${HACKGEN_VERSION}/HackGen_NF_${HACKGEN_VERSION}.zip"
            unzip -q "HackGen_NF_${HACKGEN_VERSION}.zip" -d hackgen
            cp hackgen/HackGen_NF_${HACKGEN_VERSION}/*.ttf "$FONT_DIR/"
            rm -rf hackgen "HackGen_NF_${HACKGEN_VERSION}.zip"
            fc-cache -f
        else
            warn "HackGenフォントは既にインストールされています"
        fi

        success "GUIツールのインストールが完了しました"
    else
        warn "GUI環境が検出されませんでした"
    fi
}

# dotfilesのリンクを作成
setup_dotfiles() {
    log "dotfilesのリンクを作成しています..."
    local LINK_SCRIPT="${DOTFILES_ROOT}/scripts/symbolic_link/link.sh"
    
    if [ -f "$LINK_SCRIPT" ]; then
        bash "$LINK_SCRIPT"
        success "dotfilesのリンク作成が完了しました"
    else
        error "link.shスクリプトが見つかりません: $LINK_SCRIPT"
    fi
}

# VSCode拡張機能のインストール
setup_vscode() {
    local VSCODE_SCRIPT="${DOTFILES_ROOT}/scripts/tools/vscode/setup.sh"
    if command -v code &> /dev/null; then
        log "VSCode拡張機能をインストールしています..."
        
        if [ -f "$VSCODE_SCRIPT" ]; then
            bash "$VSCODE_SCRIPT"
            success "VSCode拡張機能のインストールが完了しました"
        else
            error "setup.shスクリプトが見つかりません: $VSCODE_SCRIPT"
        fi
    else
        warn "VSCodeがインストールされていません"
    fi
}

# SSH鍵の生成
setup_ssh() {
    log "SSH鍵の生成を行います..."
    
    if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
        # .sshディレクトリの作成と権限設定
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        
        # メールアドレスの入力
        read -p "メールアドレスを入力してください: " email
        
        # SSH鍵の生成
        ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519" || error "SSH鍵の生成に失敗しました"
        
        # ssh-agentの起動と鍵の追加
        eval "$(ssh-agent -s)"
        ssh-add "$HOME/.ssh/id_ed25519"
        
        echo -e "\nSSH公開鍵:"
        cat "$HOME/.ssh/id_ed25519.pub"
        
        success "SSH鍵の生成が完了しました"
    else
        warn "SSH鍵は既に存在します"
    fi
}

# システム設定
setup_system() {
    log "システム設定を行っています..."
    
    # タイムゾーンの設定
    if [ "$(timedatectl show --property=Timezone --value)" != "Asia/Tokyo" ]; then
        log "タイムゾーンを設定しています..."
        sudo timedatectl set-timezone Asia/Tokyo
    fi
    
    # ロケールの設定
    if ! locale -a | grep -q "ja_JP.utf8"; then
        log "日本語ロケールを設定しています..."
        sudo apt-get install -y language-pack-ja
        sudo update-locale LANG=ja_JP.UTF-8
    fi
    
    # キーボードレイアウトの設定
    if [ -f "/etc/default/keyboard" ]; then
        log "キーボードレイアウトを設定しています..."
        sudo sed -i 's/XKBLAYOUT=.*/XKBLAYOUT="jp"/' /etc/default/keyboard
    fi

    success "システム設定が完了しました"
}
