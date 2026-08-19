return {
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})

      -- 1. اختصار Normal Mode: إضافة "" حول الكلمة الحالية فوراً
      vim.keymap.set("n", "<leader>sw", 'ysiw"', { remap = true, desc = "Surround word with quotes" })

      -- 2. اختصار Visual Mode: تظليل النص ثم الضغط على Leader + s للإحاطة
      vim.keymap.set("x", "<leader>s", "<Plug>(nvim-surround-visual)", { desc = "Surround selection" })
    end,
  },
}
