-- dotfiles/nvim/lua/user/plugins/00_core.lua

return {
  -- カラースキーム
  {
    "folke/tokyonight.nvim",
    priority = 1000, -- 最初に読み込む
    config = function()
      vim.cmd.colorscheme("tokyonight-storm") -- 'storm' テーマを適用
    end,
  },

  -- ステータスライン
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- アイコンも入れる
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
        },
      })
    end,
  },

  -- どのキーに何が割り当てられているか表示
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },

  -- Git の変更をガター（行番号の横）に表示
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
  -- Git
  {
    "tpope/vim-fugitive",
    cmd = {
        "Git",
        "G",
        "Gstatus",
    "Gblame",
    "Gdiff",
    "Gcommit",
    "Glog",
    "Gpush",
    "Gpull",
    "Gfetch",
    -- 必要に応じて他のfugitiveコマンドも追加できます
  },
  -- 頻繁に使うキーマップをここで設定することもできます
  -- config = function()
  --   vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "[G]it [S]tatus" })
  --   vim.keymap.set("n", "<leader>gc", vim.cmd.Gcommit, { desc = "[G]it [C]ommit" })
  -- end,
  },
}
