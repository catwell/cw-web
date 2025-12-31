local type Node = require("djot").Node
local type HtmlRenderer = require("djot.html").Renderer

local type HtmlRenderMethod = function(HtmlRenderer, Node)

local djot = require "cwdjot"
local lustache = require "lustache"
local pathx = require "pl.path"
local dirx = require "pl.dir"
local Date = require "pl.Date"

local TPL = require "templates"
local SITE_DIR = "../site"
local GEMINI_DIR = "../gemini"
local TMP_DIR = ".."

--- TOOLS

local fmt = string.format

local function file_read(fn: string): string
    local f = io.open(fn, "rb")
    if not f then return nil end
    local data = f:read("*all")
    f:close()
    return data
end

local function file_write(fn: string, data: string)
    local f = assert(io.open(fn, "wb"))
    f:write(data)
    f:close()
end

local function parse_date(s: string): Date
    return Date.Format("yyyy-mm-dd HH:MM:SS"):parse(s)
end

local function date_to_atom(date: Date): string
    return Date.Format("yyyy-mm-ddTHH:MM:SSZ"):tostring(date) .. "Z"
end

---

local record Metadata
    title: string
    description: string
    published: string
    updated: string
    has_code: boolean
    links: {string}
    skip: boolean
end

local function article_to_html_chunk(md: string): string, Metadata
    local input = djot.parse(md)
    local handle = djot.StringHandle.new()
    local renderer: HtmlRenderer = djot.html.Renderer:new()
    local metadata: Metadata = {links = {}}

    djot.override_renderer_method(
        renderer, "raw_block", function(self: HtmlRenderer, node: Node, old: HtmlRenderMethod)
            if node.format == "lua-meta" then
                load(node.s, nil, "t", metadata as table)()
            end
            old(self, node)
        end
    )

    djot.override_renderer_method(
        renderer, "verbatim", function(self: HtmlRenderer, node: Node, old: HtmlRenderMethod)
            metadata.has_code = true
            old(self, node)
        end
    )

    djot.override_renderer_method(
        renderer, "code_block", function(self: HtmlRenderer, node: Node, old: HtmlRenderMethod)
            metadata.has_code = true
            old(self, node)
        end
    )

    djot.override_renderer_method(
        renderer, "link", function(self: HtmlRenderer, node: Node, old: HtmlRenderMethod)
            if node.destination then
                table.insert(metadata.links, node.destination)
            end
            old(self, node)
        end
    )

    -- Hacks to close tags for Atom validity

    djot.override_renderer_method(
        renderer, "image", function(self: HtmlRenderer, node: Node, old: HtmlRenderMethod)
            old(self, node)
            assert(handle:pop() == ">")
            self.out("/>")
        end
    )

    djot.override_renderer_method(
        renderer, "thematic_break", function(self: HtmlRenderer, _node: Node, _old: HtmlRenderMethod)
            self.out("<hr/>\n")
        end
    )

    renderer:render(input, handle)
    local html = handle:flush()
    return html, metadata
end

local function article_to_gemtext(md: string): string
    local input = djot.parse(md)
    local handle = djot.StringHandle.new()
    local renderer = djot.gemini.Renderer.new()
    renderer:render(input, handle)
    return handle:flush()
end

local record ParsedEntry
    html: string
    gemtext: string
    metadata: Metadata
end

local function parse_entry(fname: string): ParsedEntry
    local md = assert(file_read(fname))
    local html, metadata = article_to_html_chunk(md)
    local gemtext = article_to_gemtext(md)
    metadata.description = metadata.description:
        gsub("%s+"," "):gsub("^ ",""):gsub(" $","")
    return {
        html = html,
        gemtext = gemtext,
        metadata = metadata,
    }
end

local function clean_for_atom(s: string): string
    local subst: {string: string} = {
        ["&ldquo;"] = "&#8220;",
        ["&rdquo;"] = "&#8221;",
        ["&lsquo;"] = "&#8216;",
        ["&rsquo;"] = "&#8217;",
        ["&hellip;"] = "&#8230;",
        ["&mdash;"] = "&#8212;",
        ["&ndash;"] = "&#8211;",
    }
    for k, v in pairs(subst) do
        s = s:gsub(k, v)
    end
    return s
end

local record AtomData
    published: string
    updated: string
    fragment: string
    content: string
end

local record Entry
    title: string
    raw_title: string
    url: string
    content: string
    gemtext: string
    shortdate: string
    updated: string
    has_code: boolean
    description: string
    fnpart: string
    links: {string}
    atom: AtomData
end

local function process_file(path: string): Entry
    local fnpart = pathx.splitext(pathx.basename(path))
    print(fnpart)
    local fname = fmt("articles/%s.dj", fnpart)
    local url = fmt("%s.html", fnpart)
    local parsed_entry = parse_entry(fname)
    local metadata = parsed_entry.metadata
    local pdate = assert(parse_date(metadata.published))
    local sdate = Date.Format("yyyy-mm-dd"):tostring(pdate)
    pdate:toUTC()
    local udate = pdate
    if metadata.updated then
        udate = parse_date(metadata.updated)
        udate:toUTC()
    end
    local fragment = fnpart:sub(12)
    assert(fmt("%s-%s", sdate, fragment) == fnpart, "mismatching dates")
    local entry: Entry = {
        title = metadata.title:gsub("&", "&amp;"),
        raw_title = metadata.title,
        url = url,
        content = parsed_entry.html,
        gemtext = parsed_entry.gemtext,
        shortdate = sdate,
        has_code = metadata.has_code,
        description = metadata.description,
        fnpart = fnpart,
        links = metadata.links,
        atom = {
            published = date_to_atom(pdate),
            updated = date_to_atom(udate),
            fragment = fragment,
            content = clean_for_atom(parsed_entry.html),
        }
    }
    if metadata.updated then
        sdate = Date.Format("yyyy-mm-dd"):tostring(udate)
        if sdate ~= entry.shortdate then
            entry.updated = sdate
        end
    end
    if not metadata.skip then
        return entry
    end
end

local record FeedData
    updated: string
    entries: {Entry}
end

local function process_all()
    local files = dirx.getallfiles("articles", "*.dj")
    table.sort(files, function(x: string, y: string): boolean return x > y end) -- newest first
    local entries: {Entry} = {}
    for i = 1, #files do
        local entry = process_file(files[i])
        if entry then table.insert(entries, entry) end
    end
    for i = 1, #entries do
        local entry = entries[i]
        local html = lustache:render(TPL.html_post, entry)
        local gemini = lustache:render(TPL.gemini_post, entry)
        file_write(fmt("%s/%s.html", SITE_DIR, entry.fnpart), html)
        file_write(fmt("%s/%s.gmi", GEMINI_DIR, entry.fnpart), gemini)
    end
    local feed_data: FeedData = {
        updated = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time()),
        entries = entries,
    }
    local atom = lustache:render(TPL.atom_feed, feed_data)
    file_write(fmt("%s/feed.atom", SITE_DIR), atom)

    local index = lustache:render(TPL.html_index, feed_data)
    file_write(fmt("%s/index.html", SITE_DIR), index)

    local gemini_index = lustache:render(TPL.gemini_index, feed_data)
    file_write(fmt("%s/index.gmi", GEMINI_DIR), gemini_index)

    local links_data: FeedData = {entries = entries}
    local links_index = lustache:render(TPL.links_index, links_data)
    file_write(fmt("%s/links.html", TMP_DIR), links_index)
end

process_all()
