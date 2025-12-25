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
            local lsp_utils = require("user.utils.lsp_manage")

            -- Helper function to setup a server compatible with both 0.10 and 0.11+
            local function setup_server(server_name, opts)
                if vim.lsp.config and vim.lsp.config[server_name] then
                    -- Neovim 0.11+ (Native)
                    -- Merge existing config if any, then enable
                    vim.lsp.config[server_name] = vim.tbl_deep_extend("force", vim.lsp.config[server_name], opts or {})
                    vim.lsp.enable(server_name)
                else
                    -- Neovim 0.10 or older (Legacy lspconfig)
                    lspconfig[server_name].setup(opts or {})
                end
            end

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls", "pyright", "rust_analyzer", "ts_ls", "bashls",
                    "dockerls", "jsonls", "yamlls", "astro", "marksman",
                },
                handlers = {
                    -- Default Handler
                    function(server_name)
                        -- Skip if registered in the "board" (skip_servers)
                        if lsp_utils.skip_servers[server_name] then
                            return
                        end

                        -- Setup with common options
                        setup_server(server_name, {
                            on_attach = lsp_utils.on_attach,
                            capabilities = lsp_utils.capabilities,
                        })
                    end,
                },
            })
        end,
    },
}
