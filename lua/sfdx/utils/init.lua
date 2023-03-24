local M = {}
local api = vim.api

local root = vim.fn.getcwd() -- get the current working directory
local bufferNumber = -1

local function file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

function M.hasFile(filename)
	local filepath = root .. "/" .. filename -- construct the full file path
	return file_exists(filepath)
end

function M.getCurrentBufferNumber()
	return api.nvim_get_current_buf()
end

function M.getCurrentBufferName()
	return api.nvim_buf_get_name(0)
end

function M.notify(message, isError)
	local severity
	if isError then
		severity = vim.log.levels.ERROR
	else
		severity = vim.log.levels.INFO
	end

	vim.notify(message, severity, { title = "SFDX" })
end

function M.isSfdxProject()
	if not M.hasFile("sfdx-project.json") then
		M.notify("Not an SFDX project.", true)
		return false
	end
	return true
end

local function changeBufferToReadonly()
	api.nvim_buf_set_option(bufferNumber, "readonly", true)
	api.nvim_buf_set_option(bufferNumber, "modified", false)
end

local function changeBufferToWriteable()
	api.nvim_buf_set_option(bufferNumber, "readonly", false)
end

function M.logOutput(_, data)
	if data then
		changeBufferToWriteable()
		api.nvim_buf_set_lines(bufferNumber, -1, -1, true, data)
		changeBufferToReadonly()
		local bufferWindow = api.nvim_call_function("bufwinid", { bufferNumber })
		local bufferLineCount = api.nvim_buf_line_count(bufferNumber)
		api.nvim_win_set_cursor(bufferWindow, { bufferLineCount, 0 })
	end
end

function M.addLineToBuffer(line)
	if line then
		changeBufferToWriteable()
		api.nvim_buf_set_lines(bufferNumber, -1, -1, true, { line })
		changeBufferToReadonly()
	end
end

function M.openBuffer(title)
	if title == nil then
		title = "OUTPUT"
	end
	local bufferVisible = api.nvim_call_function("bufwinnr", { bufferNumber })
	if bufferNumber == -1 or not bufferVisible then
		api.nvim_command("botright vsplit " .. title)
		bufferNumber = api.nvim_get_current_buf()
		vim.opt_local.readonly = true
	end
	return bufferNumber
end

function M.clearBuffer()
	changeBufferToWriteable()
	api.nvim_buf_set_lines(bufferNumber, 0, -1, false, {})
	changeBufferToReadonly()
end

return M
