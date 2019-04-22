local os_tmpname = os.tmpname
local getenv = os.getenv
local io_open = io.open
local gsub = string.gsub
local tinsert = table.insert

local M = {}

-- 默认的临时文件名生成器
local function tmpname()
    local tempname = os_tmpname()
    -- Lua os.tmpname returns a full path in Unix, but not in Windows
    -- so we strip the eventual prefix
    tempname = gsub(tempname, "(/tmp/)", "")
    return tempname
end

M.tmpfiles = {}

-- Returns a temporary file in a directory using a name generator
-- @param dir Base directory for the temporary file
-- @param namefunction Name generator function
function M.tmpfile(dir, namefunction)
    dir = dir or getenv("TEMP") or getenv ("TMP") or "/tmp"
    namefunction = namefunction or tmpname
    local tempname = namefunction()
    local filename = dir.."/"..tempname
    local file, err = io_open(filename, "w+b")

    -- 临时文件存储下来，可用于结束后清理
    if file then
        tinsert(M.tmpfiles, {name = filename, file = file})
    end
    
    return file, filename, err
end

return M