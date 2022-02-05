local lunamark = require "lunamark"
local lustache = require "lustache"
local pathx = require "pl.path"
local dirx = require "pl.dir"
local Date = require "pl.Date"

local TPL = require "templates"
local SITE_DIR = "../site"
local GEMINI_DIR = "../gemini"

--- TOOLS

local fmt = string.format

local function file_read(fn)
    local f = io.open(fn, "rb")
    if not f then return nil end
    local data = f:read("*all")
    f:close()
    return data
end

local function file_write(fn, data)
    local f = assert(io.open(fn, "wb"))
    f:write(data)
    f:close()
end

local function parse_date(s)
    return Date.Format("yyyy-mm-dd HH:MM:SS"):parse(s)
end

local function date_to_atom(date)
    return Date.Format("yyyy-mm-ddTHH:MM:SSZ"):tostring(date) .. "Z"
end

local function linearize(t)
    if type(t) == "string" then
        return t
    else
        assert(type(t) == "table")
        local r = {}
        for i = 1, #t do r[i] = linearize(t[i]) end
        -- remove everything in < >, e.g. links in titles
        ::loop::
        for i = 1, #r do
            if r[i]:sub(1, 1) == "<" then
                while r[i]:sub(-1) ~= ">" do
                    table.remove(r, i)
                end
                table.remove(r, i)
                goto loop
            end
        end
        return table.concat(r)
    end
end

local function as_slug(s)
    s = linearize(s)
    s = string.gsub(s, "[^A-Za-z0-9 /_%-]", "")
    return string.gsub(s, "[ /_]+", "-"):lower()
end

---

local function md_to_html_chunk(md)
    local writer = lunamark.writer.html5.new({})
    local has_code, description = false, nil
    writer.verbatim = function(s)
        local desc = s:match("^::description::\n(.-)\n")
        local raw = s:match("^::raw::\n(.-)\n")
        if desc then
            description = desc
            return ""
        elseif raw then
            return raw
        else
            has_code = true
            local lang, code = s:match("^lang: (%w+)\n(.*)")
            local l1
            if lang and code then
                l1 = fmt("<pre><code data-language=\"%s\">", lang)
            else
                code = s
                l1 = "<pre><code>"
            end
            return table.concat({l1, writer.string(code), "</code></pre>"})
        end
    end
    local old_code = writer.code
    writer.code = function(s)
        has_code = true
        return old_code(s)
    end
    writer.header = function(s, level)
        return {
            "<h", level, " id=\"", as_slug(s), "\">",
            s,
            "</h", level, ">"
        }
    end
    local parse = lunamark.reader.markdown.new(
        writer,
        {pandoc_title_blocks = true, lua_metadata = true}
    )
    local html, metadata = parse(md)
    if has_code then metadata.has_code = true end
    metadata.description = assert(description)
    return html, metadata
end

local function md_links(links)
    local link_rows = {}
    for _, link in ipairs(links) do
        if not link.written then
            links.ref = links.ref + 1
            link.ref = links.ref
            link.written = true
            table.insert(link_rows, fmt("=> %s %d: %s\n", link.url, links.ref, link.url))
        end
    end
    return link_rows
end

local function md_to_gemtext(md)
    local writer = lunamark.writer.generic.new({})
    local links = {ref = 0}

    writer.verbatim = function(s)
        local desc = s:match("^::description::\n(.-)\n")
        local raw = s:match("^::raw::\n(.-)\n")
        if desc or raw then
            return ""
        end
        local code = s:match("^lang: %w+\n(.*)")
        return {"```\n", code or s, "\n```"}
    end

    writer.header = function(s, level)
        if level > 3 then return s end
        local prefix = {string.rep("#", level), " "}
        local link_id = lunamark.util.rope_to_string(s):match("<<<(%d+)>>>")

        if link_id then
            local link = links[tonumber(link_id)]
            link.written = true
            return {md_links(links), prefix, link.label, "\n", "=> ", link.url}
        end
        return {md_links(links), prefix, s}
    end

    writer.link = function(label, url)
        local link_id = #links + 1
        links[link_id] = {label = lunamark.util.rope_to_string(label), url = url}
        return { "<<<", tostring(link_id), ">>>" }
    end

    writer.code = function(s)
        return {"`", s, "`"}
    end

    writer.blockquote = function(s)
        local r = {"> "}
        for _,v in ipairs(s) do
            if type(v) == "string" and v == "\n\n" then
                table.insert(r, "\n> \n> ")
            else
                table.insert(r, v)
            end
        end
        return r
    end

    writer.bulletlist = function(items)
        local buffer = {}
        for i, v in ipairs(items) do
            buffer[i] = {"* ", v}
        end
        return lunamark.util.intersperse(buffer, "\n")
    end

    writer.image = function(label, src)
        return {"=> ", src, " ", label}
    end

    writer.stop_document = function()
        local rows = md_links(links)
        if #rows > 0 then
            return {"\n\n", rows}
        end
    end

    local parse = lunamark.reader.markdown.new(
        writer,
        {pandoc_title_blocks = true, lua_metadata = true}
    )
    local function f(link_id)
        local link = links[tonumber(link_id)]
        return fmt("%s [%d]", link.label, link.ref)
    end
    return parse(md):gsub("<<<(%d+)>>>", f)
end

local function parse_entry(fname)
    local md = assert(file_read(fname))
    local html, metadata = md_to_html_chunk(md)
    local gemtext = md_to_gemtext(md)
    metadata.date = table.concat(metadata.date)
    metadata.title = lunamark.util.rope_to_string(metadata.title)
    metadata.author = table.concat(metadata.author[1])
    return {
        html = html,
        gemtext = gemtext,
        metadata = metadata,
    }
end

local function process_file(path)
    local fnpart = pathx.splitext(pathx.basename(path))
    print(fnpart)
    local fname = fmt("articles/%s.md", fnpart)
    local url = fmt("%s.html", fnpart)
    local parsed_entry = parse_entry(fname)
    local metadata = parsed_entry.metadata
    local pdate = assert(parse_date(metadata.date))
    local sdate = Date.Format("yyyy-mm-dd"):tostring(pdate)
    pdate:toUTC()
    local udate = pdate
    if metadata.updated then
        udate = parse_date(metadata.updated)
        udate:toUTC()
    end
    local fragment = fnpart:sub(12)
    assert(fmt("%s-%s", sdate, fragment) == fnpart)
    local entry = {
        title = metadata.title,
        url = url,
        content = parsed_entry.html,
        gemtext = parsed_entry.gemtext,
        shortdate = sdate,
        has_code = metadata.has_code,
        description = metadata.description,
        fnpart = fnpart,
        atom = {
            published = date_to_atom(pdate),
            updated = date_to_atom(udate),
            fragment = fragment,
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

local function process_all()
    local files = dirx.getallfiles("articles", "*.md")
    table.sort(files, function(x, y) return x > y end) -- newest first
    local entries = {}
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
    local atom = lustache:render(TPL.atom_feed, {
        updated = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time()),
        entries = entries,
    })
    file_write(fmt("%s/feed.atom", SITE_DIR), atom)

    local index = lustache:render(TPL.html_index, {
        updated = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time()),
        entries = entries,
    })
    file_write(fmt("%s/index.html", SITE_DIR), index)

    local gemini_index = lustache:render(TPL.gemini_index, {
        updated = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time()),
        entries = entries,
    })
    file_write(fmt("%s/index.gmi", GEMINI_DIR), gemini_index)
end

process_all()
