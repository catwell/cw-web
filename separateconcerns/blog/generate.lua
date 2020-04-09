local lunamark = require "lunamark"
local lustache = require "lustache"
local pathx = require "pl.path"
local dirx = require "pl.dir"
local Date = require "pl.Date"

local TPL = require "templates"
local SITE_DIR = "../site"

--- TOOLS

local fmt = string.format

local file_read = function(fn)
    local f = io.open(fn, "rb")
    if not f then return nil end
    local data = f:read("*all")
    f:close()
    return data
end

local file_write = function(fn, data)
    local f = assert(io.open(fn, "wb"))
    f:write(data)
    f:close()
end

local parse_date = function(s)
    return Date.Format("yyyy-mm-dd HH:MM:SS"):parse(s)
end

local date_to_atom = function(date)
    return Date.Format("yyyy-mm-ddTHH:MM:SSZ"):tostring(date) .. "Z"
end

local linearize; linearize = function(t)
    if type(t) == "string" then
        return t
    else
        assert(type(t) == "table")
        local r = {}; for i = 1, #t do r[i] = linearize(t[i]) end
        -- remove everything in < >, e.g. links in titles
        local loop = true
        while loop do
            loop = false
            for i = 1, #r do
                if r[i]:sub(1, 1) == "<" then
                    while r[i]:sub(-1) ~= ">" do
                        table.remove(r, i)
                    end
                    table.remove(r, i)
                    loop = true; break
                end
            end
        end
        return table.concat(r)
    end
end

local as_slug = function(s)
    s = linearize(s)
    s = string.gsub(s, "[^A-Za-z0-9 /_%-]", "")
    return string.gsub(s, "[ /_]+", "-"):lower()
end

---

local md_to_html_chunk = function(md)
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
                l1 = fmt("<pre><code data-language=\"lua\">", lang)
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

local function get_from_parts(parts)
    if type(parts) == 'string' then
        return parts
    elseif type(parts) == 'table' then
        local t = {}
        for i, v in ipairs(parts) do
            t[i] = get_from_parts(v)
        end
        return table.concat(t)
    elseif type(parts) == 'function' then
        return get_from_parts((parts()))
    end
end

local process_one = function(fname)
    local md = assert(file_read(fname))
    local content,metadata = md_to_html_chunk(md)
    metadata.date = table.concat(metadata.date)
    metadata.title = get_from_parts(metadata.title)
    metadata.author = table.concat(metadata.author[1])
    return content, metadata
end

local process_all = function()
    local files = dirx.getallfiles("articles", "*.md")
    table.sort(files, function(x, y) return x > y end) -- newest first
    local entries = {}
    local fnpart, content, metadata, pdate, sdate, udate, fragment, entry
    for i=1,#files do
        fnpart = pathx.splitext(pathx.basename(files[i]))
        print(fnpart)
        fname = fmt("articles/%s.md", fnpart)
        url = fmt("%s.html", fnpart)
        content, metadata = process_one(fname)
        pdate = assert(parse_date(metadata.date))
        sdate = Date.Format("yyyy-mm-dd"):tostring(pdate)
        pdate:toUTC()
        udate = pdate
        if metadata.updated then
            udate = parse_date(metadata.updated)
            udate:toUTC()
        end
        fragment = fnpart:sub(12)
        assert(fmt("%s-%s", sdate, fragment) == fnpart)
        entry = {
            title = metadata.title,
            url = url,
            content = content,
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
            table.insert(entries, entry)
        end
    end
    for i=1,#entries do
        entry = entries[i]
        local html = lustache:render(TPL.html_post, entry)
        file_write(fmt("%s/%s.html", SITE_DIR, entry.fnpart), html)
    end
    local atom = lustache:render(TPL.atom_feed, {
        updated = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time()),
        entries = entries,
    })
    file_write(fmt("%s/feed.atom",SITE_DIR), atom)
    local index = lustache:render(TPL.html_index, {
        updated = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time()),
        entries = entries,
    })
    file_write(fmt("%s/index.html", SITE_DIR), index)
end

process_all()
