-- dotfiles/nvim/lua/user/plugins/41_toggleterm.lua

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    -- 1. toggleterm の基本設定
    require("toggleterm").setup({
      size = 20,
      -- Ctrl+\ で通常のターミナルを開閉（お好みで）
      open_mapping = [[<c-\>]], 
      direction = "float",
      float_opts = {
        border = "curved",
      },
    })

    -- 2. dstask 専用のターミナル定義
    local Terminal = require("toggleterm.terminal").Terminal

    local dstask_term = Terminal:new({
      -- cmd を省略 = デフォルトのシェル(zsh/bash等)が起動します。
      -- これにより、開いた後に "dstask add <タスク>" などを自由に入力できます。
      hidden = true,
      direction = "float",
      float_opts = {
        border = "curved",
        width = 100,
        height = 30,
        title = " dstask ", -- 枠にタイトルを表示
      },
      on_open = function(term)
        -- 開いた瞬間にインサートモードにする
        vim.cmd("startinsert!")

        -- このターミナルバッファ内でのみ有効なキーマップ
        -- ノーマルモード(jkで抜けた後)に 'q' を押すと閉じる
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = term.bufnr, noremap = true, silent = true })
      end,
    })

    -- トグル関数
    local function _dstask_toggle()
      dstask_term:toggle()
    end

    -- 3. キーマップ設定: <Space>t で dstask 画面を呼び出す
    vim.keymap.set("n", "<leader><leader>", _dstask_toggle, { desc = "Toggle dstask terminal" })
  end,
}
