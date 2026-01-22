-- dotfiles/nvim/lua/user/keymaps.lua

-- キーマップ設定のヘルパー関数
local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, desc = desc })
end

-- Insert モードを 'jk' で抜ける
map("i", "jk", "<ESC>", "Exit Insert Mode")

-- ウィンドウ操作
map("n", "<C-h>", "<C-w>h", "Window Left")
map("n", "<C-j>", "<C-w>j", "Window Down")
map("n", "<C-k>", "<C-w>k", "Window Up")
map("n", "<C-l>", "<C-w>l", "Window Right")

-- バッファ操作
map("n", "<leader>bn", ":bnext<CR>", "Buffer Next")
map("n", "<leader>bp", ":bprevious<CR>", "Buffer Previous")
map("n", "<leader>bd", ":bdelete<CR>", "Buffer Delete")

-- ターミナルモード (Insert モードから抜ける)
map("t", "jk", "<C-\\><C-n>", "Exit Terminal Mode")

-- <leader>dc (Diff Clipboard) でクリップボード比較を実行
map("n", "<leader>dc", function()
  require("user.custom.diff").diff_with_clipboard()
end, "Diff with Clipboard")
