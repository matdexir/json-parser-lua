local test = require("u-test")
local utils = require("test-utils")

local prefix_path = "../JSONTestSuite/test_parsing"

local files = utils:dirScan(prefix_path)

local target_files = utils:filterArray(files, function(x) return string.sub(x, 1, 2) == "y_" end) or {}

print(target_files, type(target_files), #target_files)

for idx, file in ipairs(target_files) do
	print(idx, file)
end
