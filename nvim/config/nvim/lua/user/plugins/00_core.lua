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

    -- ステータスライン
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- アイコンも入れる
        config = function()
            require("lualine").setup({
                options = {
                    theme = "tokyonight",
                },
            })
        end,
    },

    -- どのキーに何が割り当てられているか表示
    {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup()
        end,
    },

    -- Git の変更をガター（行番号の横）に表示
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end,
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            current_line_blame = true, -- カーソル行のコミット情報を表示（AI変更箇所の追跡に便利）
            current_line_blame_opts = {
                delay = 500,
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                end

                -- キーバインド: AIの変更箇所をジャンプしたり戻したりする
                map("n", "]c", function() -- 次の変更箇所へ
                    if vim.wo.diff then return "]c" end
                    vim.schedule(function() gs.next_hunk() end)
                    return "<Ignore>"
                end, { expr = true, desc = "Next Change" })

                map("n", "[c", function() -- 前の変更箇所へ
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() gs.prev_hunk() end)
                    return "<Ignore>"
                end, { expr = true, desc = "Prev Change" })

                map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk (AI Undo)") -- AIの変更を部分的に取り消す
                map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")       -- 変更内容を浮き出し表示
            end,
        },
    },
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose" },
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open DiffView" }, -- 全体差分を確認
            { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close DiffView" },
        },
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
                    "python", "javascript", "typescript", "html", "css", "bash"     -- あなたの開発言語
                },
                highlight = {
                    enable = true, -- シンタックスハイライト有効化
                },
            })
        end,
    },
    {
        "tpope/vim-fugitive",
        cmd = {
            "Git",
            "G",
            "Gstatus",
            "Gblame",
            "Gdiff",
            "Gcommit",
            "Glog",
            "Gpush",
            "Gpull",
            "Gfetch",
            -- 必要に応じて他のfugitiveコマンドも追加できます
        },
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
