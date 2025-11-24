return {
  {
    "nvim-mini/mini.files",
    lazy = false,
    opts = {
      options = {
        use_as_default_explorer = true,
      },
      windows = {
        width_nofocus = 15,
        width_focus = 25,
        width_preview = 75,
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
    },
  },
}
