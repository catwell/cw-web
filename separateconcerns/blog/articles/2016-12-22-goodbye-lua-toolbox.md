<!--@
  title="Goodbye Lua Toolbox"
  published="2016-12-22 08:00:00"
  description = "The Lua Toolbox has been merged into the main LuaRocks website."
-->

In November 2013, I gave
[a talk](http://files.catwell.info/presentations/2013-11-lua-workshop-lua-ecosystem)
about the Lua Ecosystem at [Lua Workshop](https://www.lua.org/wshop13.html), in
which I mentioned that finding the best module for some job could be hard and
introduced a website I had built to solve that problem.

That website, Lua Toolbox, was inspired by the popular
[Ruby Toolbox](https://www.ruby-toolbox.com/). It had two major features:
modules classification ("labels") and endorsements by users. I had written it
using Leaf Corcoran's relatively new Lua Web framework,
[Lapis](http://leafo.net/lapis/), and Redis as the datastore.

![Lua Toolbox homepage](img/lua-toolbox.jpg)

In August 2014, MoonRocks, one of Leaf's many projects, became the official
website for LuaRocks. It offered many features including user accounts,
manifests and the ability to upload rocks on the Web. We quickly
[started to discuss](https://github.com/catwell/lua-toolbox/issues/18)
merging Lua Toolbox into MoonRocks, but it led nowhere at first and the two
websites continued their separate lives.

Eventually, in March 2016, Etiene Dalcol
[took up the project](https://github.com/luarocks/luarocks-site/pull/86).
By September her and Leaf had written the code for labels and "follows",
which replace endorsements. They also added a feature for users to convert
their Toolbox endorsements to LuaRocks follows. I sent them a data dump which
they imported into the production LuaRocks website, and I turned Lua Toolbox
read-only.

Today, I finally replaced the whole website by
[a static page](https://lua-toolbox.com)
redirecting users to LuaRocks. In the end, the Toolbox had 232 users and
referenced 1217 modules. The source code
<a href="https://github.com/catwell/lua-toolbox">remains available</a> but
I would not advise you to do anything with it (it uses old Lapis APIs, from
a time where plain Lua support was not official).
