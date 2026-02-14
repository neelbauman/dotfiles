-- nvim/config/nvim/lua/user/plugins/100_zenn.lua

return {
  -- クリップボードの画像を Zenn の images フォルダに自動保存
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        dir_path = "images", -- Zenn CLI の推奨構成
        use_absolute_path = false,
        relative_to_current_file = true,
      },
    },
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Zenn: Paste Image" },
    },
  },

  -- Zenn特有のFront Matterを自動挿入するスニペット (LuaSnip連携)
  {
    "L3MON4D3/LuaSnip",
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node

      -- Markdownファイルで 'zenn' と打って展開
      ls.add_snippets("markdown", {
        s("zenn", {
          t({ "---", "title: \"" }), i(1, "記事タイトル"),
          t({ "\"", "emoji: \"" }), i(2, "😺"),
          t({ "\"", "type: \"" }), i(3, "tech"), -- tech or idea
          t({ "\"", "topics: [" }), i(4, "tags"),
          t({ "]", "published: false", "---", "" }),
          i(0)
        }),
      })
    end,
  },
}
