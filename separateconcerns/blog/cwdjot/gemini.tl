local type djot = require "djot"
local type Node = djot.Node
local type IHandle = djot.IHandle
local type IRenderer = djot.IRenderer

local fmt = string.format

local function is_deep(node: Node): boolean
    return (node.c and #node.c > 0)
end

local record Link
    label: string
    url: string
    written: boolean
    ref: integer
end

local record Links
    {Link}
    ref: integer
end

local record M
    record Renderer is IRenderer
        newlines: integer
        quote_context: boolean
        links: Links

        new: function(): Renderer
        adjust_newlines: function(Renderer, integer)
        render_children: function(Renderer, Node)
        as_text: function(Renderer, Node): string
        dump_links: function(Renderer)
    end
end

local Renderer = M.Renderer
local Renderer_mt: metatable<Renderer> = { __index = Renderer }

function Renderer.new(): Renderer
    return setmetatable({
        quote_context = false,
        links = { ref = 0 },
    }, Renderer_mt)
end

function Renderer:adjust_newlines(n: integer)
    if not self.newlines then
        return -- start of document, special case
    end

    if self.quote_context then
        for _ = self.newlines, n - 1 do
            self.out("\n> ")
        end
        self.newlines = n
        return
    end

    for _ = self.newlines, n - 1 do
        self.out("\n")
    end
end

function Renderer:render(doc: Node, handle: IHandle)
    assert(handle)
    self.out = function(s: string)
        if s:sub(-1) == "\n" then
            for i = #s, 1, -1 do
                if s:sub(i) ~= "\n" then break end
                self.newlines = (self.newlines or 0) + 1
            end
        else
            self.newlines = 0
        end
        handle:write(s)
    end
    local method = assert(self[doc.t], fmt("Gemini renderer does not support %s", doc.t))
    method(self, doc)
end


function Renderer:render_children(node: Node)
    if is_deep(node) then
        for i = 1 , #node.c do
            local subnode = node.c[i]
            local render_method = self[subnode.t]
            if render_method then
                render_method(self, node.c[i])
            elseif subnode.c and #subnode.c > 0 then
                self:render_children(subnode)
            else
                self.out(subnode.s)
            end
        end
    end
end

function Renderer:as_text(node: Node): string
    if not is_deep(node) then return node.s end
    local old_out = self.out
    local accum: {string} = {}
    self.out = function(s: string) table.insert(accum, s) end
    self:render_children(node)
    self.out = old_out
    return table.concat(accum)
end

function Renderer:dump_links()
    local found = false
    for _, link in ipairs(self.links) do
        if not link.written then
            self.links.ref = self.links.ref + 1
            link.ref = self.links.ref
            link.written = true
            if not found then self:adjust_newlines(2) end
            found = true
            self:adjust_newlines(1)
            self.out(fmt("=> %s %d: %s", link.url, self.links.ref, link.url))
        end
    end
end

function Renderer:doc(node: Node)
    self:render_children(node)
    self:dump_links() -- also called in heading
end

function Renderer:raw_block(_node: Node)
    -- skip
end

function Renderer:para(node: Node)
    self:adjust_newlines(2)
    self:render_children(node)
end

function Renderer:blockquote(node: Node)
    -- We rely on newline handling to add the angle brackets.
    self:adjust_newlines(2)
    self.out("> ")
    self.newlines = nil
    self.quote_context = true
    self:render_children(node)
    self.quote_context = false
end

function Renderer:heading(node: Node)
    self:adjust_newlines(2)
    self:dump_links()
    self:adjust_newlines(2)

    local label: string
    local link: string
    if is_deep(node) then
        for _, subnode in ipairs(node.c) do
            if subnode.t == "link" then
                link = subnode.destination
                break
            end
        end
        if link then
            local label_t: {string} = {}
            for i = 1, #node.c do
                label_t[i] = self:as_text(node.c[i])
            end
            label = table.concat(label_t)
        end
    end
    label = label or self:as_text(node)

    if node.level <= 3 then
        for _ = 1, node.level do self.out("#") end
        self.out(" ")
    end
    self.out(label)
    if link then
        self.out(fmt("\n=> %s", link))
    end
end

function Renderer:thematic_break(_node: Node)
    self:adjust_newlines(3)
end

function Renderer:code_block(node: Node)
    self:adjust_newlines(2)
    self.out("```\n")
    self.out(node.s)
    self.out("\n```")
end

function Renderer:list(node: Node)
    assert(is_deep(node))
    self:adjust_newlines(2)
    for i = 1, #node.c do
        local subnode = node.c[i]
        assert(subnode.t == "list_item")
        self:adjust_newlines(1)
        self.out("* ")
        self.newlines = nil
        self:render_children(subnode)
    end
end

function Renderer:softbreak(_node: Node)
    self.out(" ")
end

function Renderer:hardbreak(_node: Node)
    self.out("\n")
end

function Renderer:nbsp(_node: Node)
    self.out("\160")
end

function Renderer:verbatim(node: Node)
    self.out("`")
    self.out(node.s)
    self.out("`")
end

function Renderer:link(node: Node)
    assert(node.destination)
    local label = self:as_text(node)
    local link_id = #self.links + 1
    self.links[link_id] = {label = label, url = node.destination}

    self.out(label)
    self.out(" [")
    self.out(tostring(link_id))
    self.out("]")
end

function Renderer:image(node: Node)
    assert(node.destination)
    local label = self:as_text(node)
    self.out(fmt("=> %s %s", node.destination, label))
end

function Renderer:double_quoted(node: Node)
    self.out('"')
    self:render_children(node)
    self.out('"')
end

function Renderer:single_quoted(node: Node)
    self.out("'")
    self:render_children(node)
    self.out("'")
end

return M
