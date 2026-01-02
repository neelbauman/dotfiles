-- dotfiles/nvim/config/nvim/lua/user/plugins/50_comment.lua

return {
  'numToStr/Comment.nvim',
  event = "VeryLazy",

  -- setup() を自動で呼び出す
  opts = {},

  -- 'keys' テーブルでキーマップを定義
  keys = {
    { "gc", "<cmd>CommentToggle<CR>", mode = "n", desc = "Comment: Toggle line (Normal)" },
    { "gc", "<cmd>CommentToggle<CR>", mode = "v", desc = "Comment: Toggle selection (Visual)"},
  }
}
