-- dotfiles/nvim/config/nvim/lua/user/plugins/10_tree.lua

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  -- lazy = false,
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Explorer: Toggle Neo-tree" },
  },
  config = function()
    -- Nerd Font の有無を判定
    local use_nerd_font = vim.g.have_nerd_font or false

    -- Nerd Font の有無に応じてアイコンを設定
    local icons = {}
    if use_nerd_font then
      -- Nerd Font がある場合（デフォルト）
      icons = {
        default = "",
        -- folder_closed = "",
        -- folder_open = "",
        -- folder_empty = "",
        -- folder_empty_open = "",
        -- symlink = "",
        -- symlink_target = "",
      }
    else
      -- Nerd Font がない場合（フォールバック）
      icons = {
        default = "■",
        folder_closed = "└─",
        folder_open = "├─",
        folder_empty = "├─",
        folder_empty_open = "├─",
        symlink = "↗",
        symlink_target = "↘",
      }
    end

    require("neo-tree").setup({
      default_component_configs = {
        icon = {
          default = icons.default,
          folder_closed = icons.folder_closed,
          folder_open = icons.folder_open,
          folder_empty = icons.folder_empty,
          folder_empty_open = icons.folder_empty_open,
          symlink = icons.symlink,
          symlink_target = icons.symlink_target,
          highlight = "NeoTreeFileIcon",
          use_diagnostic_colors = true,
          use_filtered_colors = true,
        },
        -- git_status アイコンもフォールバック
        git_status = use_nerd_font and {
          symbols = {
            -- デフォルトのNerd Fontアイコン
            added     = "✚",
            modified  = "",
            deleted   = "✖",
            renamed   = "󰁕",
            untracked = "",
            ignored   = "",
            unstaged  = "󰄱",
            staged    = "",
            conflict  = "",
          }
        } or {
          symbols = {
            -- フォールバックアイコン
            added     = "+",
            modified  = "~",
            deleted   = "-",
            renamed   = "R",
            untracked = "?",
            ignored   = "!",
            unstaged  = "U",
            staged    = "S",
            conflict  = "C",
          }
        },
        -- diagnostics アイコンもフォールバック
        diagnostics = use_nerd_font and {
          symbols = {
            hint = "󰌵",
            info = "",
            warn = "",
            error = "",
          }
        } or {
          symbols = {
            hint = "H",
            info = "I",
            warn = "W",
            error = "E",
          }
        },
      },
      window = {
        position = "left",
        width = 30,
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        window = {
            mappings = {
                ["a"] = "add",
                ["A"] = function(state)
                    require("user.custom.randomfilename").add_random(state, { ext = "" })
                end,
            },
        },
      },
    })

  end,
}
