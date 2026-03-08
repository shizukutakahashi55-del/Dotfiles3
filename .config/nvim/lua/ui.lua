-- ============================================================
--  plugins/ui.lua  –  Interfaz visual
-- ============================================================
return {

  -- ── Barra de estado ───────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme                = "tokyonight",  -- cambia si usas otro tema
        globalstatus         = true,
        component_separators = { left = "", right = "" },
        section_separators   = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },   -- ruta relativa
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- ── Pestañas de buffers ───────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    version      = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<Tab>",   "<cmd>BufferLineCycleNext<CR>", desc = "Buffer siguiente" },
      { "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", desc = "Buffer anterior" },
      { "<leader>x", "<cmd>bdelete<CR>",           desc = "Cerrar buffer" },
    },
    opts = {
      options = {
        mode              = "buffers",
        diagnostics       = "nvim_lsp",
        show_close_icon   = false,
        separator_style   = "slant",   -- "thin" | "thick" | "slant" | "padded_slant"
        offsets = {
          {
            filetype   = "neo-tree",
            text       = "  Explorador",
            highlight  = "Directory",
            separator  = true,
          },
        },
      },
    },
  },

  -- ── Guías de indentación ──────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent  = { char = "│" },
      scope   = { enabled = true, show_start = false },
      exclude = {
        filetypes = { "help", "dashboard", "neo-tree", "lazy", "mason" },
      },
    },
  },

  -- ── Pares automáticos ─────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts  = {},
  },

  -- ── Comentarios rápidos  (gcc / gc en visual) ─────────────
  {
    "numToStr/Comment.nvim",
    opts = {},
  },

  -- ── Dashboard al abrir Neovim sin archivo ─────────────────
  {
    "nvimdev/dashboard-nvim",
    event        = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("dashboard").setup({
        theme = "doom",
        config = {
          header = {
            "",
            "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
            "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
            "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
            "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
            "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
            "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
            "",
          },
          center = {
            { icon = "  ", desc = "Nuevo archivo       ", key = "n", action = "enew" },
            { icon = "  ", desc = "Buscar archivo      ", key = "f", action = "Telescope find_files" },
            { icon = "  ", desc = "Archivos recientes  ", key = "r", action = "Telescope oldfiles" },
            { icon = "  ", desc = "Buscar texto        ", key = "g", action = "Telescope live_grep" },
            { icon = "  ", desc = "Configuración       ", key = "c", action = "edit $MYVIMRC" },
            { icon = "󰒲  ", desc = "Plugins (Lazy)      ", key = "l", action = "Lazy" },
            { icon = "  ", desc = "Salir               ", key = "q", action = "qa" },
          },
          footer = { "", "  Neovim cargado  " },
        },
      })
    end,
  },

  -- ── Notificaciones bonitas ────────────────────────────────
  {
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require("notify")
      require("notify").setup({
        background_colour = "#000000",
        timeout  = 3000,
        max_width = 60,
      })
    end,
  },

  -- ── Which-key: muestra atajos disponibles ─────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = {
      delay = 500,
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>f", group = "Buscar (Telescope)" },
        { "<leader>e", group = "Explorador (Neo-tree)" },
        { "<leader>g", group = "Git" },
      })
    end,
  },

  -- ── Treesitter: resaltado de sintaxis ─────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc",
          "javascript", "typescript", "tsx",
          "python", "rust", "go",
          "html", "css", "json", "yaml", "toml",
          "bash", "markdown", "markdown_inline",
        },
        auto_install   = true,
        highlight      = { enable = true },
        indent         = { enable = true },
      })
    end,
  },
}
