-- dotfiles/nvim/config/nvim/lua/user/plugins/21_lsp.lua

return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" }, -- ★ チューニング: バッファを開くまで読み込まない（起動高速化）
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local lsp_utils = require("user.utils.lsp_manage")

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls", "pyright", "rust_analyzer", "ts_ls", "bashls",
                    "dockerls", "jsonls", "yamlls", "astro", "marksman",
                },
                handlers = {
                    -- Default Handler
                    function(server_name)
                        -- スキップ対象は除外
                        if lsp_utils.skip_servers[server_name] then
                            return
                        end

                        -- ★ チューニング: Neovim 0.11+ のネイティブAPIに一本化し、コードをスッキリさせる
                        local opts = {
                            on_attach = lsp_utils.on_attach,
                            capabilities = lsp_utils.capabilities,
                        }
                        
                        -- 設定をマージして有効化
                        vim.lsp.config[server_name] = vim.tbl_deep_extend("force", vim.lsp.config[server_name] or {}, opts)
                        vim.lsp.enable(server_name)
                    end,
                },
            })
        end,
    },
    {
        "zeioth/garbage-day.nvim",
        dependencies = "neovim/nvim-lspconfig",
        event = "VeryLazy",
        opts = {
            grace_period = 60 * 5,
            wakeup_delay = 0,
            notifications = false,
        },
    },
}
