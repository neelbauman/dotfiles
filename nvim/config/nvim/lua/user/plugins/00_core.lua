-- dotfiles/nvim/lua/user/plugins/00_core.lua

return {
    -- カラースキーム
    {
        "folke/tokyonight.nvim",
        priority = 1000, -- 最初に読み込む
        config = function()
            vim.cmd.colorscheme("tokyonight-storm") -- 'storm' テーマを適用
        end,
    },

    -- どのキーに何が割り当てられているか表示
    {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup()
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.configs").setup({
                -- 必要な言語のみインストールして軽量化
                ensure_installed = { 
                    "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "yaml", -- システム系
                    "python", "javascript", "go", "rust", "typescript", "html", "css", "bash"     -- あなたの開発言語
                },
                highlight = {
                    enable = true, -- シンタックスハイライト有効化
                },
            })
        end,
    },
    {
        "zeioth/garbage-day.nvim",
        dependencies = "neovim/nvim-lspconfig",
        event = "VeryLazy",
        opts = {
            grace_period = 60 * 5, -- 5分 (300秒) 放置でLSP停止
            wakeup_delay = 0,      -- 再開時の遅延なし
            notifications = false, -- 通知を出さない（静かに仕事をする）
        },
    },
}
