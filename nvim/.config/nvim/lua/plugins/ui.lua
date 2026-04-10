return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
 ███████╗ █████╗ ██╗██████╗      █████╗      ██╗ ██████╗ 
 ╚══███╔╝██╔══██╗██║██╔══██╗    ██╔══██╗     ██║██╔═══██╗
   ███╔╝ ███████║██║██║  ██║    ███████║     ██║██║   ██║
  ███╔╝  ██╔══██║██║██║  ██║    ██╔══██║██   ██║██║   ██║
 ███████╗██║  ██║██║██████╔╝    ██║  ██║╚█████╔╝╚██████╔╝
 ╚══════╝╚═╝  ╚═╝╚═╝╚═════╝     ╚═╝  ╚═╝ ╚════╝  ╚═════╝ ]],
        },
        sections = {
          -- hl = "String" سيعطي الشعار لوناً أخضر/زيتي مريح جداً في Mocha
          { section = "header", padding = 2, hl = "String" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },

  -- تعطيل الإضافات القديمة
  { "goolord/alpha-nvim", enabled = false },
  { "nvimdev/dashboard-nvim", enabled = false },

  -- إعداد ثيم Catppuccin Mocha
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- تم التغيير لـ Mocha
      transparent_background = true,
      term_colors = true,
      integrations = {
        snacks = true,
        telescope = true,
        mason = true,
        which_key = true,
      },
    },
  },

  -- تفعيل الثيم كافتراضي
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
