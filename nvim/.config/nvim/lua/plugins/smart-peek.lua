return {
  "zaidejjo/smart-peek.nvim",
  keys = {
    {
      "<leader>pt",
      function()
        require("smart-peek").open_tab()
      end,
      desc = "Peek in New Tab",
    },
    {
      "<leader>pv",
      function()
        require("smart-peek").open_vsplit()
      end,
      desc = "Peek in VSplit",
    },
    {
      "<leader>pp",
      function()
        require("smart-peek").peek()
      end,
      desc = "Floating Peek Window",
    },
  },
  config = function()
    require("smart-peek").setup()
  end,
}
