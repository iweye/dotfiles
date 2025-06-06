--[[
    An addon for file-browser which decodes URLs so that they are more readable
]]

---@type ParserConfig
local urldecode = {
    priority = 5,
    api_version = "1.0.0"
}

--decodes a URL address
--this piece of code was taken from: https://stackoverflow.com/questions/20405985/lua-decodeuri-luvit/20406960#20406960
---@type fun(s: string): string
local decodeURI
do
    local char, gsub, tonumber = string.char, string.gsub, tonumber
    local function _(hex) return char(tonumber(hex, 16)) end

    function decodeURI(s)
        s = gsub(s, '%%(%x%x)', _)
        return s
    end
end

function urldecode:can_parse(directory)
    return self.get_protocol(directory) ~= nil
end

---@async
function urldecode:parse(directory)
    local list, opts = self:defer(directory)
    opts = opts or {}
    if opts.directory and not self.get_protocol(opts.directory) then return list, opts end

    opts.directory_label = decodeURI(opts.directory_label or (opts.directory or directory))
    return list, opts
end

return urldecode
