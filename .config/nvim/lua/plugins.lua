return {
  -- Árbol de archivos lateral
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
    require("nvim-tree").setup({
      view = { width = 30, side = "left" },
      filters = { dotfiles = false },
    })
    vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>", { silent = true })
    end,
  },

  -- Búsqueda difusa
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<C-p>", builtin.find_files, {})
    vim.keymap.set("n", "<C-f>", builtin.live_grep, {})
    vim.keymap.set("n", "<C-e>", builtin.buffers, {})
    end,
  },

  -- Barra de estado
  {
    "nvim-lualine/lualine.nvim",
    config = function()
    require("lualine").setup({ options = { theme = "catppuccin" } })
    end,
  },

  -- Tema Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      transparent_background = true,
      styles = {
        comments = { "italic" },
        keywords = { "italic" },
      },
    })
    vim.cmd.colorscheme("catppuccin")
    end,
  },
}
