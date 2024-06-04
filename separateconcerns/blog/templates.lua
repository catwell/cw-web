local TPL = {}

TPL.html_post = [[
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta content="width=device-width, initial-scale=1" name="viewport">
    {{#description}}<meta name="description" content="{{description}}">{{/description}}
    <link rel="canonical" href="https://blog.separateconcerns.com/{{url}}">
    <link href="css/theme.css?cache=3" rel="stylesheet" type="text/css">
    {{#has_code}}
      <link href="css/prism.css" rel="stylesheet" type="text/css">
    {{/has_code}}
    <link
      rel="alternate" type="application/atom+xml"
      href="https://blog.separateconcerns.com/feed.atom"
    />
    <title>{{{title}}}</title>
  </head>
  <body>
    <div id="container">
    <header>
      <h1>{{{title}}}</h1>
      <h4>
        published {{shortdate}}{{#updated}},
        updated {{updated}}{{/updated}}
        [ <a href="index.html">home</a> ]
      </h4>
    </header>
    {{{content}}}
    </div>
    <div id="footer">
      [ <a href="index.html">home</a> ]
    </div>
    {{#has_code}}<script src="js/prism.js"></script>{{/has_code}}
    <script
      data-goatcounter="https://separateconcerns.goatcounter.com/count"
      async src="//gc.zgo.at/count.js"></script>
  </body>
</html>
]]

local _desc = table.concat({
  "Pierre Chapuis' online journal about system architecture,",
  "programming, startups and the separation of concerns.",
}, " ")

TPL.html_index = [[
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta content="width=device-width, initial-scale=1" name="viewport">
    <meta
      name="description"
      content="]] .. _desc .. [["
    >
    <link rel="canonical" href="https://blog.separateconcerns.com">
    <link href="css/theme.css" rel="stylesheet" type="text/css">
    <link
      rel="alternate" type="application/atom+xml"
      href="https://blog.separateconcerns.com/feed.atom"
    />
    <title>Separate Concerns</title>
  </head>
  <body>
    <div id="container">
    <header>
      <h1>Separate Concerns</h1>
      <h4>
        <a href="https://catwell.info" rel="me">catwell</a>'s
        online journal
        [ <a href="feed.atom">subscribe</a> ]
      </h4>
    </header>
    <ol class="index">
      {{#entries}}
      <li>
        <span class="daydate">{{shortdate}}</span>
        <a href="{{url}}">{{{title}}}</a>
      </li>
      {{/entries}}
    </ol>
    {{{content}}}
    </div>
    <script
      data-goatcounter="https://separateconcerns.goatcounter.com/count"
      async src="//gc.zgo.at/count.js"></script>
  </body>
</html>
]]

TPL.atom_feed = [[
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Separate Concerns</title>
  <link
    href="https://blog.separateconcerns.com/feed.atom"
    rel="self" type="application/atom+xml"
  />
  <link
    href="https://blog.separateconcerns.com"
    rel="alternate" type="application/xhtml+xml"
  />
  <id>tag:blog.separateconcerns.com,2012-12-13:atomfeed</id>
  <updated>{{updated}}</updated>
  <author>
    <name>Pierre 'catwell' Chapuis</name>
    <uri>https://catwell.info/</uri>
  </author>
  {{#entries}}
  <entry>
    <title>{{{title}}}</title>
    <link
      rel="alternate" type="text/html"
      href="https://blog.separateconcerns.com/{{url}}"
    />
    <id>tag:blog.separateconcerns.com,{{shortdate}}:{{atom.fragment}}</id>
    <published>{{atom.published}}</published>
    <updated>{{atom.updated}}</updated>
    <content type="xhtml">
      <div xmlns="http://www.w3.org/1999/xhtml">
        {{{atom.content}}}
      </div>
    </content>
  </entry>
  {{/entries}}
</feed>
]]

TPL.gemini_post = [[
# {{title}}
published {{shortdate}}{{#updated}},updated {{updated}}{{/updated}}

{{{gemtext}}}
]]

TPL.gemini_index = [[
# Separate Concerns

## catwell's online journal

=> https://blog.separateconcerns.com Visit on the Web
=> gemini://catwell.info catwell.info

{{#entries}}
=> {{fnpart}}.gmi {{shortdate}} - {{{title}}}
{{/entries}}
]]

TPL.links_index = [[
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta content="width=device-width, initial-scale=1" name="viewport">
    <title>Dead links verification</title>
  </head>
  <body>
  {{#entries}}
  <h2>{{{title}}}</h2>
  <ul>
    {{#links}}
    <li><a href="{{.}}">{{.}}</a></li>
    {{/links}}
  </ul>
  {{/entries}}
  </body>
</html>
]]

return TPL
