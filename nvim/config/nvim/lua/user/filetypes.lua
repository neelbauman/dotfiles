-- dotfiles/nvim/config/nvim/lua/user/filetypes.lua

-- Prompty実行用ターミナルのインスタンスを保持する変数（ファイル全体で共有）
local prompty_term = nil

vim.filetype.add({
  extension = {
    prompty = "prompty",
  },
})

vim.treesitter.language.register("markdown", "prompty")

-- 色定義
vim.api.nvim_set_hl(0, "PromptyRoleColor", { fg = "#ee55ee", bold = true })
vim.api.nvim_set_hl(0, "PromptyVarColor",  { fg = "#00e8c6", italic = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "prompty",
  callback = function(event)
    -- 1. ハイライト設定
    vim.fn.matchadd("PromptyRoleColor", [[^\s*\(system\|user\|assistant\):]], 100)
    vim.fn.matchadd("PromptyVarColor", [[{{.\{-}}}]], 100)

    -- 2. 実行用キーマップ (<leader>rp)
    vim.keymap.set("n", "<leader>rp", function()
      -- ToggleTermのTerminalクラスを読み込み
      local Terminal = require('toggleterm.terminal').Terminal
      local file = vim.fn.expand("%:p")
      
      -- すでに実行中のPromptyターミナルがあれば、一度完全に終了させる
      -- これにより「ウィンドウが二重に開く」のを防ぎます
      if prompty_term then
        prompty_term:shutdown()
      end

      -- 新しい実行用ターミナルを作成
      prompty_term = Terminal:new({
        -- --source オプション付きで実行
        cmd = string.format("prompty --source '%s'", file),
        display_name = "Prompty Result",
        direction = "float",
        close_on_exit = false, -- 結果を見るために閉じない
        float_opts = {
          border = "curved",
          width = 120,
          height = 30,
        },
      })

      -- ターミナルを表示
      prompty_term:toggle()
      
    end, { 
      buffer = event.buf, 
      desc = "Run Prompty (Reset & Run)" 
    })
  end,
})

