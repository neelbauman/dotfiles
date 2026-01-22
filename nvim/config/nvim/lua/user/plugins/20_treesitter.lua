-- dotfiles/nvim/config/nvim/lua/user/plugins/20_treesitter.lua

return {
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
}

