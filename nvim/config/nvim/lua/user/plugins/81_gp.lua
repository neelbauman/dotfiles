-- lua/user/plugins/81_gp.lua

return {
    "Robitx/gp.nvim",
    config = function()
        local conf = {
            chat_dir = vim.fn.expand("~/ai-chats"),
            -- 1. プロバイダーの設定
            providers = {
                openai = {
                    endpoint = "https://api.openai.com/v1/chat/completions",
                    secret = os.getenv("OPENAI_API_KEY"),
                },
                anthropic = {
                    endpoint = "https://api.anthropic.com/v1/messages",
                    secret = os.getenv("ANTHROPIC_API_KEY"),
                },
            },

            -- 2. エージェントの定義 (最新モデル 4.5 世代へ更新)
            agents = {
                -- ChatGPT Agent (GPT-4.5)
                {
                    provider = "openai",
                    name = "ChatGPT4o",
                    chat = true,
                    command = false,
                    model = { model = "gpt-4o", temperature = 0.7 },
                    system_prompt = "あなたは有能なAIアシスタントです。日本語で回答してください。",
                },
                -- Claude Agent (Claude Sonnet 4.5)
                {
                    provider = "anthropic",
                    name = "ClaudeSonnet4-5",
                    chat = true,
                    command = false,
                    model = { model = "claude-sonnet-4-5-20250929", temperature = 0.5 },
                    system_prompt = "あなたはAnthropicによってトレーニングされたAIであるClaudeです。日本語で簡潔に答えてください。",
                },
            },

            -- 3. デフォルトエージェントの指定
            default_chat_agent = "ClaudeSonnet4-5", 
            default_command_agent = "ChatGPT4o",

            -- 4. フックの追加（新しいバッファに出力）
            hooks = {
                CommitMsg = function(gp, params)
                    local git_diff = vim.fn.system("git diff --cached")
                    if git_diff == "" then
                        vim.notify("ステージされた変更がありません", vim.log.levels.WARN)
                        return
                    end
                    local template = "以下のgit diffから簡潔なコミットメッセージを日本語で生成してください:\n\n"
                        .. "```diff\n" .. git_diff .. "\n```"
                    local agent = gp.get_command_agent()
                    gp.Prompt(params, gp.Target.popup, agent, template)
                end,
            },
        }

        require("gp").setup(conf)

        -- キーマップ
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, nowait = true, desc = "GP: " .. desc })
        end

        map({ "n", "i" }, "<C-g>c", "<cmd>GpChatNew<cr>", "New Chat")
        map({ "n", "i" }, "<C-g>t", "<cmd>GpChatToggle<cr>", "Toggle Chat")
        map("n", "<C-g>a", "<cmd>GpAgent<cr>", "Select Agent")
        -- コミットメッセージ生成のキーマップ
        map("n", "<C-g>m", "<cmd>GpCommitMsg<cr>", "Generate Commit Message")
    end,
}
