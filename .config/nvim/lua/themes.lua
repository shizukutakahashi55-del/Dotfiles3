-- ============================================================
--  plugins/themes.lua  –  Temas de color
-- ============================================================
return {

  -- ── TokyoNight (por defecto en init.lua) ─────────────────
  {
    "folke/tokyonight.nvim",
    priority = 1000,   -- carga primero que otros plugins
    opts = {
      style      = "night",   -- opciones: "night" | "storm" | "moon" | "day"
      transparent = false,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
    },
  },

  -- ── Catppuccin ────────────────────────────────────────────
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",   -- opciones: "latte" | "frappe" | "macchiato" | "mocha"
      integrations = {
        neo_tree   = true,
        telescope  = { enabled = true },
        treesitter = true,
        lualine    = true,
      },
    },
  },

  -- ── Gruvbox Material ──────────────────────────────────────
  {
    "sainnhe/gruvbox-material",
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background        = "medium"  -- "hard" | "medium" | "soft"
      vim.g.gruvbox_material_foreground        = "material"
      vim.g.gruvbox_material_enable_italic     = 1
      vim.g.gruvbox_material_enable_bold       = 1
    end,
  },

  -- ── Keymaps para cambiar tema rápido ──────────────────────
  -- <leader>t1 → TokyoNight
  -- <leader>t2 → Catppuccin
  -- <leader>t3 → Gruvbox Material
  {
    "nvim-lua/plenary.nvim",   -- dependencia común, se incluye aquí para orden
    lazy = true,
  },
}
