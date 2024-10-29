# エイリアスファイルのローダー

# エイリアスディレクトリのパス
ALIASES_DIR="$HOME/.aliases"

# 基本的なエイリアス
if [ -f "$ALIASES_DIR/basic.sh" ]; then
    source "$ALIASES_DIR/basic.sh"
fi

# 開発関連のエイリアス
if [ -f "$ALIASES_DIR/dev.sh" ]; then
    source "$ALIASES_DIR/dev.sh"
fi

# システム管理用エイリアス
if [ -f "$ALIASES_DIR/system.sh" ]; then
    source "$ALIASES_DIR/system.sh"
fi
