local object = require("classic")
local parser = object:extend()

local boxed_nil = {}
boxed_nil.value = nil

--- comment
--- @param json_str string
function parser:new(json_str)
	self.json_str = json_str
end

---@return any
---@return number
function parser:generic_parse(i)
	local c = self.json_str:sub(i, i)

	if c == "{" then
		return self.parse_object(self, i)
	elseif c == "[" then
		return self.parse_array(self, i)
	else
		return self.parse_value(self, i)
	end
end

---@return table
---@return number
function parser:parse_array(i)
	local array_content = {}
	local idx = 1

	local array_end_idx = self.json_str:find("]", i)
	if array_end_idx == nil then
		error("array is {" .. self.json_str:sub(i - 1, #self.json_str) .. "} not terminated")
	end

	while true do
		i = i + 1
		local c = self.json_str:sub(i, i)
		if c == "]" then
			return array_content, i
		elseif c == "," then
			-- do nothing, there is no continue statement in lua
		else
			local value, new_i = self:generic_parse(i)
			array_content[idx] = value
			idx = idx + 1
			i = new_i
		end

	end
end

---comment
---@param i number
---@return any
---@return number
function parser:parse_value(i)
	local c = self.json_str:sub(i, i)

	-- parse null
	if c == "n" then
		assert(self.json_str:sub(i, i + 3) == "null", "Expected Null")
		return boxed_nil, i + 3
	end

	-- parse true or false
	if c == "t" then
		assert(self.json_str:sub(i, i + 3) == "true", "Expected True")
		return true, i + 3
	elseif c == "f" then
		assert(self.json_str:sub(i, i + 4) == "false", "Expected True")
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
				c = self.json_str:sub(i, i)
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
				elseif c == "u" then -- beautiful unicode
					local unicode = self.json_str:sub(i - 1, i + 4)
					i = i + 4
					-- print("Unicode" .. unicode)
					str = str .. unicode
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

---@param i number
---@return table
---@return number
function parser:parse_object(i)
	local new_object = {}

	i = i + 1
	while true do
		if self.json_str:sub(i, i) == "}" then
			return new_object, i
		elseif self.json_str:sub(i, i) == "," then
			-- print("comma " .. self.json_str:sub(i, i), i)
			i = i + 1
		end

		-- parse key
		local key, new_i = self.parse_value(self, i)
		if type(key) ~= "string" then
			error("key: " .. self.json_str:sub(i, new_i) .. " is not a valid string")
		end
		new_i = new_i + 1

		i = new_i
		-- parse colon
		if self.json_str:sub(i, i) ~= ":" then
			error("character " .. self.json_str:sub(i, i)(" after key was not a colon(:)"))
		end
		-- print("should be colon: " .. i, self.json_str:sub(i, i))
		i = i + 1

		-- parse value
		local value
		value, new_i = self.generic_parse(self, i)
		-- print("should be value: " .. i, value, self.json_str:sub(i, new_i))

		new_object[key] = value
		i = new_i + 1
	end
end

---@param json string
---@return string
function parser:minify_json(json)
	-- Remove whitespace (spaces, tabs, and newlines) between tokens
	json = json:gsub("%s+", "") -- Remove all spaces, tabs, and newlines

	-- Optional: handle cases where commas or colons might have extra spaces around them
	json = json:gsub("%s*([,:])%s*", "%1")

	return json
end

return parser
