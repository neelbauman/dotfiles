-- dotfiles/nvim/config/nvim/lua/user/custom/filetypes.lua

vim.filetype.add({
  extension = {
    prompty = "prompty",
  },
})

vim.treesitter.language.register("markdown", "prompty")

-- 【追加】Prompty専用の色定義を作成 (Tokyonightなどのテーマに関係なく強制適用)
-- fg (文字色), bg (背景色), bold (太字), italic (斜体) などが指定可能
vim.api.nvim_set_hl(0, "PromptyRoleColor", { fg = "#ee55ee", bold = true })  -- 例: ビビッドなピンク + 太字
vim.api.nvim_set_hl(0, "PromptyVarColor",  { fg = "#00e8c6", italic = true }) -- 例: シアン + 斜体

vim.api.nvim_create_autocmd("FileType", {
  pattern = "prompty",
  callback = function()
    -- 作成した "PromptyRoleColor" を指定
    vim.fn.matchadd("PromptyRoleColor", [[^\s*\(system\|user\|assistant\):]], 100)

    -- 作成した "PromptyVarColor" を指定
    vim.fn.matchadd("PromptyVarColor", [[{{.\{-}}}]], 100)
  end,
})
