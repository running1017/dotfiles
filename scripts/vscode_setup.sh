#!/bin/bash

VSCODE_USER_DIR="$HOME/.dotfiles/dotfiles/tools/vscode/User"

# Check if code command exists
if ! command -v code &> /dev/null; then
    echo "VSCode command line tool not found."
    echo "Please install VSCode and run 'Install Code Command in PATH' from the command palette (F1)"
    exit 1
fi

# Install extensions from extensions.json
if [ -f "${VSCODE_USER_DIR}/extensions.json" ]; then
    echo "Installing recommended extensions..."
    extensions=$(jq -r '.recommendations[]' "${VSCODE_USER_DIR}/extensions.json")
    echo "$extensions" | while read -r extension; do
        if [ ! -z "$extension" ]; then
            echo "Installing $extension..."
            code --install-extension "$extension"
        fi
    done
else
    echo "extensions.json not found in ${VSCODE_USER_DIR}"
    exit 1
fi

echo "VSCode setup completed!"
