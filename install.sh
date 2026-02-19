#!/bin/bash
# install.sh — dotfiles ブートストラップスクリプト
#
# ワンライナー:
#   curl -fsSL https://raw.githubusercontent.com/neelbauman/dotfiles/main/install.sh | bash
#
# 処理フロー:
#   1. dotfiles リポジトリをクローン（既にあれば pull）
#   2. GitHub Releases から最新バイナリをダウンロード
#   3. バイナリがなければ cargo build --release にフォールバック
#   4. それもなければ Bash フォールバック

set -euo pipefail

REPO_URL="https://github.com/neelbauman/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
BIN_DIR="$DOTFILES_DIR/bin"
INSTALLER_BIN="$BIN_DIR/dotfiles-installer"
GITHUB_REPO="neelbauman/dotfiles"

# ---------------------------------------------------------
# ヘルパー関数
# ---------------------------------------------------------
info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; }

detect_target() {
    local os arch target
    os="$(uname -s)"
    arch="$(uname -m)"

    case "$os" in
        Linux)  os="unknown-linux-gnu" ;;
        Darwin) os="apple-darwin" ;;
        *)      error "未対応の OS: $os"; return 1 ;;
    esac

    case "$arch" in
        x86_64)  arch="x86_64" ;;
        aarch64|arm64) arch="aarch64" ;;
        *)       error "未対応のアーキテクチャ: $arch"; return 1 ;;
    esac

    target="${arch}-${os}"
    echo "$target"
}

# ---------------------------------------------------------
# 1. リポジトリの取得
# ---------------------------------------------------------
clone_or_pull() {
    if [ -d "$DOTFILES_DIR/.git" ]; then
        info "既存リポジトリを更新中: $DOTFILES_DIR"
        git -C "$DOTFILES_DIR" pull --rebase --quiet
    else
        info "リポジトリをクローン中: $DOTFILES_DIR"
        git clone "$REPO_URL" "$DOTFILES_DIR"
    fi
}

# ---------------------------------------------------------
# 2. GitHub Releases からバイナリをダウンロード
# ---------------------------------------------------------
download_binary() {
    local target asset_name url

    target="$(detect_target)" || return 1
    asset_name="dotfiles-installer-${target}.tar.gz"

    info "最新リリースを確認中..."

    # GitHub API で最新リリースのアセット URL を取得
    url="$(curl -fsSL "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" \
        | grep -o "\"browser_download_url\": *\"[^\"]*${asset_name}\"" \
        | head -1 \
        | cut -d'"' -f4)" || true

    if [ -z "$url" ]; then
        warn "リリースバイナリが見つかりません (${asset_name})"
        return 1
    fi

    info "バイナリをダウンロード中: $asset_name"
    mkdir -p "$BIN_DIR"
    curl -fsSL "$url" | tar xz -C "$BIN_DIR"
    chmod +x "$INSTALLER_BIN"
    info "ダウンロード完了: $INSTALLER_BIN"
}

# ---------------------------------------------------------
# 3. cargo build フォールバック
# ---------------------------------------------------------
cargo_build() {
    if ! command -v cargo >/dev/null 2>&1; then
        return 1
    fi

    if [ ! -f "$DOTFILES_DIR/Cargo.toml" ]; then
        return 1
    fi

    info "Rust インストーラーをビルド中..."
    cargo build --release --manifest-path "$DOTFILES_DIR/Cargo.toml"
    mkdir -p "$BIN_DIR"
    cp "$DOTFILES_DIR/target/release/dotfiles-installer" "$INSTALLER_BIN"
    chmod +x "$INSTALLER_BIN"
    info "ビルド完了: $INSTALLER_BIN"
}

# ---------------------------------------------------------
# 4. Bash フォールバック
# ---------------------------------------------------------
bash_fallback() {
    warn "Rust installer not available, using Bash fallback..."

    link_file() {
        local source_path="$1"
        local target_path="$2"

        [ -e "$source_path" ] || return

        mkdir -p "$(dirname "$target_path")"

        if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
            echo "Backing up $target_path..."
            mv "$target_path" "$target_path.backup_$(date +%Y%m%d_%H%M%S)"
        fi

        ln -snf "$source_path" "$target_path"
        echo "Linked: $source_path -> $target_path"
    }

    process_default_convention() {
        local topic_dir="$1"
        local topic_name
        topic_name=$(basename "$topic_dir")
        local processed=false

        if [ -d "$topic_dir/config" ]; then
            echo "  [Auto] Found config/ in $topic_name"
            for item in "$topic_dir/config"/*; do
                local fname
                fname=$(basename "$item")
                link_file "$item" "$HOME/.config/$fname"
            done
            processed=true
        fi

        if [ -d "$topic_dir/home" ]; then
            echo "  [Auto] Found home/ in $topic_name"
            for item in "$topic_dir/home"/*; do
                local fname
                fname=$(basename "$item")
                if [[ "$fname" != .* ]]; then
                    link_file "$item" "$HOME/.$fname"
                else
                    link_file "$item" "$HOME/$fname"
                fi
            done
            processed=true
        fi

        if [ -d "$topic_dir/bin" ]; then
            echo "  [Auto] Found bin/ in $topic_name"
            for item in "$topic_dir/bin"/*; do
                local fname
                fname=$(basename "$item")
                link_file "$item" "$HOME/.local/bin/$fname"
            done
            processed=true
        fi

        if [ "$processed" = false ]; then
            echo "  (No configuration found for $topic_name, skipping)"
        fi
    }

    echo "Starting dotfiles setup (Bash fallback)..."

    for topic_dir in "$DOTFILES_DIR"/topics/*; do
        [ -d "$topic_dir" ] || continue
        local topic_name
        topic_name=$(basename "$topic_dir")

        # 除外リスト
        case "$topic_name" in
            vim|dev) continue ;;
        esac

        echo "Checking topic: $topic_name"

        process_default_convention "$topic_dir"

        if [ -x "$topic_dir/install.sh" ]; then
            echo "  [Hook] Running install.sh in $topic_name..."
            bash "$topic_dir/install.sh"
        fi
    done

    echo "Setup complete!"
}

# ---------------------------------------------------------
# メインフロー
# ---------------------------------------------------------
main() {
    # ワンライナー実行時はクローンから開始
    # ローカル実行時（BASH_SOURCE が存在）はクローン不要
    if [ -z "${BASH_SOURCE[0]:-}" ] || [ ! -d "$(dirname "${BASH_SOURCE[0]}")/.git" ]; then
        clone_or_pull
    else
        DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        BIN_DIR="$DOTFILES_DIR/bin"
        INSTALLER_BIN="$BIN_DIR/dotfiles-installer"
    fi

    # 既にバイナリがあればそのまま実行
    if [ -x "$INSTALLER_BIN" ]; then
        info "既存バイナリを使用: $INSTALLER_BIN"
        exec "$INSTALLER_BIN" --dotfiles-dir "$DOTFILES_DIR" "$@"
    fi

    # GitHub Releases からダウンロード → 実行
    if download_binary 2>/dev/null; then
        exec "$INSTALLER_BIN" --dotfiles-dir "$DOTFILES_DIR" "$@"
    fi

    # cargo build → 実行
    if cargo_build; then
        exec "$INSTALLER_BIN" --dotfiles-dir "$DOTFILES_DIR" "$@"
    fi

    # Bash フォールバック
    bash_fallback
}

main "$@"
