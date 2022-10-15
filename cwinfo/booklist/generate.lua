local lustache = require "lustache"
local books = require "books"

local template = [[
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta
      name="description"
      content="Reading list of Pierre Chapuis (catwell)"
    >
    <link href="style.css" rel="stylesheet" type="text/css">
    <title>catwell's books</title>
  </head>
  <body>
    <div class="container">
      <h1>Reading list of <a href="https://catwell.info">Pierre Chapuis</a></h1>
      <div>
      {{#books}}
        <div class="book">
          <h3><a href="{{{url}}}">{{title}}</a></h3>
          <div class="cover">
            <a href="{{{url}}}"><img src="{{{cover}}}" alt=""></a>
          </div>
          <ul>
            {{#author}}<li><b>Author:</b> {{author}}</li>{{/author}}
            {{#authors}}<li><b>Authors:</b> {{authors}}</li>{{/authors}}
          </ul>
        </div>
      {{/books}}
      </div>
    </div>
    <script
      data-goatcounter="https://catwell.goatcounter.com/count"
      async src="//gc.zgo.at/count.js"></script>
  </body>
</html>
]]

local titles = {}
local book
for j=1,#books do
  book = books[j]
  if type(book.cover) == "table" then
    book.cover = string.format(
      "https://images-na.ssl-images-amazon.com/images/I/%s._SL160_.jpg",
      book.cover.amazon
    )
  end
  if #book.authors > 1 then
    book.authors = table.concat(book.authors, ", ")
  else
    book.author = book.authors[1]
    book.authors = nil
  end
  assert(not titles[book.title], book.title)
  titles[book.title] = true
end

table.sort(books, function(a, b) return a.title:lower() < b.title:lower() end)
print(lustache:render(template, {books = books}))
