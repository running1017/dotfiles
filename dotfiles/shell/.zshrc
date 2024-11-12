# Zsh Configuration

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt share_history
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Basic auto/tab complete
autoload -U compinit
zstyle ":completion:*" menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files

# Colors
autoload -U colors && colors

# Key bindings
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Load aliases
if [ -f "$HOME/.aliases.d/loader.sh" ]; then
    source "$HOME/.aliases.d/loader.sh"
fi

# custom tools
export PATH="$HOME/.local/tools:$PATH"

# Initialize Starship
eval "$(starship init zsh)"
