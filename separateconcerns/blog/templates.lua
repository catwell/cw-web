local TPL = {}

TPL.html_post = [[
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="description" content="{{description}}">
    <link href="css/theme.css" rel="stylesheet" type="text/css">
    {{#has_code}}
      <link href="css/rainbow-github.css" rel="stylesheet" type="text/css">
    {{/has_code}}
    <link
      rel="alternate" type="application/atom+xml"
      href="http://blog.separateconcerns.com/feed.atom"
    />
    <title>{{{title}}}</title>
  </head>
  <body>
    <div id="container">
    <header>
      <h1>{{{title}}}</h1>
      <h4>published {{shortdate}}</h4>
    </header>
    {{{content}}}
    </div>
    <div id="footer">
      [ <a href="index.html">home</a> ]
    </div>
    {{#has_code}}<script src="js/rainbow.min.js"></script>{{/has_code}}
  </body>
</html>
]]

TPL.html_index = [[
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta
      name="description"
      content="Pierre Chapuis' online journal about system architecture, programming, startups and the separation of concerns."
    >
    <link href="css/theme.css" rel="stylesheet" type="text/css">
    <link
      rel="alternate" type="application/atom+xml"
      href="http://blog.separateconcerns.com/feed.atom"
    />
    <title>Separate Concerns</title>
  </head>
  <body>
    <div id="container">
    <header>
      <h1>Separate Concerns</h1>
      <h4>
        <a href="http://catwell.info" rel="me">catwell</a>'s
        journal on system architecture
        [<a href="feed.atom">subscribe</a>]
      </h4>
    </header>
    <ol class="index">
      {{#entries}}
      <li>
        {{shortdate}}
        <a href="{{url}}">{{{title}}}</a>
      </li>
      {{/entries}}
    </ol>
    {{{content}}}
    </div>
  </body>
</html>
]]

TPL.atom_feed = [[
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Separate Concerns</title>
  <link
    href="http://blog.separateconcerns.com/feed.atom"
    rel="self" type="application/atom+xml"
  />
  <link
    href="http://blog.separateconcerns.com"
    rel="alternate" type="application/xhtml+xml"
  />
  <id>tag:blog.separateconcerns.com,2012-12-13:atomfeed</id>
  <updated>{{updated}}</updated>
  <author>
    <name>Pierre 'catwell' Chapuis</name>
    <uri>http://catwell.info/</uri>
  </author>
  {{#entries}}
  <entry>
    <title>{{{title}}}</title>
    <link
      rel="alternate" type="text/html"
      href="http://blog.separateconcerns.com/{{url}}"
    />
    <id>tag:blog.separateconcerns.com,{{shortdate}}:{{atom.fragment}}</id>
    <published>{{atom.published}}</published>
    <updated>{{atom.updated}}</updated>
    <content type="xhtml">
      <div xmlns="http://www.w3.org/1999/xhtml">
        {{{content}}}
      </div>
    </content>
  </entry>
  {{/entries}}
</feed>
]]

return TPL
