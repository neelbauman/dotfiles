-- dotfiles/nvim/config/nvim/lua/user/plugins/langtools/02_rust.lua

require("user.utils.lsp_manage").register_custom_config("rust_analyzer")

return {
    {
        'mrcjkb/rustaceanvim',
        version = '^5', 
        lazy = false,   
        init = function() -- ★ ここを config から init に変更します
            local lsp_utils = require("user.utils.lsp_manage")
            vim.g.rustaceanvim = {
                server = {
                    on_attach = function(client, bufnr)
                        lsp_utils.on_attach(client, bufnr) 

                        local map = function(mode, lhs, rhs, desc)
                            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Rust: " .. desc })
                        end
                        map("n", "<leader>rr", "<cmd>RustLsp runnables<CR>", "Run (Cargo)")
                        map("n", "<leader>rd", "<cmd>RustLsp debuggables<CR>", "Debug (DAP)")
                    end,
                },
                dap = {},
            }
        end
    },

    -- デバッグ機能の本体
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require('dap')

            -- IDE感を抑えた最小限のキーマップ
            -- 普段は意識せず、デバッグしたい時だけ使う
            vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = "Debug: Start/Continue" })
            vim.keymap.set('n', '<F10>', function() dap.step_over() end, { desc = "Debug: Step Over" })
            vim.keymap.set('n', '<F11>', function() dap.step_into() end, { desc = "Debug: Step Into" })
            vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })

            -- 変数の中身を浮かび上がるウィンドウで確認 (Floating Window)
            -- これなら画面レイアウトが崩れません
            vim.keymap.set('n', '<leader>dr', function() require('dap.ui.widgets').hover() end, { desc = "Debug: Inspect Variable" })
        end
    }
}
