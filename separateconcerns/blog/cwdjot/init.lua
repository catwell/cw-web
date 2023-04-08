local djot = require "djot"
djot.html = require "djot.html"
djot.gemini = require "cwdjot.gemini"

local StringHandle = {}

function StringHandle.new()
    local buffer = {}
    setmetatable(buffer, StringHandle)
    StringHandle.__index = StringHandle
    return buffer
end

function StringHandle:write(s)
    self[#self + 1] = s
end

function StringHandle:flush()
    return table.concat(self)
end

djot.StringHandle = StringHandle

function djot.overload_renderer_method(renderer, name, f)
    local old = renderer[name]
    renderer[name] = function(self, node)
        f(self, node, old)
    end
end

return djot
