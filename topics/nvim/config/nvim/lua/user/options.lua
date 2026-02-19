-- dotfiles/nvim/lua/user/options.lua

-- リーダーキーを Space に設定
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false

local opt = vim.opt -- 可読性のため

-- 行番号
opt.number = true
opt.relativenumber = true

-- インデント
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true -- タブをスペースに変換
opt.autoindent = true

-- 検索
opt.ignorecase = true -- 大文字小文字を無視
opt.smartcase = true  -- ただし大文字が含まれていれば厳密に

-- UI
opt.termguicolors = true -- 24-bit RGB カラーを有効化
opt.signcolumn = "yes"     -- 常にサインカラム（LSPの警告など）を表示

-- 挙動
opt.mouse = "a"           -- マウスサポートを有効化
opt.clipboard = "unnamedplus" -- OSのクリップボードと連携
opt.wrap = true           -- ソフトラップを有効化
opt.linebreak = true      -- 単語単位で折り返す
opt.colorcolumn = "80"    -- 80文字目のガイドライン
opt.swapfile = false      -- スワップファイルを作成しない
opt.backup = false        -- バックアップファイルを作成しない
opt.scrolloff = 999       -- カーソルを中央に置く
opt.splitright = true
opt.splitbelow = true

-- 外部でのファイル変更を検知して自動リロード (Claude Code連携用)
opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    group = vim.api.nvim_create_augroup("AutoRead", { clear = true }),
    pattern = "*",
    callback = function()
        if vim.fn.getcmdwintype() == "" then
            vim.cmd("checktime")
        end
    end,
})
