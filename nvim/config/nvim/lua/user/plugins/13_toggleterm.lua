-- dotfiles/nvim/config/nvim/lua/user/plugins/41_toggleterm.lua

return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        -- 1. toggleterm の基本設定
        require("toggleterm").setup({
            size = 20,
            open_mapping = [[<c-\>]], 
            direction = "float",
            float_opts = {
                border = "curved",
            },
            -- 永続化設定
            hide_numbers = true,
            shade_terminals = true,
            start_in_insert = true,
            persist_mode = true,
        })

        -- 2. dstask 専用のターミナル定義
        local Terminal = require("toggleterm.terminal").Terminal

        local dstask_term = Terminal:new({
            hidden = true,
            direction = "float",
            float_opts = {
                border = "curved",
                width = 100,
                height = 30,
                title = " dstask ",
            },
            on_open = function(term)
                -- ウィンドウを閉じてもバッファを裏で維持する設定
                vim.bo[term.bufnr].bufhidden = "hide"
                vim.cmd("startinsert!")

                -- 'q' でウィンドウだけ閉じる (バッファは隠れる)
                vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = term.bufnr, noremap = true, silent = true })
            end,
        })

        -- トグル関数
        local function _dstask_toggle()
            dstask_term:toggle()
        end

        -- zenn用のトグル
        local zenn_preview = Terminal:new({
            cmd = "npx zenn preview",
            hidden = true,
            direction = "vertical", -- 画面右側に表示
            on_open = function(term)
                vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
            end,
        })

        function _zenn_preview_toggle()
            zenn_preview:toggle()
        end


        -- 3. キーマップ設定: Space連打
        vim.keymap.set("n", "<leader><leader>", _dstask_toggle, { desc = "Toggle dstask" })
        vim.keymap.set("n", "<leader>zp", "<cmd>lua _zenn_preview_toggle()<CR>", { desc = "Zenn: Toggle Preview Server" })


        -- 【追加】終了時 (:wqa / :qa) の自動クリーンアップ
        -- これがないと "E948: Job still running" で終了を阻止されます
        vim.api.nvim_create_autocmd("ExitPre", {
            group = vim.api.nvim_create_augroup("DstaskExit", { clear = true }),
            callback = function()
                -- dstaskのバッファが存在する場合、強制的に削除(force=true)してジョブを終了させる
                if dstask_term.bufnr and vim.api.nvim_buf_is_valid(dstask_term.bufnr) then
                    vim.api.nvim_buf_delete(dstask_term.bufnr, { force = true })
                end
            end,
        })
    end,
}
