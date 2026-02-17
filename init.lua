-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if vim.g.neovide then
	vim.o.guifont = "BerkeleyMono Nerd Font:h13" -- text below applies for VimScript
	vim.g.neovide_disable_all_animations = true
	vim.g.neovide_cursor_trail_size = 0
	vim.g.neovide_cursor_vfx_mode = ""
	vim.g.neovide_cursor_animation_length = 0.0
	vim.g.neovide_position_animation_length = 0.0
	vim.g.neovide_scroll_animation_length = 0.0
	vim.g.neovide_scroll_animation_far_lines = 0
	vim.g.neovide_no_idle = true
end
