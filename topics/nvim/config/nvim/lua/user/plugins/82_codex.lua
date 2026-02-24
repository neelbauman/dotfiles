-- nvim/config/nvim/lua/user/plugins/82_codex.lua

return {
    {
        "ishiooon/codex.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        
        -- ここで明示的にCodex用のキーマップ（<leader>o 始まり）を指定します
        keys = {
            { "<leader>oo", "<cmd>Codex<cr>",     desc = "Codex: Open" },
            { "<leader>ot", "<cmd>CodexTask<cr>", desc = "Codex: Task" },
            {
                "<leader>ob",
                function()
                    local ft = vim.bo.filetype
                    if ft == "codecompanion" then
                        vim.notify("CodeCompanion バッファは追加できません", vim.log.levels.WARN)
                        return
                    end
                    vim.cmd("CodexAdd %")
                end,
                desc = "Codex: Add buffer",
            },
            { "<leader>os", "<cmd>CodexSend<cr>",  mode = "v", desc = "Codex: Send selection" },
            { "<leader>oa", "<cmd>CodexTreeAdd<cr>", ft = "neo-tree", desc = "Codex: Add from tree" },
        },
        
        opts = {
            -- プラグイン内蔵のデフォルトキーマップを無効化する（重要）
            -- ※プラグインの仕様により以下のいずれかが効くことが多いです
            default_keymaps = false, 
            create_keybindings = false,
            
            track_selection = true,
            diff_opts = {
                vertical_split = true,
                keep_terminal_focus = true,
                open_in_new_tab = true,
                auto_close_on_accept = true,
            },
        },
        config = function(_, opts)
            require("codex").setup(opts)
            
            -- 【念のための強制リセット】
            -- セットアップ後に<space>ccが奪われてしまった場合、Claude Code側に戻す
            vim.schedule(function()
                -- <space>cc を ClaudeCode に強制再マッピング
                vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCode<cr>", { desc = "Claude: Open", remap = false })
            end)
        end,
    }
}
