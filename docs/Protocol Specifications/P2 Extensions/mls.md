---
title: polyproto-mls
---

# P2 Extension: polyproto-mls

!!! bug "TODO"

    This is a work in progress. MLS-related content is currently being migrated over from the polyproto-core specification.
    This document is not yet complete.

**v0.1.0-alpha.1** - Treat this as an unfinished draft.
[Semantic versioning v2.0.0](https://semver.org/spec/v2.0.0.html) is used to version this specification.
The version number specified here also applies to the API documentation.

- [P2 Extension: polyproto-mls](#p2-extension-polyproto-mls)
  - [1. Encryption](#1-encryption)
    - [1.1. KeyPackages](#11-keypackages)
      - [1.1.1 Last resort KeyPackages](#111-last-resort-keypackages)
    - [1.2 Initial authentication](#12-initial-authentication)
    - [1.3 Multi-device support](#13-multi-device-support)
      - [6.1.3 Key rotation](#613-key-rotation)

The following sections describe the additional behavior that polyproto implementations must implement
to support encryption via the Messaging Layer Security (MLS) protocol.

## 1. Encryption

!!! abstract "About MLS"

    Polyproto offers end-to-end encryption for messages via
    [Message Layer Security (MLS)](https://messaginglayersecurity.rocks/). polyproto compliant
    servers take on the role of both an Authentication Service and a Delivery Service in the context
    of MLS.

    MLS is a cryptographic protocol that provides confidentiality, integrity, and authenticity
    guarantees for group messaging applications. It builds on top of the
    [Double Ratchet Algorithm](https://signal.org/docs/specifications/doubleratchet/) and
    [X3DH](https://signal.org/docs/specifications/x3dh/) to provide these security guarantees.

Implementations of polyproto can opt to support encryption to secure communication channels.
The selected security protocol for all polyproto implementations is the Messaging Layer Security
protocol, given its feasibility within the implementation context. MLS inherently supports
negotiation of protocol versions, cipher suites, extensions, credential types, and extra proposal
types. For two implementations of polyproto to be compatible with each other in the context of
encryption, they must have overlapping capabilities in these areas.

The following sections explain the additional behavior that polyproto implementations utilizing MLS
must implement.

### 1.1. KeyPackages

!!! warning

    The sections 1.1 and 1.1.1 are not exhaustive and do not cover all aspects of MLS and
    KeyPackages. They exist solely to give a general overview of how KeyPackages are used in
    polyproto. Please read and understand the MLS specification (RFC9420) to implement polyproto
    correctly.

A polyproto compliant server must store KeyPackages for all clients registered on it. The
KeyPackage is a JSON object that contains the following information:

```json
{
  "protocol_version": "<Version>",
  "cipher_suite": "<CipherSuite>",
  "init_key": "<HPKEPublicKey>",
  "leaf_node": "<LeafNode>",
  "extensions": "<Extensions>",
}
```

- `protocol_version` denotes the MLS protocol version.
- `cipher_suite` indicates the used cipher suite for this KeyPackage. Note that a server can store
  many KeyPackages for a single actor, to support various cipher suites.
- `init_key` is a public key for encrypting initial group secrets.
- `leaf_node` is a signed `LeafNodeTBS` struct as defined in section `7.2. Leaf Node Contents` in
  RFC9420. A `LeafNode` has information representing a users' identity, in the form of the users'
  **ID-Cert** for a given session or client. The `LeafNodeTBS` is signed by using the actor's
  private identity key.
- `extensions` can be used to add additional information to the protocol, as defined in section
  `13. Extensibility` in RFC9420.

A KeyPackage is supposed to be used only once. Servers must ensure the following things:

- That any KeyPackage is not given out to clients more than once.
- That the `init_key` values of all KeyPackages are unique, as the `init_key` is what makes the
  KeyPackage one-time use.
- That the contents of the `LeafNode` and the `init_key` were signed by the actor who submitted the KeyPackage.

Because KeyPackages are supposed to be used only once, servers should retain multiple valid
KeyPackages for each actor, alerting clients when their stock is running low. Consult the
["Registration needed"-API](/APIs/Core/Routes%3A Registration needed) for more information about
how servers should request new KeyPackages from clients. Servers should delete KeyPackages when
their validity lapses.

Servers only store KeyPackages for home server users, not for foreign users.

!!! note "About keys"

    It is recommended that keys are generated using the `EdDSA` signature scheme, however, other
    signature schemes may be used as well.
    Consider, that intercompatibility can only be guaranteed if all communicating parties have an
    overlapping set of supported signature schemes.

#### 1.1.1 Last resort KeyPackages

A "last resort" KeyPackage, which, contrasting regular KeyPackages, is reusable, is issued when a
server runs out of regular KeyPackages for an actor. This is to prevent `DoS` attacks, where
malicious clients deplete all KeyPackages for a given actor, blocking that actor's inclusion into
encrypted groups or guild channels.

Servers are to replace a "last resort" KeyPackage after it has been used at least once by requesting
one from the client.

### 1.2 Initial authentication

During the initial authentication process, a client must provide at least one
[KeyPackage](#11-keypackages) and one ["last resort" KeyPackage](#111-last-resort-keypackages) to
the server, in addition to the required registration information.

The public identity key inside the `LeafNode` of this KeyPackage corresponds to the public identity
key found inside a clients' ID-Cert.

### 1.3 Multi-device support

polyproto servers and clients employing encryption must support multi-device use. The MLS protocol
assigns each device a unique `LeafNode` and prohibits key sharing across devices. Each device offers
distinct KeyPackages and an own ID-Cert.

--- 

TODO: Integrate this from the core spec

```text
A server identity key's lifetime might come to an early or unexpected end, perhaps due to some sort
of leak of the corresponding private key. When this happens, the server should generate a new
identity key pair and broadcast the
[`SERVER_KEY_CHANGE`](/docs/APIs/Core/WebSockets/gateway_events.md#server_key_change) and
[`LOW_KEY_PACKAGES`](/docs/APIs/Core/WebSockets/gateway_events.md#low_key_packages) gateway events
to all clients. Clients must request new ID-Certs (through a CSR), and respond appropriately to the
[`LOW_KEY_PACKAGES`](/docs/APIs/Core/WebSockets/gateway_events.md#low_key_packages)
event. Should a client be offline at the time of the key change, it must be informed of the change
upon reconnection.

!!! note

    A `LOW_KEY_PACKAGES` event is only sent by servers which use MLS encryption. Server/Clients not
    implementing MLS encryption can safely ignore this event.

```

#### 6.1.3 Key rotation

A session can choose to rotate their ID-Cert at any time. This is done by generating a new identity
key pair, using the new private key to generate a new CSR, and sending the new Certificate Signing
Request to the home server, along with at least one new KeyPackage and a corresponding 'last resort'
KeyPackage, if encryption is offered. The home server will then generate the new ID-Cert, given that
the CSR is valid and that the server accepts the creation of new ID-Certs at this time.

TODO ^ I copied this paragraph over from core.md. The important part here is the fact that a keypackage
and last resort keypackage should be sent when rotating keys. i posted the entire paragraph for context