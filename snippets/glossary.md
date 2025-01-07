- **Actor** - An entity represented by a federation ID, registered on a home server. Actors can be
  users, bots, or any other entity with a federation ID.
- **CA, Certificate Authority** - Any home server that issues and publicly attests to the validity
  of ID-Certs. In polyproto, only home servers are CAs.
- **Client** - Any application used by an actor to connect to an instance.
- **CSR, Certificate Signing Request** - A request sent to a CA to obtain a certificate. It holds
  information about the entity requesting the certificate, including their public identity key.
- **DN, Distinguished Name** - A set of RDNs (Relative Distinguished Names) that uniquely identify
  a certificate. See <https://ldap.com/ldap-dns-and-rdns/>
- **Federation ID** - A unique identifier; In public contexts, usually **actor@**subdomain.**example**.com,
  where bold parts are required and non-bold parts are optional.
- **Foreign server** - An instance that an actor is not registered on; essentially a third party.
- **Home server** - The instance that an actor is registered on. Any polyproto-core compliant server
  hosted on the same domain is also considered a home server. A home server is the instance that
  publicly attests to the validity of all legitimate ID-Certs issued under its [FQDN](https://en.wikipedia.org/wiki/Fully_qualified_domain_name).
  A domain can have many home servers, but only one per subdomain.
- **ID-CSR** - A certificate signing request for a client's identity key pair. It is used to obtain
  an ID-Cert.
- **Identity** - Synonymous with "Federation ID".
- **Identity Key Pair** - A key pair associating an identity with a set of cryptographic keys used
  to sign and possibly encrypt messages.
- **Instance** - A server hosting polyproto compliant software for clients.
- **Message, Messages**: In the context of this protocol specification, a **message** is any piece
  of data sent by a client that is intended to be identifiable as being sent by a specific actor.
  To qualify as a "message", this piece of data must also, at any point in time, and also if only
  briefly, be visible to other users or to the unauthenticated public. Examples of things that would
  qualify as messages include:

    - A message sent to another actor in a chat application
    - A post on a social media platform
    - A "like" interaction on a social media platform
    - Reaction emojis in Discord-like chat applications
    - Group join or leave messages
    - Reporting a post or actor, if the report is not anonymous

- **P2** - Shortened form of polyproto.
- **P2 Extension** - A polyproto extension.
- **polyproto-chat** - The chat-API used by Polyphony. An extension of the polyproto protocol,
  defining the routes and capabilities of the chat-API used by Polyphony.
- **polyproto** - The core federation protocol and APIs of polyproto, enabling identification and
  authorization on foreign servers. It is independent of the chat-API used.
- **RawR** - [Resource addressing with relative roots](/Protocol%20Specifications/core#731-resource-addressing-with-relative-roots).
- **Root Certificate** - A certificate used to sign other certificates, establishing a chain of
  trust. In polyproto, only home servers have root certificates.
- **Service**: Any application-specific implementation of polyproto, defined by a P2 extension.
  All services are P2 extensions, but not all P2 extensions are services. polyproto-chat is an
  example of a service.
- **Session** - A specific period of authenticated interaction between a client and an instance.
  During the lifetime of a session, the client can perform actions as the actor they are authenticated
  as.
- **Session ID** - [See polyproto specification: Section 6.1.1.3](/Protocol%20Specifications/core#6113-session-ids)
