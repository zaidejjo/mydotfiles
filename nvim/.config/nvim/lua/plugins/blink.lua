return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "none",

      -- Tab للتنقل للاقتراح التالي
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },

      -- Shift+Tab للتنقل للاقتراح السابق
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },

      -- Enter لتأكيد الاختيار فقط
      ["<CR>"] = { "accept", "fallback" },

      -- Ctrl+e لإخفاء نافذة التكملة فوراً
      ["<C-e>"] = { "hide", "fallback" },
    },

    completion = {
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
      -- إظهار الاقتراحات حتى داخل النصوص والاقتباسات (Strings)
      keyword = { range = "prefix" },
      trigger = {
        show_in_snippet = true,
      },
    },

    -- ضبط مصادر الإكمال وتفعيل المسارات
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        path = {
          opts = {
            trailing_slash = true,
            label_trailing_slash = true,
            get_cwd = function(context)
              return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
            end,
            show_hidden_files_by_default = true,
          },
        },
      },
    },
  },
}
