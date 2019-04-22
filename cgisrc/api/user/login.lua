local md5 = require 'lzlib.md5'
local cgiauth = require 'cgi.cgiauth'

local M = {
    auth = -1
}

function M.exec(cgi, req)
    cgi.log(req.data)

    -- TODO
    local account = 'wwws'
    local password = 'admin'

    -- 验证
    if not (req.data and req.data.account == account and req.data.password == password) then
        return cgi.response(nil, 99902, 'verify fail')
    end

    local level = 0  -- TODO

    -- 设置cookie
    local cookies = cgiauth.build(level)
    for _, v in ipairs(cookies) do
        print('Set-Cookie: ' .. v)
    end
    
    cgi.response(nil)
end

return M
