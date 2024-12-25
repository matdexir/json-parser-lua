Object = require("classic")
Parser = Object:extend()

--- comment
--- @param json_str string
function Parser:new(json_str)
	self.json_str = json_str
end

---@return any
---@return number
function Parser:generic_parse()
	local c = self.json_str:sub(1, 1)

	if c == "{" then
		error("NOT IMPLEMENTED")
		self.parse_obj(self)
	elseif c == "[" then
		error("NOT IMPLEMENTED")
		self.parse_array(self)
	else
		return self.parse_value(self, 1)
	end
end

function Parser:parse_array(self) end

---comment
---@param i number
---@return any
---@return number
function Parser:parse_value(i)
	local c = self.json_str:sub(i, i)

	-- parse null
	if c == "n" then
		assert(self.json_str:sub(i, i + 4) == "null", "Expected Null")
		return nil, i + 4
	end

	-- parse true or false
	if c == "t" then
		assert(self.json_str:sub(i, i + 4) == "true", "Expected True")
		return true, i + 4
	elseif c == "f" then
		assert(self.json_str:sub(i, i + 5) == "false", "Expected True")
		return false, i + 5
	end

	-- parse number
	if c:match("[0-9%-]") then
		local num_str, new_i = self.json_str:match("([%-]?[0-9%.eE+%-]+)", i)
		return tonumber(num_str), new_i
	end

	-- parse string
	if c == '"' then
		local str = ""
		i = i + 1
		while true do
			c = self.json_str:sub(i, i)
			if c == '"' then
				break
			elseif c == "\\" then
				i = i + 1
				c = self.json_str(i, i)
				if c == '"' then
					str = str .. '"'
				elseif c == "\\" then
					str = str .. "\\"
				elseif c == "/" then
					str = str .. "/"
				elseif c == "b" then
					str = str .. "\b"
				elseif c == "f" then
					str = str .. "\f"
				elseif c == "n" then
					str = str .. "\n"
				elseif c == "r" then
					str = str .. "\r"
				elseif c == "t" then
					str = str .. "\t"
				else
					error("Invalid escape character: " .. c)
				end
			else
				str = str .. c
			end
			i = i + 1
		end
		return str, i + 1
	end
	error("Unexpected character: " .. c)
end

function Parser:parse_obj() end

local json_str = '"word"'

local parser = Parser(json_str)

local result = parser:generic_parse()
print(result, type(result))
