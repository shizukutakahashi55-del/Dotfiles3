-- ============================================================
--  plugins/neo-tree.lua  –  Árbol de archivos
-- ============================================================
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch       = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",  -- íconos (requiere Nerd Font)
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>e",  "<cmd>Neotree toggle<CR>",          desc = "Toggle árbol" },
    { "<leader>ef", "<cmd>Neotree reveal<CR>",          desc = "Revelar archivo actual" },
    { "<leader>eg", "<cmd>Neotree git_status<CR>",      desc = "Git status en árbol" },
  },
  opts = {
    close_if_last_window = true,   -- cierra Neovim si Neo-tree es la última ventana
    popup_border_style   = "rounded",

    default_component_configs = {
      indent = {
        indent_size        = 2,
        padding            = 1,
        with_markers       = true,
        indent_marker      = "│",
        last_indent_marker = "└",
        with_expanders     = true,
      },
      icon = {
        folder_closed = "",
        folder_open   = "",
        folder_empty  = "󰜌",
      },
      git_status = {
        symbols = {
          added     = "✚",
          modified  = "",
          deleted   = "✖",
          renamed   = "󰁕",
          untracked = "",
          ignored   = "",
          unstaged  = "󰄱",
          staged    = "",
          conflict  = "",
        },
      },
    },

    window = {
      position = "left",
      width    = 35,
      mappings = {
        ["<space>"] = "toggle_node",
        ["<cr>"]    = "open",
        ["S"]       = "open_split",
        ["s"]       = "open_vsplit",
        ["t"]       = "open_tabnew",
        ["P"]       = { "toggle_preview", config = { use_float = true } },
        ["a"]       = { "add",            config = { show_path = "relative" } },
        ["d"]       = "delete",
        ["r"]       = "rename",
        ["y"]       = "copy_to_clipboard",
        ["x"]       = "cut_to_clipboard",
        ["p"]       = "paste_from_clipboard",
        ["c"]       = "copy",
        ["m"]       = "move",
        ["q"]       = "close_window",
        ["R"]       = "refresh",
        ["?"]       = "show_help",
      },
    },

    filesystem = {
      filtered_items = {
        visible         = false,
        hide_dotfiles   = false,   -- muestra archivos ocultos (.env, .gitignore…)
        hide_gitignored = true,
        hide_by_name    = { "node_modules", ".git" },
      },
      follow_current_file = {
        enabled = true,            -- resalta el archivo abierto en el árbol
      },
      use_libuv_file_watcher = true,
    },

    buffers = {
      follow_current_file = { enabled = true },
    },

    git_status = {
      window = { position = "float" },
    },
  },
}
