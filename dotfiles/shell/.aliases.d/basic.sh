# 基本的なファイル操作とナビゲーション用エイリアス

# ディレクトリを作成して直接移動する関数
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Ezaによるリスト表示のエイリアス
alias ei="eza --git --icons"
alias ea="eza -a --git --icons"
alias ee="eza -aahl --git --icons"

# ツリー表示コマンド
alias et="eza -T -a -I 'node_modules|.git|.cache'"
alias eta="eza -T -a -I 'node_modules|.git|.cache' --color=always | less -r"
alias eti="eza -T -a -I 'node_modules|.git|.cache' --icons"
alias etia="eza -T -a -I 'node_modules|.git|.cache' --color=always --icons | less -r"

# 標準的なlsコマンドのエイリアス
alias ls=ei
alias la=ea
alias ll=ee
alias lt=et
alias lta=eta
alias lti=eti
alias ltia=etia
alias l="clear && ls"

# ディレクトリ移動の簡略化
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"

# 基本的なファイル操作
alias md="mkdir -p"
alias rd="rmdir"
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"

# よく使うディレクトリへのショートカット
alias dl="cd ~/Downloads"
alias doc="cd ~/Documents"
alias desk="cd ~/Desktop"
alias p="cd ~/projects"
