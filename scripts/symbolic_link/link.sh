#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${SCRIPT_DIR}/common.sh"

# シンボリックリンクを作成
cd "${DOTFILES_ROOT}/dotfiles" || exit 1

for linklist in "linklist.Unix.txt" "linklist.$(uname).txt"; do
    [ ! -r "${linklist}" ] && continue
    log "リンクリストを処理中: ${linklist}"

    __remove_linklist_comment "$linklist" | while read target link; do
        # パスを展開
        target=$(dotfiles_to_abs_path "$target")
        link=$(eval echo "$link")
        
        # 親ディレクトリを作成
        __mkdir "$(dirname "$link")"
        
        # リンクを作成
        __ln "$target" "$link"
    done
done
