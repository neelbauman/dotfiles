-- nvim/config/nvim/lua/user/plugins/100_rust.lua

return {
  {
    'mrcjkb/rustaceanvim',
    version = '^5', -- 推奨バージョン
    lazy = false,   -- ftpluginとして動作するため、falseでOK
    config = function()
      vim.g.rustaceanvim = {
        -- LSPの設定
        server = {
          on_attach = function(client, bufnr)
            -- 既存のLSPキーマップを継承しつつ、Rust固有のものを追加
            local map = function(mode, lhs, rhs, desc)
              vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Rust: " .. desc })
            end

            -- 必要な時だけ呼び出す「便利な機能」
            map("n", "<leader>rr", "<cmd>RustLsp runnables<CR>", "Run (Cargo)")
            map("n", "<leader>rd", "<cmd>RustLsp debuggables<CR>", "Debug (DAP)")
          end,
        },
        -- DAPの設定 (自動的に codelldb と連携します)
        dap = {},
      }
    end
  },

  -- デバッグ機能の本体
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require('dap')

      -- IDE感を抑えた最小限のキーマップ
      -- 普段は意識せず、デバッグしたい時だけ使う
      vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = "Debug: Start/Continue" })
      vim.keymap.set('n', '<F10>', function() dap.step_over() end, { desc = "Debug: Step Over" })
      vim.keymap.set('n', '<F11>', function() dap.step_into() end, { desc = "Debug: Step Into" })
      vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })

      -- 変数の中身を浮かび上がるウィンドウで確認 (Floating Window)
      -- これなら画面レイアウトが崩れません
      vim.keymap.set('n', '<leader>dr', function() require('dap.ui.widgets').hover() end, { desc = "Debug: Inspect Variable" })
    end
  }
}
