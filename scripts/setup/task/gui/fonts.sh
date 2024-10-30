#!/bin/bash

source "${SETUP_DIR}/utils.sh"

# フォントディレクトリの設定
setup_font_directories() {
    log "フォントディレクトリを設定しています..."

    local dirs=(
        "$HOME/.local/share/fonts"
        "$HOME/.fonts"
    )

    for dir in "${dirs[@]}"; do
        run_command "mkdir -p \"$dir\"" \
            "フォントディレクトリを作成: $dir"
    done

    # フォントキャッシュディレクトリの作成
    run_command "mkdir -p \"$HOME/.cache/fontconfig\"" \
        "フォントキャッシュディレクトリを作成"
}

# HackGenフォントのダウンロードと展開
download_hackgen_font() {
    log "HackGenフォントをダウンロードしています..."

    local work_dir
    work_dir=$(mktemp -d)
    log "作業ディレクトリ: $work_dir"

    # バージョン定義
    local version="v2.9.0"
    local filename="HackGen_NF_${version}"
    local url="https://github.com/yuru7/HackGen/releases/download/${version}/${filename}.zip"

    # ダウンロード
    run_command "curl -L -o \"${work_dir}/${filename}.zip\" \"$url\"" \
        "HackGenフォントのダウンロード"

    # 展開
    run_command "unzip -q \"${work_dir}/${filename}.zip\" -d \"${work_dir}/hackgen\"" \
        "フォントファイルの展開"

    echo "$work_dir"
}

# フォントファイルのインストール
install_font_files() {
    local work_dir="$1"
    local font_dir="$HOME/.local/share/fonts"
    log "フォントファイルをインストールしています..."

    # フォントファイルのコピー
    run_command "cp \"${work_dir}/hackgen/HackGen_NF_\"*/*.ttf \"$font_dir/\"" \
        "フォントファイルのコピー"

    # 作業ディレクトリの削除
    run_command "rm -rf \"$work_dir\"" \
        "一時ファイルの削除"
}

# フォントキャッシュの更新
update_font_cache() {
    log "フォントキャッシュを更新しています..."

    # フォントキャッシュの削除
    run_command "rm -rf \"$HOME/.cache/fontconfig\"" \
        "古いフォントキャッシュを削除"

    # フォントキャッシュの再生成
    if command -v fc-cache &> /dev/null; then
        run_command "fc-cache -f" \
            "フォントキャッシュを再生成"
    else
        warn "fc-cacheが見つかりません。fontconfigパッケージをインストールしてください。"
    fi
}

# インストール済みフォントの確認
check_installed_fonts() {
    if ! command -v fc-list &> /dev/null; then
        warn "fc-listが見つかりません。fontconfigパッケージをインストールしてください。"
        return 1
    }

    log "インストールされたHackGenフォントを確認しています..."
    if fc-list | grep -i "HackGen" > /dev/null; then
        local font_count
        font_count=$(fc-list | grep -i "HackGen" | wc -l)
        success "HackGenフォント($font_count個)が正常にインストールされています"
        
        # 詳細なフォント情報の表示
        log "インストールされたHackGenフォントの詳細:"
        run_command "fc-list | grep -i 'HackGen' | sort" \
            "フォント一覧" true
    else
        error "HackGenフォントが見つかりません"
        return 1
    fi
}

# 必要なパッケージの確認とインストール
install_font_dependencies() {
    log "フォント関連パッケージをインストールしています..."

    local packages=(
        fontconfig
        unzip
        curl
    )

    for package in "${packages[@]}"; do
        run_apt "install" "$package" "$package のインストール"
    done
}

# HackGenフォントのインストール
install_hackgen_font() {
    log "HackGenフォントのインストールを開始します..."

    # すでにインストールされているか確認
    if fc-list | grep -i "HackGenConsoleNF-Regular" > /dev/null; then
        warn "HackGenフォントは既にインストールされています"
        check_installed_fonts
        return 0
    fi

    local work_dir

    # 依存パッケージのインストール
    install_font_dependencies

    # フォントディレクトリの準備
    setup_font_directories

    # フォントのダウンロードと展開
    work_dir=$(download_hackgen_font)
    if [ $? -ne 0 ]; then
        error "フォントのダウンロードに失敗しました"
        return 1
    fi

    # フォントファイルのインストール
    install_font_files "$work_dir"

    # フォントキャッシュの更新
    update_font_cache

    # インストールの確認
    check_installed_fonts

    success "HackGenフォントのインストールが完了しました"
}

# メインのセットアップ関数
setup_fonts() {
    log "フォントのセットアップを開始します..."

    # GUI環境の確認
    if [ ! "$DISPLAY" ]; then
        error "GUI環境が検出されませんでした"
        return 1
    fi

    # HackGenフォントのインストール
    install_hackgen_font

    success "フォントのセットアップが完了しました"
}
