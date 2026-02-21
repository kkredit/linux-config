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
  buf_set_keymap('n', '<leader>le',
    '<cmd>lua vim.diagnostic.jump({severity={min=vim.diagnostic.severity.ERROR},count=1})<CR>', opts)
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

-- integrate with nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- vim LSP setup
vim.lsp.config('*', {
  on_attach = on_attach,
  capabilities = capabilities,
})
vim.lsp.config('clangd', {
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' }, -- default list also includes 'proto'
})
vim.lsp.config('gopls', {
  on_attach = on_attach_with_autofmt,
})
vim.lsp.config('ltex', {
  filetypes = { 'latex' },
})
vim.lsp.config('lua_ls', {
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
vim.lsp.config('pylsp', {
  on_attach = on_attach_with_autofmt,
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
vim.lsp.config('harper_ls', {
  on_attach = on_attach_with_autofmt,
  settings = {
    -- see https://writewithharper.com/docs/integrations/neovim
    linters = {
      ToDoHyphen = false,
      ExpandMemoryShorthands = false
    },
    codeActions = {
      ForceStable = true
    },
    diagnosticSeverity = "hint",
  }
})

-- Setup Mason
-- See https://github.com/mason-org/mason.nvim
-- and https://github.com/mason-org/mason-lspconfig.nvim
require("mason").setup()
require("mason-lspconfig").setup()

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

-- Custom on_attach for typescript-tools applied via LspAttach autocmd
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "typescript-tools" then
      local bufnr = args.buf

      -- -- auto-import (Keeps timing out... :( )
      -- local api = require("typescript-tools.api")
      -- vim.api.nvim_create_autocmd("BufWritePre", {
      --   group = augroup,
      --   buffer = bufnr,
      --   callback = function()
      --     -- api.add_missing_imports(true)
      --     -- api.organize_imports(true)
      --   end,
      -- })

      -- leave formatting to eslint_d via null-ls
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
      -- this left for reference if necessary; conditional disabling of formatting
      -- -- hack to fix inconsistent monorepo formatting behavior:
      -- -- disable formatting ability when path includes '/packages/' or '/apps/'
      -- local bufname = vim.api.nvim_buf_get_name(bufnr)
      -- if bufname:match("/apps/") or bufname:match("/packages/") then
      --   client.server_capabilities.documentFormattingProvider = false
      --   client.server_capabilities.documentRangeFormattingProvider = false
      -- end

      on_attach_with_autofmt(client, bufnr)

      -- key bindings
      local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
      local opts = { noremap = true, silent = true }
      buf_set_keymap('n', 'gD', ':TSToolsGoToSourceDefinition<CR>', opts)
      buf_set_keymap('n', '<leader>lR', ':TSToolsRenameFile<CR>', opts)
      buf_set_keymap('n', '<leader>lF', ':TSToolsFixAll<CR>', opts)
      buf_set_keymap('n', '<leader>li', ':TSToolsAddMissingImports<CR>:TSToolsSortImports<CR>', opts)
    end
  end,
})

require("typescript-tools").setup {
  -- handlers = {
  -- ["textDocument/publishDiagnostics"] = api.filter_diagnostics(
  -- -- Ignore 'This may be converted to an async function' diagnostics.
  -- { 80006 }
  -- ),
  -- },
  settings = {
    tsserver_max_memory = 16384,
    tsserver_file_preferences = {
      importModuleSpecifierPreference = "relative",
      -- importModuleSpecifierPreference = "project-relative",
      -- importModuleSpecifierPreference = "absolute",
    },
    -- spawn additional tsserver instance to calculate diagnostics on it
    separate_diagnostic_server = false,
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
    'graphql-language-service-cli',
    'json-lsp',
    'ltex-ls',
    'lua-language-server',
    'marksman',
    'prisma-language-server',
    'pyright',
    'python-lsp-server',
    'rust-analyzer',
    'sqlls',
    'taplo',
    -- 'typescript-language-server', -- trying to replace with pmizio/typescript-tools.nvim
    'terraform-ls',
    'tree-sitter-cli',
    'vim-language-server',
    'yaml-language-server',

    -- linters
    'actionlint',
    'buf',
    -- 'eslint-lsp', -- very slow
    'eslint_d',
    'harper-ls',
    'markdownlint',
    'mdformat',
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
    -- 'prettierd',
    'shfmt',
  },

  auto_update = false,
  run_on_start = false,
  start_delay = 0,
}

-- Install mdformat-gfm plugin after mdformat is installed
vim.api.nvim_create_autocmd("User", {
  pattern = "MasonToolsUpdateCompleted",
  callback = function()
    local mdformat_pip = vim.fn.stdpath("data") .. "/mason/packages/mdformat/venv/bin/pip"
    if vim.fn.filereadable(mdformat_pip) == 1 then
      vim.fn.jobstart({ mdformat_pip, "install", "mdformat-gfm" }, { detach = true })
    end
  end,
})

-- None-ls/Null-ls setup
-- see https://github.com/nvimtools/none-ls.nvim
local none_ls = require("null-ls")
local util = require("lspconfig.util")

-- for eslint_d, pick markers that exist in each package
local pkg_root = util.root_pattern(
  "eslint.config.js",
  "eslint.config.mjs",
  ".eslintrc",
  ".eslintrc.cjs",
  ".eslintrc.js",
  "package.json",
  "tsconfig.json"
)

local function eslint_cwd(params)
  -- params.bufname is the file path
  return pkg_root(params.bufname)
end

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
    require('none-ls-external-sources.code_actions.eslint_d').with({
      -- require('none-ls-external-sources.code_actions.eslint').with({
      cwd = eslint_cwd,
    }),

    none_ls.builtins.completion.spell,
    none_ls.builtins.completion.tags,

    none_ls.builtins.diagnostics.actionlint,
    none_ls.builtins.diagnostics.buf,
    require('none-ls-external-sources.diagnostics.eslint_d').with({
      -- require('none-ls-external-sources.diagnostics.eslint').with({
      cwd = eslint_cwd,
    }),
    none_ls.builtins.diagnostics.markdownlint.with {
      args = { '--disable', 'MD013' }, -- line-length
    },
    -- Semgrep -- works, but burns CPU
    --none_ls.builtins.diagnostics.semgrep.with({
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
    require('none-ls-external-sources.formatting.eslint_d').with({
      -- require('none-ls-external-sources.formatting.eslint').with({
      cwd = eslint_cwd,
    }),
    none_ls.builtins.formatting.goimports,
    none_ls.builtins.formatting.isort,
    -- none_ls.builtins.formatting.prettierd.with {
    --   runtime_condition = function(params)
    --     -- disable if '/packages/' or '/apps/' is in the path
    --     return not (params.bufname:match("/packages/") or params.bufname:match("/apps/"))
    --   end,
    -- },
    none_ls.builtins.formatting.mdformat.with {
      extra_args = function()
        local args = { "--number" }
        if vim.fn.getcwd():match("kodex") then
          table.insert(args, "--wrap")
          table.insert(args, "keep")
        else
          table.insert(args, "--wrap")
          table.insert(args, "80")
        end
        return args
      end,
    },
    none_ls.builtins.formatting.shfmt,
    none_ls.builtins.formatting.sqlfluff.with {
      extra_args = { "--dialect", "postgres" },
    },
    none_ls.builtins.formatting.terraform_fmt,
  },
})

-- Treesitter textobjects
require("nvim-treesitter-textobjects").setup {
  select = {
    lookahead = true,
    selection_modes = {
      ['@parameter.outer'] = 'v', -- charwise
      ['@function.outer'] = 'V',  -- linewise
      ['@class.outer'] = '<c-v>', -- blockwise
    },
    include_surrounding_whitespace = false,
  },
  move = {
    set_jumps = true,
  },
}

-- Treesitter textobjects keymaps
local select = require("nvim-treesitter-textobjects.select")
vim.keymap.set({ "x", "o" }, "af", function()
  select.select_textobject("@function.outer", "textobjects")
end, { desc = "Select outer function" })
vim.keymap.set({ "x", "o" }, "if", function()
  select.select_textobject("@function.inner", "textobjects")
end, { desc = "Select inner function" })
vim.keymap.set({ "x", "o" }, "ac", function()
  select.select_textobject("@class.outer", "textobjects")
end, { desc = "Select outer class" })
vim.keymap.set({ "x", "o" }, "ic", function()
  select.select_textobject("@class.inner", "textobjects")
end, { desc = "Select inner class" })
vim.keymap.set({ "x", "o" }, "as", function()
  select.select_textobject("@local.scope", "locals")
end, { desc = "Select language scope" })

-- Treesitter move keymaps
local move = require("nvim-treesitter-textobjects.move")
vim.keymap.set({ "n", "x", "o" }, "]m", function()
  move.goto_next_start("@function.outer", "textobjects")
end, { desc = "Next function start" })
vim.keymap.set({ "n", "x", "o" }, "]M", function()
  move.goto_next_end("@function.outer", "textobjects")
end, { desc = "Next function end" })
vim.keymap.set({ "n", "x", "o" }, "[m", function()
  move.goto_previous_start("@function.outer", "textobjects")
end, { desc = "Previous function start" })
vim.keymap.set({ "n", "x", "o" }, "[M", function()
  move.goto_previous_end("@function.outer", "textobjects")
end, { desc = "Previous function end" })
vim.keymap.set({ "n", "x", "o" }, "]]", function()
  move.goto_next_start("@class.outer", "textobjects")
end, { desc = "Next class start" })
vim.keymap.set({ "n", "x", "o" }, "][", function()
  move.goto_next_end("@class.outer", "textobjects")
end, { desc = "Next class end" })
vim.keymap.set({ "n", "x", "o" }, "[[", function()
  move.goto_previous_start("@class.outer", "textobjects")
end, { desc = "Previous class start" })
vim.keymap.set({ "n", "x", "o" }, "[]", function()
  move.goto_previous_end("@class.outer", "textobjects")
end, { desc = "Previous class end" })

-- Repeatable movements with ; and ,
local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })

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

-- Leap
vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')
require('leap').opts.preview = function(ch0, ch1, ch2)
  return not (
    ch1:match('%s')
    or (ch0:match('%a') and ch1:match('%a') and ch2:match('%a'))
  )
end
require('leap').opts.equivalence_classes = {
  ' \t\r\n', '([{', ')]}', '\'"`'
}
-- require('leap.user').set_repeat_keys('<enter>', '<backspace>') -- breaks item selection in quickfix window

-- Other plugins
require("trouble").setup {
  focus = true,
  auto_preview = false,
}
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

require("CopilotChat").setup {
  model = "gpt-4.1",
}

-- Start 'Telescope find_files' when Vim is started without file arguments.
--vim.cmd([[
--autocmd StdinReadPre * let s:std_in=1
--autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | :Telescope find_files | endif
--]])
