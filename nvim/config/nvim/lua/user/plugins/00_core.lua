-- dotfiles/nvim/config/nvim/lua/user/plugins/00_core.lua

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
}
