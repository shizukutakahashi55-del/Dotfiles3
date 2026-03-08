-- ============================================================
--  plugins/telescope.lua  –  Buscador fuzzy
-- ============================================================
return {
  "nvim-telescope/telescope.nvim",
  branch       = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    -- Extensión nativa (mucho más rápida para proyectos grandes)
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond  = function() return vim.fn.executable("make") == 1 end,
    },
    -- Buscador de proyectos recientes
    "nvim-telescope/telescope-project.nvim",
  },

  keys = {
    -- Archivos
    { "<leader>ff", "<cmd>Telescope find_files<CR>",                    desc = "Buscar archivos" },
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>",                      desc = "Archivos recientes" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>",                     desc = "Buscar texto (grep)" },
    { "<leader>fw", "<cmd>Telescope grep_string<CR>",                   desc = "Buscar palabra bajo cursor" },
    -- Buffers / UI
    { "<leader>fb", "<cmd>Telescope buffers<CR>",                       desc = "Buffers abiertos" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>",                     desc = "Ayuda de Neovim" },
    { "<leader>fk", "<cmd>Telescope keymaps<CR>",                       desc = "Ver keymaps" },
    { "<leader>fc", "<cmd>Telescope colorscheme<CR>",                   desc = "Cambiar tema" },
    -- Git
    { "<leader>gc", "<cmd>Telescope git_commits<CR>",                   desc = "Git commits" },
    { "<leader>gb", "<cmd>Telescope git_branches<CR>",                  desc = "Git branches" },
    { "<leader>gs", "<cmd>Telescope git_status<CR>",                    desc = "Git status" },
    -- Diagnósticos LSP
    { "<leader>fd", "<cmd>Telescope diagnostics<CR>",                   desc = "Diagnósticos" },
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>",          desc = "Símbolos del documento" },
  },

  config = function()
    local telescope = require("telescope")
    local actions   = require("telescope.actions")

    telescope.setup({
      defaults = {
        prompt_prefix   = "  ",
        selection_caret = " ",
        path_display    = { "smart" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width   = 0.55,
            results_width   = 0.45,
          },
          vertical = { mirror = false },
          width    = 0.87,
          height   = 0.80,
        },
        mappings = {
          i = {
            ["<C-k>"]    = actions.move_selection_previous,
            ["<C-j>"]    = actions.move_selection_next,
            ["<C-q>"]    = actions.send_selected_to_qflist + actions.open_qflist,
            ["<Esc>"]    = actions.close,
            ["<C-u>"]    = false,   -- limpia el prompt con Ctrl+u
          },
        },
      },

      pickers = {
        find_files = {
          hidden       = true,          -- incluye archivos ocultos
          find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
        },
        live_grep = {
          additional_args = { "--hidden" },
        },
        colorscheme = {
          enable_preview = true,        -- previsualiza el tema antes de aplicar
        },
      },

      extensions = {
        fzf = {
          fuzzy                   = true,
          override_generic_sorter = true,
          override_file_sorter    = true,
          case_mode               = "smart_case",
        },
      },
    })

    -- Cargar extensiones
    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "project")
  end,
}
