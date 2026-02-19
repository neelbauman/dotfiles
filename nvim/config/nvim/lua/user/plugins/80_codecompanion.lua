-- dotfiles/nvim/config/nvim/lua/user/plugins/80_codecompanion.lua

local system_prompt_jp = [[
# Role
あなたは、高度な知能と幅広い知識を持つ、日本語のAIアシスタントです。
ユーザーの知的パートナーとして、あらゆる支援をします。

# Guidelines
1. **言語とトーン**:
   - 常に自然で流暢な日本語で回答してください。
   - 丁寧でプロフェッショナル、かつ親しみやすいトーン（です・ます調）を維持してください。
   - ユーザーの意図を汲み取り、文脈に応じた適切な深さで回答してください。

2. **回答の質とスタイル**:
   - **論理的思考**: 複雑な質問に対しては、いきなり結論を出さず、ステップバイステップで論理的に考察してください。
   - **正確性**: 事実に基づいた正確な情報を提供してください。不確実な場合は、正直にその旨を伝えてください。
   - **客観性**: 主観的な意見を求められた場合は、多角的な視点（メリット・デメリットなど）を提示してください。

3. **フォーマット**:
   - **Markdownの活用**: 見出し、箇条書き、太字、表などを適切に使用し、視認性の高い構成にしてください。
   - **コードブロック**: コードやコマンド等は、言語指定付きのコードブロック（```lua など）で囲ってください。
   - **数式**: 数学的な表現が必要な場合はLaTeX形式を使用してください。

4. **制約事項**:
   - 倫理的・道徳的に問題のあるコンテンツや、差別的な内容は生成しないでください。
   - 以前の指示と矛盾しない限り、常にユーザーの指示を最優先してください。
]]

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
                        dir_to_save = vim.fn.expand('~/ai-chats'),
                    },
                },
            },
            interactions = {
                chat = {
                    adapter = "anthropic",
                    opts = {
                        system_prompt = function(_ctx)
                            return system_prompt_jp
                        end,
                    },
                    tools = {
                        -- 利用可能なツール: @{cmd_runner}, @{read_file}, @{file_search},
                        -- @{grep_search}, @{create_file}, @{delete_file}, @{fetch_webpage},
                        -- @{insert_edit_into_file}, @{memory}, @{get_changed_files},
                        -- @{list_code_usages}, @{web_search}
                        ["web_search"] = {
                            -- $TAVILY_API_KEY が未設定の場合は自動で無効化して通知
                            enabled = function()
                                local key = vim.env.TAVILY_API_KEY
                                if not key or key == "" then
                                    vim.notify(
                                        "[CodeCompanion] web_search: $TAVILY_API_KEY が未設定です",
                                        vim.log.levels.WARN
                                    )
                                    return false
                                end
                                return true
                            end,
                            opts = {
                                adapter = "tavily",
                                opts = {
                                    search_depth = "advanced", -- "basic" or "advanced"
                                    topic = "general",         -- "general" or "news"
                                    max_results = 5,
                                },
                            },
                        },
                    },
                },
                inline = { adapter = "openai" },
            },
            adapters = {
                anthropic = function()
                    return require("codecompanion.adapters").extend("anthropic", {
                        env = {
                            api_key = "cmd:echo $ANTHROPIC_API_KEY", -- pragma: allowlist secret
                        },
                        schema = {
                            model = {
                                default = "claude-sonnet-4-6",
                            },
                        },
                    })
                end,
                openai = function()
                    return require("codecompanion.adapters").extend("openai", {
                        env = {
                            api_key = "cmd:echo $OPENAI_API_KEY", -- pragma: allowlist secret
                        },
                        schema = {
                            model = {
                                default = "gpt-4o",
                            },
                        },
                    })
                end,
                tavily = function()
                    return require("codecompanion.adapters").extend("tavily", {
                        env = {
                            api_key = "cmd:echo $TAVILY_API_KEY", -- pragma: allowlist secret
                        },
                    })
                end,
            },
            display = {
                action_palette = {
                    provider = "telescope", -- コマンドパレット統合
                },
                chat = {
                    window = {
                        layout = "vertical",
                        width = 0.35,
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
        map({"n", "v"}, "<leader>an", "<cmd>CodeCompanionChat<cr>", { desc = "AI Chat New" })

        -- 2. Inline (実装): 選択範囲をその場で変更、または現在位置に挿入
        map({"n", "v"}, "<leader>ai", "<cmd>CodeCompanion<cr>", { desc = "AI Inline Edit" })

        -- 3. Add (コンテキスト追加): 選択範囲をチャットに送る
        map("v", "ag", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add selection to Chat" })

        -- 4. Action Pallete (プロンプト切り替えなどに便利）
        map("n", "<leader>ap", "<cmd>CodeCompanionActions<cr>", { desc = "AI Actions Palette" })
    end,
}
