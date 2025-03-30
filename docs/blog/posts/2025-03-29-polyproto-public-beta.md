---
date: 2025-03-30
draft: true
categories:
  - polyproto
authors:
  - bitfl0wer
title: polyproto v1.0-beta
---

For well over a year, I have been working on polyproto—a new, user-friendly federation protocol.
I'm incredibly happy to finally release this first beta version to the public today. Let's talk about
it in-depth!

<!-- more -->

## The "what?"'s and "why?"'s

So, *what is* this "polyproto" thing even? Where did my perceived need for something new come from and
what existing problems does it solve?

As you might know, I am working on [Polyphony](https://github.com/polyphony-chat), a FO3S
(Free, Open-Source, *Self-hostable* Software) alternative to Discord, currently still in its infancy
(but growing up by the day!). Federation is an important topic for self-hostable chat software, and after
looking into the topic for a bit, the following became clear:

- People, especially technical users, *want* federation and decentralization.
- People, especially non-technical users never want to have to think about federation, how it
  works and what it means.
- People do not want all their stuff to be gone if their home server says "buh-bye" for
  any reason. Account portability is a must.

!!! info "About ATProto"

    When I started working on polyproto over a year ago, ATProto was already known to me, but it
    was nowhere near as complete as it is now. In fact, one ATProto developer had this to say at
    that point in time:

    > I work on Bluesky and helped build the AT Protocol. [...] Bluesky and the AT Proto are in beta.
    The stuff that seems incomplete or poorly documented *is* incomplete and poorly documented.

    *([source](https://news.ycombinator.com/item?id=35881905))*

    Out of all the options, when viewing it from a surface level, polyproto and ATProto do seem sort
    of similar. My opinion is, that they try to accomplish similar overall end-goals, but they have
    different ideas on how to get there, making each protocol unique again.
    But we'll get to that later, pinkie promise. Also, some[¹](https://dustycloud.org/blog/how-decentralized-is-bluesky/)
    [²](https://dustycloud.org/blog/re-re-bluesky-decentralization/)
    [³](https://www.youtube.com/watch?v=D0wbCctcEIA) might even argue that ATProto isn't
    really decentralized. But
    [that is its own rabbit hole](https://blog.muni.town/atproto-isnt-what-you-think/) entirely.

During my research into existing protocols which fulfill these criteria, the following are the most promising
ones I have encountered. I will also explain why I did not end up choosing them.

### XMPP

Much like XMPP, I have decided to make polyproto an extensible protocol.

I am of the opinion that XMPPs biggest downfall is how many extensions there are, and that a server
aiming to be compatible with other
implementations of XMPP-based chat services should aim to implement all of the XEPs to be a
viable choice.

polyproto is actively trying to circumvent this by limiting polyproto extensions (P2 extensions for
short) to

- either be a **set** of APIs and behaviors, defining a generic(!) version of a service. A "service"
  is, for example, a chat application, a microblogging application or an image blogging application.
  Service extensions should be the core functionality that is universally needed to make an
  application function. In the case of a chat application, that might be:
  
  - Defining message group size granularity: Direct messages, Group messages, Guild-based messages
  - Defining what a room looks like
  - Defining the APIs and behaviors required to send and receive messages
  - Defining the APIs and behaviors required to perform commonly sought after things, such as reacting to a message with an emoji
  - etc.
  
  The goal is that all different polyproto-based chat applications should then implement this shared behavior. Of course, developers
  may absolutely add their own behaviors and functionality which is perhaps exclusive to their specific implementation. Core
  functionality remains commonly defined however, which should make all polyproto-based chat applications interoperable in these
  defined, common behaviors.
  
- or describe a **major** technological addition, which can be used in the "requires" section of another P2 extension. This "requires"
  section can be thought of like the dependency list of a software package.
  
  Technological additions might be:
  - Defining APIs and behaviors needed to implement the MLS (Messaging Layer Security) Protocol
  - Defining APIs and behaviors needed to establish and maintain a WebSocket connection, and how to send/receive messages over this
    WebSocket connection.
    
By using clay-brick-sized building blocks instead of more LEGO-sized building blocks like XMPP does, we hope to mitigate this problem
that we perceive, while still offering an extensible yet well-defined platform to build on.

Account portability has been implemented in XMPP with
[XEP-0227: Portable Import/Export Format for XMPP-IM Servers](https://xmpp.org/extensions/xep-0227.html).
However, while I think that this XEP is really cool (and I might ~~steal~~ be inspired from it), it
does not protect 