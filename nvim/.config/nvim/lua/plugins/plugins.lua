return {
  -- البحث السريع
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- تلوين الكود المتقدم
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- شريط الحالة
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup()
    end,
  },

  -- إكمال الأقواس تلقائياً
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2", -- النسخة الأحدث والمستقرة
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
    end,
  },
}
