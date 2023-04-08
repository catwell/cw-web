% [Quora] Explaining classes to a 10 year old
% Pierre 'catwell' Chapuis
% 2020-04-11 13:00:00

<!--@
  description = [[
    How would you explain the concept of a "class" in Python to a 10 year old?
  ]]
-->

Continuing my [Quora answers series](https://blog.separateconcerns.com/2020-04-09-quora-lua-call.html) with [this question](https://www.quora.com/How-would-you-explain-the-concept-of-a-class-in-Python-to-a-10-year-old) which I answered on June 26, 2012:

> How would you explain the concept of a "class" in Python to a 10 year old?

---

You cannot distinguish the concept of "class" from the concept of "instance". I think OOP is often taught the wrong way around, paradoxically because it is taught with languages that have support for class-based Object Oriented Programming such as Python (or Java for that matter). So excuse me but I will use another language (Lua, but you don't need to know to understand) to explain it. (Note: this will be *bad* Lua on purpose, but the point is not to teach Lua, it is to explain OOP).

Since you wrote "to a 10 year old" let's proceed with examples.

Imagine you come from another planet and you do not know what cats are. You encounter something small that purrs. You decide to name it Sam. Later on, you see something else very similar, except it is bigger, and you name it Max.

Let us describe Sam and Max in Lua.

    lang: lua
    sam = {
        name = "Sam",
        size = "small",
    }

    max = {
        name = "Max",
        size = "big",
    }

Now we said that they purr, so let's define purring:

    lang: lua
    purr = function(self)
        print(self.name .. " purrs!")
    end

`purr` is a function that has its first argument called `self` and represents the thing that purrs. For instance you could make Max purr
like this:

    lang: lua
    purr(max)

Now you could stop here, or you could see purring as a property of Sam and Max. To represent that we could make `purr` a "method" of the "objects" Sam and Max:

    lang: lua
    sam.purr = purr
    max.purr = purr

Now with the Lua syntax we cound also make Max purr like this:

    lang: lua
    max:purr()

Which is a short way to write this:

    lang: lua
    max.purr(max)

Since we said that `max.purr = purr` it works as expected.

After some time on Earth you realize there are lots of things like Sam and Max. Moreover there are lots of things Sam, Max and their friends do, such as sleep on keyboards. They also have things in common such as the fact they have two eyes.

You grow tired to say: "Max purrs. Max has two eyes. (...). Sam purrs. (...)". It would be much simpler to say give a name to the set of Sam, Max and their friends (for instance "Cats") and say "Cats purr. Cats have two eyes.".

Note that "Cats" is nothing physical, it is an idea, a *category* you have created for Sam, Max and their friends in order to be able to express things about them in an easier way.

Let's switch to Python to show how this is done now:

    lang: python
    class Cat:
        eyes = 2

        def __init__(self, name, size):
            self.name = name
            self.size = size

        def purr(self):
            print(self.name + " purrs!")

And how you use it:

    lang: python
    sam = Cat(name="Sam", size="small")
    sam.purr()

Note that we have never said explicitly that Sam can purr. He can purr because he is a Cat.

In this example:

- Cat is a class, ie. a category of objects ;

- Sam and Max are instances of the Cat class ;

- `purr` is a method of the Cat class, ie. not much more conceptually than a function that takes a Cat instance as its first argument and some syntactic sugar (ie. special notation) to call it.

---

By the way, this answer got one of the best comments I ever got on a Quora answer:

> Sam and Max are not cats!

;)
