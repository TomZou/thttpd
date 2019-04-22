local json = cjson
local urlcode = require 'lzlib.urlcode'
local post = require 'cgi.post'
local dump = require 'lzlib.dump'

local ioread = io.read
local strfind = string.find
local getenv = os.getenv
local tinsert = table.insert
local osexit = os.exit

local M = {}

function M.init()
    return {
        uri = getenv('SCRIPT_NAME'),   -- eg: /api/index.lua
        method = getenv('REQUEST_METHOD'),  -- eg: GET POST
        queryString = urlcode.parse_query(getenv('QUERY_STRING') or ''),  -- eg: m=userLogin
        contentLen = tonumber(getenv('CONTENT_LENGTH') or '0'),
        contentType = getenv('CONTENT_TYPE') or '',
        cookies = urlcode.parse_cookies(getenv('HTTP_COOKIE') or ''),  -- TODO
    }
end

-- 解析post数据，保存在req.post中
function M.handlePost(req)
    req.post = {
        maxBodySize = 0x300000,   -- post body最大3M
        maxFileSize = 0x100000,   -- 上传文件最大1M
    }

    if req.contentLen > req.post.maxBodySize then
        serverError('post body too large')
    elseif req.contentLen == 0 then
        return
    end

    if strfind(req.contentType, 'application/json', 1, true) then
        local ok, data = pcall(json.decode, ioread(req.contentLen))
        if ok then
            req.data = data
        else
            serverError('invalid json body')
        end
    elseif strfind(req.contentType, 'x-www-form-urlencoded', 1, true) then
        req.data = urlcode.parse_query(ioread(req.contentLen))
    elseif strfind(req.contentType, 'multipart/form-data', 1, true) then
        post.handleFormData(M, req)
    else
        req.data = ioread(req.contentLen)
    end

    req.post = nil -- 释放掉
end

-- 按application/json格式输出，data是个对象
function M.response(data, ret, msg, headers)
    if headers then
        for k, v in pairs(headers) do
            print(k .. ': ' .. v)
        end
    end

    if true then
        -- 要求data字段是个table
        if type(data) == 'table' then
            data.logs = M.logs  -- 测试阶段，带上logs
        else
            data = {
                raw = data,   -- 把原来的data变成{}的一个字段
                logs = M.logs   -- 测试阶段，带上logs
            }
        end
    end
    
    print('Cache-Control: no-cache')  -- 禁止缓存
    print('Content-Type: applistion/json; charset=UTF-8')
    print('') -- http header和body的分割
    print(json.encode({
        ret = ret or 0,
        msg = msg,
        data = data
    }))
end

-- response后exit
function M.responseExit(data, ret, msg, headers)
    M.response(data, ret, msg, headers)
    os.exit()
end

M.logs = {}
function M.log(line, desc)
    if type(line) == 'table' then
        tinsert(M.logs, dump.dump2str(line, desc))
    else
        tinsert(M.logs, (desc and desc .. ': ' or '') .. tostring(line))
    end
end

-- 默认输出后结束当前CGI
function M.dumplog(exit)
    M.response(M.logs)
    M.logs = {}
    if exit ~= false then
        osexit()
    end
end

-- 测试用
function M.dumpenv()
    local function gv(k)
        M.log(k .. ': ' .. (getenv(k) or 'nil'))
    end

    gv('PATH')
    gv('LD_LIBRARY_PATH')
    gv('SERVER_SOFTWARE')
    gv('SERVER_NAME')
    gv('GATEWAY_INTERFACE')
    gv('SERVER_PROTOCOL')
    gv('SERVER_PORT')
    gv('REQUEST_METHOD')
    gv('PATH_INFO')
    gv('PATH_TRANSLATED')
    gv('SCRIPT_NAME')
    gv('QUERY_STRING')
    gv('REMOTE_ADDR')
    gv('HTTP_REFERER')
    gv('HTTP_REFERRER')
    gv('HTTP_USER_AGENT')
    gv('HTTP_ACCEPT')
    gv('HTTP_ACCEPT_ENCODING')
    gv('HTTP_ACCEPT_LANGUAGE')
    gv('HTTP_COOKIE')
    gv('CONTENT_TYPE')
    gv('HTTP_HOST')
    gv('CONTENT_LENGTH')
    gv('CGI_PATTERN')

    M.dumplog()
end

return M