local lustache = require "lustache"
local categories = require "books"

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
    <div id="container">
      <h1>Reading list of <a href="http://catwell.info">Pierre Chapuis</a></h1>
      <div id="toc">
      <h2>Categories</h2>
      <ul>
      {{#categories}}
        <li><a href="#{{short}}">{{name}}</a></li>
      {{/categories}}
      </ul>
      </div>
      <div id="books">
      {{#categories}}
        <h2 id="{{short}}">{{name}}</h2>
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
      {{/categories}}
      </div>
    </div>
  </body>
</html>
]]

local books,book
for i=1,#categories do
  books = categories[i].books
  for j=1,#books do
    book = books[j]
    if type(book.cover) == "table" then
      book.cover = string.format(
        "http://ecx.images-amazon.com/images/I/%s._SL160_.jpg",
        book.cover.amazon
      )
    end
    if type(book.authors) == "table" then
      if #book.authors > 1 then
        book.authors = table.concat(book.authors, ", ")
      else
        book.author = book.authors[1]
        book.authors = nil
      end
    end
  end
end

local html = lustache:render(
  template,
  {categories = categories}
)

print(html)
