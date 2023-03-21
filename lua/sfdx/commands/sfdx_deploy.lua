local diagnostics = {}
local sfdx_executable = "sfdx"
local utils = require("sfdx.utils")
local config = require("sfdx.config")

local msg = {
	validate_start = "Validating source.",
	deploy_start = "Deploying source.",
	validate_finish = "Validated source.",
	deploy_finish = "Deployment finished.",
}

local function notify(message, isError)
	local severity
	if isError then
		severity = vim.log.levels.ERROR
	else
		severity = vim.log.levels.INFO
	end

	vim.notify(message, severity, { title = "SFDX" })
end

local function set_diagnostics()
	vim.diagnostic.set(config.namespace, utils.getCurrentBufferNumber(), diagnostics)
end

local function clear_diagnostics()
	vim.diagnostic.set(config.namespace, utils.getCurrentBufferNumber(), {})
end

local function parse_sfdx_output(output, validateOnly)
	if output == nil or output == "" then
		return
	end

	local json_result = vim.json.decode(output)
	if json_result == nil then
		return
	end

	if json_result.status == 1 and not validateOnly then
		notify("Error deploying metadata", true)
	end

	diagnostics = {}

	local details = json_result.result.details

	for _, error in ipairs(details.componentFailures) do
		local diagnostic = {}
		diagnostic.severity = vim.diagnostic.severity.ERROR
		diagnostic.message = error.problemType .. ": " .. error.problem
		diagnostic.source = "sfdx"
		diagnostic.lnum = tonumber(error.lineNumber) - 1
		diagnostic.col = tonumber(error.columnNumber) - 1

		table.insert(diagnostics, diagnostic)
	end
	set_diagnostics()
end

return function(validateOnly)
	local buffer_name = utils.getCurrentBufferName()

	if buffer_name == nil or buffer_name == "" then
		notify("Cannot run command without buffer.", true)
		return
	end

	if not utils.hasFile("sfdx-project.json") then
		notify("Not an SFDX project.", true)
		return
	end

	local command = sfdx_executable .. " force source deploy -p " .. buffer_name .. " --json"

	if validateOnly == nil then
		validateOnly = false
	end

	local message_start = msg.deploy_start
	local message_end = msg.deploy_finish

	if validateOnly then
		command = command .. " -c"
		message_start = msg.validate_start
		message_end = msg.validate_finish
	end

	notify(message_start, false)
	clear_diagnostics()

	local jobOpts = {
		on_stdout = function(_, data, _)
			local output = table.concat(data)
			parse_sfdx_output(output, validateOnly)
		end,
		on_stderr = function(_, data, _)
			print(vim.inspect(data))
		end,
		on_exit = function(_, _, _)
			notify(message_end, false)
		end,
	}
	vim.fn.jobstart(command, jobOpts)
end
