-- dotfiles/nvim/config/nvim/lua/user/plugins/langtools/01_python.lua

-- 1. 20_lsp.lua での自動起動をスキップするよう登録
require("user.utils.lsp_manage").register_custom_config("pyright")

return {
    {
        "neovim/nvim-lspconfig",
        ft = { "python" },
        config = function()
            -- 【重要】ここは require("lspconfig") のままにしておいてください
            -- 古いバージョンへのフォールバックや、デフォルト設定の参照に使います
            local lspconfig = require("lspconfig")
            local lsp_utils = require("user.utils.lsp_manage")

            -- Python用の設定値
            local opts = {
                on_attach = lsp_utils.on_attach,
                capabilities = lsp_utils.capabilities,
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic",
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                            diagnosticMode = "workspace",
                        },
                    },
                },
            }

            -- 【ここが修正ポイント】
            -- vim.lsp.config が使える場合（Neovim 0.11+）はそちらを使う
            if vim.lsp.config and vim.lsp.config["pyright"] then
                -- 新しい方式: .setup() ではなく、設定をマージして enable する
                vim.lsp.config["pyright"] = vim.tbl_deep_extend("force", vim.lsp.config["pyright"], opts)
                vim.lsp.enable("pyright")
            else
                -- 古い方式: これまで通り .setup() を呼ぶ
                lspconfig.pyright.setup(opts)
            end
        end,
    },
}
