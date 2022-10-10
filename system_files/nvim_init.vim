set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc
lua << EOF

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
    { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
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
      {"╭", "FloatBorder"},
      {"─", "FloatBorder"},
      {"╮", "FloatBorder"},
      {"│", "FloatBorder"},
      {"╯", "FloatBorder"},
      {"─", "FloatBorder"},
      {"╰", "FloatBorder"},
      {"│", "FloatBorder"},
}

-- See https://github.com/neovim/nvim-lspconfig
local lspconfig = require('lspconfig')
local configs = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Styling
  vim.lsp.handlers["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = border})
  vim.lsp.handlers["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = border})

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
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
  buf_set_keymap('n', '<leader>lf', '<cmd>lua vim.lsp.buf.format({async = true})<CR>', opts)

  buf_set_keymap('n', '<leader>l1', '<cmd>LspRestart<CR>', opts)
end

-- Show source in diagnostics
-- See https://github.com/neovim/nvim-lspconfig/wiki/UI-customization
--vim.lsp.handlers["textDocument/publishDiagnostics"] =
--  function(_, _, params, client_id, _)
--    local config = { -- your config
--      underline = true,
--      virtual_text = {
--        prefix = "■ ",
--        spacing = 4,
--      },
--      signs = true,
--      update_in_insert = false,
--    }
--    local uri = params.uri
--    local bufnr = vim.uri_to_bufnr(uri)
--
--    if not bufnr then
--      return
--    end
--
--    local diagnostics = params.diagnostics
--
--    for i, v in ipairs(diagnostics) do
--      diagnostics[i].message = string.format("%s: %s", v.source, v.message)
--    end
--
--    vim.lsp.diagnostic.save(diagnostics, bufnr, client_id)
--
--    if not vim.api.nvim_buf_is_loaded(bufnr) then
--      return
--    end
--
--    vim.lsp.diagnostic.display(diagnostics, bufnr, client_id, config)
--  end

-- Setup Mason
-- See https://github.com/williamboman/mason.nvim
-- and https://github.com/williamboman/mason-lspconfig.nvim
require("mason").setup()
mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup()

-- integrate with nvim-cmp
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- see https://github.com/williamboman/mason.nvim/discussions/92
mason_lspconfig.setup_handlers({
  function(server_name) -- Default handler (optional)
    lspconfig[server_name].setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end
})

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
    'golangci-lint-langserver',
    'gopls',
    'grammarly-languageserver',
    'json-lsp',
    'ltex-ls',
    'lua-language-server',
    'marksman',
    'pyright',
    'rust-analyzer',
    'sqls',
    'taplo',
    'terraform-ls',
    'vim-language-server',
    'yaml-language-server',

    -- debug adapters
    'delve', -- go

    -- linters
    'actionlint',
    'buf',
    'cspell',
    'codespell',
    'markdownlint',
    'shellcheck',
    'tflint',
    'yamllint',

    -- formatters
    'gofumpt',
    'goimports',
    'jq',
    'shfmt',
  },

  auto_update = false,
  run_on_start = false,
  start_delay = 0,
}

-- Null-ls setup
-- see https://github.com/jose-elias-alvarez/null-ls.nvim
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls = require("null-ls")
null_ls.setup({
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
  sources = {
    null_ls.builtins.diagnostics.cspell.with({
      diagnostic_config = {
        underline = true,
        virtual_text = false,
        signs = false,
        update_in_insert = false,
        severity_sort = true,
      },
      diagnostics_postprocess = function(diagnostic)
        diagnostic.severity = vim.diagnostic.severity.INFO
      end,
      filetypes = {'markdown', 'latex', 'text'},
    }),
    null_ls.builtins.code_actions.gitsigns,
    null_ls.builtins.code_actions.shellcheck,

    null_ls.builtins.completion.spell,
    null_ls.builtins.completion.tags,

    null_ls.builtins.diagnostics.actionlint,
    null_ls.builtins.diagnostics.buf,
    null_ls.builtins.diagnostics.codespell,
    null_ls.builtins.diagnostics.markdownlint,
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.yamllint,

    null_ls.builtins.formatting.buf,
    null_ls.builtins.formatting.codespell,
    null_ls.builtins.formatting.gofumpt,
    null_ls.builtins.formatting.goimports,
    null_ls.builtins.formatting.jq,
    null_ls.builtins.formatting.shfmt,
  },
})

-- Treesitter
-- Add proto parser
local parser_config = require 'nvim-treesitter.parsers'.get_parser_configs()
parser_config.proto = {
  install_info = {
    url = '~/git/linux-config/submodules/tree-sitter-proto',
    files = {'src/parser.c'}
  },
  filetype = 'proto', -- if filetype does not agrees with parser name
  --used_by = {'proto'} -- additional filetypes that use this parser
}
-- Configure Treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
    -- one of "all", or a list of languages
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true
  },
}

-- Telescope
local telescope = require 'telescope'
local actions = require 'telescope.actions'
telescope.load_extension('fzy_native')
telescope.setup{
  defaults = {
    mappings = {
      i = {
        ["<C-f>"] = actions.send_selected_to_qflist + actions.open_qflist,
        ["<C-F>"] = actions.send_to_qflist + actions.open_qflist,
      }
    }
  },
  pickers = {
    find_files = {
      theme = "ivy",
    },
    command_history = {
      theme = "ivy",
    },
  },
}

require("trouble").setup {
  icons = false,
}
require('leap').set_default_keymaps()
require('gitsigns').setup()
require("which-key").setup()

EOF

set completeopt=menu,menuone,noselect
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
