local urlcode = require 'lzlib.urlcode'

local format, gsub, strfind, strmatch = string.format, string.gsub, string.find, string.match
local date = os.date
local escape, unescape = urlcode.escape, urlcode.unescape

local M = {}

local function optional (what, name)
	if name ~= nil and name ~= "" then
		return format("; %s=%s", what, name)
	else
		return ""
	end
end

----------------------------------------------------------------------------
-- build a value to a cookie, with the given options.
-- @param name String with the name of the cookie.
-- @param value String with the value of the cookie.
-- @param options Table with the options (optional).

function M.build (name, value, options)
	if not name or not value then
		error("cookie needs a name and a value")
	end
	local cookie = name .. "=" .. escape(value)
	options = options or {}
	if options.expires then
		local t = date("!%A, %d-%b-%Y %H:%M:%S GMT", options.expires)
		cookie = cookie .. optional("expires", t)
	end
	cookie = cookie .. optional("path", options.path)
	cookie = cookie .. optional("domain", options.domain)
	cookie = cookie .. optional("secure", options.secure)
	return cookie
end

----------------------------------------------------------------------------
-- Deletes a cookie, by setting its value to "xxx".
-- @param name String with the name of the cookie.
-- @param options Table with the options (optional).

function M.buildDelete (name, options)
	options = options or {}
	options.expires = 1
	M.build(name, "deleted", options)
end

return M
