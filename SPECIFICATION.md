# Polyphony Specification

**v0.0.0** - Treat this as an unfinished draft.

- [Polyphony Specification](#polyphony-specification)
  - [1. Polyphony APIs](#1-polyphony-apis)
    - [1.1. Client-Server API](#11-client-server-api)
      - [1.1.1. Initial authentication](#111-initial-authentication)
    - [1.2. Server-Server API](#12-server-server-api)
  - [2. Federated Identity](#2-federated-identity)
    - [2.1 Federation tokens](#21-federation-tokens)
    - [2.2 Signing keys and message signing](#22-signing-keys-and-message-signing)
    - [2.3 Reducing network strain when verifying signatures](#23-reducing-network-strain-when-verifying-signatures)
    - [2.4 Best practices](#24-best-practices)
      - [2.4.1 Signing keys](#241-signing-keys)
      - [2.4.2 Home server operation and design](#242-home-server-operation-and-design)
  - [3. Federating direct/group messages](#3-federating-directgroup-messages)
    - [3.1 Direct messages](#31-direct-messages)
    - [3.2 Group messages](#32-group-messages)
  - [4. Users](#4-users)
  - [5. Encryption](#5-encryption)
    - [5.1 Encrypted guild channels](#51-encrypted-guild-channels)
    - [5.2 Encrypted direct messages](#52-encrypted-direct-messages)
    - [5.3 Encrypted group messages](#53-encrypted-group-messages)
    - [5.4 Multi-device support](#54-multi-device-support)
    - [5.5 Best practices](#55-best-practices)
  - [6. Keys and signatures](#6-keys-and-signatures)
    - [6.1. KeyPackages](#61-keypackages)
      - [6.1.1 Last resort KeyPackages](#611-last-resort-keypackages)
    - [6.2. User identity](#62-user-identity)


This document defines a set of protocols and APIs for a chat service primarily focused on communities. The document is intended to be used as a reference for developers who want to implement a client or server for the Polyphony chat service. Uses of this protocol, hereafter referred to as "the Polyphony protocol", include Instant Messaging, Voice over IP, and Video over IP, where your identity is federated between multiple servers.

The information provided to you via this document only fully covers the Polyphony Protocol itself. To correctly implement the Polyphony protocol, you must read the MLS specification (RFC9420). It is imperative that implementations of this protocol respect all aspects of this specification. 

The structure of this reference document is heavily inspired by the really well written [Matrix specification](https://spec.matrix.org/latest).

## 1. Polyphony APIs

The specification defines a set of APIs that are used to implement the Polyphony protocol. These APIs are:

- Client-Server API
- Server-Server API

### 1.1. Client-Server API

The Client-Server API is a RESTful API that is used by clients to communicate with the server. It is a modification of the Discord v9 API and is completely backwards compatible with it, even if not all endpoints are supported. An example of an unsupported endpoint would be the "Super-reactions" endpoint, which are treated as regular reactions by Polyphony.

#### 1.1.1. Initial authentication

During the initial authentication (registration) process, a client must provide at least one `KeyPackage`, as well as one "last resort" `KeyPackage` (see [6.1.1 Last resort KeyPackages](#611-last-resort-keypackages)) in addition to the required registration information.

The identity key inside the `LeafNode` of this `KeyPackage` is signed using the home servers' private key, so that home servers act as a certificate authority for their users' keys.

See [6.1. KeyPackages](#61-keypackages) for an outline on what a `KeyPackage` is, and consult the MLS specification (RFC9420) for more implementation details.

### 1.2. Server-Server API

The Server-Server APIs are used to enable federation between multiple Polyphony servers (federated identity).
TODO

## 2. Federated Identity

Federating user identities means that users can fully participate on other instances. This means that users can, for example, DM users from another server or join external Guilds. 

The identity key defined in [6.1. KeyPackages](#61-keypackages) is used to sign messages that the user sends to other servers.

**Example:**
Say that Alice is on server A, and Bob is on server B. Alice wants to send a message to Bob.

Alice's client will send a message to her home server (Server A), asking it to generate a one-time use federation token for registering on server B. Alice takes this token and sends it to server B. Server B will then ask server A if the token is valid. If all goes well, server B will send a newly generated session token back to Alice's client. Alice's client can then authenticate with server B using this token, and send the message to server B. Server B will then send the message to Bob's client.

```
Alice's Client              Server A            Server B            Bob's Client
|                           |                   |                   |
|-Federation token request->|                   |                   |
|                           |                   |                   |
|<-----Federation token-----|                   |                   |
|                    [Federation handshake start]                   |
|                           |                   |                   |
|---------Federation token+Profile------------->|                   |
|                           |                   |                   |
|                           |<--Verification?---|                   |
|                           |                   |                   |
|                           |-----Yes, valid--->|                   |
|                           |                   |                   |
|<----------------Session Token-----------------|                   |
|                           |                   |                   |
|                   [Federation handshake complete]                 |
|                           |                   |                   |
|---------Session Token+Signed message--------->|                   |
|                           |                   |                   |
|                           |                   |--Signed message-->|
|                           |                   |                   |
```

TODO: Server B does not have to ask Server A if the token is valid, no? :thinking:
 
Fig. 1: Sequence diagram of a successful federation handshake.

If Alice's session token expires, or if Alice would like to sign in on another device, she can repeat this process of generating a federation token and exchanging it for a session token.

The usage of a federation token prevents a malicious user from generating an external session token on behalf of another user.

### 2.1 Federation tokens

Federation tokens are generated by the user's home server. The token is a JSON object that contains the following information:

- The time at which the token expires.
- The user's federation ID.
- The domain of the server that the token is intended for.
- The domain of the user's home server.
- A securely-randomly generated nonce


### 2.2 Signing keys and message signing

As mentioned in the previous section, users must hold on to a private key at all times. This key is used to sign all messages that the user sends to other instances. The key is generated by the user's home server, and is sent to the user's client when the user first registers on the server. The key is stored in the client's local storage. The signing key must not be used for encryption purposes.

A client may choose to rotate their signing key at any time. When this happens, the home server will send a new signing key to the user. The user's client will have to save this updated key and use it when communicating with other servers. The home server has to keep track of the old signing key, and use it to verify messages that were signed with the old key.

Signing messages prevents a malicious server from impersonating a user.

TODO: Note about signing keys and how they are generated

### 2.3 Reducing network strain when verifying signatures

If Bob receives a message from Alice, he will ask Server B to provide the public identity key of Alice at the time the message was sent. Server B will then ask Server A for this key. Server A will then send the appropriate key to Server B. Server B will then store this key in its database and forward it to Bob. Bobs' client should then ask Server A for its signing key, cache this key and verify that Server B has stored/provided the correct public identity key for Alice at the time the message was sent. Should Bob want to re-verify the signature of Alice's message in the future, or should another User of Server B want to verify the signature of Alice's message, Server B will already have the public identity key cached.

Bob's client could always ask Server A for the public identity key of Alice, but this would put unnecessary strain on the network. This is why Server B should cache the public identity keys of users from other instances.

### 2.4 Best practices

#### 2.4.1 Signing keys

- Instance/user signing keys should be rotated at least every 30 days. This is to ensure that a compromised key can only be used for a limited amount of time.
- If Bobs client fails to verify the signature of Alice's message with the public key provided by Server B, it should ask Server A for the public key of Alice at the time the message was sent. If the verification fails again, the message should be treated with extreme caution.

#### 2.4.2 Home server operation and design

- Employ a caching layer to handle the potentially large amount of requests for public keys without putting unnecessary strain on the database.

## 3. Federating direct/group messages

### 3.1 Direct messages

Federating direct messages is relatively simple. When Alice sends a message to Bob, her client will send the message to her home server via an API request. Her home server will then send the message to Bob's client via an established WebSocket connection, and vice versa.

### 3.2 Group messages

Group messages work just like guilds. The data is stored by the home server of the group's creator, meaning that all group members will have to communicate with the group creator's home server. If the group creator leaves the group, the ownership of the group is transferred to another member. The group chat stays on the group creator's home server, unless a migration is initiated by the group owner.

## 4. Users

Each client must have a user associated with it. A user is identified by a unique federation ID (FID), which consists of the user's username (which must be unique on the instance) and the instance's root domain. A FID is formatted as follows: `user@domain.tld`, which makes for a globally unique user ID. Federation IDs are case-insensitive.

The following regex can be used to validate user IDs: `\b([A-Z0-9._%+-]+)@([A-Z0-9.-]+\.[A-Z]{2,})\b`.

## 5. Encryption

The Polyphony protocol offers end-to-end encryption for messages via Message Layer Security (MLS). Polyphony protocol compliant servers take on the role of both an Authentication Service and a Delivery Service in context of MLS.

Message Layer Security (MLS) is a cryptographic protocol that provides confidentiality, integrity, and authenticity guarantees for group messaging applications. MLS builds on top of the [Double Ratchet Algorithm](https://signal.org/docs/specifications/doubleratchet/) and [X3DH](https://signal.org/docs/specifications/x3dh/) to provide these security guarantees.

Clients and servers must support encryption, but whether to encrypt a message channel is up to the users.

Note, that in the below sequence diagrams, the MLS Welcome message and the MLS Group notify message are all encrypted using the public key of the recipient. The public key in this context is not to be confused with the public signing key.

TODO: Write about multi-device support and using X3DH to securely sync message history between devices.

### 5.1 Encrypted guild channels

Encrypting a guild channel is done by a client with the `MANAGE_CHANNEL` permission. Upon successfully requesting enabling encryption of a channel, all future messages in it will be encrypted. Joining an encrypted channel is done by sending a join request to the server. The server will then notify the channels' members of the join request. The members will then decide whether to accept or reject the join request. If the join request is accepted by any member, that member will initiate the MLS welcoming process. If the member finds that the join request is invalid (perhaps due to an invalid `KeyPackage`), the join request must be denied. It is imperative that join requests are verified correctly by the server.

```
     Charlie                                        Server                                            Alice                         Bob
     |                                              |                                                 |                             |
     | Channel join request + KeyPackage            |                                                 |                             |
     |--------------------------------------------->|                                                 |                             |
     |                                              |                                                 |                             |
     |                                              | Notify gatekeepers of join request              |                             |
     |                                              |-----------------------------------              |                             |
     |                                              |                                  |              |                             |
     |                                              |<----------------------------------              |                             |
     |                                              |                                                 |                             |
     |                                              | Channel join request + Charlie's KeyPackage     |                             |
     |                                              |------------------------------------------------>|                             |
     |                                              |                                                 |                             |
     |                                              |                                                 | Verify Charlie's KeyPackage |
     |                                              |                                                 |------------------------     |
     |                                              |                                                 |                       |     |
     |                                              |                                                 |<-----------------------     |
     |                                              |                                                 |                             |
     |                                              |             Notify group of new member: Charlie |                             |
     |                                              |<------------------------------------------------|                             |
     |                                              |                                                 |                             |
     |                                              |                           Encrypted MLS Welcome |                             |
     |                                              |<------------------------------------------------|                             |
     |                                              |                                                 |                             |
     |                                              | Forward: Notify group of new member: Charlie    |                             |
     |                                              |------------------------------------------------------------------------------>|
     |                                              |                                                 |                             |
     | Forward: Notify group of new member: Charlie |                                                 |                             |
     |<---------------------------------------------|                                                 |                             |
     |                                              |                                                 |                             |
     |               Forward: encrypted MLS Welcome |                                                 |                             |
     |<---------------------------------------------|                                                 |                             |
     |                                              |                                                 |                             |
```
Fig. 2: Sequence diagram of a successful encrypted channel join in which Alice acts as a gatekeeper. The sequence diagram assumes that Alice can verify Charlies' public key to indeed belong to Charlie, and that Alice accepts the join request.

### 5.2 Encrypted direct messages

Adding another person to a direct message is not possible, and would not make much sense, as the new person cannot see any messages that were sent before they joined the group. If Alice wants to add Charlie to a direct message with Bob, she will have to create a new direct message with Bob and Charlie.

```
Alice                                          Server                             Bob
|                                              |                                  |
| Request Bob's KeyPackages                    |                                  |
|--------------------------------------------->|                                  |
|                                              |                                  |
|                            Bob's KeyPackages |                                  |
|<---------------------------------------------|                                  |
|                                              |                                  |
| Verify Bob's KeyPackages                     |                                  |
| -----------------------                      |                                  |
|                       |                      |                                  |
|<-----------------------                      |                                  |
|                                              |                                  |
| Notify group of new member: Bob              |                                  |
|--------------------------------------------->|                                  |
|                                              |                                  |
| Encrypted MLS Welcome                        |                                  |
|--------------------------------------------->|                                  |
|                                              |                                  |
|                                              | Forward: New group member: Bob   |
|                                              |--------------------------------->|
|                                              |                                  |
|                                              | Forward encrypted MLS Welcome    |
|                                              |--------------------------------->|
|                                              |                                  |
```
Fig. 3: Sequence diagram of a successful encrypted direct message creation. 


### 5.3 Encrypted group messages

Encrypted group messages work by using the traditional MLS protocol, with the additional concept of group owners. Only group owners can add new members to the group and forcibly remove others from the group. The Group owner is determined by the Client-Server API.

```
Alice (gatekeeper)                                 Server                                  Bob       Charlie
|                                                  |                                       |         |
| Request Bob's KeyPackages                        |                                       |         |
|------------------------------------------------->|                                       |         |
|                                                  |                                       |         |
|                                Bob's KeyPackages |                                       |         |
|<-------------------------------------------------|                                       |         |
|                                                  |                                       |         |
| Verify Bob's KeyPackages                         |                                       |         |
|------------------------                          |                                       |         |
|                       |                          |                                       |         |
|<-----------------------                          |                                       |         |
|                                                  |                                       |         |
| Notify group of new member: Bob                  |                                       |         |
|------------------------------------------------->|                                       |         |
|                                                  |                                       |         |
| Encrypted MLS Welcome                            |                                       |         |
|------------------------------------------------->|                                       |         |
|                                                  |                                       |         |
|                                                  | Forward: New group member: Bob        |         |
|                                                  |-------------------------------------->|         |
|                                                  |                                       |         |
|                                                  | Forward encrypted MLS Welcome         |         |
|                                                  |-------------------------------------->|         |
|                                                  |                                       |         |
| Request Charlie's KeyPackages                    |                                       |         |
|------------------------------------------------->|                                       |         |
|                                                  |                                       |         |
|                            Charlie's KeyPackages |                                       |         |
|<-------------------------------------------------|                                       |         |
|                                                  |                                       |         |
| Verify Charlie's KeyPackages                     |                                       |         |
|----------------------------                      |                                       |         |
|                           |                      |                                       |         |
|<---------------------------                      |                                       |         |
|                                                  |                                       |         |
| Notify group of new member: Charlie              |                                       |         |
|------------------------------------------------->|                                       |         |
|                                                  |                                       |         |
| Encrypted MLS Welcome                            |                                       |         |
|------------------------------------------------->|                                       |         |
|                                                  |                                       |         |
|                                                  | Forward: New group member: Charlie    |         |
|                                                  |-------------------------------------->|         |
|                                                  |                                       |         |
|                                                  | Forward: New group member: Charlie    |         |
|                                                  |------------------------------------------------>|
|                                                  |                                       |         |
|                                                  | Forward encrypted MLS Welcome         |         |
|                                                  |------------------------------------------------>|
|                                                  |                                       |         |
```
Fig. 4: Sequence diagram of a successful encrypted group creation with 3 members.

### 5.4 Multi-device support

Polyphony servers and clients must implement multi-device support, as defined in the MLS specification (RFC9420).
In addition to the MLS specification, Polyphony servers and clients must also implement the X3DH key agreement protocol to securely sync message history. Clients must not use the same keys on multiple devices. Instead, the MLS protocol considers each login on a new device a new client.

TODO: Can two clients safely negotiate keys with each other when the server is hijacked? If not, scrap message history sync.

Regardless of channel or group permissions, a user join request from a new device should be accepted by default.

### 5.5 Best practices

- In case of encrypted guild channel join requests, it may be a good idea to treat multiple join requests from the same user with different clients as a single join request.
- Joining an encrypted channel, even from an already established member with a new device, should be an event clearly visible to all members of the channel. This is to prevent a malicious user from joining a channel without the other members noticing.

## 6. Keys and signatures

All keys must be generated using the `EdDSA` signature scheme.
TODO: Specifics?

### 6.1. KeyPackages

A Polyphony server must store KeyPackages for all users that are registered on the server. The `KeyPackage` is a JSON object that contains the following information:

```json
{
  "protocol_version": "<Version>",
  "cipher_suite": "<CipherSuite>",
  "init_key": "<HPKEPublicKey>",
  "leaf_node": "<LeafNode>",
  "extensions": "<Extensions>",
}
```

- `protocol_version` is the version of the MLS protocol the `KeyPackage` is using.
- `cipher_suite` is the cipher suite that this KeyPackage is using. Note that a client may store multiple KeyPackages for a single user, to support multiple cipher suites.
- `init_key` is a public key that is used to encrypt the group's initial secrets.
- `leaf_node` is a signed `LeafNodeTBS` struct as defined in section `7.2. Leaf Node Contents` in RFC9420. Generally, a `LeafNode` contains information to verify a user's identity. The `LeafNodeTBS` is signed using the user's private signing key.
- `extensions` can be used to add additional information to the protocol, as defined in section `13. Extensibility` in RFC9420.

A `KeyPackage` is supposed to be used only once. Servers must ensure the following things:
-  That any `KeyPackage` is not given out to clients more than once.
-  That the `init_key` values of all `KeyPackages` are unique, as the `init_key` is what makes the `KeyPackage` one-time use.
-  That the contents of the `LeafNode` as well as the `init_key` were signed by the user who submitted the `KeyPackage`.

Because `KeyPackages` are supposed to be used only once, it is recommended that servers store multiple valid `KeyPackages` for each user. A server must notify a client when it is running low on `KeyPackages` for a user. Consult the Client-Server-API for more information on how servers should request new `KeyPackages` from clients. Servers should delete a `KeyPackage` when it is no longer valid.

#### 6.1.1 Last resort KeyPackages

A "last resort" `KeyPackage` is a `KeyPackage` which can be used multiple times. Such `KeyPackages` are only to be given out to clients when a server has no more valid, regular `KeyPackages` available for a user. This is to prevent DoS attacks, where a malicious client could request a large amount of `KeyPackages` for a user, causing other users not being able to adding the attacked user to an encrypted group or guild channel.

Once a server has given out a "last resort" `KeyPackage` to a client, the server should request a new "last resort" `KeyPackage` from the client from the user, once they connect to the server again. The old "last resort" `KeyPackage` should then be deleted.

### 6.2. User identity

Even though section 6.1 defines that a `KeyPackage` should be deleted by the server after it has been given out once, servers must keep track of the identity keys of all users that are registered on the server, and must be able to provide a users' identity key (or keys, in the case of multi-device users) for a given timestamp, when requested. This is to ensure messages sent by users, even ones sent a long time ago, can be verified by other servers and their users. This is because the public key of a user may change over time and users must sign all messages they send to other servers.

