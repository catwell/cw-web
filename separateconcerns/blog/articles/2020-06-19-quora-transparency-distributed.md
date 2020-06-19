% [Quora] Transparency in distributed systems UX
% Pierre 'catwell' Chapuis
% 2020-06-19 18:52:00

    ::description::
    Why is transparency (UX) a major issue in databases and other distributed systems?

Yet another [Quora answer](https://blog.separateconcerns.com/2020-04-09-quora-lua-call.html), this time to with [this question](https://www.quora.com/Why-is-Transparency-a-major-issue-in-distributed-databases) which I answered on August 24, 2016:

> Why is Transparency a major issue in distributed databases?

---

First, a few words about what "transparency" is. Transparency is a [UX term](https://en.wikipedia.org/wiki/Transparency_(human%E2%80%93computer_interaction)) about the user not noticing that they are using a distributed system. We actually talk about transparencies in the plural, because there are several kinds of transparencies: fault transparency, location transparency, concurrency transparency, access transparency, etc. In my opinion, the choice of wording is not so good: when we talk about "transparency" we actually mean we hide things from the user, so "opacity" would be more logical. (The name comes from the fact that, if we replace a single node system by a distributed system, it will be transparent for the user, i.e. then will not notice it.)

The reason why transparency is important is usability. The more transparencies our system has, the less cognitive burden there is on the user. In other words: *transparencies simplify the API of the system*.

However, what transparencies we implement or not is a trade-off between that simplicity of API and things like flexibility, performance, and sometimes correctness. Years ago (when Object Oriented programming à la Java was booming) it was fashionable to abstract everything and make the user forget that they were using an actual distributed system. For instance, we had RPC everywhere, which kind of hid the network from the user. Since then we learnt that [abstracting the network entirely is a bad idea](http://www.rgoarchitects.com/Files/fallacies.pdf).

On the other hand, exposing too many knobs to the user is dangerous as well: they might turn them without really understanding what they do and set the system on fire.

So, determining what to expose to the user and what to implement "transparently" is a crucial point in all distributed systems work, not only databases.

In databases in particular, conflict resolution is a contention point. Do we only provide the user with databases that are consistent, knowing that this severly impacts performance and availability? Do we let them tweak the parameters (the R and W parameters in a quorum system, for instance)? Do we tolerate divergence, detect it, inform the user and let them reconcile (à la CouchDB)? Do we provide the user with constrained datastructures that resolve conflicts by themselves (CRDTs)?

Some people have gone as far as saying that [Distributed Systems Are a UX Problem](https://bravenewgeek.com/distributed-systems-are-a-ux-problem/) and I tend to agree with this line of reasoning.
