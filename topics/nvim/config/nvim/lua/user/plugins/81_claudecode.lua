-- nvim/config/nvim/lua/user/plugins/81_claudecode.lua

return {
    {
        "coder/claudecode.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        cmd = { "ClaudeCode", "ClaudeCodeTask", "ClaudeCodeAdd", "ClaudeCodeSend", "ClaudeCodeTreeAdd" },
        keys = {
            -- ターミナル
            { "<leader>cc", "<cmd>ClaudeCode<cr>",     desc = "Claude: Open" },
            { "<leader>ct", "<cmd>ClaudeCodeTask<cr>", desc = "Claude: Task" },

            -- コンテキスト送信
            {
                "<leader>cb",
                function()
                    local ft = vim.bo.filetype
                    if ft == "codecompanion" then
                        vim.notify("CodeCompanion バッファは追加できません", vim.log.levels.WARN)
                        return
                    end
                    vim.cmd("ClaudeCodeAdd %")
                end,
                desc = "Claude: Add buffer",
            },
            { "<leader>cs", "<cmd>ClaudeCodeSend<cr>",  mode = "v", desc = "Claude: Send selection" },

            -- neo-tree
            { "<leader>ca", "<cmd>ClaudeCodeTreeAdd<cr>", ft = "neo-tree", desc = "Claude: Add from tree" },
        },
        opts = {
            track_selection = true, -- カーソル位置・選択範囲をリアルタイムで送信
            diff_opts = {
                vertical_split = true,
                keep_terminal_focus = true,
                open_in_new_tab = true,
                auto_close_on_accept = true,
            },
        },
        config = function(_, opts)
            require("claudecode").setup(opts)
        end,
    }
}
