local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = vim.keycode('<Space>')
vim.g.maplocalleader = "\\"
vim.g.bookmark_save_per_working_dir = 1
vim.g.bookmark_auto_save = 1
vim.g.bookmark_auto_close = 1
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.signcolumn = 'yes'
vim.opt.clipboard = 'unnamedplus'
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.winborder = 'rounded'
-- split below and right, how is this not the intuitive way
vim.opt.splitright = true
vim.opt.splitbelow = true

-- folding
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- use fugitive syntax for folding instead of treesitter
vim.api.nvim_create_autocmd('Filetype', {
	group = vim.api.nvim_create_augroup('syntaxfold', { clear = true }),
	pattern = {
		'fugitive',
		'git',
	},
	callback = function() vim.opt.foldmethod = 'syntax' end,
})

-- line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.api.nvim_create_autocmd({'InsertEnter', 'FocusLost'}, {
	pattern = { "*" },
	callback = function() 
		vim.opt.number = true
		vim.opt.relativenumber = false
	end,
})
vim.api.nvim_create_autocmd({'InsertLeave', 'FocusGained'}, {
	pattern = { "*" },
	callback = function() 
		vim.opt.relativenumber = true
	end,
})


-- Setup lazy.nvim
require("lazy").setup({
	defaults = {
		lazy = false,
	},
	spec = {
		{'tpope/vim-sensible'},
		{'tpope/vim-fugitive'},
		{'tpope/vim-surround'},
		{'tpope/vim-repeat'},
		{'tpope/vim-commentary'},
		{'tpope/vim-sleuth'},
		{'tpope/vim-vinegar'},
		{'airblade/vim-gitgutter'},
		{'MattesGroeger/vim-bookmarks'},
		{'hiphish/rainbow-delimiters.nvim'},
		{'AndrewRadev/linediff.vim'},
		{'farmergreg/vim-lastplace'},
		{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
		{
			"lukas-reineke/indent-blankline.nvim",
			main = "ibl",
			---@module "ibl"
			---@type ibl.config
			opts = {},
		},
		{
			'maxmx03/solarized.nvim',
			lazy = false,
			priority = 1000,
			---@type solarized.config
			opts = {},
			config = function(_, opts)
				vim.o.termguicolors = true
				vim.o.background = 'light'
				require('solarized').setup(opts)
				vim.cmd.colorscheme 'solarized'
			end,
		},
		{
			'neovim/nvim-lspconfig',
			dependencies = {
				'hrsh7th/cmp-nvim-lsp',
				'hrsh7th/cmp-buffer',
				'hrsh7th/cmp-path',
				'hrsh7th/cmp-cmdline',
				'hrsh7th/nvim-cmp',
			},
		},
		{
			"ibhagwan/fzf-lua",
			-- optional for icon support
			dependencies = { "nvim-tree/nvim-web-devicons" },
			-- or if using mini.icons/mini.nvim
			-- dependencies = { "echasnovski/mini.icons" },
			opts = {}
		},
		-- {
		-- 	"3rd/image.nvim",
		-- 	opts = {}
		-- },
	},
	rocks = {
		hererocks = true,  -- recommended if you do not have global installation of Lua 5.1.
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = {},
	-- automatically check for plugin updates
	checker = { enabled = true },
})

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local cmp = require'cmp'
cmp.setup({
	mapping = cmp.mapping.preset.insert({
		['<C-Space>'] = cmp.mapping.complete(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		['<C-j>'] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Insert,
			select = true,
		},

		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				if #cmp.get_entries() == 1 then
					cmp.confirm({ select = true })
				else
					cmp.select_next_item()
				end
			elseif has_words_before() then
				cmp.complete()
				if #cmp.get_entries() == 1 then
					cmp.confirm({ select = true })
				end
			else
				fallback()
			end
		end, { "i", "s" }),

		['<S-Tab>'] = function(fallback)
			if not cmp.select_prev_item() then
				if vim.bo.buftype ~= 'prompt' and has_words_before() then
					cmp.complete()
				else
					fallback()
				end
			end
		end,
	}),
	sources = cmp.config.sources({
		{name = 'nvim_lsp'},
	}, {
		{name = 'buffer'},
	})
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
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
	}),
	matching = { disallow_symbol_nonprefix_matching = false }
})

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}

    -- Display documentation of the symbol under the cursor
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)

    -- Jump to the definition
    vim.keymap.set('n', 'gd', function() vim.cmd([[split]]) vim.lsp.buf.definition() end, opts)

    -- Format current file
    vim.keymap.set({'n', 'x'}, 'gq', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)

    -- Displays a function's signature information
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('i', '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)

    -- Jump to declaration
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)

    -- Lists all the implementations for the symbol under the cursor
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)

    -- Jumps to the definition of the type symbol
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)

    -- Lists all the references
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)

    -- Renames all references to the symbol under the cursor
    vim.keymap.set('n', '<leader>ln', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)

    -- Selects a code action available at the current cursor position
    vim.keymap.set('n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    vim.keymap.set('n', '<leader>ll', '<cmd>lua vim.lsp.codelens.run()<cr>', opts)
    vim.keymap.set('n', '<leader>lL', '<cmd>lua vim.lsp.codelens.refresh()<cr>', opts)
  end,
})

-- Put diagnostics in virtual lines below the error
vim.diagnostic.config({
  virtual_lines = true
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require'lspconfig'.bashls.setup{}
require'lspconfig'.rust_analyzer.setup{}
require'lspconfig'.gopls.setup{}
require'lspconfig'.pylsp.setup{
	plugins = {
		ruff = {
			enabled = true,
		},
		jedi_completion = {
			enabled = true,
		},
		black = {
			enabled = true,
		},
		pylsp_mypy = {
			enabled = true,
		},
	}
}
require'lspconfig'.yamlls.setup{
	settings = {
		yaml = {
			schemas = {
				["kubernetes"] = "*.yaml",
				["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
				["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
				["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
				["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
				["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
				["http://json.schemastore.org/ansible-playbook"] = "*play*.{yml,yaml}",
				["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
				["https://json.schemastore.org/dependabot-v2"] = ".github/dependabot.{yml,yaml}",
				["https://json.schemastore.org/gitlab-ci"] = "*gitlab-ci*.{yml,yaml}",
				["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json"] = "*api*.{yml,yaml}",
				["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
				["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = "*flow*.{yml,yaml}",
			}
		}
	}
}

require'fzf-lua'.setup{
	previewers = {
		builtin = {
			extensions = {
				-- neovim terminal only supports `viu` block output
				["png"] = { "viu" },
				["jpg"] = { "viu" },
			},   
		},
	},
}
vim.keymap.set('n', '<leader>f', '<cmd>FzfLua files<cr>', opts)
vim.keymap.set('n', '<leader>r', '<cmd>FzfLua live_grep<cr>', opts)
vim.keymap.set('n', '<leader>b', '<cmd>FzfLua buffers<cr>', opts)

require'nvim-treesitter.configs'.setup {
	auto_install = true,
	indent = {
		enable = true
	},
	highlight = {
		enabled = true,
	},
}
