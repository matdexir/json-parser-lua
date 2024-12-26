Object = require("classic")
Parser = Object:extend()

local BoxedNil = {}
BoxedNil.value = nil

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
		return self.parse_array(self, 1)
	else
		return self.parse_value(self, 1)
	end
end

---@return table
---@return number
function Parser:parse_array(i)
	local array_content = {}
	local idx = 1
	i = i + 1

	while true do
		local value, new_i = self:parse_value(i)
		array_content[idx] = value
		idx = idx + 1

		i = new_i + 1
		local c = self.json_str:sub(i, i)
		print(c, i)
		if c == "]" then
			return array_content, i + 1
		elseif c == "," then
			i = i + 1
		end
	end
end

---comment
---@param i number
---@return any
---@return number
function Parser:parse_value(i)
	local c = self.json_str:sub(i, i)

	-- parse null
	if c == "n" then
		print(self.json_str:sub(i, i + 3))
		assert(self.json_str:sub(i, i + 3) == "null", "Expected Null")
		return BoxedNil, i + 3
	end

	-- parse true or false
	if c == "t" then
		assert(self.json_str:sub(i, i + 4) == "true", "Expected True")
		return true, i + 3
	elseif c == "f" then
		assert(self.json_str:sub(i, i + 5) == "false", "Expected True")
		return false, i + 4
	end

	-- parse number
	if c:match("[0-9%-]") then
		local num_str = self.json_str:match("([%-]?[0-9%.eE+%-]+)", i)
		return tonumber(num_str), i + #num_str - 1
	end

	-- parse string
	if c == '"' then
		local str = ""
		i = i + 1
		local str_end_idx = self.json_str:find('"', i)
		if str_end_idx == nil then
			error("string {" .. self.json_str:sub(i - 1, #self.json_str) .. "} is not terminated")
		end
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
		return str, i
	end
	error("Unexpected character: " .. c)
end

function Parser:parse_obj() end

---@param json string
---@return string
local minify_json = function(json)
	-- Remove whitespace (spaces, tabs, and newlines) between tokens
	json = json:gsub("%s+", "") -- Remove all spaces, tabs, and newlines

	-- Optional: handle cases where commas or colons might have extra spaces around them
	json = json:gsub("%s*([,:])%s*", "%1")

	return json
end

local json_str = '"nil'

local parser = Parser(minify_json(json_str))
print(parser.json_str)

local result = parser:generic_parse()
if type(result) == "table" then
	for index, value in pairs(result) do
		print(index, value, type(value))
	end
else
	print(result, type(result))
end
