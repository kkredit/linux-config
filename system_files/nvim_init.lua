vim.cmd('source ~/.vimrc')

-- Completion (nvim-cmp)
-- Setup nvim-cmp
local cmp = require('cmp')

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },

  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
  })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- LSP
-- Styling
local border = {
  { "╭", "FloatBorder" },
  { "─", "FloatBorder" },
  { "╮", "FloatBorder" },
  { "│", "FloatBorder" },
  { "╯", "FloatBorder" },
  { "─", "FloatBorder" },
  { "╰", "FloatBorder" },
  { "│", "FloatBorder" },
}

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- See https://github.com/neovim/nvim-lspconfig
local lspconfig = require('lspconfig')

local fmtFilter = function(client)
  return client.name ~= "tsserver"
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr) -- (client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings
  local opts = { noremap = true, silent = true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  --buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', '<leader>lh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  --buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  --buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  --buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  --buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  --buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  --buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('v', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  --buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>le', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '<leader>lN', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', '<leader>ln', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<leader>ls', '<cmd>lua vim.diagnostic.show()<CR>', opts)
  buf_set_keymap('n', '<leader>ll', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  MyFormat = function()
    vim.lsp.buf.format {
      async = true,
      filter = fmtFilter,
    }
  end
  buf_set_keymap('n', '<leader>lf', '<cmd>lua MyFormat()<CR>', opts)
  --buf_set_keymap('n', '<leader>lf', '<cmd>lua vim.lsp.buf.format({async = true})<CR>', opts)

  buf_set_keymap('n', '<leader>l1', '<cmd>LspRestart<CR>', opts)
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local register_autofmt = function(bufnr)
  --vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.format({
        bufnr = bufnr,
        filter = fmtFilter,
      })
    end,
  })
end

local on_attach_with_autofmt = function(_, bufnr)
  on_attach(_, bufnr)
  register_autofmt(bufnr)
end

-- Setup Mason
-- See https://github.com/williamboman/mason.nvim
-- and https://github.com/williamboman/mason-lspconfig.nvim
require("mason").setup()
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup()

-- integrate with nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- see https://github.com/williamboman/mason.nvim/discussions/92
mason_lspconfig.setup_handlers({
  function(server_name) -- Default handler (optional)
    lspconfig[server_name].setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end,
  ["clangd"] = function(_)
    lspconfig.clangd.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      --filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' }, -- default
      filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
    })
  end,
  ["gopls"] = function(_)
    lspconfig.gopls.setup({
      on_attach = on_attach_with_autofmt,
      capabilities = capabilities,
    })
  end,
  ["ltex"] = function(_)
    lspconfig.ltex.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      filetypes = { 'latex' },
    })
  end,
  ["lua_ls"] = function(_)
    lspconfig.lua_ls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
          },
          diagnostics = {
            globals = { 'vim' },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
        },
      },
    })
  end,
  ["pylsp"] = function(_)
    lspconfig.pylsp.setup({
      on_attach = on_attach_with_autofmt,
      capabilities = capabilities,
      settings = {
        pylsp = {
          plugins = {
            pycodestyle = {
              maxLineLength = 999, -- let other tools handle this
            }
          }
        }
      }
    })
  end,
})

-- replacing with pmizio/typescript-tools.nvim, but leaving this for now
-- require("typescript").setup({
  -- server = {
    -- -- pass options to lspconfig's setup method
    -- on_attach = function(client, bufnr)
      -- -- auto-import
      -- vim.api.nvim_create_autocmd("BufWritePre", {
        -- group = augroup,
        -- buffer = bufnr,
        -- callback = function()
          -- require("typescript").actions.addMissingImports({ sync = true })
          -- --require("typescript").actions.organizeImports({sync = true})
        -- end,
      -- })
      -- -- normal on_attach + autofmt
      -- on_attach_with_autofmt(client, bufnr)
      -- -- override go-to-definition (requires TS 4.7)
      -- local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
      -- local opts = { noremap = true, silent = true }
      -- -- somehow, despite trying so many things, I cannot suppress the error
      -- --  > go to source definition failed: requires typescript 4.7
      -- -- so instead of overriding `gd`, override `gD` and use it only when necessary.
      -- buf_set_keymap('n', 'gD', ':silent! TypescriptGoToSourceDefinition<CR>', opts)
    -- end,
    -- capabilities = capabilities,
  -- },
-- })

-- See https://github.com/pmizio/typescript-tools.nvim#%EF%B8%8F-configuration
local api = require("typescript-tools.api")
require("typescript-tools").setup {
  on_attach = function(client, bufnr)
    -- auto-import
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        -- times out all the time :(
        -- api.add_missing_imports(true)
        -- api.organize_imports(true)
      end,
    })
    -- normal on_attach + autofmt
    on_attach_with_autofmt(client, bufnr)
    -- key bindings
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap = true, silent = true }
    buf_set_keymap('n', 'gD', ':TSToolsGoToSourceDefinition<CR>', opts)
    buf_set_keymap('n', '<leader>lR', ':TSToolsRenameFile<CR>', opts)
    buf_set_keymap('n', '<leader>lF', ':TSToolsFixAll<CR>', opts)
    buf_set_keymap('n', '<leader>li', ':TSToolsAddMissingImports<CR>:TSToolsSortImports<CR>', opts)
  end,
  -- handlers = {
    -- ["textDocument/publishDiagnostics"] = api.filter_diagnostics(
      -- -- Ignore 'This may be converted to an async function' diagnostics.
      -- { 80006 }
    -- ),
  -- },
  settings = {
    tsserver_file_preferences = {
      importModuleSpecifierPreference = "relative",
      -- importModuleSpecifierPreference = "project-relative",
      -- importModuleSpecifierPreference = "absolute",
    },
    -- spawn additional tsserver instance to calculate diagnostics on it
    separate_diagnostic_server = true,
    -- "change"|"insert_leave" determine when the client asks the server about diagnostic
    publish_diagnostic_on = "insert_leave",
    -- array of strings("fix_all"|"add_missing_imports"|"remove_unused"|
    -- "remove_unused_imports"|"organize_imports") -- or string "all"
    -- to include all supported code actions
    -- specify commands exposed as code_actions
    expose_as_code_action = "all",
    -- JSXCloseTag
    -- WARNING: it is disabled by default (maybe you configuration or distro already uses nvim-auto-tag,
    -- that maybe have a conflict if enable this feature. )
    jsx_close_tag = {
      enable = false,
      filetypes = { "javascriptreact", "typescriptreact" },
    }
  },
}

-- Setup tool installer
-- see https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
require('mason-tool-installer').setup {
  -- a list of all tools you want to ensure are installed upon
  -- start; they should be the names Mason uses for each tool
  ensure_installed = {
    -- language servers
    'bash-language-server',
    'clangd',
    'dockerfile-language-server',
    'elm-language-server',
    'gopls',
    'grammarly-languageserver',
    'graphql-language-service-cli',
    'json-lsp',
    'ltex-ls',
    'lua-language-server',
    'marksman',
    'pyright',
    'python-lsp-server',
    'rust-analyzer',
    'sqlls',
    'taplo',
    -- 'typescript-language-server', -- trying to replace with pmizio/typescript-tools.nvim
    'terraform-ls',
    'vim-language-server',
    'yaml-language-server',

    -- linters
    'actionlint',
    'buf',
    'codespell',
    -- 'editorconfig-checker', -- seems to cause false alarms
    'eslint-lsp',
    'markdownlint',
    'shellcheck',
    'sqlfluff',
    'tflint',
    'yamllint',

    -- formatters
    'black',
    'gofumpt',
    'goimports',
    'isort',
    'jq',
    'prettierd',
    'shfmt',
  },

  auto_update = false,
  run_on_start = false,
  start_delay = 0,
}

-- None-ls/Null-ls setup
-- see https://github.com/nvimtools/none-ls.nvim
local none_ls = require("null-ls")
none_ls.setup({
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    -- format-on-save
    --if client.supports_method("textDocument/formatting") then
    --register_autofmt(bufnr)
    --end
  end,
  capabilities = capabilities,
  sources = {
    none_ls.builtins.code_actions.gitsigns,
    none_ls.builtins.code_actions.refactoring,
    -- require('typescript.extensions.null-ls.code-actions'),

    none_ls.builtins.completion.spell,
    none_ls.builtins.completion.tags,

    none_ls.builtins.diagnostics.actionlint,
    none_ls.builtins.diagnostics.buf,
    -- Codespell -- glitchy and consuming CPU lately!
    -- none_ls.builtins.diagnostics.codespell.with {
      -- args = { '-L requestor' },
    -- },
    -- null_ls.builtins.diagnostics.editorconfig_checker.with {
    -- command = 'editorconfig-checker'
    -- },
    none_ls.builtins.diagnostics.markdownlint.with {
      args = { '--disable', 'MD013' }, -- line-length
    },
    -- Semgrep -- works, but burns CPU
    --null_ls.builtins.diagnostics.semgrep.with({
    --args = function(_)
    --if vim.fn.isdirectory("dev-scripts/semgrep") then
    --return { "-q", "--json", "--config=dev-scripts/semgrep", "--config=auto", "$FILENAME" }
    --else
    --return { "-q", "--json", "--config=auto", "$FILENAME" }
    --end
    --end,
    --timeout = 30000, -- ms
    --}),
    none_ls.builtins.diagnostics.terraform_validate,
    none_ls.builtins.diagnostics.tfsec,
    none_ls.builtins.diagnostics.sqlfluff.with {
      extra_args = { "--dialect", "postgres" },
    },
    none_ls.builtins.diagnostics.yamllint,

    none_ls.builtins.formatting.black,
    none_ls.builtins.formatting.buf,
    -- null_ls.builtins.formatting.codespell,
    none_ls.builtins.formatting.goimports,
    none_ls.builtins.formatting.isort,
    none_ls.builtins.formatting.prettierd,
    none_ls.builtins.formatting.shfmt,
    none_ls.builtins.formatting.sqlfluff.with {
      extra_args = { "--dialect", "postgres" },
    },
    none_ls.builtins.formatting.terraform_fmt,
  },
})

-- Treesitter
require 'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  sync_install = false,
  auto_install = false,
  ignore_install = {},
  modules  = {}, -- not sure what this is, but linter wants it
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = {'markdown'},
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grs",
      node_decremental = "grN",
    },
  },
  indent = {
    enable = true
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
      },
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V',  -- linewise
        ['@class.outer'] = '<c-v>', -- blockwise
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = { query = "@class.outer", desc = "Next class start" },
        ["]o"] = "@loop.*",
        ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
        ["]b"] = { query = "@block.inner", desc = "Next block" },
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
        ["[o"] = "@loop.*",
        ["[s"] = { query = "@scope", query_group = "locals", desc = "Previous scope" },
        ["[z"] = { query = "@fold", query_group = "folds", desc = "Previous fold" },
        ["[b"] = { query = "@block.inner", desc = "Previous block" },
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
      goto_next = {
        ["]d"] = "@conditional.outer",
      },
      goto_previous = {
        ["[d"] = "@conditional.outer",
      }
    },
    lsp_interop = {
      enable = true,
      border = 'none',
      floating_preview_opts = {},
      peek_definition_code = {
        ["<leader>pf"] = "@function.outer",
        ["<leader>pF"] = "@class.outer",
      },
    },
  },
}

local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"

-- Repeat movement with ; and ,
-- ensure ; goes forward and , goes backward regardless of the last direction
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

-- vim way: ; goes to the direction you were moving.
-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
-- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)

-- Telescope
local telescope = require 'telescope'
local actions = require 'telescope.actions'
telescope.setup {
  defaults = {
    mappings = {
      i = {
        ["<C-f>"] = actions.send_selected_to_qflist + actions.open_qflist,
        ["<C-a>"] = actions.send_to_qflist + actions.open_qflist,
      }
    }
  },
  pickers = {
    --grep_string = {
    --  search = "",
    --  only_sort_text = true,
    --},
    find_files = {
      theme = "ivy",
      --search_file = "",
    },
    command_history = {
      theme = "ivy",
    },
  },
  extensions = {
    fzf_native = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
  }
}
telescope.load_extension('fzf')
vim.cmd("set foldmethod=expr")
vim.cmd("set foldexpr=nvim_treesitter#foldexpr()")

require("trouble").setup {
  focus = true,
  auto_preview = false,
}
require('leap').set_default_keymaps()
require('gitsigns').setup()
require('which-key').setup()
---@diagnostic disable-next-line: missing-fields
require('glow').setup {
  glow_path = vim.env.HOME .. '/.local/share/nvim/mason/bin/glow',
}
require('colorizer').setup()
require('illuminate').configure()
vim.opt.termguicolors = true
require('bufferline').setup {
  options = {
    mode = 'buffers',
    show_buffer_icons = false,
    diagnostics = 'nvim_lsp',
    separator_style = 'thick',
  },
  -- highlights = {
  -- buffer_visible = {
  -- -- fg = '#7A5454',
  -- bg = '#7A5454'
  -- },
  -- buffer_selected = {
  -- -- fg = '#7A5454',
  -- bg = '#7A5454'
  -- },
  -- }
}

-- Start 'Telescope find_files' when Vim is started without file arguments.
--vim.cmd([[
--autocmd StdinReadPre * let s:std_in=1
--autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | :Telescope find_files | endif
--]])
