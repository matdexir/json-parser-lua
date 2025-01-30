local test = require("u-test")
local utils = require("test-utils")
local io = require("io")
local parser = require("parser")

local prefix_path = "./JSONTestSuite/test_parsing/"

local files = utils:dirScan(prefix_path)

local target_files = utils:filterArray(files, function(x) return string.sub(x, 1, 2) == "y_" end) or {}


for idx, file in ipairs(target_files) do
	test[file] = function()
		local test_file = io.open(prefix_path..file)
		local minified_test_input = parser:minify_json(test_file:read("*all"))
		local json_parser = parser:new(nil, minified_test_input)
		local parsed = json_parser:generic_parse(1)
		test.is_not_nil(parsed)
		test_file:close()
	end
end


test.summary()

