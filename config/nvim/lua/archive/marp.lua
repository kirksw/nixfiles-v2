return {
  {
    "mpas/marp-nvim",
    keys = {
      { "<leader>Mt", "<cmd>MarpToggle<cr>", desc = "Toggle Marp (start/stop)" },
      { "<leader>Ms", "<cmd>MarpStatus<cr>", desc = "Check Marp status" },
    },
    config = function()
      require("marp").setup({
        port = 8080,
        wait_for_response_timeout = 30,
        wait_for_response_delay = 1,
      })
    end,
  },
}
