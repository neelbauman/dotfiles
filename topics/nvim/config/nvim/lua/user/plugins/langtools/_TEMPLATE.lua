-- dotfiles/nvim/config/nvim/lua/user/plugins/langtools/_TEMPLATE.lua

-- 【使い方】
-- 1. このファイルをコピーして `04_typescript.lua` などにリネームする
-- 2. この return {} を削除する
return {}
-- 3. 以下のコメントアウト（--[[ ... ]]）を外す
-- 4. "YOUR_SERVER" や "your_lang" を書き換える


--[[
-- 1. 自動設定の無効化（自己申告）
require("user.utils.lsp_manage").register_custom_config("YOUR_LSP_SERVER_NAME")

return {
    -- =========================================================================
    -- 2. LSP (Language Server) の言語固有設定
    -- =========================================================================
    {
        "neovim/nvim-lspconfig",
        ft = { "your_lang" }, -- ここで指定したファイルを開くまで読み込まれない
        config = function()
            local lspconfig = require("lspconfig")
            local lsp_utils = require("user.utils.lsp_manage")

            local opts = {
                on_attach = lsp_utils.on_attach,
                capabilities = lsp_utils.capabilities,
                settings = {
                    -- 言語固有の設定 (例: analysis = { ... })
                },
            }

            -- 設定の適用
            if vim.lsp.config and vim.lsp.config["YOUR_LSP_SERVER_NAME"] then
                vim.lsp.config["YOUR_LSP_SERVER_NAME"] = vim.tbl_deep_extend("force", vim.lsp.config["YOUR_LSP_SERVER_NAME"], opts)
                vim.lsp.enable("YOUR_LSP_SERVER_NAME")
            else
                lspconfig["YOUR_LSP_SERVER_NAME"].setup(opts)
            end
        end,
    },

    -- =========================================================================
    -- 3. DAP (Debugger) の言語固有設定
    -- ※ 必要なければこのブロックは削除してください
    -- =========================================================================
    {
        "mfussenegger/nvim-dap",
        -- デバッグ対象のファイルを開いたときに読み込む
        ft = { "your_lang" }, 
        config = function()
            local dap = require("dap")

            -- 1. アダプターの定義 (デバッガをどう起動するか)
            -- 例: "server" タイプや "executable" タイプなど
            -- dap.adapters.your_debugger = {
            --     type = 'executable',
            --     command = 'path/to/debugger',
            --     args = { '--port', '${port}' },
            -- }

            -- 2. 設定の定義 (デバッグ開始時の挙動)
            -- dap.configurations.your_lang = {
            --     {
            --         type = 'your_debugger',
            --         request = 'launch',
            --         name = "Launch file",
            --         program = "${file}",
            --     },
            -- }

            -- 3. キーマップ (Rustの設定と同様、必要な場合のみ記述)
            -- ※ F5, F10などの基本操作は 21_dap.lua にまとめるのが推奨ですが、
            --   言語固有の操作があればここに書きます。
            -- vim.keymap.set('n', '<leader>dt', function() dap.run_last() end, { desc = "Debug: Run Last" })
        end
    },
}
--]]

