% Thoughts 4 - SSO Tax and various links
% Pierre Chapuis
% 2022-12-11 18:20:00

    ::description::
    Thoughts on the SSO tax in SaaS, Amazon's Distributed Computing Manifesto, an old Aaron Swartz essay, and approachable research.

> "Thoughts" are posts about what has been on my mind. Sometimes practical, sometimes not; often just things I read recently. Less thought out than regular posts.

## The SSO Tax

I have had several discussions about how SSO should be priced by SaaS providers. On the one hand, making it prohibitively expensive weakens security for everyone, and there is [a website about that](https://sso.tax). On the other hand, features that distinguish between business categories are often related to security and compliance (audit logs, SLAs, etc).

My personal position - and I do not speak for anyone here including my employer - is the following:

- not having any SSO for free plans is fine;
- any paying customer should be able to use protocols such as OpenID Connect;
- charging extra for SAML support is fair.

## Amazon's Distributed Computing Manifesto

I often say SOA started to become mainstream when Jeff Bezos mandated it at Amazon around 2002, a story famously told by Steve Yegge. But Werner Vogels has [shared a document](https://www.allthingsdistributed.com/2022/11/amazon-1998-distributed-computing-manifesto.html) that shows the move began in 1998 and was advocated by engineers.

The Manifesto already emphasized moving data to the process, hiding data models from clients, data consistency issues... A fascinated read, almost 25 years later.

## Fix the machine, not the person

[This essay by Aaron Swartz](http://www.aaronsw.com/weblog/nummi) is ten years old. A good time to read it again.

> An organization is not just a pile of people, it’s also a set of structures. It’s almost like a machine made of men and women. [...] True, sometimes you have the wrong gears and need to replace them, but more often you’re just using them in the wrong way. When there’s a problem, you shouldn’t get angry with the gears — you should fix the machine. [...] You can’t force other people to change. You can, however, change just about everything else. And usually, that’s enough.

## Journal of Comprehensible Explanations

[Greg Wilson would like a journal of peer-reviewed summaries of research findings](https://third-bit.com/2022/11/20/journal-of-comprehensible-explanations/). No new results, just good explanations. Me too!
