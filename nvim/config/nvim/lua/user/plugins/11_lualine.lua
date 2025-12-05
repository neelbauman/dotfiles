-- dotfiles/nvim/lua/user/plugins/11_statusline.lua

return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local use_nerd_font = vim.g.have_nerd_font or false

        -- Nerd Font の有無に応じてアイコンを設定
        local icons = {}
        if use_nerd_font then
            icons = {
                error = '',
                warn = '',
                info = '',
                hint = '',
                modified = '●',
                readonly = '',
                git_branch = '',
                git_added = '',
                git_modified = '',
                git_removed = '',
            }
        else
            icons = {
                error = 'E',
                warn = 'W',
                info = 'I',
                hint = 'H',
                modified = '*',
                readonly = 'RO',
                git_branch = 'BR',
                git_added = '+',
                git_modified = '~',
                git_removed = '-',
            }
        end


        local function git_branch_description()
            local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null")

            if vim.v.shell_error ~= 0 or branch == nil or branch == '' then
                return ""
            end

            branch = string.gsub(branch, "\n", "")

            local desc = vim.fn.system("git config branch." .. branch .. ".description 2>/dev/null")

            if vim.v.shell_error ~= 0 or branch == nil or branch == '' then
                return ""
            end

            desc = string.gsub(desc, "\n", "")

            return "BRANCH_DESCRIPTION: " .. desc
        end

        -- 1. CodeCompanionの処理状態を管理する変数を定義
        local codecompanion_processing = false

        -- 2. イベントを監視して変数を切り替える
        -- (lualineのsetupの前、または同じファイル内の上の方に書いてください)
        local group = vim.api.nvim_create_augroup("CodeCompanionStatus", { clear = true })

        vim.api.nvim_create_autocmd("User", {
            pattern = "CodeCompanionRequestStarted",
            group = group,
            callback = function()
                codecompanion_processing = true
                require("lualine").refresh() -- 即座に反映させる
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            pattern = "CodeCompanionRequestFinished",
            group = group,
            callback = function()
                codecompanion_processing = false
                require("lualine").refresh()
            end,
        })


        require('lualine').setup({
            options = {
                icons_enabled = use_nerd_font,
                theme = 'auto',
            },
            sections = {
                lualine_a = {'mode'},
                lualine_b = {
                    {
                        'branch',
                        icon = icons.git_branch
                    },
                    {
                        'diff',
                        symbols = {
                            added = icons.git_added,
                            modified = icons.git_modified,
                            removed = icons.git_removed
                        }
                    }
                },
                lualine_c = {
                    {
                        git_branch_description,
                        {
                            'filename',
                            symbols = {
                                modified = icons.modified,
                                readonly = icons.readonly,
                            }
                        }
                    }
                },
                lualine_x = {
                    {
                        'diagnostics',
                        symbols = {
                            error = icons.error,
                            warn = icons.warn,
                            info = icons.info,
                            hint = icons.hint,
                        }
                    },
                    'encoding',
                    'fileformat',
                    'filetype',
                    {
                        function()
                            if codecompanion_processing then
                                return " Processing..." -- ここに好きなアイコンや文字
                            else
                                return ""
                            end
                        end,
                        color = { fg = "#ff9e64" }, -- 色の設定（オレンジなど）
                    },
                },
                lualine_y = {'progress'},
                lualine_z = {'location'}
            },
        })
    end,
}
