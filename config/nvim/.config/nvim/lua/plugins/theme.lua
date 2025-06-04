return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
  {
    "catppuccin/nvim",
    lazy = false,
    priority = 1000,
    name = "catppuccin",
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      transparent_background = true,
      term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
    },
    cconfig = function()
      vim.o.termguicolors = true
    end,
  },
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   opts = {
  --     options = {
  --       theme = "catppuccin-mocha",
  --       section_separators = "",
  --       component_separators = "",
  --       icons_enabled = true,
  --     },
  --     dependencies = {
  --       "nvim-tree/nvim-web-devicons",
  --     },
  --     sections = {
  --       lualine_a = { "mode" },
  --       lualine_b = { "branch", "diff", "diagnostics" },
  --       lualine_c = { "filename" },
  --       lualine_x = { "filetype" },
  --       lualine_y = { "progress" },
  --       lualine_z = { "location" },
  --     },
  --   },
  -- },
}
