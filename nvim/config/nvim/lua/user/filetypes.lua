-- dotfiles/nvim/config/nvim/lua/user/filetypes.lua

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
    vim.fn.matchadd("PromptyRoleColor", [[^\s*\(system\|user\|assistant\):]], 100)
    vim.fn.matchadd("PromptyVarColor", [[{{.\{-}}}]], 100)

    vim.keymap.set("n", "<leader>rp", function()
      if vim.fn.executable("prompty") ~= 1 then
        vim.notify("Error: 'prompty' command not found.\nPlease run './install.sh' to install it.", vim.log.levels.ERROR)
        return
      end

      local Terminal = require('toggleterm.terminal').Terminal
      local file = vim.fn.expand("%:p")
      
      if prompty_term then
        prompty_term:shutdown()
      end

      prompty_term = Terminal:new({
        cmd = string.format("prompty --source '%s'", file),
        display_name = "Prompty Result",
        direction = "float",
        close_on_exit = false,
        float_opts = {
          border = "curved",
          width = 120,
          height = 30,
        },
      })

      prompty_term:toggle()
      
    end, { 
      buffer = event.buf, 
      desc = "Run Prompty (Reset & Run)" 
    })
  end,
})
