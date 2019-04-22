local tmpfile = require 'cgi.tmpfile'
local readuntil = require 'cgi.readuntil'

local tinsert, tconcat = table.insert, table.concat
local format, gmatch, strfind, strlower, strlen, strmatch = string.format, string.gmatch, string.find, string.lower, string.len, string.match


local M = {}

-- Extract the boundary string from CONTENT_TYPE metavariable
local function getBoundary(req)
    local boundary = strmatch(req.contentType, "boundary=(.*)$")
	if boundary then
		return "--"..boundary
	else
		serverError("Error processing multipart/form-data.\nMissing boundary")
	end
end

local function discardInput(req, inputsize)
    readuntil(req, '\0', function() end)
end


-- Create a table containing the headers of a multipart/form-data field
local function breakHeaders(hdrdata)
	local headers = {}
	for name, value in gmatch(hdrdata, '([^%c%s:]+):%s+([^\n]+)') do
		name = strlower(name)
		headers[name] = value
	end
	return headers
end

--
-- Read the headers of the next multipart/form-data field 
--
--  This function returns a table containing the headers values. Each header
--  value is indexed by the corresponding header "type". 
--  If end of input is reached (no more fields to process) it returns nil.
--
local function readFieldHeaders(req)
    local EOH = "\r\n\r\n" -- <CR><LF><CR><LF>
    local hdrparts = {}
	local out = function (str) tinsert(hdrparts, str) end
	if readuntil.readUntil(req, EOH, out) then
		-- parse headers
		return breakHeaders(tconcat(hdrparts))
	else
		-- no header found
		return nil
	end
end

-- Extract a field name (and possible filename) from its disposition header
local function getFieldNames(headers)
	local disposition_hdr = headers["content-disposition"]
	if not disposition_hdr then
		serverError("Error processing multipart/form-data."..
			"\nMissing content-disposition header")
	end

	local attrs = {}
	for attr, value in gmatch(disposition_hdr, ';%s*([^%s=]+)="(.-)"') do
		attrs[attr] = value
	end
	return attrs.name, attrs.filename
end


-- Read the contents of a 'regular' field to a string
local function readFieldContents(req)
	local parts = {}
	local boundaryline = "\r\n" .. req.post.boundary
	local out = function (str) tinsert(parts, str) end
	if readuntil(req, boundaryline, out) then
		return tconcat(parts)
	else
		serverError("Error processing multipart/form-data.\nUnexpected end of input\n")
	end
end

-- Read the contents of a 'file' field to a temporary file (file upload)
local function fileUpload(req, filename)
	-- create a temporary file for uploading the file field
	local file, tmpfilename, err = tmpfile.tmpfile()
	if file == nil then
		discardInput(req, req.post.bytesleft)
		serverError("Cannot create a temporary file, " .. tostring(err))
    end

    local bytesread = 0
	local boundaryline = "\r\n" .. req.post.boundary
	local out = function(str)
		local sl = strlen (str)
		if bytesread + sl > req.post.maxFileSize then
            discardInput(req, bytesleft)
			serverError(format ("Maximum file size (%d Kbytes) exceeded while uploading `%s'", req.post.maxFileSize / 1024, filename))
		end
		file:write(str)
		bytesread = bytesread + sl
	end
    
    if readuntil.readUntil(req, boundaryline, out) then
		file:seek ("set", 0)
		return file, bytesread, tmpfilename
	else
		serverError(format ("Error processing multipart/form-data.\nUnexpected end of input while uploading %s", filename))
	end
end

-- Compose a file field 'value' 
local function fileValue(filehandle, filename, filesize, headers, tmpfilename)
    -- the temporary file handle
    local value = {
        file = filehandle,
        filename = filename,
        filesize = filesize,
        tmpfilename = tmpfilename
    }

    -- copy additional header values
    for hdr, hdrval in pairs(headers) do
        if hdr ~= "content-disposition" then
            value[hdr] = hdrval
        end
    end
    return value
end

----------------------------------------------------------------------------
-- Insert a (name=value) pair into table [[args]]
-- @param args Table to receive the result.
-- @param name Key for the table.
-- @param value Value for the key.
-- Multi-valued names will be represented as tables with numerical indexes
--	(in the order they came).
----------------------------------------------------------------------------
local function insertField(args, name, value)
	if not args[name] then
		args[name] = value
	else
		local t = type (args[name])
		if t == "string" then
			args[name] = {
				args[name],
				value,
			}
		elseif t == "table" then
			tinsert (args[name], value)
		else
			serverError("CGILua fatal error (invalid args table)!")
		end
	end
end

-- 解析formdata, 把解析后的结果放到req.post.data中
function M.handleFormData(cgi, req)
    -- set the environment for processing the multipart/form-data
    req.post.bytesleft = req.contentLen
    req.post.boundary = getBoundary(req)
    req.post.current = ''
    req.data = {} -- 保存解析后的结果

    while true do
        -- read the next field header(s)
        local headers = readFieldHeaders(req)
        if not headers then break end	-- end of input

        -- get the name attributes for the form field (name and filename)
        local name, filename = getFieldNames(headers)

        -- get the field contents
        local value
        if filename then
            local filehandle, filesize, tmpfilename = fileUpload(req, filename)
            value = fileValue(filehandle, filename, filesize, headers, tmpfilename)
        else
            value = readFieldContents(req)
        end

        -- insert the form field into table [[args]]
        insertField(req.data, name, value)
    end
end

return M
