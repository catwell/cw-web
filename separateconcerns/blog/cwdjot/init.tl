local djot = require "djot"
local djot_html = require "djot.html"
local gemini = require "cwdjot.gemini"

local type Node = djot.Node
local type NodeTag = djot.NodeTag
local type IHandle = djot.IHandle
local type HtmlRenderer = djot_html.Renderer

local record StringHandle is {string}, IHandle
end

local StringHandle_mt: metatable<StringHandle> = { __index = StringHandle }

function StringHandle.new(): StringHandle
    return setmetatable({}, StringHandle_mt)
end

function StringHandle:write(s: string)
    self[#self + 1] = s
end

function StringHandle:flush(): string
    return table.concat(self as {string})
end

function StringHandle:pop(): string
    local r = self[#self]
    self[#self] = nil
    return r
end

local function override_renderer_method(
    renderer: HtmlRenderer,
    name: NodeTag,
    f: function(HtmlRenderer, Node, function(HtmlRenderer, Node))
)
    local old = renderer[name]
    renderer[name] = function(self: HtmlRenderer, node: Node)
        f(self, node, old)
    end
end

local cwdjot = {
    parse = djot.parse,
    StringHandle = StringHandle,
    override_renderer_method = override_renderer_method,
    html = djot_html,
    gemini = gemini,
}

return cwdjot
