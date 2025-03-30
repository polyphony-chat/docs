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

During