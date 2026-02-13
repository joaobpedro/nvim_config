return {
  -- Add naysayer theme
  {
    "whizikxd/naysayer-colors.nvim",
    lazy = false, -- Load at startup
    priority = 1000, -- Load before other plugins
    config = function()
      vim.cmd("colorscheme naysayer")
    end,
  },

  -- Set it as the active colorscheme in LazyVim
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "naysayer",
    },
  },
}
