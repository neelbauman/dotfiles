-- dotfiles/nvim/lua/user/plugins/20_lsp.lua

return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- 共通のキーマップ設定
            local on_attach = function(client, bufnr)
                local bufmap = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = "LSP: " .. desc })
                end
                bufmap("n", "K", vim.lsp.buf.hover, "Hover")
                bufmap("n", "gd", vim.lsp.buf.definition, "Go to Definition")
                bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
                bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
            end

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls", "pyright", "rust_analyzer", "ts_ls", "bashls",
                    "dockerls", "jsonls", "yamlls", "astro", "marksman",
                },
                handlers = {
                    -- 全サーバー共通のデフォルト設定
                    function(server_name)
                        -- rust_analyzer は rustaceanvim が行うため除外
                        if server_name == "rust_analyzer" then return end
                        lspconfig[server_name].setup({
                            on_attach = on_attach,
                            capabilities = capabilities,
                        })
                    end,
                    -- pyright 専用設定を維持
                    ["pyright"] = function()
                        lspconfig.pyright.setup({
                            on_attach = on_attach,
                            capabilities = capabilities,
                            settings = {
                                python = { analysis = { typeCheckingMode = "basic" } },
                            },
                        })
                    end,
                },
            })
        end,
    },
}
