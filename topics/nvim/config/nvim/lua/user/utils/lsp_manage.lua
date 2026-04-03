-- nvim/config/nvim/lua/user/utils/lsp_manage.lua
local M = {}

M.skip_servers = {}

--- インフラ側(20_lsp.lua)の自動セットアップを無効化するためにサーバーを登録します。
function M.register_custom_config(server_name)
    M.skip_servers[server_name] = true
end

-- 【変更点】 capabilities を関数で遅延評価するように変更し、循環参照を防止します
function M.get_capabilities()
    local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if status_ok then
        return cmp_nvim_lsp.default_capabilities()
    end
    return vim.lsp.protocol.make_client_capabilities()
end

-- ここで診断表示の見た目（アイコンなど）も設定しておくと見やすくなります
vim.diagnostic.config({
    virtual_text = true, -- 行末のメッセージを表示
    signs = true,        -- 行番号横のアイコンを表示
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "always",
    },
})

M.on_attach = function(client, bufnr)
    local bufmap = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = "LSP: " .. desc })
    end

    -- 既存のキーマップ
    bufmap("n", "K", vim.lsp.buf.hover, "Hover")
    bufmap("n", "gd", vim.lsp.buf.definition, "Go to Definition")
    bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")

    -- 【追加】診断ジャンプ (]d / [d)
    bufmap("n", "]d", function() 
        vim.diagnostic.goto_next({ float = { border = "rounded" } }) 
    end, "Next Diagnostic")

    bufmap("n", "[d", function() 
        vim.diagnostic.goto_prev({ float = { border = "rounded" } }) 
    end, "Prev Diagnostic")
end

return M
