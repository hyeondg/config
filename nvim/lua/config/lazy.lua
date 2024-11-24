local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		-- add LazyVim and import its plugins
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
		-- import/override with your plugins
		{ import = "plugins" },
	},
	defaults = {
		-- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
		-- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
		lazy = false,
		-- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
		-- have outdated releases, which may break your Neovim install.
		version = false, -- always use the latest git commit
		-- version = "*", -- try installing the latest stable version for plugins that support semver
	},
	checker = { enabled = false }, -- automatically check for plugin updates
})

require("catppuccin").setup()
vim.cmd("colorscheme catppuccin-macchiato")
-- vim.cmd("colorscheme nord")

require("jupytext").setup({
	style = "markdown",
	output_extension = "md",
	force_ft = "markdown",
})

require("mini.starter").setup()
require("mini.pairs").setup()
require("mini.extra").setup()
require("mini.completion").setup()
require("mini.indentscope").setup({
	draw = {
		animation = function()
			return 0
		end,
	},
	symbol = "│",
})

require("neo-tree").setup({
	event_handlers = {
		{
			event = "vim_buffer_enter",
			handler = function()
				if vim.bo.filetype == "neo-tree" then
					vim.cmd("setlocal number")
				end
			end,
		},
	},
	window = {
		position = "right",
	},
})
