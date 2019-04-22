#!/usr/local/bin/lua

package.cpath = package.cpath .. ';../../lualibc/?.so'
package.path = package.path .. ';../../lualib/?.lua;../../cgisrc/?.lua'
cjson = require 'cjson'  -- json库在本项目太常用了，加载到全局
local main = require 'main'

local json = cjson
local print = print

-- 全局的报错函数
_G.serverError = function(err)
    print('Cache-Control: no-cache')  -- 禁止缓存
    print('Content-Type: application/json; charset=UTF-8')
    print('')
    print(json.encode({
        ret = 99901,
        msg = err
    }))

    -- 因为是CGI，直接exit
    os.exit(false)
end

-- 保护模式执行main
xpcall(main.run, function(...)
    print('Cache-Control: no-cache')  -- 禁止缓存
    print('Content-Type: text/plain; charset=UTF-8')
    print('')
    print(debug.traceback(...))
end)
