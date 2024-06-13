## Glossary

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
- **P2 Extension** - A **p**oly**p**roto (P2) extension/
- **polyproto-chat** - The chat-API used by Polyphony. An extension of the polyproto protocol,
  defining the routes and capabilities of the chat-API used by Polyphony.
- **polyproto** - The core federation protocol and APIs of polyproto, enabling identification and
  authorization on foreign servers. It is independent of the chat-API used.
- **Root Certificate** - A certificate used to sign other certificates, establishing a chain of
  trust. In polyproto, only home servers have root certificates.
- **Service** - "Service" describes an application-specific set of behaviors and routes packaged as a
  P2 extension. polyproto-chat is a service, for example.
- **Session** - A specific period of authenticated interaction between a client and an instance.
  During the lifetime of a session, the client can perform actions as the actor they are authenticated
  as.
- **Session ID** - [See core.md](/Protocol%20Specifications/core#7113-session-ids)
