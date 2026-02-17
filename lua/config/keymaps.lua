-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function toggle_markdown_smart()
	local line = vim.api.nvim_get_current_line()
	local is_empty = line:match("^%s*$") ~= nil
	local current_mode = vim.api.nvim_get_mode().mode

	-- Logic: Toggle or Add
	if line:match("%[% %]") then
		line = line:gsub("%[% %]", "[x]", 1)
	elseif line:match("%[x%]") then
		line = line:gsub("%[x%]", "[ ]", 1)
	else
		local indent = line:match("^%s*")
		local content = line:gsub("^%s*", ""):gsub("^[*-] ", "", 1)
		line = indent .. "* [ ] " .. content
	end

	vim.api.nvim_set_current_line(line)

	-- Logic: When to enter/stay in Insert Mode
	-- 1. If we started in Insert mode, we want to stay there.
	-- 2. If we started in Normal mode but the line was empty, we want to start typing.
	if current_mode:find("i") or is_empty then
		vim.cmd("startinsert!")
	end
end

-- Keymaps
vim.keymap.set("n", "<C-x>", toggle_markdown_smart, { desc = "Toggle Checkbox" })
vim.keymap.set("i", "<C-x>", toggle_markdown_smart, { desc = "Toggle Checkbox" })
