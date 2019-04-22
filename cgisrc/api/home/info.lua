local M = {}

function M.exec(cgi, req)
    cgi.log(req)
    cgi.response(nil)
end

return M
