# Dotfiles

私の個人的な設定ファイル（dotfiles）リポジトリです。
Rust製のクロスプラットフォームインストーラーで、安全かつ柔軟にシンボリックリンクを管理します。

## 特徴

- **クロスプラットフォーム:** Linux / macOS / Windows に対応（Rust製インストーラー）。
- **トピック指向:** 設定は機能（例: `nvim`, `bash`, `ssh`）ごとにディレクトリ分けされています。
- **自動リンク（Convention）:** 規定のディレクトリ構造に従うだけで、自動的に適切な場所にリンクされます。
- **TOML 設定:** `topic.toml` で任意の場所へのリンクやプラットフォーム制限が可能です。
- **フック対応:** トピックごとに `install.sh` / `install.ps1` で追加のセットアップ処理を実行できます。
- **安全性:** 既存のファイルを上書きする際、自動的にバックアップを作成します。冪等性があり、何度実行しても安全です。
- **Bash フォールバック:** Rust ツールチェインがない環境では従来の Bash スクリプトで動作します。

## インストール

### ワンライナー（推奨）

**Linux / macOS:**

```bash
curl -fsSL https://raw.githubusercontent.com/neelbauman/dotfiles/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/neelbauman/dotfiles/main/install.ps1 | iex
```

GitHub Releases からプリビルドバイナリを自動ダウンロードし、dotfiles をセットアップします。
Rust 環境不要で、Linux (x86_64) / macOS (x86_64, ARM) / Windows (x86_64) に対応しています。

### 手動インストール

```bash
# 1. リポジトリをクローン
git clone https://github.com/neelbauman/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2a. cargo run（Rust ツールチェインがある場合）
cargo run --release

# 2b. または install.sh 経由（バイナリダウンロード → cargo build → Bash の順にフォールバック）
./install.sh
```

### プリビルドバイナリを直接使用

[GitHub Releases](https://github.com/neelbauman/dotfiles/releases) からバイナリをダウンロードし、任意の場所に配置して実行できます。

```bash
./dotfiles-installer --dotfiles-dir ~/dotfiles
```

### CLI オプション

```
dotfiles-installer [OPTIONS]

Options:
  -n, --dry-run          プレビューモード（実際のリンク作成を行わない）
  -v, --verbose          詳細出力
  -t, --topic <NAME>     特定トピックのみインストール（複数指定可）
      --dotfiles-dir     dotfilesディレクトリ指定
      --no-hooks         フック実行スキップ
```

**使用例:**

```bash
# ドライランで何が起きるか確認
cargo run -- --dry-run

# 特定のトピックのみインストール
cargo run -- --topic bash --topic nvim

# フックをスキップしてリンクのみ作成
cargo run -- --no-hooks

# 詳細出力付きでドライラン
cargo run -- -n -v
```

## ディレクトリ構造とルール

このリポジトリは「Convention over Configuration（設定より規約）」の哲学に基づいています。
各トピックディレクトリ内のフォルダ名によって、インストール先が自動的に決定されます。

### 1\. `config/` ディレクトリ

`~/.config/` 以下に配置されます（Windows: `%APPDATA%`）。ディレクトリ構造はそのまま維持されます。

  - **配置例:** `dotfiles/nvim/config/nvim/init.lua`
  - **リンク先:** `~/.config/nvim` → `dotfiles/nvim/config/nvim`

### 2\. `home/` ディレクトリ

ホームディレクトリ `~/` 直下に配置されます（Windows: `%USERPROFILE%`）。
**ファイル名にドット（`.`）が含まれていない場合、リンク作成時に自動的に付与されます。**

  - **配置例:** `dotfiles/bash/home/bashrc` （ドットなし）
  - **リンク先:** `~/.bashrc` （ドットあり）

### 3\. `bin/` ディレクトリ

`~/.local/bin/` に配置されます（実行権限のあるスクリプト用）。

  - **配置例:** `dotfiles/git-tools/bin/git-cb`
  - **リンク先:** `~/.local/bin/git-cb`

-----

## 高度な設定 (topic.toml)

上記のルールに当てはまらない場合、各トピックディレクトリに `topic.toml` を作成することで、リンク先を明示的に指定できます。

### 書式

```toml
# プラットフォーム制限（省略すると全OS対応）
# platforms = ["linux", "macos", "windows"]

# Convention ルールの無効化（デフォルト: [[links]] があれば自動スキップ）
# skip_conventions = true

# カスタムリンク定義
[[links]]
source = "config"
target = "~/.ssh/config"
```

### `topic.toml` の使用例

**例1: 特定パスへのリンク（ssh/topic.toml）**

```toml
[[links]]
source = "config"
target = "~/.ssh/config"
```

**例2: プラットフォーム制限**

```toml
platforms = ["linux"]

[[links]]
source = "config.conf"
target = "~/.config/myapp/config.conf"
```

**例3: カスタムリンクと Convention の併用**

```toml
skip_conventions = false  # 明示的に false を指定すると [[links]] と Convention を併用

[[links]]
source = "extra.conf"
target = "~/.config/extra.conf"
```

> **Note:** `topic.toml` がないトピックは Convention ルールのみで動作します（設定不要）。

## フックスクリプト

各トピックに `install.sh`（Unix）/ `install.ps1`（Windows）を置くと、リンク作成後に自動実行されます。
パッケージのインストールなど、シンボリックリンクだけでは対応できない処理に使います。

```
prompty/
  install.sh      # Unix 用フック
  install.ps1     # Windows 用フック
```

`--no-hooks` オプションでフック実行をスキップできます。

## 除外ファイル

以下のファイル・ディレクトリはインストーラーによって無視されます。

  - `.git`, `.github`
  - `src/`, `target/`, `bin/` （Rust プロジェクト / ビルド関連）
  - `install.sh`, `install.ps1` （ルートのブートストラップスクリプト）
  - `README.md`
  - `vim/`, `dev/` （レガシー / テンプレート用）

## License

MIT
