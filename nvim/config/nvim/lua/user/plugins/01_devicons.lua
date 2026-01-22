-- nvim/config/nvim/lua/user/plugins/01_devicons.lua

return {
  "nvim-tree/nvim-web-devicons",

  opts = function()
    local devicons = require('nvim-web-devicons')

    local icons = devicons.get_icons()

    if not vim.g.have_nerd_font then
      -- Nerd Font 無 → フォールバック (□アイコンなど)
      for _, config in pairs(icons) do
        config.icon = "■"
      end
      return {
        override = icons,
        default_icon = "■",
      }
    else
      -- Nerd Font 有 → 元のアイコンを使う
      return {
        override = icons,
        default = true,
      }
    end
  end,
}
