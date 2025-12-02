-- dotfiles/nvim/lua/user/plugins/20_lsp.lua

return {
  -- LSP インストーラ
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- mason と lspconfig を繋ぐ
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
  },

  -- LSP 本体
  -- -- dotfiles/nvim/lua/user/plugins/20_lsp.lua
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp", -- (補完機能から capabilities をもらうため)
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- 診断機能 (diagnostic) 用のグローバルキーマップ
      vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show line diagnostics (float)" })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to prev diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })

      -- LSPがアタッチされた時の共通設定 (キーマップなど)
      local on_attach = function(client, bufnr)
        local bufmap = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = "LSP: " .. desc })
        end

        bufmap("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
        bufmap("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
        bufmap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
        bufmap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

      end

      -- mason-lspconfig のセットアップ
      require("mason-lspconfig").setup({
        -- 1. 自動インストールしたいLSPサーバー
        ensure_installed = {
          "lua_ls",
          "pyright",
          "ts_ls",
          "bashls",
          "dockerls",
          "jsonls",
          "yamlls",
          "astro",
          "marksman",
        },

        -- 2. 各サーバーに渡す設定
        handlers = {

          -- まず、全てのサーバーに対する共通設定
          function(server_name)
            lspconfig[server_name].setup({
              on_attach = on_attach,
              capabilities = capabilities,
            })
          end,

          -- -- 次に、pyright 専用の追加設定
          -- ["pyright"] = function()
          --   lspconfig.pyright.setup({
          --     on_attach = on_attach,
          --     capabilities = capabilities,
          --     -- 仮想環境のライブラリを認識させるための設定
          --     settings = {
          --       python = {
          --         analysis = {
          --           useLibraryCodeForTypes = true,
          --           autoSearchPaths = true,
          --           diagnosticMode = "workspace",
          --         },
          --       },
          --     },
          --   })
          -- end,
        },
      })
    end,
  },
}
