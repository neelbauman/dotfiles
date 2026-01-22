return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cF", -- code Format
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    -- ここで言語ごとのフォーマッターを定義
    formatters_by_ft = {
      lua = { "stylua" },
      -- Python: isortで整列してからblackで整形
      python = { "isort", "black" }, 
      -- Web系: まとめてprettierにお任せ
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      -- シェルスクリプト
      sh = { "shfmt" },
    },
    -- 保存時の自動整形
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true, -- フォーマッターがない場合はLSPを使う
    },
  },
}
