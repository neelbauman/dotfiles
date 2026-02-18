-- nvim/config/nvim/lua/user/plugins/99_claudecode.lua

return {
    {
        "coder/claudecode.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        -- lazy.nvimでの読み込み設定
        cmd = { "ClaudeCode", "ClaudeCodeTask" }, -- コマンド実行時にロード
        keys = {
            { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Open Claude Code" },
            { "<leader>at", "<cmd>ClaudeCodeTask<cr>", desc = "Start Claude Code Task" },
        },
        opts = {
            -- 必要に応じて設定をカスタマイズ
            -- window = {
            --     position = "right", -- "float" | "right" | "bottom"
            --     width = 0.4,
            -- },
        },
    }
}
