return {
  "Exafunction/codeium.nvim",
  event = "InsertEnter", -- يشتغل أول ما تدخل وضع الكتابة

  dependencies = {
    "hrsh7th/nvim-cmp", -- مهم عشان التكامل
  },

  config = function()
    require("codeium").setup({
      enable_cmp_source = true, -- يربطه مع cmp
      virtual_text = {
        enabled = true,
        key_bindings = {
          accept = "<Tab>", -- قبول الاقتراح
          accept_word = "<C-Right>",
          accept_line = "<C-Down>",
          clear = "<C-c>",
        },
      },
    })

    -- ربط Codeium مع nvim-cmp
    local cmp = require("cmp")

    cmp.setup({
      sources = cmp.config.sources({
        { name = "codeium" }, -- مهم جدًا
      }),
    })
  end,
}
