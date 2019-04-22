local cgi = require 'cgi.cgi'
local cgiauth = require 'cgi.cgiauth'
local stringu = require 'lzlib.string'

local json = cjson
local print = print

local M = {}

function M.run()
    math.randomseed(os.time()) -- 初始化随机数种子，重要

    local req = cgi.init()

    -- 计算要加载的cgi
    if not req.queryString.m then
        serverError('queryString need method')
    end

    local items = stringu.split(req.queryString.m, '/')
    if items == nil or #items < 2 then
        serverError('invalid method: ' .. req.queryString.m)
    end

    local path = 'api.' .. table.concat(items, '.', 2)  -- path => 'api.user.login'
    if path == 'main' then
        serverError('invalid method: ' .. req.queryString.m)
    end

    -- 加载cgi
    local ok, instance = pcall(require, path)
    if not ok or not instance then
        return cgi.response(nil, 99905, 'invalid path')
    end

    -- 检测该method是否需要检查登录态和权限
    local level = 0
    if instance.auth ~= nil then
        level = instance.auth
    end
    if level >= 0 then
        -- 检查登录态
        if not cgiauth.auth(req) then
            return cgi.response(nil, 99905, 'auth ss fail')
        end

        -- 检查权限
        if tonumber(req.cookies.sl) < level then
            return cgi.response(nil, 99905, 'auth sl fail')
        end
    end

    -- 权限啥的验证通过了再处理post
    if req.method == 'POST' then
        cgi.handlePost(req)
    end

    -- 执行cgi的具体逻辑
    return instance.exec(cgi, req)
end

return M
