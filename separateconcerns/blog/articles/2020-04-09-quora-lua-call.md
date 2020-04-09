% [Quora] What is the call metamethod in Lua?
% Pierre 'catwell' Chapuis
% 2020-04-09 08:40:00

    ::description::
    What is the call metamethod in Lua and what are some of its uses and basic examples?

From 2011 to 2014, I used to post answers on [Quora](https://www.quora.com/). I don't anymore, because I don't really like what the website has become. I have a copy of some of my answers [here](http://files.catwell.info/misc/mirror/quora-answers/) but someone [commented](https://www.quora.com/What-is-the-__call-metamethod-in-Lua-and-what-are-some-of-its-uses-and-basic-examples/all_comments/Pierre-Chapuis?__nsrc__=4&__snid3__=7556751152&comment_id=135057589&comment_type=2) on one of my answers that it should be available more prominently on the Web, so I decided to repost a few of my answers here, starting with this one.

The original question was:

> I'm really new to lua and relatively new to programming.,so kindly excuse if I say something stupid.
>
> I have a table named x and its metatable named y.
> When I have a `__call` method defined for the metatable `y`, then I can call `x()` but if I have a `__call` for `x` then I can not call `x()`.
>
> What is `__call` used for? How does it work and what are some examples of usage

I answered it on February 25, 2013.

---

`__call` is a metamethod, that means it is meant to be defined in a
metatable. A `__call` field added to a regular table (`x` in your example)
does nothing.

The role of `__call` is to make something that is not a function (usually
a table) act like a function. There are a few reasons why you may want
to do that. Here are two examples.

The first one is a memoizing factorial function. In Lua you could write
a recursive factorial like this:

    lang: lua
    local function fact(n)
        if n == 0 then
            return 1
        else
            return n * fact(n - 1)
        end
    end

Note: this is not a good way to write a recursive factorial because you
are not taking advantage of tail calls, but it's enough for what I want
to explain.

Now imagine your code uses that function to calculate the factorials of
numbers from 1 to `N`. This would be very wasteful since you would
calculate the factorial of `N` once, the factorial of `N-1` twice, and so
on. You would end up computing approximately `N²/2` factorials.

Instead you could write that:

    lang: lua
    local fact
    fact = setmetatable(
        {[0] = 1},
        {
            __call = function(t, n)
                if not t[n] then
                    t[n] = n * fact(n - 1)
                end
                return t[n]
            end
        }
    )

It is an implementation of factorial that memoizes the results it has
already computed, which you can call like a function. You can use it
exactly like the previous implementation of factorial and get linear
complexity.

Another use case for `__call` is matrices. Imagine you have a matrix
implementation that works like that:

    lang: lua
    local methods = {
        get = function(self, i, j)
            return self[i + 1][j + 1]
        end
    }

    local mt = {__index = methods}

    local new_matrix = function(t)
        return setmetatable(t, mt)
    end

You can use it like that:

    lang: lua
    local M = new_matrix({ {1, 2}, {3, 4} })
    local v = M:get(0, 1)
    assert(v == 2)

However scientists would probably expect something like this:

    lang: lua
    local v = M(0, 1)
    assert(v == 2)

You can achieve that thanks to `__call`:

    lang: lua
    local mt = {
        __index = methods,
        __call = function(self, i, j)
            return self:get(i, j)
        end
    }

I hope this gives you enough information to understand how you can use
`__call`. A word of warning though: like most other metamethods, it is
useful but it is important not to abuse it. Simple code is better :)
