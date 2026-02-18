-- dotfiles/nvim/init.lua

-- 1. lazy.nvim のブートストラップ（自動インストール）
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- lazy.nvim の安定版を使う
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 2. 基本オプションとキーマップを読み込む
-- (dotfiles/nvim/config/nvim/lua/user/options.lua を読み込む)
require("user.options")
-- (dotfiles/nvim/config/nvim/lua/user/keymaps.lua を読み込む)
require("user.keymaps")
-- (dotfiles/nvim/config/nvim/lua/user/filetypes.lua を読み込む)
require("user.filetypes")

-- 3. lazy.nvim をセットアップし、プラグイン設定を読み込む
-- "user.plugins" は "dotfiles/nvim/config/nvim/lua/user/plugins/" ディレクトリを指します
require("lazy").setup({
    { import = "user.plugins" },
    { import = "user.plugins.langtools" },
})
