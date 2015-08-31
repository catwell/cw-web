local lunamark = require "lunamark"
local lustache = require "lustache"
local pretty = require "pl.pretty"
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

---

local md_to_html_chunk = function(md)
    local writer = lunamark.writer.html5.new({})
    local has_code, description = false, nil
    writer.verbatim = function(s)
        local desc = s:match("^::description::\n(.-)\n")
        if desc then
            description = desc
            return ""
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
    local parse = lunamark.reader.markdown.new(
        writer,
        {pandoc_title_blocks = true, lua_metadata = true}
    )
    local html, metadata = parse(md)
    if has_code then metadata.has_code = true end
    metadata.description = assert(description)
    return html, metadata
end

local process_one = function(fname)
    local md = assert(file_read(fname))
    local content,metadata = md_to_html_chunk(md)
    metadata.date = table.concat(metadata.date)
    metadata.title = table.concat(metadata.title)
    metadata.author = table.concat(metadata.author[1])
    return content, metadata
end

local process_all = function()
    local files = dirx.getallfiles("articles", "*.md")
    table.sort(files, function(x, y) return x > y end) -- newest first
    local entries = {}
    local fnpart, content, metadata, pdate, sdate, udate, fragment
    for i=1,#files do
        fnpart = pathx.splitext(pathx.basename(files[i]))
        print(fnpart)
        fname = fmt("articles/%s.md", fnpart)
        url = fmt("%s.html", fnpart)
        content, metadata = process_one(fname)
        pdate = parse_date(metadata.date)
        sdate = Date.Format("yyyy-mm-dd"):tostring(pdate)
        pdate:toUTC()
        udate = pdate
        if metadata.updated then
            udate = parse_date(metadata.updated)
            udate:toUTC()
        end
        fragment = fnpart:sub(12)
        assert(fmt("%s-%s", sdate, fragment) == fnpart)
        entries[i] = {
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
            if sdate ~= entries[i].shortdate then
                entries[i].updated = sdate
            end
        end
    end
    local entry
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
