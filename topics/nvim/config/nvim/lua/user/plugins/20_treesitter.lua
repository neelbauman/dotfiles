-- dotfiles/topics/nvim/config/nvim/lua/user/plugins/20_treesitter.lua

return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false, -- 【重要】遅延読み込みをオフにし、起動時に確実にロードさせる
        config = function()
            -- pcallを使って安全にモジュールを読み込む
            -- ダウンロード中の場合、ここでエラーにならずに静かにスキップされる
            local status_ok, configs = pcall(require, "nvim-treesitter.configs")
            if not status_ok then
                vim.notify("nvim-treesitter is installing or not found. Please run :Lazy sync", vim.log.levels.WARN)
                return
            end

            configs.setup({
                ensure_installed = { 
                    "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "yaml",
                    "python", "javascript", "go", "rust", "typescript", "html", "css", "bash"
                },
                highlight = {
                    enable = true, -- シンタックスハイライト有効化
                },
                -- 必要な場合は indent などの設定もここに追加
            })
        end,
    },
}
