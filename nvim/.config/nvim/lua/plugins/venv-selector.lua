return {
  "linux-cultist/venv-selector.nvim",
  branch = "regexp", -- فرع النسخة الجديدة والأسرع
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-telescope/telescope.nvim",
    "mfussenegger/nvim-dap-python",
  },
  opts = {
    settings = {
      options = {
        notify_user_on_venv_activation = true, -- يظهر تنبيه عند تفعيل البيئة
      },
    },
  },
  keys = {
    -- الاختصار: مفتاح اللييدير (عادة Space) ثم v ثم s
    { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
  },
}
