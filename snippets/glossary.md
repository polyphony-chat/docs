## Glossary

- **Client** - A device or application used by a user or bot to connect to a server.
- **Federation ID** - A unique identifier; In public contexts, usually `username@optionalsubdomain.domain.tld`
- **Foreign client** - Any client authenticated on a server that is not its home server.
- **Foreign server** - A server that a user is not registered on; essentially a third party.
- **Home client** - Any client registered and authenticated on its home server.
- **Home server** - The server that a user is registered on. Any polyproto-core compliant server hosted on the same domain is also considered a home server.
- **Identity** - A unique Federation ID.
- **Identity Key** - A key pair representing a user's identity in a session, used for signing and encrypting messages.
- **Instance** - A server hosting polyproto compliant software for clients.
- **polyproto-chat** - The chat-API used by Polyphony. An extension of the polyproto protocol, defining the routes and capabilities of the chat-API used by Polyphony.
- **polyproto** - The core federation protocol and APIs of polyproto, enabling identification and authorization on 'foreign' servers. It is independent of the chat-API used.
- **Session** - A specific period of interaction between a client and a server, typically identified and authenticated by the use of an identity key. The session begins when the client connects to the server and ends when the client disconnects. During a session, the client can interact with the server (e.g., send messages, make requests) under the identity associated with the session.
- **User** - An entity represented by a federation ID, registered on a home server.
