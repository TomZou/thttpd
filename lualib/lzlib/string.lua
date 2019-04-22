local type = type
local sformat = string.format
local slen = string.len
local sbyte = string.byte
local schar = string.char
local sfind = string.find
local sgmatch = string.gmatch
local sgsub = string.gsub
local ssub = string.sub
local tinsert = table.insert
local random = math.random

local M = {}

function M.split(str, delimiter)
	if str == nil or str =='' or delimiter == nil then
		return nil
	end

	local result = {}
	for match in sgmatch(str..delimiter, "(.-)"..delimiter) do
		tinsert(result, match)
	end
	return result
end

function M.replace(str, pat, repl)
    if sfind(repl, "%", 1, true) then
        local newRepl = ""
        -- '%'使用‘%%’替换
        local len = slen(repl)
        for i = 1, len do
            local byte = ssub(repl, i, i)
            if byte == '%' then
                newRepl = newRepl .. "%%"
            else
                newRepl = newRepl .. byte
            end
        end
        repl = newRepl
    end
    return sgsub(str, pat, repl)
end

-- 把str的内容转换为十六进制形式的字符串，一行包含16个
-- 'hello' -> ''
function M.str2hex(str)
	if type(str) ~= "string" then return nil end

	local len = slen(str)
	local ret = ""
	local b0 = sbyte('0')
	local bA = sbyte('a') - 10
	local count = 0
	for i = 1, len do
		local byte = sbyte(str, i)
		local bH = byte >> 4
		if bH < 10 then
			ret = ret .. schar(b0 + bH)
		else
			ret = ret .. schar(bA + bH)
		end

		bH = byte & 0xF
		if bH < 10 then
			ret = ret .. schar(b0 + bH) .. " "
		else
			ret = ret .. schar(bA + bH) .. " "
		end

		count = count + 1
		if count == 16 then
			ret = ret .. "\n"
			count = 0
		end
	end

	return ret
end

-- Taken from http://lua-users.org/wiki/StringRecipes then modified for RFC3986
function M.urlEncode(str)
	if str then
		str = sgsub(str, "([^%w-._~])", function(c)
			if c == " " then return "+" end
			return sformat ("%%%02X", sbyte(c))
		end)
	end
	return str
end

return M
