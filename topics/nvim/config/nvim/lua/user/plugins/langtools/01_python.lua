-- dotfiles/nvim/config/nvim/lua/user/plugins/langtools/01_python.lua

require("user.utils.lsp_manage").register_custom_config("pyright")

return {
    {
        "neovim/nvim-lspconfig",
        ft = { "python" },
        config = function()
            local lsp_utils = require("user.utils.lsp_manage")

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

            -- ★ チューニング: 0.11+ 向けに一本化
            vim.lsp.config["pyright"] = vim.tbl_deep_extend("force", vim.lsp.config["pyright"] or {}, opts)
            vim.lsp.enable("pyright")
        end,
    },
}
