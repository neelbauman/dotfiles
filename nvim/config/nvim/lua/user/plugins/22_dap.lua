-- dotfiles/nvim/config/nvim/lua/user/plugins/21_dap.lua

return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",     -- 外部エンジン管理の親玉
      "mfussenegger/nvim-dap",      -- デバッグ機能の本体
    },
    config = function()
      require("mason-nvim-dap").setup({
        -- ここに自動インストールしたいデバッガ（外部エンジン）を記述します
        ensure_installed = { 
          "codelldb", -- Rust, C, C++ 用
        },
        -- インストールされていない場合に自動で入れる設定
        automatic_installation = true,
      })
    end,
  },
}
