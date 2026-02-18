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

-- Localize functions for maximum LuaJIT performance
local gmatch = string.gmatch
local match = string.match
local rep = string.rep
local concat = table.concat

--- Core formatting logic optimized for Neovim line arrays
local function format_markdown_table_nvim(lines)
	local rows = {}
	local col_widths = {}
	local num_rows = 0
	local num_cols = 0

	-- Pass 1: Parse arrays directly (no string splitting needed)
	for i = 1, #lines do
		local line = lines[i]

		-- Skip the separator row
		if not match(line, "^%s*|[%-%s%|:]+|%s*$") then
			local row = {}
			local col_idx = 1

			for cell in gmatch(line, "|([^|]+)") do
				local clean_cell = match(cell, "^%s*(.-)%s*$") or ""
				row[col_idx] = clean_cell

				local cell_len = #clean_cell
				if cell_len > (col_widths[col_idx] or 0) then
					col_widths[col_idx] = cell_len
				end
				col_idx = col_idx + 1
			end

			if col_idx > 1 then
				num_rows = num_rows + 1
				rows[num_rows] = row
				if col_idx - 1 > num_cols then
					num_cols = col_idx - 1
				end
			end
		end
	end

	-- Fallback if no table data was found
	if num_rows == 0 then
		return lines
	end

	-- Pass 2: Pre-calculate the separator line
	local sep_parts = {}
	for i = 1, num_cols do
		sep_parts[i] = rep("-", (col_widths[i] or 0) + 2)
	end
	local separator_line = "|" .. concat(sep_parts, "|") .. "|"

	-- Pass 3: Build the final array for Neovim
	local out = {}
	local out_idx = 1

	for r = 1, num_rows do
		local row = rows[r]
		local row_parts = {}

		for c = 1, num_cols do
			local cell = row[c] or ""
			local pad_len = (col_widths[c] or 0) - #cell
			row_parts[c] = " " .. cell .. rep(" ", pad_len) .. " "
		end

		out[out_idx] = "|" .. concat(row_parts, "|") .. "|"
		out_idx = out_idx + 1

		-- Insert separator after header
		if r == 1 then
			out[out_idx] = separator_line
			out_idx = out_idx + 1
		end
	end

	return out
end

-- Create a Neovim user command to format the selected range
vim.api.nvim_create_user_command("FormatTable", function(opts)
	-- Neovim API lines are 0-indexed, end-exclusive
	local start_line = opts.line1 - 1
	local end_line = opts.line2

	-- Get lines from the current buffer
	local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)

	-- Format them
	local formatted_lines = format_markdown_table_nvim(lines)

	-- Write back to the buffer
	vim.api.nvim_buf_set_lines(0, start_line, end_line, false, formatted_lines)
end, { range = true, desc = "Format Markdown Table" })

-- Optional: Bind it to a keyboard shortcut (e.g., <leader>tt)
vim.keymap.set("v", "<leader>tt", ":FormatTable<CR>", { desc = "Format selected table" })
