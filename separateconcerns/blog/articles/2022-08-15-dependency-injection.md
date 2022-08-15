% Dependency Injection
% Pierre 'catwell' Chapuis
% 2022-08-15 21:20:00

    ::description::
    I use dependency injection for non-deterministic code.

In the list of application architecture patterns I like to use, [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) comes rather high. Here is how and why I use it.

## How I use Dependency Injection

If you have already seen dependency injection used in practice, you may believe it requires the use of a framework such as [Dagger](https://dagger.dev). Although I did use such frameworks - especially in Angular where [it is native](https://angular.io/guide/dependency-injection) - most of the time I use a simpler form of DI where I just pass dependencies to functions or constructors.

For instance, in Lua object-oriented code, instead of writing this:

    lang: lua
    local json = require "dkjson"

    local obj_mt = {
        __index = {
            as_json = function(self)
                return json.encode(self.data)
            end
        }
    }

    local function new_obj(data)
        return setmetatable({data = data}, obj_mt)
    end

    local o = new_obj({foo = 5})
    o:as_json()

I could write something like this:

    lang: lua
    local obj_mt = {
        __index = {
            as_json = function(self)
                return self.json_encoder(self.data)
            end
        }
    }

    local function new_obj(data, json_encoder)
        return setmetatable(
            {data = data, json_encoder = json_encoder},
            obj_mt
        )
    end

    local json = require "dkjson"
    local o = new_obj({foo = 5}, json.encode)
    o:as_json()

Note that this follows the [Dependency Inversion principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle), which is often confused with dependency injection but not exactly the same thing. It may not be obvious in a dynamic language such as Lua but the implementation of `obj` implicitly defines the signature of the JSON encoder it expects, and you may substitute the encoder for something else.

Also, on a stylistic note, in a larger program I would probably not pass every injected dependency as a different parameter, instead I would use a single container for this.

In case you're interested, here is the same example closer to how I'd write it in practice in [Teal](https://github.com/teal-language/tl):

    local type JsonAble = {string: any}
    local type JsonEncoder = function(JsonAble): string

    local record ObjDeps
        json_encoder: JsonEncoder
    end

    local record Obj
        data: JsonAble
        as_json: function(Obj): string
        _deps: ObjDeps
    end

    local obj_mt = {
        __index = {
            as_json = function(self: Obj): string
                return self._deps.json_encoder(self.data)
            end
        }
    }

    local function new_obj(data: JsonAble, deps: ObjDeps): Obj
        return setmetatable({data = data, _deps = deps}, obj_mt)
    end

    local json = require "dkjson"
    local o = new_obj(
        {foo = 5},
        {json_encoder = json.encode as JsonEncoder}
    )
    o:as_json()


Now let us see a few use cases for this.

## Testing I/O

Probably the most well-known use case for DI is simplifying testing of code that does I/O, for instance code that makes network requests or interacts with a database. It makes it easy to replace the problematic part with a mock. You can mock just what you need or the entire dependency, for instance you can replace Redis with [fakeredis](https://luarocks.org/modules/catwell/fakeredis).

## Supporting different implementations of dependencies

This is a less well-known but very good use-case, especially in Lua. Let us consider my JSON example above. Users of this code may want to use [dkjson](https://luarocks.org/modules/dhkolf/dkjson), but maybe they want to use a faster, pure C module, or maybe they are running in OpenResty and have [cjson](https://openresty.org/en/lua-cjson-library.html) available. With dependency injection, it's easy to just use it.

## Eliminating randomness

This is in fact the use case that prompted me to write this blog post. I was writing some algorithmic code in Teal for which I had a reference in Python, and I wanted to apply [the dual-implementation comparison technique I like](https://blog.separateconcerns.com/2013-06-20-three-years-proprietary-projects.html#seed). However, this was AI code that had random parts.

What I did was that I re-wrote the code in both languages so that all sources of randomness were injected, and then I injected deterministic pseudo-random values instead, which meant I could now compare the state of both implementations at all time and easily debug things such as numerical problems.

## When not to use DI

DI is a great tool, but it tends to make code a bit more complicated, so for instance I do not use it to inject pure functions or libraries from the same codebase.

If you have used Angular with [Storybook](https://storybook.js.org), you may know what abuse of DI looks like. It can be super verbose because sometimes you need to inject a lot of things you do not really care about for it to work.

A way to work around that if you still want to use DI may be to have sensible defaults for some injected objects. That way you can still override them if needed, but you can still have simple sample code.
