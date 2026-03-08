-- ============================================================
--  init.lua  –  Neovim config principal
-- ============================================================

-- Opciones generales
vim.opt.number         = true        -- números de línea
vim.opt.relativenumber = true        -- números relativos
vim.opt.tabstop        = 2
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true
vim.opt.termguicolors  = true        -- colores 24-bit (necesario para temas)
vim.opt.signcolumn     = "yes"
vim.opt.wrap           = false
vim.opt.scrolloff      = 8
vim.opt.updatetime     = 250
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.clipboard      = "unnamedplus" -- comparte portapapeles con el SO

-- Tecla líder → Espacio
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ── Bootstrap lazy.nvim ──────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ── Cargar plugins ───────────────────────────────────────────
require("lazy").setup("plugins", {
  change_detection = { notify = false },
})

-- ── Tema por defecto ─────────────────────────────────────────
-- Cambia a "catppuccin" si lo prefieres
vim.cmd.colorscheme("tokyonight-night")

-- ── Keymaps generales ────────────────────────────────────────
local map = vim.keymap.set

-- Guardar / salir rápido
map("n", "<leader>w", "<cmd>w<CR>",  { desc = "Guardar" })
map("n", "<leader>q", "<cmd>q<CR>",  { desc = "Salir" })

-- Mover entre ventanas con Ctrl + hjkl
map("n", "<C-h>", "<C-w>h", { desc = "Ventana izquierda" })
map("n", "<C-l>", "<C-w>l", { desc = "Ventana derecha" })
map("n", "<C-j>", "<C-w>j", { desc = "Ventana abajo" })
map("n", "<C-k>", "<C-w>k", { desc = "Ventana arriba" })

-- Quitar resaltado de búsqueda
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
