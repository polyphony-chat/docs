---
date: 2024-10-14
categories:
  - polyproto
  - updates
authors:
  - bitfl0wer
title: NLnet grant application
---

# NLnet grant application

The [NLnet foundation](https://nlnet.nl/) is a non-profit organization that supports open-source projects. They have a
grant program that funds projects that align with their goals. On behalf of Polyphony and the
polyproto project, I have submitted an application for a grant of 10,000€ from the NLnet foundation
in their funding round of October 2024.

<!-- more -->

Should we be successful in our application, the grant will be used to fund the development of the
Polyphony and polyproto projects, which would rapidly increase the development velocity of both
projects and bring them one big step closer to being ready for a public alpha release.

The application required a bunch of different, interesting questions to be answered. I would like
to share the answers with you, as they give a good overview of what we are working on, what we
are planning to do, and considerations we have made in the past.

## Can you explain the whole project and its expected outcome(s)?

polyproto is a new federation protocol with the goal of offering account portability and an effortless experience for users and developers alike.
It is part of the Polyphony Project, which aims to be a truly competitive alternative to centralized, proprietary chat services like Discord.
We came up with the idea for polyproto because of a lingering frustration with current federation protocols and their sub-optimal suitability for
such a project.

polyproto is not limited to an application in a chat service, and that it is not incompatible with federation protocols
such as ActivityPub. It would technically be possible to write a polyproto + ActivityPub server and client to offer new possibilities to the
currently existing Fediverse. We want to empower users, not split userbases further.

Our goal is to deliver the Polyphony chat service with polyproto at its core, build great SDKs for other developers to work with, and to also directly
work together with other developers to get alternative implementations of polyproto-based chat services for users to choose from. Polyphony
should be the ideal, federated and decentralized Discord replacement; a service, that can be used by teenagers, the elderly and anyone in
between and which ideally does not require any additional technical knowledge or proficiency to use.

Documentation/Protocol specification:
https://docs.polyphony.chat/Protocol%20Specifications/core/
Simplified overview of the protocol (sadly a little dated, but it can give an overview of the basics nonetheless):
https://docs.polyphony.chat/Overviews/core/
API Documentation:
https://docs.polyphony.chat/APIs/core/
"polyproto-rs" Rust crate:
https://github.com/polyphony-chat/polyproto-rs
Polyphony organization overview:
https://github.com/polyphony-chat
"chorus" API Wrapper for Discord, Spacebar-Chat (formerly "Fosscord") and our own server:
https://github.com/polyphony-chat/chorus

## Have you been involved with projects or organisations relevant to this project before? And if so, can you tell us a bit about your contributions?

I (Flori Weber, bitfl0wer) have been following the Spacebar-Chat (formerly "Fosscord") project for some time before deciding to start the
Polyphony-Chat GitHub organization in March 2023. The contributions I have made to the Spacebar project were limited to additions and overhauls
of the projects documentation, because of a lack of TypeScript knowledge, which is the programming language primarily used in the Spacebar
organization. Of course, I have prior experience in software development and software design through my work at Deutsche Telekom MMS GmbH,
but this is my first project with such a topic. I am part of a software development community called "Commune", which is a home for individuals
and groups who also have interest in federated and/or decentralized social media, as well as "reclaiming" the web from the hands of large
corporations. There, I have access to like-minded individuals who are also very much interested in polyproto and in seeing polyproto succeed.

## Requested Amount
$10.000

## Explain what the requested budget will be used for? Does the project have other funding sources, both past and present?

There are three key things that I (Flori Weber, bitfl0wer) have been wanting to tackle for months now, but have never been able to do, because of
a lack of available personal time or expertise. These three things are:

1. Writing new material and, if necessary, reworking existing material that
	- Describes, in a condensed form, what polyproto is about, targeted towards people who do not have [a lot of] existing knowledge in the topics of
	  federation and decentralized social networking concepts ($250-400)
	- Describes, in a condensed form, how polyproto works, targeted towards developers who might be interested in learning more about the inner
	  workings of polyproto, without needing to read the entire protocol specification document ($250-400)
2. Starting to build some sort of "brand" by
	- Commissioning an artist to create a recognizable logo for polyproto ($200-400)
	- Commissioning a frontend developer to build a landing page for our project, since non-developers do seem to prefer information hosted outside
	  of GitHub and plain looking documentation pages. This landing page would also host the written material mentioned in 1. ($500-1500)
3. Paying (freelance) developers to expedite this projects' journey to completion, where there are the following tasks we could use additional brains on:
	- Paying developers to start integrating our polyproto crate into our "chorus" client library and "symfonia" server (~$2000)
	- Stabilizing and extending the symfonia server to host a first, publicly usable instance (~$1500)
	- Getting additional help from UI/UX designers and frontend developers to build a client mockup, then having this mockup translated into
	  a client prototype which can be hosted alongside the symfonia server (~$2000)
	- "Overhaul"/Refactoring tasks which we, as a group of mainly university students working part time jobs in addition, simply did not yet have the
	  time to get to (~$1000-1500)

This would total to $7700 or $9700, depending on whether the lower or higher estimate is used.
Additionally, I would like to extend the domains polyphony.chat and polyproto.org for some years using the funding and top up our prepaid E-Mail
server hosted at https://uberspace.de/en/. The domain and the E-Mail server make up most of our current operating costs, ranging between 7-12$ a month.
This might not sound like a lot in the grand scheme of things, but I am currently paying for these out of my own pocket as an undergraduate with
little income, so being able to potentially reduce monthly expenses is a nice prospect. 

We currently have and have never had additional/other sources of funding. Receiving funding from NLNet would thus be our first source of funding.

## Compare your own project with existing or historical efforts.

### Spacebar Chat

Already previously mentioned, Spacebar Chat is also working on an open-source Discord replacement in form of offering an API-compatible server.
However, they do not seem interested in making Spacebar Chat a federated chat application with good user experience, as their primary focus
is to reverse-engineer and re-implement the Discord API spec-for-spec.

From talking to Spacebar Maintainers, their code reportedly seems to have accrued noticeable amounts of technical debt which made it undesirable
for most of the maintainers to continue development on the server. Being friends with some of the now mostly inactive maintainers, I have
considered forking the server repository to have an already mostly working starting ground to work with. However, due to the reports of
technical debt and our organizations' unfamiliarity with JavaScript/TypeScript, we have decided to start from scratch, in Rust.

The accumulated knowledge that Spacebar contributors and maintainers have collected in form of documentation has already been of great use
for our project, and we are contributing back by updating documentation and creating issues, when we find disparities between the behaviours of
our own server implementation and their server implementation.

### XMPP

Much like XMPP, I have decided to make polyproto an extensible protocol.

I am of the opinion that XMPPs biggest downfall is how many extensions there are, and that a server aiming to be compatible with other
implementations of XMPP-based chat services should aim to implement all of the XEPs to be a viable choice.

polyproto is actively trying to circumvent this by limiting polyproto extensions (P2 extensions for short) to

- either be a **set** of APIs and behaviours, defining a generic(!) version of a service. A "service" is, for example, a chat application,
  a microblogging application or an image blogging application. Service extensions should be the core functionality that is universally needed
  to make an application function. In the case of a chat application, that might be:
  
  - Defining message group size granularity: Direct messages, Group messages, Guild-based messages
  - Defining what a room looks like
  - Defining the APIs and behaviours required to send and receive messages
  - Defining the APIs and behaviours required to perform commonly sought after things, such as reacting to a message with an emoji
  - etc.
  
  The goal is that all different polyproto-based chat applications should then implement this shared behaviour. Of course, developers
  may absolutely add their own behaviours and functionality which is perhaps exclusive to their specific implementation. Core
  functionality remains commonly defined however, which should make all polyproto-based chat applications interoperable in these
  defined, common behaviours.
  
- or describe a **major** technological addition, which can be used in the "requires" section of another P2 extension. This "requires"
  section can be thought of like the dependency list of a software package.
  
  Technological additions might be:
  - Defining APIs and behaviours needed to implement the MLS (Messaging Layer Security) Protocol
  - Defining APIs and behaviours needed to establish and maintain a WebSocket connection, and how to send/receive messages over this
    WebSocket connection.
    
By using clay-brick-sized building blocks instead of more LEGO-sized building blocks like XMPP does, we hope to mitigate this problem
that we perceive, while still offering an extensible yet well-defined platform to build on.

### Matrix/Element

Matrix is perhaps the closest we have yet gotten to federated chat software aimed towards a general audience. However, as a strong
believer in user experience - especially how first impressions impact new, non-technical users, I believe that Matrix falls flat in this
regard. A lot of peoples first experience with Matrix is the infamous "Could not decrypt: The senders device has not yet sent us the keys
for this message". The protocol and its sub-protocols are vast and complicated and use bespoke cryptography protocol implementations such
as Olm and Megolm, which, in the past, has already been the cause of high-caliber vulnerabilities (see: https://nebuchadnezzar-megolm.github.io/
and, more recently, https://soatok.blog/2024/08/14/security-issues-in-matrixs-olm-library/#addendum-2024-08-14).

Matrix is truly impressive from a technical standpoint. Its extremely low centralized architecture fills a niche which especially
people already interested in technology seem to enjoy. However, this invariably results in the fact that user experience has to be
compromised. It is of my opinion that while Matrix is relatively good at what it is doing, it is not a good fit to be a potential
Discord replacement. 

As for a comparison: We are taking a radically different approach to Matrix. Matrix aims for eventually-consistent federation of events
using cryptographically fully verifiable directed acyclic event graphs, where as polyproto, and by extension Polyphony, prioritize
usability above all, intentionally disregarding highly complex or novel data structures in favor of cryptographic verifiability
through digital signatures and simple public key infrastructure.

## What are significant technical challenges you expect to solve during the project, if any?

Currently, our trust model acknowledges, that a users home server is able to create sessions and session tokens on the users' behalf,
and is thus able to listen in on unencrypted communications, or, in the case of a truly malicious admin, would even be able to send messages
on behalf of the user. This is not a novel problem, as it also affects all Mastodon ActivityPub servers in existence. Given that this
potential abuse risk has not been a large issue in the Fediverse, we expect this to also not be a major problem. However, I would like
to find additional mitigations or even a solution for this problem during further development of polyproto.

Another area that will likely need more work is my current design for how to connect to multiple servers at once: Currently, I expect
every client to hold a WebSocket connection with each server that they are communicating with, at once. Depending on the amount of traffic,
this could lead to constantly high resource consumption for clients. If this turns out to be the case, I am sure that we can find plenty
of software- and protocol-side adjustments and improvements to implement - though it is still a potential technical challenge.

My last major area of concern is how well transmission and de-/serializing of the X.509 based Identity Certificates will work. I am optimistic
about this however, since the X.500 series of RFCs are extremely well documented and already deeply explored, so that even if challenges
arise in this area, I am certain that there is enough literature on the exact problem we might be facing, and enough people to ask/talk to.

## Describe the ecosystem of the project, and how you will engage with relevant actors and promote the outcomes?

As the commercialization of Discord.com steadily increases, it is becoming clear that people are looking for a usable alternative.
This is an audience that we are hoping to capture. Our Polyphony Chat service is Discord API compatible, so that actors may use
the Polyphony client to interact with both Discord.com and polyproto-chat-based instances, and that existing bots and automations
could potentially be ported over very easily. This essentially gives people looking for a Discord replacement exactly what they
are looking for, as there should be little to no additional concepts, behaviors or patterns that users have to learn or
re-learn to use our service.

As previously touched on, we are blessed to already have made a great amount of connections to like-minded developers also working
on similar projects, who are looking optimistically towards polyproto as the tool to use to federate. I also have received explicit
permission from Spacebar Maintainers to promote our projects on their Discord Guild, which currently counts 3600 members.
