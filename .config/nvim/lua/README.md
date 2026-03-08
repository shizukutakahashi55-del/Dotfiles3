# Configuración Neovim

## Estructura de archivos

```
~/.config/nvim/
├── init.lua                  ← entrada principal
└── lua/
    └── plugins/
        ├── themes.lua        ← TokyoNight, Catppuccin, Gruvbox
        ├── neo-tree.lua      ← árbol de archivos
        ├── telescope.lua     ← buscador fuzzy
        └── ui.lua            ← lualine, bufferline, treesitter, etc.
```

## Instalación

```bash
# 1. Haz backup de tu config actual (si tienes)
mv ~/.config/nvim ~/.config/nvim.bak

# 2. Copia esta carpeta
cp -r ./nvim ~/.config/nvim

# 3. Abre Neovim — lazy.nvim se instala solo
nvim
# Escribe :Lazy para ver el estado de los plugins
```

## Requisitos

| Herramienta | Para qué |
|-------------|----------|
| [Nerd Font](https://www.nerdfonts.com/) | Íconos en Neo-tree y lualine |
| `git` | Clonar plugins |
| `fd` | Búsqueda rápida en Telescope (`brew install fd`) |
| `ripgrep` | Live grep en Telescope (`brew install ripgrep`) |
| `make` | Compilar telescope-fzf-native |
| `node` | Opcional, para LSP servers con Mason |

## Atajos principales

### Árbol de archivos (Neo-tree)
| Atajo | Acción |
|-------|--------|
| `<Space>e`  | Abrir/cerrar árbol |
| `<Space>ef` | Revelar archivo actual en árbol |
| `a`         | Nuevo archivo/carpeta (dentro del árbol) |
| `d`         | Eliminar |
| `r`         | Renombrar |
| `s`         | Abrir en split vertical |

### Telescope (buscador)
| Atajo | Acción |
|-------|--------|
| `<Space>ff` | Buscar archivos |
| `<Space>fr` | Archivos recientes |
| `<Space>fg` | Buscar texto en proyecto |
| `<Space>fw` | Buscar palabra bajo cursor |
| `<Space>fb` | Buffers abiertos |
| `<Space>fc` | Cambiar tema (con preview) |
| `<Space>gc` | Git commits |

### Buffers
| Atajo | Acción |
|-------|--------|
| `<Tab>`   | Buffer siguiente |
| `<S-Tab>` | Buffer anterior |
| `<Space>x` | Cerrar buffer actual |

### Ventanas
| Atajo | Acción |
|-------|--------|
| `Ctrl+h/l/j/k` | Moverse entre splits |
| `<Space>w`     | Guardar archivo |
| `<Space>q`     | Salir |

## Cambiar tema

### Opción 1 — desde Telescope (interactivo con preview)
```
<Space>fc
```

### Opción 2 — permanente en `init.lua`
Cambia esta línea al final de `init.lua`:
```lua
-- TokyoNight variantes: tokyonight-night | tokyonight-storm | tokyonight-moon | tokyonight-day
vim.cmd.colorscheme("tokyonight-night")

-- Catppuccin variantes: catppuccin-latte | catppuccin-frappe | catppuccin-macchiato | catppuccin-mocha
vim.cmd.colorscheme("catppuccin-mocha")

-- Gruvbox
vim.cmd.colorscheme("gruvbox-material")
```

## Agregar más plugins

Crea un nuevo archivo en `lua/plugins/` con el formato:
```lua
return {
  "autor/nombre-plugin",
  opts = { ... },
}
```
lazy.nvim lo detecta automáticamente.
