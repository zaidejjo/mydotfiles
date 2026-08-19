return {
  "folke/flash.nvim",
  keys = {
    -- تعطيل اختصار s العادي عشان ما يتعارض مع mini.surround
    { "s", mode = { "n", "x", "o" }, false },
    -- تعيين f للـ Flash Search
    {
      "f",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash Search",
    },
    -- تعيين F للـ Flash Treesitter
    {
      "F",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
  },
}
