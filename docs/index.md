---
title: Home
---


# polyproto

Advanced, secure and scalable protocol for federated chat services.

The core of the protocol lies in the [protocol specification](./specification.md) and in the federation
API routes, which are used to negotiate and establish connections between foreign servers and
clients. 

Theoretically, the polyproto-core federation protocol can be used with a different set of chat-APIs 
However, a full implementation of the protocol requires the use of the
polyproto-chat routes. 

!!! info
    polyproto provides no chat-interoperability if you do not use the polyproto-chat API.

---

--8<-- "snippets/glossary.md"