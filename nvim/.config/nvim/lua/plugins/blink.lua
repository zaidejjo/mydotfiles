return {
  "saghen/blink.cmp",
  -- Add the dictionary provider as a dependency
  dependencies = {
    "Kaiser-Yang/blink-cmp-dictionary",
  },
  opts = {
    keymap = {
      preset = "none",

      -- Tab to navigate to the next item or snippet expansion
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },

      -- Shift+Tab to navigate to the previous item or snippet backward
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },

      -- Enter to confirm the selection
      ["<CR>"] = { "accept", "fallback" },

      -- Ctrl+e to hide the completion menu immediately
      ["<C-e>"] = { "hide", "fallback" },
    },

    completion = {
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
      -- Show completions even within strings and comments
      keyword = { range = "prefix" },
      trigger = {
        show_in_snippet = true,
      },
    },

    -- Configure completion sources
    sources = {
      -- Added "dictionary" to the default sources list
      default = { "lsp", "path", "snippets", "buffer", "dictionary" },
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
        -- Dictionary provider configuration
        dictionary = {
          module = "blink-cmp-dictionary",
          name = "Dict",
          score_offset = -3,
          opts = {
            -- استخدم هذا الخيار إذا كنت تشير إلى مجلد يحتوي على ملفات .txt
            dictionary_directories = {
              vim.fn.expand("~/.config/nvim/dictionary"),
            },

            -- أو استخدم هذا الخيار إذا كنت تشير إلى ملفات محددة بالاسم
            -- dictionary_files = {
            --   vim.fn.expand("~/.config/nvim/dictionary/clean_words.txt"),
            --   vim.fn.expand("~/.config/nvim/dictionary/tech.txt"),
            --   vim.fn.expand("~/.config/nvim/dictionary/personal.txt"),
            -- },
          },
        },
      },
    },
  },
}
