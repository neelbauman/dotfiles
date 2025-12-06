return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-telescope/telescope.nvim", -- ファイル選択(#file)に使用
        "ravitemer/codecompanion-history.nvim",
        "echasnovski/mini.diff",
    },
    config = function()
        require("mini.diff").setup({
            view = {
                style = "sign", -- 行番号の横に色を出すだけ (最も軽量)
                signs = { add = "+", change = "~", delete = "-" },
            },
            -- Git連携はGitsignsに任せるので、ここでは無効化してメモリ節約
            source = nil, 
        })

        require("codecompanion").setup({
            extensions = {
                history = {
                    enabled = true,
                    opts = {
                        keymap = "gh",
                        save_chat_keymap = "sc",
                        auto_save = true,
                        auto_generate_title = true,
                        picker = "telescope",
                        dir_to_save = vim.fn.stdpath('data') .. '/codecompanion-history',
                    },
                },
            },

            strategies = {
                chat = { adapter = "openai" },   -- 思考・相談
                inline = { adapter = "openai" }, -- 実装・修正
                agent = { adapter = "openai" },  -- ツール使用（将来用）
            },

            -- 【アダプター設定】
            adapters = {
                openai = function()
                    return require("codecompanion.adapters").extend("openai", {
                        env = {
                            api_key = "cmd:echo $OPENAI_API_KEY",
                        },
                        schema = {
                            model = {
                                -- 思考と実装のバランスが良い "gpt-4o" をデフォルトに推奨
                                -- コストを抑えたい場合は "gpt-4o-mini" に変更してください
                                default = "gpt-4o",
                            },
                        },
                    })
                end,
            },

            -- 【UI設定】Crostini向けにシンプルに
            display = {
                action_palette = {
                    provider = "telescope", -- コマンドパレット統合
                },
                chat = {
                    window = {
                        layout = "vertical", -- 画面右側に分割
                        width = 0.35, -- 35%の幅
                    },
                    show_settings = true, -- 使用中のモデルなどを表示
                },
                diff = {
                    provider = "mini_diff", -- Neovim標準のDiff (最軽量)
                },
            },
        })

        -- 【キーバインド】
        local map = vim.keymap.set

        -- 1. Chat (思考): 右側にチャットを開く
        -- 使い方: ここで "#" を押すとファイルを選択してコンテキストに含められます
        map({"n", "v"}, "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "AI Chat Toggle" })

        -- 2. Inline (実装): 選択範囲をその場で変更、または現在位置に挿入
        map({"n", "v"}, "<leader>ai", "<cmd>CodeCompanion<cr>", { desc = "AI Inline Edit" })

        -- 3. Add (コンテキスト追加): 選択範囲をチャットに送る
        map("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add selection to Chat" })
    end,
}
