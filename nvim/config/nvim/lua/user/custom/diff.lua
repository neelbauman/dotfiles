-- dotfiles/nvim/config/nvim/lua/user/custom/diff.lua

local M = {}

function M.diff_with_clipboard()
  -- 元のウィンドウとファイルタイプを記録
  local original_win = vim.api.nvim_get_current_win()
  local filetype = vim.bo.filetype

  -- 左側に垂直分割で新規バッファを作成
  vim.cmd("vnew")
  local diff_win = vim.api.nvim_get_current_win()
  local diff_buf = vim.api.nvim_get_current_buf()

  -- スクラッチバッファ（保存不要の一時バッファ）として設定
  vim.bo[diff_buf].buftype = "nofile"
  vim.bo[diff_buf].bufhidden = "wipe"
  vim.bo[diff_buf].swapfile = false
  vim.bo[diff_buf].filetype = filetype -- シンタックスハイライトを元のファイルに合わせる

  -- クリップボード(+)の内容を取得してバッファにセット
  local content = vim.fn.getreg("+")
  if content == "" then
    vim.notify("Clipboard is empty!", vim.log.levels.WARN)
    vim.cmd("close") -- 空なら閉じる
    return
  end
  local lines = vim.split(content, "\n")
  vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, lines)

  -- 両方のウィンドウでDiffモードを有効化
  vim.api.nvim_set_current_win(original_win)
  vim.cmd("diffthis")
  vim.api.nvim_set_current_win(diff_win)
  vim.cmd("diffthis")

  -- 比較用バッファを閉じたら、元のバッファのDiffモードも終了させる
  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = diff_buf,
    callback = function()
      if vim.api.nvim_win_is_valid(original_win) then
        vim.api.nvim_win_call(original_win, function()
          vim.cmd("diffoff")
        end)
      end
    end,
    once = true,
  })
end

return M

