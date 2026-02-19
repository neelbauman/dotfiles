# Neovim 言語環境セットアップガイド

新しいプログラミング言語の開発環境を追加する際、**「Step 1: お手軽版」**と**「Step 2: 拡張版」**の2段階の運用フローを採用しています。

基本的には **Step 1** だけで十分です。詳細なLSP設定や、言語固有のデバッグ機能が必要になった場合のみ、**Step 2** へ移行してください。

## Step 1: お手軽版 (Quick Start)

**～とりあえず動くようにする～**

基本的な機能（シンタックスハイライト、補完、フォーマット、デバッグ）を使えるようにするには、以下の中央管理ファイルリストに言語名やツール名を追記するだけです。

### 手順

1. **シンタックスハイライト (Treesitter)**
* ファイル: `nvim/lua/user/plugins/20_treesitter.lua`
* `ensure_installed` に言語名を追加（例: `"go"`, `"gomod"`）


2. **LSP サーバー (Mason & LSPConfig)**
* ファイル: `nvim/lua/user/plugins/21_lsp.lua`
* `ensure_installed` にサーバー名を追加（例: `"gopls"`）
* *これだけでデフォルト設定のままLSPが起動します。*


3. **デバッガ (DAP)**
* ファイル: `nvim/lua/user/plugins/22_dap.lua`
* `ensure_installed` にデバッガ名を追加（例: `"delve"`）


4. **フォーマッター (Conform.nvim)**
* ファイル: `nvim/lua/user/plugins/23_formatting.lua`
* `formatters_by_ft` に言語とツールを追加（例: `go = { "goimports", "gofmt" }`）



---

## Step 2: 拡張版 (Advanced)

**～こだわり設定を入れる～**

Step 1で使っていて、「LSPの警告レベルを変えたい」「言語固有の便利なプラグインを入れたい」といった要望が出てきたら、専用ファイルを作成して設定を切り出します。

### 手順

1. **設定ファイルの作成**
* `nvim/lua/user/plugins/langtools/_TEMPLATE.lua` をコピーして、言語専用ファイルを作成します。
* 例: `nvim/lua/user/plugins/langtools/03_go.lua`


2. **自動設定の無効化（重要）**
* 作成したファイルの冒頭で `register_custom_config` を呼び出し、Step 1（`21_lsp.lua`）の自動ループ処理からこの言語を除外します。


```lua
-- 例: gopls の自動設定を無効化
require("user.utils.lsp_manage").register_custom_config("gopls")

```


3. **詳細設定の記述**
* LSPの `settings` テーブルや、`on_attach` でのキーマップ追加などを記述します。
* 言語専用のプラグイン（例: `rustaceanvim`, `nvim-dap-go`）のセットアップもここに書きます。


*※フォーマッター設定については、Step 2移行後も `23_formatting.lua` での一元管理を継続することを推奨します。*

### 構成イメージ

```lua
-- dotfiles/nvim/config/nvim/lua/user/plugins/langtools/03_go.lua

-- 1. デフォルトの自動起動を無効化
require("user.utils.lsp_manage").register_custom_config("gopls")

return {
    {
        "neovim/nvim-lspconfig",
        ft = { "go" },
        config = function()
            -- 2. こだわりのLSP設定
            require("lspconfig").gopls.setup({
                settings = {
                    gopls = {
                        analyses = { unusedparams = true },
                        staticcheck = true,
                    },
                },
                -- 共通設定をマージ
                on_attach = require("user.utils.lsp_manage").on_attach,
                capabilities = require("user.utils.lsp_manage").capabilities,
            })
        end,
    },
    -- 3. デバッグ機能の拡張など
    {
        "mfussenegger/nvim-dap",
        dependencies = { "leoluz/nvim-dap-go" },
        config = function()
            require("dap-go").setup()
        end
    }
}

```

---

## まとめ：どっちを使う？

| ケース | 推奨ルート |
| --- | --- |
| 「とりあえず新しい言語を書きたい」 | **Step 1 (お手軽版)** |
| 「LSPの挙動を細かくチューニングしたい」 | **Step 2 (拡張版)** へ移行 |
| 「RustやGoでデバッグ機能をフル活用したい」 | **Step 2 (拡張版)** へ移行 |
| 「その言語専用のプラグインを使いたい」 | **Step 2 (拡張版)** へ移行 |
