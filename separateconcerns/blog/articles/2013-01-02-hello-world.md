% Hello again, World!
% Pierre 'catwell' Chapuis
% 2013-01-02 14:00:00

<!--@
  description = "Hello World post for Pierre Chapuis' new blog."
-->

[I](http://catwell.info) have not had a blog for over two years. The main reason for that is that writing is hard, so I went shopping on Twitter instead.

This was a bit hypocrite since I am an advocate for the Open Web and a huge consumer of information feeds, with several hundreds of them in my news reader. So for this New Year I have decided to put an end to this situation, thrown together a few lines of Lua code that act as a static blog generator (because reinventing the wheel is fun), and here it is: my new online journal.

I do not know with what frequency I will publish but expect articles about working at startups, distributed systems, programming in Lua, dealing with mobile networks, and whatever I happen to read and find interesting. Oh, and also the occasional rant, I guess.

Now here's to the tradition:

    lang: lua
    local greet = function(name)
      print(string.format("Hello, %s!",name))
    end

    greet("World")
