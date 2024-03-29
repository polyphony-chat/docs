## Glossary

- **Actor** - An entity represented by a federation ID, registered on a home server. Actors can be
  users, bots, or any other entity with an identity.
- **CA, Certificate Authority** - An entity that issues digital certificates. In polyproto, home
  servers act as CAs.
- **Client** - Any application used by an actor to connect to a server.
- **CSR, Certificate Signing Request** - A request sent to a CA to obtain a certificate. It holds
  information about the entity requesting the certificate, including the public key.
- **DN, Distinguished Name** - A set of RDNs (Relative Distinguished Names) that uniquely identify
  a certificate.
- **Federation ID** - A unique identifier; In public contexts, usually `username@optionalsubdomain.domain.tld`
- **Foreign client** - Any client authenticated on a server that is not its home server.
- **Foreign server** - A server that an actor is not registered on; essentially a third party.
- **Home client** - Any client registered and authenticated on its home server.
- **Home server** - The server that an actor is registered on. Any polyproto-core compliant server
  hosted on the same domain is also considered a home server.
- **ID-CSR** - A certificate signing request for a client's identity key. It is used to obtain an ID-Cert.
- **Identity** - A unique Federation ID.
- **Identity Key** - A key pair representing an actor's identity in a session, used for signing and
  encrypting messages.
- **Instance** - A server hosting polyproto compliant software for clients.
- **polyproto-chat** - The chat-API used by Polyphony. An extension of the polyproto protocol,
  defining the routes and capabilities of the chat-API used by Polyphony.
- **polyproto** - The core federation protocol and APIs of polyproto, enabling identification and
  authorization on 'foreign' servers. It is independent of the chat-API used.
- **Root Certificate** - A certificate used to sign other certificates, establishing a chain of
  trust. In polyproto, only home servers have root certificates.
- **Session** - A specific period of interaction between a client and a server, typically identified
  and authenticated by the use of an identity key. The session begins when the client connects to
  the server and ends when the client disconnects. During a session, the client can interact with
  the server (e.g., send messages, make requests) under the identity associated with the session.
- **Session ID** - [See core.md](/Protocol%20Specifications/core#7113-session-ids)
