-- lua/user/plugins/81_gp.lua

return {
    "Robitx/gp.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
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

            -- 2. エージェントの定義
            agents = {
                {
                    provider = "openai",
                    name = "ChatGPT4o",
                    chat = true,
                    command = false,
                    model = { model = "gpt-4o", temperature = 0.7 },
                    system_prompt = "あなたは有能なAIアシスタントです。日本語で回答してください。",
                },
                {
                    provider = "anthropic",
                    name = "ClaudeSonnet4-6",
                    chat = true,
                    command = false,
                    model = { model = "claude-sonnet-4-6", temperature = 0.5 },
                    system_prompt = "あなたはAnthropicによってトレーニングされたAIであるClaudeです。日本語で簡潔に答えてください。",
                },
            },

            -- 3. デフォルトエージェント
            default_chat_agent = "ClaudeSonnet4-6",
            default_command_agent = "ChatGPT4o",

            -- 4. フック（Telescope統合を追加）
            hooks = {
                -- コミットメッセージ生成
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

                -- 【新規】単一ファイル選択
                TelescopeFile = function(gp, params)
                    local telescope = require('telescope.builtin')
                    local actions = require('telescope.actions')
                    local action_state = require('telescope.actions.state')
                    
                    telescope.find_files({
                        prompt_title = "GPT: ファイルを選択",
                        attach_mappings = function(prompt_bufnr, map)
                            actions.select_default:replace(function()
                                local selection = action_state.get_selected_entry()
                                actions.close(prompt_bufnr)
                                
                                local file_path = selection.path or selection.value
                                
                                -- ファイルサイズチェック（100KB以上は警告）
                                local file_size = vim.fn.getfsize(file_path)
                                if file_size > 100000 then
                                    local confirm = vim.fn.confirm(
                                        string.format("ファイルサイズが大きいです (%d bytes)。続行しますか？", file_size),
                                        "&Yes\n&No",
                                        2
                                    )
                                    if confirm ~= 1 then return end
                                end
                                
                                local content = table.concat(vim.fn.readfile(file_path), "\n")
                                local context = string.format(
                                    "以下のファイルについて質問があります:\n\n" ..
                                    "ファイル: %s\n\n" ..
                                    "```\n%s\n```\n\n",
                                    file_path,
                                    content
                                )
                                
                                gp.cmd.ChatNew({}, context)
                            end)
                            
                            return true
                        end,
                    })
                end,

                -- 【新規】複数ファイル選択
                TelescopeMultiFile = function(gp, params)
                    local telescope = require('telescope.builtin')
                    local actions = require('telescope.actions')
                    local action_state = require('telescope.actions.state')
                    
                    telescope.find_files({
                        prompt_title = "GPT: 複数ファイル選択 (Tabで選択、Enterで確定)",
                        attach_mappings = function(prompt_bufnr, map)
                            actions.select_default:replace(function()
                                local picker = action_state.get_current_picker(prompt_bufnr)
                                local selections = picker:get_multi_selection()
                                actions.close(prompt_bufnr)
                                
                                -- 選択がない場合は現在のエントリーを使用
                                if #selections == 0 then
                                    selections = { action_state.get_selected_entry() }
                                end
                                
                                local context = "以下のファイルについて質問があります:\n\n"
                                
                                for _, selection in ipairs(selections) do
                                    local file_path = selection.path or selection.value
                                    local content = table.concat(vim.fn.readfile(file_path), "\n")
                                    
                                    context = context .. string.format(
                                        "=== %s ===\n```\n%s\n```\n\n",
                                        file_path,
                                        content
                                    )
                                end
                                
                                gp.cmd.ChatNew({}, context)
                            end)
                            
                            -- Tabキーでマルチセレクト
                            map('i', '<Tab>', actions.toggle_selection + actions.move_selection_worse)
                            map('i', '<S-Tab>', actions.toggle_selection + actions.move_selection_better)
                            
                            return true
                        end,
                    })
                end,

                -- 【新規】Grep結果から選択
                TelescopeGrep = function(gp, params)
                    local telescope = require('telescope.builtin')
                    local actions = require('telescope.actions')
                    local action_state = require('telescope.actions.state')
                    
                    local search_term = vim.fn.input("検索キーワード: ")
                    if search_term == "" then return end
                    
                    telescope.live_grep({
                        prompt_title = "GPT: Grep結果から選択",
                        default_text = search_term,
                        attach_mappings = function(prompt_bufnr, map)
                            actions.select_default:replace(function()
                                local selection = action_state.get_selected_entry()
                                actions.close(prompt_bufnr)
                                
                                local file_path = selection.filename
                                local line_num = selection.lnum
                                local content = table.concat(vim.fn.readfile(file_path), "\n")
                                
                                local context = string.format(
                                    "以下のファイルの %d 行目付近について質問があります:\n\n" ..
                                    "ファイル: %s\n" ..
                                    "該当行: %s\n\n" ..
                                    "```\n%s\n```\n\n",
                                    line_num,
                                    file_path,
                                    selection.text,
                                    content
                                )
                                
                                gp.cmd.ChatNew({}, context)
                            end)
                            
                            return true
                        end,
                    })
                end,

                -- 【新規】バッファから選択
                TelescopeBuffers = function(gp, params)
                    local telescope = require('telescope.builtin')
                    local actions = require('telescope.actions')
                    local action_state = require('telescope.actions.state')
                    
                    telescope.buffers({
                        prompt_title = "GPT: バッファを選択",
                        attach_mappings = function(prompt_bufnr, map)
                            actions.select_default:replace(function()
                                local selection = action_state.get_selected_entry()
                                actions.close(prompt_bufnr)
                                
                                local bufnr = selection.bufnr
                                local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                                local content = table.concat(lines, "\n")
                                local buf_name = vim.api.nvim_buf_get_name(bufnr)
                                
                                local context = string.format(
                                    "以下のバッファについて質問があります:\n\n" ..
                                    "バッファ: %s\n\n" ..
                                    "```\n%s\n```\n\n",
                                    buf_name,
                                    content
                                )
                                
                                gp.cmd.ChatNew({}, context)
                            end)
                            
                            return true
                        end,
                    })
                end,

                -- 【新規】プロジェクトファイル一括選択
                TelescopeProject = function(gp, params)
                    local pickers = require('telescope.pickers')
                    local finders = require('telescope.finders')
                    local tele_conf = require('telescope.config').values
                    local actions = require('telescope.actions')
                    local action_state = require('telescope.actions.state')
                    
                    -- プロジェクト内の重要ファイルパターン
                    local patterns = {
                        "*.lua",
                        "*.py",
                        "*.js",
                        "*.ts",
                        "*.jsx",
                        "*.tsx",
                        "*.go",
                        "*.rs",
                        "README.md",
                        "package.json",
                        "Cargo.toml",
                        "go.mod",
                    }
                    
                    local files = {}
                    for _, pattern in ipairs(patterns) do
                        local found = vim.fn.glob(pattern, false, true)
                        for _, file in ipairs(found) do
                            table.insert(files, file)
                        end
                    end
                    
                    if #files == 0 then
                        vim.notify("ファイルが見つかりませんでした", vim.log.levels.WARN)
                        return
                    end
                    
                    pickers.new({}, {
                        prompt_title = "GPT: プロジェクトファイル選択 (Tabで複数選択)",
                        finder = finders.new_table({ results = files }),
                        sorter = tele_conf.generic_sorter({}),
                        attach_mappings = function(prompt_bufnr, map)
                            actions.select_default:replace(function()
                                local picker = action_state.get_current_picker(prompt_bufnr)
                                local selections = picker:get_multi_selection()
                                actions.close(prompt_bufnr)
                                
                                if #selections == 0 then
                                    selections = { action_state.get_selected_entry() }
                                end
                                
                                local context = "プロジェクトの以下のファイルについて:\n\n"
                                
                                for _, selection in ipairs(selections) do
                                    local file_path = selection.value
                                    local content = table.concat(vim.fn.readfile(file_path), "\n")
                                    context = context .. string.format(
                                        "=== %s ===\n```\n%s\n```\n\n",
                                        file_path,
                                        content
                                    )
                                end
                                
                                gp.cmd.ChatNew({}, context)
                            end)
                            
                            map('i', '<Tab>', actions.toggle_selection + actions.move_selection_worse)
                            map('i', '<S-Tab>', actions.toggle_selection + actions.move_selection_better)
                            
                            return true
                        end,
                    }):find()
                end,
            },
        }

        require("gp").setup(conf)

        -- キーマップ設定
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, nowait = true, desc = "GP: " .. desc })
        end

        -- 既存のキーマップ
        map({ "n", "i" }, "<C-g>c", "<cmd>GpChatNew<cr>", "New Chat")
        map({ "n", "i" }, "<C-g>t", "<cmd>GpChatToggle<cr>", "Toggle Chat")
        map("n", "<C-g>a", "<cmd>GpAgent<cr>", "Select Agent")
        map("n", "<C-g>m", "<cmd>GpCommitMsg<cr>", "Generate Commit Message")

        -- 【新規】Telescope統合キーマップ
        map("n", "<C-g>f", "<cmd>GpTelescopeFile<cr>", "Select File")
        map("n", "<C-g>F", "<cmd>GpTelescopeMultiFile<cr>", "Select Multiple Files")
        map("n", "<C-g>g", "<cmd>GpTelescopeGrep<cr>", "Select from Grep")
        map("n", "<C-g>b", "<cmd>GpTelescopeBuffers<cr>", "Select from Buffers")
        map("n", "<C-g>p", "<cmd>GpTelescopeProject<cr>", "Select Project Files")

        -- ビジュアルモードでの選択範囲送信
        map("v", "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", "New Chat with Selection")
        map("v", "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", "Append Selection to Chat")
    end,
}
