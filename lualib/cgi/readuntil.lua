-- Reads an input until a given character.

local strsub, strfind, strlen = string.sub, string.find, string.len
local tinsert = table.insert
local min = math.min
local ioread = io.read

local M = {}

-- 避免一次性全读出来造成占用内存过大
local function readInput(req)
	if req.post.bytesleft then
		if req.post.bytesleft <= 0 then return nil end
		local n = min(req.post.bytesleft, 8129)
		local bytes = ioread(n)
		req.post.bytesleft = req.post.bytesleft - #bytes
		return bytes
	end
end

-- reads an input until a given character
function M.readUntil(req, del, out)
	local dellen = strlen(del) 
	local i, e

	while true do
		i, e = strfind(req.post.current, del, 1, true)
		if i then break end

		local new = readInput(req)
		if not new then break end

		do	 -- handle borders
			local endcurrent = strsub(req.post.current, -dellen+1)
			local border = endcurrent .. strsub(new, 1, dellen-1)
			if strlen(req.post.current) < dellen or strlen(new) < dellen or
					strfind(border, del, 1, true) then
				-- move last part of `current' to new block
				req.post.current = strsub(req.post.current, 1, -dellen)
				new = endcurrent .. new
			end
		end
		out(req.post.current)
		req.post.current = new
	end
	out(strsub(req.post.current, 1, (i or 0) - 1))
	req.post.current = strsub(req.post.current, (e or strlen(req.post.current)) + 1)
	return (i ~= nil)
end

return M
