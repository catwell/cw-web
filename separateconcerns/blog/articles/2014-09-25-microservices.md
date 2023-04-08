<!--@
  title="Microservices"
  published="2014-09-25 23:00:00"
  description = [[
    An opinion on microservices and why I think the number of services
    in your system should grow like the square root of your team size.
  ]]
-->

Several people have asked me what I think about microservices. The tl;dr is: I like small services, but I don't like what some call microservices, which is isolating every single feature within its own service and aiming at services at small as possible (I heard about a target of "a few hundred lines of code" per service and a hard limit at 5000 LOC).

I [see SOA](http://blog.separateconcerns.com/2013-01-02-startups-soa.html) (and modularization in general) as a technique to design a system so that it scales with the number of people on a team. The way it works is by dividing complexity between people. The following will be terribly simplified, but bear with me.

Imagine a team working on a monolithic application. It is becoming too large and complicated to understand, so they split it into three parts, A, B and C. A third of the team will be responsible for each part. Each team is tasked with exposing an interface to the others, so that team A only has to worry about the internals of A and the interfaces of B and C. For each team, complexity has gone from the complexity of the monolithic application to a third of that complexity plus the complexity of communicating with the other parts of the system, or at least just knowing they exist, so given `N` the number of parts in the system and `M` the total complexity of the system, complexity seen from a service is: `M/N + k*N`.

Now assuming the complexity of the system increases linearly with team size `S` (it probably increases faster in practice but let's approximate), complexity seen from a service is `l*S/N + k*N`. With everything else constant, the function `N(S)` to minimize that looks like a square root.

In practice, this is not entirely true: as the system grows, not every service talks to other services and not every developer needs to know about every service. But because system architects and, more importantly, operations people do, my argument still holds.

So here is my point: the number of services you have should look like a constant times the square root of the size of your team. Meaning, with a constant of three:

![graph](img/microservices.jpg)

This is the problem I have with the idea to bound the size of single services while ignoring the complexity of inter-service communication. SOA is a practice which can help you curb local complexity as you scale but there is *no way* it can make it constant without making a mess of the whole system.

That being said, the value of the constant can be discussed. Some people think it should be lower than one, others think it should be very large.

I am not a huge fan of small constants when they result in services that do too many things and require too many people. They end up looking like a few monoliths, with the same issues as a single monolith. Moreover, if you are going to do services, inter-service calls should be the norm and not an exception. Very large constants, on the other hand, result in too much accidental complexity, harder debugging and operational nightmares.

I guess mileages vary but I like numbers around three. If you look at the curve above you may (or may not) agree that it looks reasonable; I think it does.

Note that the title of this blog is still "Separate Concerns": you should still draw clear lines between services, and you should still modularize as much as possible *within* services. But not every function call needs to be turned into a message sent over a network, and not every data structure needs its own process and source control repository.

And finally, just to be clear: do not look too much at the left part of the curve if you are a very early stage startup looking for product-market fit. You can still - and probably should - start with a monolith as long as you choose an architecture or framework with good modularization capabilities (like [Flask Blueprints](https://flask.palletsprojects.com/en/2.2.x/blueprints/)). Only consider SOA when you start to have a good rough idea of what the product will look like.
