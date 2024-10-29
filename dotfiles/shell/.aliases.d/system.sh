# システム管理用エイリアス

# システム情報
alias df="df -h"
alias du="du -h"
alias free="free -m"
alias ps="ps aux"
alias psg="ps aux | grep"
alias top="htop"
alias sudo="sudo "

# ネットワーク関連
alias myip="curl http://ipecho.net/plain; echo"
alias ports="netstat -tulanp"
alias ping="ping -c 5"
alias ns="netstat -tulanp"
alias iptl="sudo iptables -L"

# システムメンテナンス
# Ubuntu/Debian用
alias update="sudo apt update"
alias upgrade="sudo apt upgrade"
alias install="sudo apt install"
alias remove="sudo apt remove"
# Arch Linux用（コメントアウト状態）
# alias update="sudo pacman -Syu"
# alias install="sudo pacman -S"
# alias remove="sudo pacman -R"

# システム操作
alias reboot="sudo reboot"
alias poweroff="sudo poweroff"
alias halt="sudo halt"

# ログ確認
alias syslog="tail -f /var/log/syslog"
alias authlog="tail -f /var/log/auth.log"

# ディスク使用量分析
alias ducks="du -cksh * | sort -rh | head -n 15"
