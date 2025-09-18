return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        disable_background = true,
        disable_float_background = true,
        dim_nc_background = false,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine",
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local rp = require("lualine.themes.rose-pine")

      local function clear_bc(mode)
        rp[mode].b.bg = "none"
        rp[mode].c.bg = "none"
      end
      for _, m in ipairs({ "normal", "insert", "visual", "replace", "command" }) do
        clear_bc(m)
      end
      rp.inactive.a.bg = "none"
      rp.inactive.b.bg = "none"
      rp.inactive.c.bg = "none"

      opts.options = opts.options or {}
      opts.options.theme = rp
      opts.options.globalstatus = true
      return opts
    end,
  },
  --{
  --  "nvim-lualine/lualine.nvim",
  --  opts = function(_, opts)
  --    -- Use rose-pine theme and make it transparent
  --    local rp = require("lualine.themes.rose-pine")
  --    for _, mode in pairs(rp) do
  --      for _, sect in pairs(mode) do
  --        sect.bg = "none"
  --      end
  --    end
  --    opts.options = opts.options or {}
  --    opts.options.theme = rp
  --    opts.options.globalstatus = true
  --    return opts
  --  end,
  --},
}
