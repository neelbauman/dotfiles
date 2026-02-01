-- lua/user/plugins/90_starter.lua

return {
    "echasnovski/mini.starter",
    version = "*", -- 最新版を使用
    event = "VimEnter",
    config = function()
        local starter = require("mini.starter")

        starter.setup({
            -- ヘッダー（アスキーアートなど）はお好みでカスタマイズ可能
            header = table.concat({
                "   Neovim config   ",
                "   with AI Agents  ",
            }, "\n"),

            -- アイテム定義
            items = {
                -- 1. AIチャットを開くカスタムアクション
                {
                    name = "AI Chat (Claude/GPT)", -- 表示名
                    action = "GpChatNew vsplit",   -- 実行するコマンド (垂直分割で新規チャット)
                    section = "Assistance",        -- セクション名
                },
                
                -- 2. 標準のセクション (最近使ったファイルなど)
                starter.sections.recent_files(5, false),
                starter.sections.builtin_actions(),
            },

            -- フッター設定 (例: 日時など)
            footer = os.date(),
        })
    end,
}

