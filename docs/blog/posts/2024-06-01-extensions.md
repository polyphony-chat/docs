---
date: 2024-06-01
categories:
  - polyproto
authors:
  - bitfl0wer
title: polyproto extensions
---

# polyproto extensions.

polyproto is a new federation protocol. Its main focus is enabling seamless participation of one
actor on many different servers. The core specification lacks routes for sending any sort of user
generated data anywhere, though. What is up with that?

<!-- more -->

## To federate is to be familiar

If any application wants to participate in the network of polyproto services, it has to speak the
same language as those other services. When wanting to send a message to a server that you are
authenticated on, your client needs to know exactly what that HTTP request has to look like. This
is nothing new. One take on a solution for this problem stems from the people working on the
ATProtocol, who created [Lexicon](https://atproto.com/guides/lexicon). From the atproto website:

!!! quote "Lexicon TL;DR"

    Lexicon is a global schema system. It uses reverse-DNS names like "`com.example.ping()`". The
    definitions are JSON documents, similar to JSON-Schema. It's currently used for HTTP endpoints,
    event streams, and repo records

The core of polyproto is supposed to be infinitely adaptable, to be flexible enough to be used for
just about anything, which is why I do not want to force a fixed set of routes onto every single
polyproto implementation.

Lexicon sounds interesting and really versatile! However, as mature as the idea itself might be, it
is pretty complex and does not yet seem to have good community support in the form of
libraries/crates to aid in working with this new schema system. I also do not want to force polyproto
integrations to use a (potentially very complex) Lexicon parser and dynamic routing system
thingymajig - although having "no rules" means, that if you *want* to build a polyproto service
which uses Lexicon, you absolutely can.

## We need a common foundation

I am a big proponent of defining a set of (mutually independent) protocol extensions, which include
additionally needed behavior and concrete HTTP routes for building a specific application. This has the following benefits:

- If you'd like to build a polyproto chat client, and there's a polyproto-chat extension, you
  simply need to add the additional things required by that extension. No need for complex parsing! Code only what you need and do not care about the rest.
- Mutual independence means being able to combine extensions however you'd like. You could, for
  example, create a chat app with integrated microblogging functionality.
- Developers are free to come up with whatever they want. How about ActivityPub x polyproto? Since
  polyproto doesn't define a message format, this is absolutely possible!
- Simplicity! polyproto and its "official" extensions will always just have plain old REST APIs,
  for which tooling is readily available. Why bother with something fancy and dynamic, when this
  does the trick?

On the other hand, everyone now has to agree on one extension to use for a specific application. You
cannot participate on servers, which have use an extension which is completely different from the one
that your client implements, as an example.

## ...the *polyproto* foundation. Get it? *sigh*

To develop, provide and maintain polyproto and some major "official" extensions (such as polyproto-chat),
creating a non-profit foundation is likely a good idea for a future where polyproto is actually being
used in the real world.

This could sort of be seen like the XMPP Standards Foundation which develops and maintains XMPP
extensions. Unlike XMPPs extensions however, official polyproto extensions should always be *major*
additions in functionality. As an example: [XEP-0084](https://xmpp.org/extensions/xep-0084.html) is
the official XMPP extension for User Avatars. An entire 12 point document, which describes one simple
feature!

polyproto extensions should either always be a major technological addition, which can be taken
advantage of by other extensions (examples for this would be WebSocket Gateways and
Messaging Layer Security), or a document describing a **set** of routes, which define a particular
application use case (A Discord-like, a Reddit-like, a Twitter-like, and so on). Having official
extensions adhere to these rules ensures that polyproto will not become a cluttered mess of
extensions and that it and its extensions are easy to understand and implement, due to less
documentation having to be read and written.

## Is this a bottleneck for me as a developer

If you are a developer, you might ask yourself:

!!! question

    Implementing common chat behaviour sounds cool in terms of intercompatibility, but doesn't this
    limit what I can do with my application? I have planned for a cool feature X to exist in my chat
    service, but that doesn't exist in the protocol extension!

Extensions should be a usable minimum of common behavior that all implementations targeting the
same "class" of application must share. Implementations can absolutely offer all the additional
special/unique features they'd like, though. polyproto clients implementing the same extensions
can be treated as clients with a reduced feature set in this case. What is crucial, however, is
that the additional features do not prohibit "reduced feature set clients" from using the behavior
described in the extension, if any sort of federation or interoperability is wanted.

!!! example "What works"

    In your implementation of a chat service, users can send each other messages with special
    effects, such as fireworks, confetti and similar. A different implementation of polyproto-chat
    is unlikely to see these special effects on their end. However, they can still see the messages'
    text contents, send replies to the message, and do all sorts of other things as described in
    this hypothetical polyproto-chat extension.
		
!!! example "What doesn't work"

    In your implementation of a chat service, users can send each other messages with special effects,
    such as fireworks, confetti and similar. Your implementation requires every client to send
    information about the special effect they'd like to send with a message - otherwise sending the
    message fails. If this is the case and you haven't implemented a sort of "adapter" for other
    polyproto-chat clients, these clients will not be able to send any messages to servers running
    your chat software. This conflicts with the behaviour required by the polyproto-chat extension
    and is therefore unacceptable.
		
Also keep in mind that through clever engineering, it might be possible to write adapters for
behavior, which should be required in your implementation and conflicts with the base extension.
Picking up the "What doesn't work" example again, the implementer could simply "translate" message
sending requests made to the polyproto-chat endpoints and add the required "special effects"
information, stating that messages sent through polyproto-chat endpoints have no special effects
added to them.

## Closing words

I am of the opinion that, while this way of having extensions might not be the most technologically
advanced solution, it certainly offers many possibilities while being easy to understand and
implement.

These are my current plans, ideas and thoughts for making a v1 of polyproto extensible. If you have
any thoughts on this matter, please do let me know! You can contact me via
[email](mailto:flori@polyphony.chat) or by writing a message on our [Discord](https://discord.com/invite/m3FpcapGDD).

Thank you for reading! :>

# Happy pride month! 🏳️‍🌈🏳️‍⚧️💛🤍💜🖤