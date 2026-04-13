return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",

  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },

  config = function()
    local cmp = require("cmp")

    cmp.setup({
      mapping = cmp.mapping.preset.insert({
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
      }),

      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "codeium" }, -- مهم
      }),
    })
  end,
}
