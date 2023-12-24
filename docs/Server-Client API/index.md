# Start

The following pages document the server-client API of polyproto. Each file represents a group of 
routes, organizing them by their purpose.

The core of the protocol lies in the [federation](federation.md) routes, which are used to 
negotiate and establish connections between foreign servers and clients. 

Theoretically, the polyproto-core federation protocol can be used with a different set of chat-APIs 
However, a full implementation of the protocol requires the use of the
[polyproto-chat](chat/index.md) routes. There is no interoperability if different chat-APIs/protocols
are used.

---

--8<-- "snippets/api.md"

---

--8<-- "snippets/glossary.md"