local io = require "io"

local P = {}
utils = P

function P:checkOS() 
	return package.config.sub(1, 1) == "\\" and "win" or "unix"
end

function P:filterArray(tbl, func)
	local result = {}
	
	for i, v in ipairs(tbl) do 
		if func(v) then 
			table.insert(result, v)
		end
	end

	return result
end

function P:dirScan(directory)
	if P:checkOS() == "win" then 
		error("Sorry friend. Only unix like is supported.")
	end

	local fileTable = {}
	local pFile = io.popen('ls -a "'.. directory ..'"') 

	for line in pFile:lines() do 
		table.insert(fileTable, line)
	end

	pFile:close()

	return fileTable
end

return utils
