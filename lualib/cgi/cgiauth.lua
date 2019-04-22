-- CGI模式下的用户skey
local cookies = require 'cgi.cookies'
local md5 = require 'lzlib.md5'

local tinsert = table.insert
local ssub = string.sub
local mrandom = math.random

local M = {}

local function buildSign(sk, sl)
    return md5.sumhexa('wwws.' .. sk .. '#!@' .. sl .. '81c8c860a9192bdcaa819172c28b2d7b')  -- sign
end

-- 生成cookies
function M.build(level)
    local sk = 's' .. ssub('' .. mrandom() .. '000000000000000000000000', 3, 18)  -- skey
    local sl = tostring(level or 0)  -- level
    local ss = buildSign(sk, sl)  -- sign

    local ret = {}
    tinsert(ret, cookies.build('sk', sk))
    tinsert(ret, cookies.build('sl', sl))
    tinsert(ret, cookies.build('ss', ss))
    return ret
end

-- 验证ss
function M.auth(req)
    local sk = req.cookies.sk
    local sl = req.cookies.sl
    local ss = req.cookies.ss
    if sk == nil or sk == '' or sl == nil or sl == '' or ss == nil or ss == '' then
        return false
    end
    return ss == buildSign(sk, sl)
end

return M
