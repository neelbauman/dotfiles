-- dotfiles/nvim/config/nvim/lua/user/custom/randomfile.lua

local M = {}

-- 形容・状態（50）
local words1 = {
  "happy","sad","angry","calm","anxious","brave","curious","eager","tired","sleepy",
  "hungry","thirsty","relaxed","stressed","focused","distracted","confident","nervous","proud","shy",
  "lonely","friendly","polite","rude","gentle","harsh","optimistic","pessimistic","hopeful","fearful",
  "grateful","jealous","enthusiastic","bored","surprised","shocked","relieved","guilty","ashamed","content",
  "joyful","melancholic","serene","restless","determined","motivated","inspired","confused","patient","impatient",
}

-- 名詞（25）
local words2 = {
  "river","forest","garden","castle","village","bridge","harbor","market","library","workshop",
  "tower","cave","desert","island","valley","meadow","temple","factory","station","laboratory",
  "portal","engine","rocket","galaxy","lantern",
}

local uv = vim.uv or vim.loop
math.randomseed(uv.hrtime() % 2147483647)

local function random_word(list)
  return list[math.random(1, #list)]
end

local function random_basename()
  return string.format("%s_%s", random_word(words1), random_word(words2))
end

local function file_exists(path)
  return uv.fs_stat(path) ~= nil
end

-- dir 内で base.ext が被る場合は base-2.ext, base-3.ext … を返す
local function unique_filename(dir, base, ext)
  local join = vim.fs.joinpath
  local name = base .. ext
  local path = join(dir, name)
  if not file_exists(path) then
    return name, path
  end
  for i = 2, 9999 do
    local n = string.format("%s-%d%s", base, i, ext)
    local p = join(dir, n)
    if not file_exists(p) then
      return n, p
    end
  end
  return nil, nil
end

local function target_dir(state)
  local node = state.tree and state.tree:get_node()
  if node and node.type == "directory" then
    return node:get_id()
  elseif node and node:get_id() then
    return vim.fn.fnamemodify(node:get_id(), ":h")
  end
  return state.path or (uv.cwd and uv.cwd() or vim.fn.getcwd())
end

function M.add_random(state, opts)
  opts = opts or {}
  local dir = target_dir(state)
  local ext = opts.ext or ".txt"

  local base = random_basename()
  local name = unique_filename(dir, base, ext)
  if not name then
    vim.notify("一意なファイル名を生成できませんでした", vim.log.levels.ERROR)
    return
  end

  -- Neo-tree 標準 add を開き、入力欄へランダム名を挿入
  local commands = require("neo-tree.sources.filesystem.commands")
  commands.add(state)

  vim.defer_fn(function()
    vim.api.nvim_feedkeys(name, "t", false)
    -- すぐ確定したい場合は次を有効化:
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "t", false)
  end, 30)
end

return M

