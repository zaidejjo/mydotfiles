return {
  "nickjvandyke/opencode.nvim",
  version = "*", -- Latest stable release
  dependencies = {
    {
      -- `snacks.nvim` integration is recommended, but optional
      ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
      "folke/snacks.nvim",
      optional = true,
      opts = {
        input = {}, -- Enhances `ask()`
        picker = { -- Enhances `select()`
          actions = {
            opencode_send = function(...)
              return require("opencode").snacks_picker_send(...)
            end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any; goto definition on the type or field for details
    }

    vim.o.autoread = true -- Required for `opts.events.reload`

    -- الاختصارات الجديدة البديلة لـ Ctrl --

    -- بديل <C-a> (Ask opencode) -> Leader + a
    vim.keymap.set({ "n", "x" }, "<leader>oa", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "Ask opencode…" })

    -- بديل <C-x> (Execute action) -> Leader + x
    vim.keymap.set({ "n", "x" }, "<leader>ox", function()
      require("opencode").select()
    end, { desc = "Execute opencode action…" })

    -- فتح وإغلاق الإضافة -> Leader + oo
    vim.keymap.set({ "n", "t" }, "<leader>oo", function()
      require("opencode").toggle()
    end, { desc = "Toggle opencode" })

    -- اختصارات الـ Operator (بقيت كما هي لأنها لا تستخدم Ctrl)
    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { desc = "Add range to opencode", expr = true })

    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = "Add line to opencode", expr = true })

    -- بديل اختصارات السكرول (الرفع والتنزيل) اللي كانت تستخدم Shift+Ctrl
    -- السكرول لأعلى -> Leader + [
    vim.keymap.set("n", "<leader>o[", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "Scroll opencode up" })

    -- السكرول لأسفل -> Leader + ]
    vim.keymap.set("n", "<leader>o]", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "Scroll opencode down" })

    -- ملاحظة: تم حذف إعدادات الـ + والـ - لأن زر الـ Ctrl عندك لا يعمل أصلاً
  end,
}
