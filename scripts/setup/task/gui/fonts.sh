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
    # 一時ディレクトリの作成（エラー出力を抑制）
    local temp_dir
    temp_dir=$(mktemp -d 2>/dev/null) || return 1

    {
        log "HackGenフォントをダウンロードしています..."
        log "作業ディレクトリ: $temp_dir"

        # バージョン定義
        local version="v2.9.0"
        local filename="HackGen_NF_${version}"
        local url="https://github.com/yuru7/HackGen/releases/download/${version}/${filename}.zip"

        # ダウンロード（標準出力とエラー出力を/dev/nullに捨てる）
        if ! curl -L -s -o "${temp_dir}/${filename}.zip" "$url" 2>/dev/null; then
            rm -rf "$temp_dir"
            return 1
        fi

        # 展開（標準出力とエラー出力を/dev/nullに捨てる）
        if ! unzip -q "${temp_dir}/${filename}.zip" -d "${temp_dir}/hackgen" 2>/dev/null; then
            rm -rf "$temp_dir"
            return 1
        fi
    } >&2 # すべてのログ出力をステラーエラー出力にリダイレクト

    # 成功した場合のみパスを標準出力に出力
    echo "$temp_dir"
}

# フォントファイルのインストール
install_font_files() {
    local work_dir="$1"
    local font_dir="$HOME/.local/share/fonts"
    log "フォントファイルをインストールしています..."

    # フォントファイルのコピー
    if [ -d "${work_dir}/hackgen" ]; then
        run_command "cp ${work_dir}/hackgen/HackGen_NF_*/*.ttf \"${font_dir}/\"" \
            "フォントファイルのコピー"
    else
        error "フォントディレクトリが見つかりません: ${work_dir}/hackgen"
        return 1
    fi

    # 作業ディレクトリの削除
    run_command "rm -rf \"$work_dir\"" \
        "一時ファイルの削除"
}

# 残りの関数は変更なし
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

check_installed_fonts() {
    if ! command -v fc-list &> /dev/null; then
        warn "fc-listが見つかりません。fontconfigパッケージをインストールしてください。"
        return 1
    fi

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

install_hackgen_font() {
    log "HackGenフォントのインストールを開始します..."

    # 依存パッケージのインストール
    install_font_dependencies

    # すでにインストールされているか確認
    if fc-list | grep -i "HackGenConsoleNF-Regular" > /dev/null; then
        warn "HackGenフォントは既にインストールされています"
        check_installed_fonts
        return 0
    fi

    local work_dir

    # フォントディレクトリの準備
    setup_font_directories

    # フォントのダウンロードと展開
    work_dir=$(download_hackgen_font)
    if [ $? -ne 0 ] || [ -z "$work_dir" ]; then
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

setup_fonts() {
    log "フォントのセットアップを開始します..."

    # HackGenフォントのインストール
    install_hackgen_font

    success "フォントのセットアップが完了しました"
}
