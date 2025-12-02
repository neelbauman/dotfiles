#!/bin/bash
# install.sh

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ---------------------------------------------------------
# ヘルパー関数: シンボリックリンク作成
# ---------------------------------------------------------
link_file() {
    local source_path="$1"
    local target_path="$2"

    if [ ! -e "$source_path" ]; then
        return # ソースがない場合は何もしない
    fi

    # ターゲットディレクトリを自動作成
    mkdir -p "$(dirname "$target_path")"

    # バックアップ作成
    if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
        echo "Backing up $target_path..."
        mv "$target_path" "$target_path.backup_$(date +%Y%m%d_%H%M%S)"
    fi

    # リンク作成
    ln -snf "$source_path" "$target_path"
    echo "Linked: $source_path -> $target_path"
}

# ---------------------------------------------------------
# 戦略1: .links ファイルによるカスタム定義の処理
# ---------------------------------------------------------
process_links_file() {
    local linkfile="$1"
    local base_dir=$(dirname "$linkfile")
    
    echo "  [Custom] Processing .links in $(basename "$base_dir")..."

    while read -r src dest; do
        [[ -z "$src" || "$src" =~ ^# ]] && continue
        
        # チルダ展開
        dest="${dest/\~/$HOME}"

        # ワイルドカード処理 (*)
        if [[ "$src" == *"*"* ]]; then
            for file in $base_dir/$src; do
                [ -e "$file" ] || continue
                local fname=$(basename "$file")
                link_file "$file" "$dest/$fname"
            done
        else
            link_file "$base_dir/$src" "$dest"
        fi
    done < "$linkfile"
}

# ---------------------------------------------------------
# 戦略2: デフォルト規則による自動処理 (Convention)
# ---------------------------------------------------------
process_default_convention() {
    local topic_dir="$1"
    local topic_name=$(basename "$topic_dir")
    
    local processed=false

    # 1. config/ フォルダ -> ~/.config/ へ
    if [ -d "$topic_dir/config" ]; then
        echo "  [Auto] Found config/ in $topic_name"
        # configディレクトリの中身を一つずつ ~/.config/ にリンク
        for item in "$topic_dir/config"/*; do
            local fname=$(basename "$item")
            link_file "$item" "$HOME/.config/$fname"
        done
        processed=true
    fi

    # 2. home/ フォルダ -> ~/ へ (ドットなしならドット付与)
    if [ -d "$topic_dir/home" ]; then
        echo "  [Auto] Found home/ in $topic_name"
        for item in "$topic_dir/home"/*; do
            local fname=$(basename "$item")
            # ファイル名がドットで始まっていなければドットをつける
            if [[ "$fname" != .* ]]; then
                link_file "$item" "$HOME/.$fname"
            else
                link_file "$item" "$HOME/$fname"
            fi
        done
        processed=true
    fi

    # 3. bin/ フォルダ -> ~/.local/bin/ へ
    if [ -d "$topic_dir/bin" ]; then
        echo "  [Auto] Found bin/ in $topic_name"
        for item in "$topic_dir/bin"/*; do
            local fname=$(basename "$item")
            link_file "$item" "$HOME/.local/bin/$fname"
        done
        processed=true
    fi
    
    # 何も処理されなかった場合のみメッセージ
    if [ "$processed" = false ]; then
        # .links もなく、規定のフォルダもない場合
        echo "  (No configuration found for $topic_name, skipping)"
    fi
}

# ---------------------------------------------------------
# メイン処理: すべてのTopicディレクトリを走査
# ---------------------------------------------------------
echo "Starting dotfiles setup..."

# dotfilesディレクトリ直下のフォルダをループ (隠しファイル除外)
for topic_dir in "$DOTFILES_DIR"/*; do
    [ -d "$topic_dir" ] || continue
    
    topic_name=$(basename "$topic_dir")
    
    # install.sh 自身や .git ディレクトリは除外
    [[ "$topic_name" == "install.sh" ]] && continue
    [[ "$topic_name" == ".git" ]] && continue
    [[ "$topic_name" == ".github" ]] && continue

    echo "Checking topic: $topic_name"

    # 優先順位: .links があればそれを使う。なければデフォルト規則。
    if [ -f "$topic_dir/.links" ]; then
        process_links_file "$topic_dir/.links"
    else
        process_default_convention "$topic_dir"
    fi
done

echo "Setup complete!"

