# polyproto-core Specification

**v0.0.0** - Treat this as an unfinished draft.

- [polyproto-core Specification](#polyproto-core-specification)
  - [1. APIs and communication protocols](#1-apis-and-communication-protocols)
    - [1.1 Client-Server API](#11-client-server-api)
      - [1.1.1 Initial authentication](#111-initial-authentication)
    - [1.2 Server-Server API](#12-server-server-api)
    - [1.3 WebSockets](#13-websockets)
  - [2. Trust model](#2-trust-model)
  - [3. Federated Identity](#3-federated-identity)
    - [3.1 Federation tokens](#31-federation-tokens)
    - [3.2 Signing keys and message signing](#32-signing-keys-and-message-signing)
    - [3.3 Abuse prevention](#33-abuse-prevention)
    - [3.4 Best practices](#34-best-practices)
      - [3.4.1 Signing keys](#341-signing-keys)
      - [3.4.2 Home server operation and design](#342-home-server-operation-and-design)
  - [4. Federating direct/group messages](#4-federating-directgroup-messages)
    - [4.1 Direct messages](#41-direct-messages)
    - [4.2 Group messages](#42-group-messages)
  - [5. Users](#5-users)
  - [6. Encryption](#6-encryption)
    - [6.1 Encrypted guild channels](#61-encrypted-guild-channels)
    - [6.2 Encrypted direct messages](#62-encrypted-direct-messages)
    - [6.3 Encrypted group messages](#63-encrypted-group-messages)
    - [6.4 Joining new devices from existing users](#64-joining-new-devices-from-existing-users)
    - [6.5 Best practices](#65-best-practices)
  - [7. Keys and signatures](#7-keys-and-signatures)
    - [7.1. KeyPackages](#71-keypackages)
      - [7.1.1 Last resort KeyPackages](#711-last-resort-keypackages)
    - [7.2 User identity](#72-user-identity)
    - [7.3 Multi-device support](#73-multi-device-support)
  - [8. Account migration](#8-account-migration)
    - [8.1 Migrating a user account](#81-migrating-a-user-account)
    - [8.2 Re-signing messages](#82-re-signing-messages)


This document defines a set of protocols and APIs for a chat service primarily focused on communities. The document is intended to be used as a reference for developers who want to implement a client or server for the Polyphony chat service. Uses of this protocol, hereafter referred to as "polyproto", include Instant Messaging, Voice over IP, and Video over IP, where your identity is federated between multiple servers.

The information provided to you via this document only fully covers polyproto itself. To correctly implement the polyproto, you must read the MLS specification (RFC9420). It is imperative that implementations of this protocol respect all aspects of this specification. 

The structure of this reference document is heavily inspired by the really well written [Matrix specification](https://spec.matrix.org/latest).

## 1. APIs and communication protocols

The polyproto-core specification defines a set of APIs that are used to implement polyproto-core. These APIs are:

- Client-Server API
- Server-Server API

Aside from these REST APIs, polyproto-core also uses WebSockets for real-time communication between clients and servers.

### 1.1 Client-Server API

The Client-Server API is a RESTful API that is used by clients to communicate with the server. The Client-Server API of polyproto-core is not to be confused with the Client-Server API of polyproto-chat, which is a separate API that is used by users for chat functionality, whereas the Client-Server API of polyproto-core is used for authentication, federation and other administrative tasks.

#### 1.1.1 Initial authentication

During the initial authentication (registration) process, a client must provide at least one [`KeyPackage`](#61-keypackages), as well as one ["last resort" `KeyPackage`](#611-last-resort-keypackages) in addition to the required registration information.

The identity key inside the `LeafNode` of this `KeyPackage` is signed using the home servers' private key, so that home servers act as a certificate authority for their users' keys.

See [6.1. KeyPackages](#61-keypackages) for an outline on what a `KeyPackage` is, and consult the MLS specification (RFC9420) for more implementation details.

### 1.2 Server-Server API

The Server-Server APIs which are used to enable federation between multiple polyproto servers (federated identity).

### 1.3 WebSockets

WebSockets in polyproto-core are used for real-time communication between clients and servers. WebSockets are only used in a Client-Server context, and not in a Server-Server context.

WebSocket connections to polyproto-core servers consist of the following cycle:

```
    +------------------+       1. Establish Connection        +-----------+
    |      Client      |------------------------------------> |  Gateway  |
    +------------------+                                      +-----------+
                                                              
    +------------------+        2. Receive Hello Event        +-----------+
    |      Client      |<------------------------------------ |  Gateway  |
    +------------------+                                      +-----------+
                                        
                      3. Start Heartbeat Interval (continually)

 +------------------------------------------------------------------------->-+
 |  +------------------+       3.1 Send Heartbeat Event       +-----------+  |
 ^  |      Client      |------------------------------------> |  Gateway  |  |
 |  +------------------+                                      +-----------+  |
 |                                                            |              |
 |  +------------------+    3.2 Receive Heartbeat ACK Event   +-----------+  |
 |  |      Client      |<------------------------------------ |  Gateway  |  v
 |  +------------------+                                      +-----------+  |
 +-<-------------------------------------------------------------------------+

    +------------------+          4. Send Identify            +-----------+
    |      Client      |------------------------------------> |  Gateway  |
    +------------------+                                      +-----------+
                                                              
    +------------------+        5. Receive Ready Event        +-----------+
    |      Client      |<------------------------------------ |  Gateway  |
    +------------------+                                      +-----------+

    +------------------+    6. Disconnect (for any reason)    +-----------+
    |      Client      |<------------------------------------ |  Gateway  |
    +------------------+                                      +-----------+

                          7. Resume connection, if eligible
                           (otherwise: repeat from step 1)

    +------------------+       7.1 Open new connection        +-----------+
    |      Client      |------------------------------------> |  Gateway  |
    +------------------+                                      +-----------+

    +------------------+        7.2 Send Resume Event         +-----------+
    |      Client      |------------------------------------> |  Gateway  |
    +------------------+                                      +-----------+
                                                              
    +------------------+      7.3 Receive Missed Events       +-----------+
    |      Client      |<------------------------------------ |  Gateway  |
    +------------------+                                      +-----------+
                      
    +------------------+      7.4 Receive Resumed Event       +-----------+
    |      Client      |<------------------------------------ |  Gateway  |
    +------------------+                                      +-----------+
```

Fig. 1: Sequence diagram of a WebSocket connection to a polyproto-core server.

To learn more about the Gateway and Gateway Events, consult the [WebSockets API documentation](/docs/APIs/Core/Server-Client%20API/WebSockets/index.md).

## 2. Trust model

polyproto-core operates under the following trust assumptions:

1.  A user trusts their home server and its admins to keep their data safe from unauthorized access, and to not perform actions which a third party would observe to be performed by the user, without the user's consent.
2.  For a user to distrust their home server, something irregular must have happened, or conflicting information must have been presented to the user.
3.  When joining a guild on another server in the context of federation, a user trusts this server and its admins with a copy of their public profile and with all other unencrypted data sent to the server.
4.  Users trust the other members of an encrypted communications channel with the content of their messages, as well as with the metadata attached to the messages.
5.  Non-home servers can not perform actions like sending messages without a foreign users' explicit consent, without immediately being exposed.
6.  A user trusts their home server to be a certificate authority for their identity keys, without the home server owning the identity itself.

## 3. Federated Identity

Federating user identities means that users can fully participate on other instances. This means that users can, for example, DM users from another server or join external Guilds. 

The identity key defined in [6. Keys and signatures](#6-keys-and-signatures) is used to sign messages that the user sends to other servers.

**Example:**
Say that Alice is on server A, and Bob is on server B. Alice wants to send a message to Bob.

Alice's client will send a message to their home server (Server A), asking it to generate a one-time use federation token for registering on server B. Alice takes this token and sends it to server B. Server B will then ask server A if the token is valid. If all goes well, server B will send a newly generated session token back to Alice's client. Alice's client can then authenticate with server B using this token, and send the message to server B. Server B will then send the message to Bob's client.

```
Alice's Client              Server A            Server B              Bob's Client
|                           |                   |                     |
| Federation token request  |                   |                     |
|-------------------------->|                   |                     |
|                           |                   |                     |
|          Federation token |                   |                     |
|<--------------------------|                   |                     |
|                      [Federation handshake start]                   |
|                           |                   |                     |
| Federation token + Public Profile             |                     |
|---------------------------------------------->|                     |
|                           |                   |                     |
|                           |        Get pubkey |                     |
|                           |<------------------|                     |
|                           |                   |                     |
|                           | Server A Pubkey   |                     |
|                           |------------------>|                     |
|                           |                   |                     |
|                           |                   | Verify fedi-token   |
|                           |                   |-------------------  |
|                           |                   |                  |  |
|                           |                   |<------------------  |
|                           |                   |                     |
|                           |     Session Token |                     |
|<----------------------------------------------|                     |
|                           |                   |                     |
|                     [Federation handshake complete]                 |
|                           |                   |                     |
| Session Token + Signed message                |                     |
|---------------------------------------------->|                     |
|                           |                   |                     |
|                           |                   | Signed message      |
|                           |                   |-------------------->|
|                           |                   |                     |
```
Fig. 3: Sequence diagram of a successful federation handshake.

If Alice's session token expires, or if Alice would like to sign in on another device, she can repeat this process of generating a federation token and exchanging it for a session token.

The usage of a federation token prevents a malicious user from generating an external session token on behalf of another user.

### 3.1 Federation tokens

Federation tokens are generated by the user's home server. The token is a JSON object that contains the following information:

- The time at which the token expires.
- The user's federation ID.
- The domain of the server that the token is intended for.
- The domain of the user's home server.
- A securely-randomly generated nonce


### 3.2 Signing keys and message signing

As mentioned in the previous section, users must hold on to a private key at all times. This key is used to sign all messages that the user sends to other instances. The key is generated by the user's home server, and is sent to the user's client when the user first registers on the server. The key is stored in the client's local storage. The signing key must not be used for encryption purposes.

A client may choose to rotate their signing key at any time. This is done by generating a new signing key pair, and sending the new public signing key to their home server. The home server will then send a new certificate that contains the clients' public signing key and the corresponding users' federation ID, to the client. This certificate is proof that the home server attests to the clients key. The client then attaches this certificate to any message it sends to other servers, alongside the actual signature of the message, generated using the clients' private signing key. The home server has to keep track of the old public signing key and its own certificates, and use them to verify messages that were signed with the old key.

Signing messages prevents a malicious server from impersonating a user.

!!! bug "TODO"

    TODO: Note about signing keys and how they are generated and stored locally.

### 3.3 Abuse prevention

To protect users from malicious home servers secretly acting on the behalf of non-consenting users,
a mechanism is needed to prevent home servers from generating federation tokens for users without
their consent.

!!! example "Potential abuse scenario"

    A malicious home server can potentially request a federation token on behalf of one of its
    users, and use it to generate a session token on the user's behalf. This is a problem, as the
    malicious server can then impersonate the user on another server, as well as read unencrypted
    text messages sent on the other server.

The above scenario is not unique to polyproto-core, and rather a problem other federated services/
protocols, like ActivityPub, have as well. There is no real solution to this problem, but it can be
mitigated a bit by making it more difficult for malicious home servers to do something like this
without the user noticing.

Polyproto servers should notify users (even guest users), when a new session token is generated for
them. This would make the malicious server's actions more noticeable to the user. However, this does
not address the issue of the malicious server being able to generate a federation token for a server
which you are not yet connected to. Clients who re-connect to a server after being offline should be
notified of any new session tokens that were generated for them while they were offline.
This `NEW_SESSION` message should be sent to all sessions, except for the new session. The
`NEW_SESSION` gateway event should contain the following information:

```json
{
  "ip": "<IP address of the session>",
  "user_agent": "<User agent of the session>",
  "timestamp": "<Timestamp of when the session was created>",
  "session_pubkey": "<Public key of the session>",
}
```

!!! note

    It is impossible for a malicious server to listen in on securely encrypted messages sent in
    direct messages, encrypted guild channels, and encrypted group messages, without all users
    noticing. MLS's forward secrecy guarantees, that messages sent before a malicious session joins
    the encrypted channel cannot be decrypted by that session. If secrecy/confidentiality are of
    concern, users should host their own home server and use end-to-end encryption.

### 3.4 Best practices

#### 3.4.1 Signing keys

- Instance/user signing keys should be rotated at least every 30 days. This is to ensure that a compromised key can only be used for a limited amount of time.
- If Bobs client fails to verify the signature of Alice's message with the public key/certificate pair received from Server B, it should ask Server A for the public key of Alice at the time the message was sent. If the verification fails again, the message should be treated with extreme caution.

#### 3.4.2 Home server operation and design

- Employ a caching layer to handle the potentially large amount of requests for public key certificates without putting unnecessary strain on the database.

## 4. Federating direct/group messages

### 4.1 Direct messages

Federating direct messages is relatively simple. When Alice sends a message to Bob, her client will send the message to her home server via an API request. Her home server will then send the message to Bob's client via an established WebSocket connection, and vice versa.

### 4.2 Group messages

Group messages work just like guilds. The data is stored by the home server of the group's creator, meaning that all group members will have to communicate with the group creator's home server. If the group creator leaves the group, the ownership of the group is transferred to another member. The group chat stays on the group creator's home server, unless a migration is initiated by the group owner.

## 5. Users

Each client must have a user associated with it. A user is identified by a unique federation ID (FID), which consists of the user's username (which must be unique on the instance) and the instance's root domain. A FID is formatted as follows: `user@domain.tld`, which makes for a globally unique user ID. Federation IDs are case-insensitive.

The following regex can be used to validate user IDs: `\b([A-Z0-9._%+-]+)@([A-Z0-9.-]+\.[A-Z]{2,})\b`.

!!! note

    Validating a federation ID with the above regex does not guarantee that the ID is valid. It only
    guarantees that the federation ID is formatted correctly.

## 6. Encryption

!!! abstract "About MLS"

    Polyproto offers end-to-end encryption for messages via [Message Layer Security (MLS)](https://messaginglayersecurity.rocks/). Polyproto compliant servers take on the role of both an Authentication Service and a Delivery Service in the context of MLS.

    MLS is a cryptographic protocol that provides confidentiality, integrity, and authenticity guarantees for group messaging applications. It builds on top of the [Double Ratchet Algorithm](https://signal.org/docs/specifications/doubleratchet/) and [X3DH](https://signal.org/docs/specifications/x3dh/) to provide these security guarantees.

Clients and servers must support encryption, but whether to encrypt a message channel is up to the users.

Note, that in the below sequence diagrams, the MLS Welcome message and the MLS Group notify message are all encrypted using the public key of the recipient. The public key in this context is not to be confused with the public signing key.

### 6.1 Encrypted guild channels

Encrypting a guild channel is done by a client with the `MANAGE_CHANNEL` permission. Upon successfully requesting enabling encryption of a channel, all future messages in it will be encrypted. Joining an encrypted channel is done by sending a join request to the server. The server will then notify the channels' members of the join request. The members will then decide whether to accept or reject the join request. If the join request is accepted by any member, that member will initiate the MLS welcoming process. If the member finds that the join request is invalid (perhaps due to an invalid `KeyPackage`), the join request must be denied. It is imperative that join requests are verified correctly by the server.

```
     Charlie                                        Server                                            Alice                         Bob
     |                                              |                                                 |                             |
     | Channel join request + KeyPackage            |                                                 |                             |
     |--------------------------------------------->|                                                 |                             |
     |                                              |                                                 |                             |
     |                                              | Notify group of join request                    |                             |
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
Fig. 3: Sequence diagram of a successful encrypted channel join in which Alice acts as a gatekeeper. The sequence diagram assumes that Alice can verify Charlies' public key to indeed belong to Charlie, and that Alice accepts the join request.

### 6.2 Encrypted direct messages

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
Fig. 4: Sequence diagram of a successful encrypted direct message creation. 


### 6.3 Encrypted group messages

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
Fig. 5: Sequence diagram of a successful encrypted group creation with 3 members.

### 6.4 Joining new devices from existing users

Regardless of channel or group permissions, a user join request from a new device should be accepted by default.

### 6.5 Best practices

- In case of encrypted guild channel join requests, it may be a good idea to treat multiple join requests from the same user with different clients as a single join request.
- Joining an encrypted channel, even from an already established member with a new device, should be an event clearly visible to all members of the channel. This is to prevent a malicious user from joining a channel without the other members noticing.

## 7. Keys and signatures

It is recommended that keys are to be generated using the `EdDSA` signature scheme, however, other signature schemes may be used as well.
The MLS protocol used by polyproto-core has a built-in ability to negotiate protocol versions, cipher suites, extensions, credential types, and additional proposal types. For two implementations of polyproto-core to be compatible with each other, they must have overlapping capabilities in these areas.

### 7.1. KeyPackages

!!! warning

    The sections 7.1 and 7.1.1 are not exhaustive and do not cover all aspects of MLS and KeyPackages. They exist solely to give a general overview of how KeyPackages are used in polyproto-core.
    Please read and understand the MLS specification (RFC9420) to implement polyproto-core correctly.

A polyproto-core compliant server must store KeyPackages for all users that are registered on the server. The `KeyPackage` is a JSON object that contains the following information:

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
- `leaf_node` is a signed `LeafNodeTBS` struct as defined in section `7.2. Leaf Node Contents` in RFC9420. A `LeafNode` contains information representing a users' identity, such as the users' **public identity key** for a given session/client. The `LeafNodeTBS` is signed using the user's private signing key.
- `extensions` can be used to add additional information to the protocol, as defined in section `13. Extensibility` in RFC9420.

A `KeyPackage` is supposed to be used only once. Servers must ensure the following things:
-  That any `KeyPackage` is not given out to clients more than once.
-  That the `init_key` values of all `KeyPackages` are unique, as the `init_key` is what makes the `KeyPackage` one-time use.
-  That the contents of the `LeafNode` as well as the `init_key` were signed by the user who submitted the `KeyPackage`.

Because `KeyPackages` are supposed to be used only once, it is recommended that servers store multiple valid `KeyPackages` for each user. A server must notify a client when it is running low on `KeyPackages` for a user. Consult the Client-Server-API for more information on how servers should request new `KeyPackages` from clients. Servers should delete a `KeyPackage` when it is no longer valid.

#### 7.1.1 Last resort KeyPackages

A "last resort" `KeyPackage` is a `KeyPackage` which can be used multiple times. Such `KeyPackages` are only to be given out to clients when a server has no more valid, regular `KeyPackages` available for a user. This is to prevent DoS attacks, where a malicious client could request a large amount of `KeyPackages` for a user, causing other users not being able to adding the attacked user to an encrypted group or guild channel.

Once a server has given out a "last resort" `KeyPackage` to a client, the server should request a new "last resort" `KeyPackage` from the client from the user, once they connect to the server again. The old "last resort" `KeyPackage` should then be deleted.

### 7.2 User identity

Even though section 6.1 defines that a `KeyPackage` should be deleted by the server after it has been given out once, servers must keep track of the identity keys of all users that are registered on the server, and must be able to provide a users' identity key (or keys, in the case of multi-device users) for a given timestamp, when requested. This is to ensure messages sent by users, even ones sent a long time ago, can be verified by other servers and their users. This is because the public key of a user may change over time and users must sign all messages they send to other servers.

Likewise, a client should also keep track of all of its own identity keys, to potentially verify their identity in case of a migration.

### 7.3 Multi-device support

Polyproto servers and clients must implement multi-device support, as defined in the MLS specification (RFC9420).
Clients must not use the same keys on multiple devices. Instead, the MLS protocol assigns a new `LeafNode` to each device.

Each device provides its own `KeyPackages` as well as an own set of unique identity and signature keys. 
Polyproto home servers must guarantee this uniqueness amongst all users of the server.

## 8. Account migration

Account migration allows users to move their account and associated data to another identity.
This allows users to switch home servers while not losing ownership of messages sent by them.

Migrating an account is done with the following steps:

1. The user creates a new account on a new home server.
2. The user requests the migration from the new home server, specifying the old account's
   federation ID.
3. The old user account confirms the migration request by sending a signed message to the new home
   server. The confirmation contains the federation ID of the new account.
4. The new server sends this information to the old server, which then sends the new server all
   information associated with the old account. 
   The old server now forward requests regarding the old account to the new server.
   Alternatively, if the old server is shut down, the new server can request the information
   from the old user directly.
5. The old account can now request the resigning of its messages, transferring ownership of the
   messages to the new account. To have all messages from a server re-signed, a user must
   prove that they are the owner of the private keys used to sign the messages.

### 8.1 Migrating a user account

```
Server_A                               Alice_A                                                Server_B                                            Alice_B 
|                                      |                                                      |                                                   |
|                                      |                                                      |      Migration Request (Signed, Alice_A->Alice_B) |
|                                      |                                                      |<--------------------------------------------------|
|                                      |                                                      |                                                   |
|                                      | Migration Request (Signed, Alice_A->Alice_B)         |                                                   |
|                                      |----------------------------------------------------->|                                                   |
|                                      |                                                      |                                                   |
|       Fetch full profile of Alice_A (Attached: Migration Request, Signed, Alice_A->Alice_B) |                                                   |
|<--------------------------------------------------------------------------------------------|                                                   |
|                                      |                                                      |                                                   |
| Verify Signed Migration Request      |                                                      |                                                   |
|--------------------------------      |                                                      |                                                   |
|                               |      |                                                      |                                                   |
|<-------------------------------      |                                                      |                                                   |
|                                      |                                                      |                                                   |
| Full profile of Alice_A              |                                                      |                                                   |
|-------------------------------------------------------------------------------------------->|                                                   |
|                                      |                                                      |                                                   |
|                                      |                                                      | Verify, replace Alice_B profile with Alice_A      |
|                                      |                                                      |---------------------------------------------      |
|                                      |                                                      |                                            |      |
|                                      |                                                      |<--------------------------------------------      |
|                                      |                                                      |                                                   |
|                                      |                                                      | New account data                                  |
|                                      |                                                      |-------------------------------------------------->|
|                                      |                                                      |                                                   |
| Deactivate Alice_A's account         |                                                      |                                                   |
|-----------------------------         |                                                      |                                                   |
|                            |         |                                                      |                                                   |
|<----------------------------         |                                                      |                                                   |
|                                      |                                                      |                                                   |
| Set up redirect from Alice_A to Alice_B                                                     |                                                   |
|-------------------------------------------------------------------------------------------->|                                                   |
|                                      |                                                      |                                                   |
```
Fig. 6: Sequence diagram depicting a successful migration of Alice_A's account to Alice_B's account, where Server A is reachable and cooperative.

Alternatively, if Server A is offline or deemed uncooperative, the following sequence diagram depicts how the migration can be done without Server A's cooperation:

```
Server_A     Alice_A                                                                          Server_B                                            Alice_B 
|            |                                                                                |                                                   |
|            |                                                                                |      Migration Request (Signed, Alice_A->Alice_B) |
|            |                                                                                |<--------------------------------------------------|
|            |                                                                                |                                                   |
|            | Migration Request (Signed, Alice_A->Alice_B)                                   |                                                   |
|            |------------------------------------------------------------------------------->|                                                   |
|            |                                                                                |                                                   |
|       Fetch full profile of Alice_A (Attached: Migration Request, Signed, Alice_A->Alice_B) |                                                   |
|<--------------------------------------------------------------------------------------------|                                                   |
|            |                                                                                |                                                   |
|            |                                                                                | Wait for response...                              |
|            |                                                                                |---------------------                              |
|            |                                                                                |                    |                              |
|            |                                                                                |<--------------------                              |
|            |                                                                                |                                                   |
|            |                       Server_A offline/not cooperative, send profile or abort? |                                                   |
|            |<-------------------------------------------------------------------------------|                                                   |
|            |                                                                                |                                                   |
|            | Full profile of Self                                                           |                                                   |
|            |------------------------------------------------------------------------------->|                                                   |
|            |                                                                                |                                                   |
|            |                                                                                | Verify, replace Alice_B profile with Alice_A      |
|            |                                                                                |---------------------------------------------      |
|            |                                                                                |                                            |      |
|            |                                                                                |<--------------------------------------------      |
|            |                                                                                |                                                   |
|            |                                                                                | New account data                                  |
|            |                                                                                |-------------------------------------------------->|
|            |                                                                                |                                                   |
```
Fig. 7: Sequence diagram depicting a successful migration of Alice_A's account to Alice_B's account, where Server A is unreachable or uncooperative.

!!! question "If the old home server is not needed for the migration, why try to contact it in the first place?"

    It is generally preferrable to have the old home server cooperate with the migration, as it
    allows for a more seamless migration. A cooperative homeserver will be able to provide the new
    home server with all information associated with the old account. It can also forward requests
    regarding the old account to the new server, which makes the process more seamless for other
    users. The "non-cooperative homeserver migration method" is only a last resort.

### 8.2 Re-signing messages

Re-signing messages is the process of transferring ownership of messages from an old account to the
new, migrated account. The process requires some coordination between the new and old accounts, 
and can only be initiated by the old account. 

To initiate the process, the old account must send an API request to the server where messages
should be re-signed. The request must contain the federation ID of the new account. The server will 
then respond with a list of all keys that were used to sign messages sent by the old account. The
old account will then need to prove that it is in possession of the private keys that were used to
sign the messages. This is done by signing a challenge string with the private keys. The server will
then verify the signature, and, if the verification is successful, grant the new account the ability
to re-sign all messages sent by the old account which were signed with the provided keys.

Re-signing messages mustn't overwrite the old signature. Instead, a new variant of the message must
be created, which contains the new signature.

```
Alice_A                                              Server_C                                                              Alice_B                                                 
|                                                    |                                                                     |                                                     
| Request allow message re-signing for Alice_B       |                                                                     |                                                     
|--------------------------------------------------->|                                                                     |                                                     
|                                                    |                                                                     |                                                     
|          List of keys to verify + challenge string |                                                                     |                                                     
|<---------------------------------------------------|                                                                     |                                                     
|                                                    |                                                                     |                                                     
| Completed challenge for each key on the list       |                                                                     |                                                     
|--------------------------------------------------->|                                                                     |                                                     
|                                                    |                                                                     |                                                     
|                                                    | Verify challenge, unlock re-signing for Alice_B                     |                                                     
|                                                    |------------------------------------------------                     |                                                     
|                                                    |                                               |                     |                                                     
|                                                    |<-----------------------------------------------                     |                                                     
|                                                    |                                                                     |                                                     
|                                                    |                   Request message re-signing for Alice_A's messages |                                                     
|                                                    |<--------------------------------------------------------------------|                                                     
|                                                    |                                                                     |                                                     
|                                                    | List of old messages (including old signatures + certificates)      |                                                     
|                                                    |-------------------------------------------------------------------->|                                                     
|                                                    |                                                                     |                                                     
|                                                    |                                                                     | Verify that Server_C has not tampered with messages 
|                                                    |                                                                     |---------------------------------------------------- 
|                                                    |                                                                     |                                                   | 
|                                                    |                                                                     |<--------------------------------------------------- 
|                                                    |                                                                     |                                                     
|                                                    |                                                                     | Re-sign messages with own keys                      
|                                                    |                                                                     |-------------------------------                      
|                                                    |                                                                     |                              |                      
|                                                    |                                                                     |<------------------------------                      
|                                                    |                                                                     |                                                     
|                                                    |                                                        New messages |                                                     
|                                                    |<--------------------------------------------------------------------|                                                     
|                                                    |                                                                     |                                                     
|                                                    | Verify that only FID and signature related fields have changed      |                                                     
|                                                    |---------------------------------------------------------------      |                                                     
|                                                    |                                                              |      |                                                     
|                                                    |<--------------------------------------------------------------      |                                                     
|                                                    |                                                                     |                                                     
```
Fig. 8: Sequence diagram depicting the re-signing procedure.