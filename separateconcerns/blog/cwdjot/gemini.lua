local fmt = string.format

local function is_deep(node)
  return (node.c and #node.c > 0)
end

local Renderer = {}
Renderer.__index = Renderer

function Renderer.new()
  local state = {
    newlines = nil,
    quote_context = false,
    links = { ref = 0 },
  }
  setmetatable(state, Renderer)
  return state
end

function Renderer:adjust_newlines(n)
  if self.newlines == nil then
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

function Renderer:render(doc, handle)
  assert(handle)
  self.out = function(s)
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
  self[doc.t](self, doc)
end


function Renderer:render_children(node)
  if is_deep(node) then
    for i = 1 , #node.c do
      local subnode = node.c[i]
      if self[subnode.t] then
        self[subnode.t](self, node.c[i])
      elseif subnode.c and #subnode.c > 0 then
        self:render_children(subnode)
      else
        self.out(subnode.s)
      end
    end
  end
end

function Renderer:as_text(node)
  if not is_deep(node) then return node.s end
  local old_out, accum = self.out, {}
  self.out = function(s) table.insert(accum, s) end
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

function Renderer:doc(node)
  self:render_children(node)
  self:dump_links() -- also called in heading
end

function Renderer:raw_block()
  assert(self) -- skip
end

function Renderer:para(node)
  self:adjust_newlines(2)
  self:render_children(node)
end

function Renderer:blockquote(node)
  -- We rely on newline handling to add the angle brackets.
  self:adjust_newlines(2)
  self.out("> ")
  self.newlines = nil
  self.quote_context = true
  self:render_children(node)
  self.quote_context = false
end

function Renderer:heading(node)
  self:adjust_newlines(2)
  self:dump_links()
  self:adjust_newlines(2)

  local label, link
  if is_deep(node) then
    for _, subnode in ipairs(node.c) do
      if subnode.t == "link" then
        link = subnode.destination
        break
      end
    end
    if link then
      local label_t = {}
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

function Renderer:thematic_break()
  self:adjust_newlines(3)
end

function Renderer:code_block(node)
  self:adjust_newlines(2)
  self.out("```\n")
  self.out(node.s)
  self.out("\n```")
end

function Renderer:list(node)
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

function Renderer:softbreak()
  self.out(" ")
end

function Renderer:hardbreak()
  self.out("\n")
end

function Renderer:nbsp()
  self.out("\160")
end

function Renderer:verbatim(node)
  self.out("`")
  self.out(node.s)
  self.out("`")
end

function Renderer:link(node)
  assert(node.destination)
  local label = self:as_text(node)
  local link_id = #self.links + 1
  self.links[link_id] = {label = label, url = node.destination}

  self.out(label)
  self.out(" [")
  self.out(tostring(link_id))
  self.out("]")
end

function Renderer:image(node)
  assert(node.destination)
  local label = self:as_text(node)
  self.out(fmt("=> %s %s", node.destination, label))
end

function Renderer:double_quoted(node)
  self.out('"')
  self:render_children(node)
  self.out('"')
end

function Renderer:single_quoted(node)
  self.out("'")
  self:render_children(node)
  self.out("'")
end

return { Renderer = Renderer }
