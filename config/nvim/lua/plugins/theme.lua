return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "catppuccin/nvim",
    version = "v1.10.0",
    lazy = false,
    priority = 1000,
    name = "catppuccin",
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      transparent_background = true,
      term_colors = true,
    },
  },
  {
    "cormacrelf/dark-notify",
    lazy = false,
    config = function()
      local function apply(mode)
        local flavour = (mode == "dark") and "mocha" or "latte"
        vim.o.background = (mode == "dark") and "dark" or "light"
        require("catppuccin").setup({
          flavour = flavour,
          transparent_background = true,
          term_colors = true,
        })
        vim.cmd.colorscheme("catppuccin")
      end

      -- Initial apply based on current macOS setting
      local out = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
      local initial = (type(out) == "string" and out:match("Dark")) and "dark" or "light"
      apply(initial)

      -- Watch for changes via dark-notify
      local dn = require("dark_notify")
      dn.run({
        onchange = function(mode)
          if mode == "dark" or mode == "light" then
            apply(mode)
          end
        end,
      })
    end,
  },
}
