-- dotfiles/nvim/config/nvim/lua/user/plugins/05_git.lua

return {
    -- Git の変更をガター（行番号の横）に表示
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            current_line_blame = true, -- カーソル行のコミット情報を表示（AI変更箇所の追跡に便利）
            current_line_blame_opts = {
                delay = 500,
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local function map(mode, l, r, opts)
                    opts = opts or {}
                    -- 文字列なら desc として扱う
                    if type(opts) == "string" then
                        opts = { desc = opts }
                    end
                    -- バッファ指定を追加
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
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
}
