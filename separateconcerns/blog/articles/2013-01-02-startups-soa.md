% Startups, think about SOA
% Pierre 'catwell' Chapuis
% 2013-01-02 14:00:01

    ::description::
    Startups should consider SOA (Service Oriented Architecture) when their scale starts to increase.

## What is SOA?

When people say SOA (Service Oriented Architecture) they often mean different things. My personal definition of SOA is rather loose and, like all the quotes in this article, [comes from Werner Vogels](http://queue.acm.org/detail.cfm?id=1142065), the CTO of Amazon:

> For us service orientation means encapsulating data with the business logic that operates on the data, with the only access through a published service interface.

If you are an Object Oriented Programming person this should ring a bell. Indeed, SOA is essentially encapsulation at the system level. Actually, I strongly believe OOP is a good idea (encapsulation) applied at the wrong layer.

The opposite of SOA in the context of the Web is monolithic applications. Think textbook Ruby on Rails or Django, for instance. Monolithic applications are fine as long as they are small, but I think SOA is a better fit for larger projects. If you are a technological startup, that means you should at least start thinking about what SOA could bring you if you are starting to have a clear idea of what your product is. Monolithic applications are great for prototypes and MVPs.

If you are wondering if what you are currently doing is closer to SOA than to monolithic applications, ask yourself these questions:

- How many different repositories does our code live in? (If you do *not* use source control you have more urgent problems to think about than SOA.)

- How many different databases do we have? How many database instances do we have? How many connections? How many schemas? (SOA and NoSQL tend to mix well.)

- Do we have a Web application that does significantly more than rendering templates? Is it stateful? What parts of that state could we also use in a mobile application? Does the same application render JSON and HTML?

## Advantages of SOA

One of the most obvious benefits of SOA is that services are easier to scale than monolithic applications. Maybe you want to migrate user authentication data to Redis and keep other data in whatever DB you already have? SOA makes it trivial. Maybe some part of your product would benefit from running on an AWS instance that has lots of RAM while another one is CPU-intensive? Just deploy the corresponding services where they run best.

SOA will also help you achieve resilience. You can program user-facing or aggregate services defensively so that they detect the unavailability of backend services and degrade gracefully. You can even use a [chaos monkey](https://blog.codinghorror.com/working-with-the-chaos-monkey/) to ensure this.

However in my opinion the main advantages of SOA are not technical, they are organizational.

As the number of your employees increases you will have to separate them into teams. The classical way to do this is by specialty: first developers and operations, then spin off DBAs... The main problem with that organization is that it hinders innovation. To create a new feature you need to coordinate all these people, and it results in endless meetings and sterile debates (not to mention clan wars).

This is not a fatality. You have probably heard of DevOps, and maybe dismissed it as Yet Another Buzzword. Well SOA is the easiest way to implement True DevOps (TM?), meaning that developers and operations really work together all the time. The trick is that there are no "devs" and "ops", because you create teams along another dimension: services. In Werner Vogel's words:

> The traditional model is that you take your software to the wall that separates development and operations, and throw it over and then forget about it. Not at Amazon. You build it, you run it. This brings developers into contact with the day-to-day operation of their software.

These teams are like smaller startups within your growing startup: they have all they need to build new features or even whole products by themselves. And they will keep you nimble if you give them enough leeway:

> We allow teams to function as independently as possible. Developers are like artists; they produce their best work if they have the freedom to do so, but they need good tools.

SOA also gives you language agnosticism almost for free. Not much prevents different services from being written in different programming languages. Why would you want to do that? Well, beyond the fact that different problems are better solved in Python, Haskell or C, there is lot of talent out there not using Ruby, Python, PHP, Scala, JavaScript or whatever language you have chosen for your monolithic application. Some of those Scheme, Io, Factor, Lua or F# hackers can be real assets for those clever enough to give them a job.

Finally, I can see a (perhaps more abstract) last advantage to SOA which is related to the rise of the Programmable Web. After all, there is little difference between a Web API and a service, except that you wrote the latter and not the former. Embracing SOA will prepare you to work with external APIs, and more importantly to publish your own. For instance, lots of AWS services have started their life as internal services at Amazon.

## Conclusion

I am not saying SOA *only* has advantages. Such an architecture can be fragile if you do not code with service unavailability in mind. Testing complex operations involving lots of services can be hard, and debugging them even harder. Correctly defining the boundaries and interfaces of services requires a significant amount of reflection and may not be a good idea when you do not know what exactly you are building.

That being said I still think more technological and/or Web startups should consider SOA instead of the "everything within the Framework" approach, not really for future scalability reasons, but because they risk limiting their flexibility, speed of iteration and capacity to hire short term if it is not already the case.
