#!/bin/bash
# prompty/install.sh — Prompty CLI インストールフック

install_prompty() {
    if command -v prompty >/dev/null 2>&1; then
        echo "prompty is already installed. Skipping."
        return
    fi

    echo "Installing prompty..."

    if ! command -v uv >/dev/null 2>&1; then
        echo "Error: 'uv' is not installed. Please install uv first."
        return 1
    fi

    local repo_dir="$HOME/.local/src/prompty"
    local target_package="$repo_dir/runtime/prompty"

    if [ ! -d "$repo_dir" ]; then
        echo "Cloning prompty repository to $repo_dir..."
        mkdir -p "$(dirname "$repo_dir")"
        git clone https://github.com/neelbauman/prompty.git "$repo_dir"
    else
        echo "Prompty repository already exists at $repo_dir. Pulling latest..."
        git -C "$repo_dir" pull
    fi

    echo "Running uv tool install..."
    uv tool install \
        --with typing_extensions \
        --with openai \
        --python 3.10 \
        --force \
        "$target_package"
}

install_prompty
