# polyproto-core Specification

**v0.0.0** - Treat this as an unfinished draft.
[Semantic versioning v2.0.0](https://semver.org/spec/v2.0.0.html) is used to version this specification.

- [polyproto-core Specification](#polyproto-core-specification)
  - [1. Terminology used in this document](#1-terminology-used-in-this-document)
  - [2. Trust model](#2-trust-model)
  - [3. APIs and communication protocols](#3-apis-and-communication-protocols)
    - [3.1 Client-Home server API](#31-client-home-server-api)
    - [3.2 Client-foreign server API](#32-client-foreign-server-api)
    - [3.3 WebSockets](#33-websockets)
  - [4. Federated Identity](#4-federated-identity)
    - [4.1 Authentication](#41-authentication)
      - [4.1.1 Registering a new user on a polyproto-core home server](#411-registering-a-new-user-on-a-polyproto-core-home-server)
      - [4.1.2 Authenticating a new client on a polyproto-core home server](#412-authenticating-a-new-client-on-a-polyproto-core-home-server)
      - [4.1.3 Authenticating on a foreign server](#413-authenticating-on-a-foreign-server)
    - [4.2 Challenge Strings](#42-challenge-strings)
    - [4.3 Abuse prevention](#43-abuse-prevention)
  - [5. Users](#5-users)
  - [6. Encryption](#6-encryption)
    - [6.1. KeyPackages](#61-keypackages)
      - [6.1.1 Last resort KeyPackages](#611-last-resort-keypackages)
    - [6.2 Initial authentication](#62-initial-authentication)
    - [6.3 Multi-device support](#63-multi-device-support)
  - [7. Keys and signatures](#7-keys-and-signatures)
    - [7.1 Home server signed certificates for public client identity keys (ID-Cert)](#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert)
      - [7.1.1 Necessity of ID-Certs](#711-necessity-of-id-certs)
    - [7.2 User identity keys and message signing](#72-user-identity-keys-and-message-signing)
      - [7.2.1 Key rotation](#721-key-rotation)
      - [7.2.2 Message verification](#722-message-verification)
    - [7.4 Best practices](#74-best-practices)
      - [7.4.1 Signing keys/ID-Certs](#741-signing-keysid-certs)
      - [7.4.2 Home server operation and design](#742-home-server-operation-and-design)
  - [8. Account migration](#8-account-migration)
    - [8.1 Migrating a user account](#81-migrating-a-user-account)
    - [8.2 Re-signing messages](#82-re-signing-messages)


The polyproto-core protocol is a home-server-based federation protocol specification intended for use in applications where a user identity is needed. polyproto-core focuses on federated identity, and apart from the usage of MLS for encryption, does not specify any application-specific features. It is intended to be used as a base for application implementations and other protocols, such as polyproto-chat, which is a chat protocol built on top of polyproto-core. Any specific polyproto-core user identity can be used for multiple applications, as long as the applications support polyproto-core. 

No part of polyproto-core is considered less important than any other part, and all parts of polyproto-core are required for a polyproto-core implementation to be considered compliant with the polyproto-core specification. The only exception to this is the encryption part of polyproto-core, which is optional, as the necessity of encryption depends on the specific implementation.

This document is intended to be used as a starting point for developers wanting to develop software which can interoperate with other polyproto-core implementations.

## 1. Terminology used in this document

In addition to the terminology found in the glossary located at the end of this document, the following terminology is used throughout this document:

- **Message, Messages**: In the context of this protocol specification, a **message** is any piece of data sent by a client that is intended to be identifiable as being sent by a specific user. To qualify as a "message", this piece of data must also, at any point in time, and also if only briefly, be visible to other users and/or the unauthenticated public. Examples of things that would qualify as messages include:
    - A message sent to another user in a chat application
    - A post on a social media platform
    - A "like" interaction on a social media platform
    - Reaction emojis in Discord-like chat applications
    - Group join/leave messages
    - Reporting a post/user, if the report is not anonymous

Terminology not specified in this section or in the glossary has been defined somewhere else in this document.

## 2. Trust model

polyproto-core operates under the following trust assumptions:

1.  A user trusts their home server and its admins to keep their data safe from unauthorized access, and to not perform actions which a third party would observe to be performed by the user, without the user's consent.
2.  For a user to distrust their home server, something irregular must have happened, or conflicting information must have been presented to the user.
3.  When joining a guild on another server in the context of federation, a user trusts this server and its admins with a copy of their public profile and with all other unencrypted data sent to the server.
4.  Users trust the other members of an MLS encrypted communications channel with their data, as well as with the metadata attached to the data.
5.  Non-home servers cannot execute actions that might seem to be performed by a foreign user without that user's explicit consent; otherwise, they would be immediately exposed.
6.  A user relies on their home server to act as a certificate authority for their identity keys, without the home server possessing the identity itself.

## 3. APIs and communication protocols

The polyproto-core specification defines a set of APIs. These APIs are the Client-Home server and Client-Foreign server APIs.

Aside from these REST APIs, polyproto-core also uses WebSockets for real-time communication between clients and servers.

### 3.1 Client-Home server API

The [*Client-Home server*](./docs/APIs/Core/Client-Home%20Server%20API/index.md) API of polyproto-core is concerned with authentication- and federation-related issues between a client and its' home server.
A client in this context is expected to be a user/bot session.

### 3.2 Client-foreign server API

The [*Client-foreign server*](./docs/APIs/Core/Client-Foreign%20Server%20API/index.md) API of polyproto-core is used for tasks such as requesting the servers' or a users' public key(s) or migrating a user account.
The definition of "client" in this context is broader, since it includes both users/bots and other polyproto-core servers.

### 3.3 WebSockets

WebSockets in polyproto-core are used for real-time communication between user/bot clients and servers. WebSockets are used both in *Client-Home server* and *Client-foreign server* communication.

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

    +------------------+      4. Send Identify payload        +-----------+
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

!!! info

    To learn more about polyproto-core WebSockets and WebSocket Events, consult the [WebSockets documentation](/docs/APIs/Core/WebSockets/index.md).

## 4. Federated Identity

Federating user identities means that users can fully participate on foreign servers, as if it were their home server.
Taking polyproto-chat as an example, this means that a polyproto-chat user can send direct messages to users from another server or join another servers' Guilds. 

An identity certificate defined in sections [#7. Keys and signatures](#7-keys-and-signatures) and [#7.1 Home server signed certificates for public client identity keys (ID-Cert)](#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) is used to sign messages that the user sends to other servers.

!!! note "Using one identity for multiple polyproto-core implementations"

    A user can choose to use the same identity for multiple polyproto-core implementations. If section [4.1.3](#413-authenticating-on-a-foreign-server) is implemented correctly, this should not be a problem. However, if a user wants to use the same identity for multiple polyproto-core implementations, they must ensure that the implementations use the same identity key pair.


!!! info

    You can read more about the Identity Pubkey and Certificate in [7. Keys and signatures](#7-keys-and-signatures).

### 4.1 Authentication

#### 4.1.1 Registering a new user on a polyproto-core home server

Registering a new user in the context of polyproto-core is done through an API route defined in the polyproto-core Client-Home server API documentation.

To register, the client sends a request to the home server, containing the registration information. The server verifies the correctness of the provided information, checks if the username is available and then responds with HTTP status code 201 and the newly created identities' federation ID, given the request was successful. The registration process is now complete, meaning that the new identity has been created. However, at this point, the server does not yet provide a session token, as the user still has to authenticate a client. Adding a new client to newly created identity is described in section [4.1.2](#412-authenticating-a-new-client-on-a-polyproto-core-home-server).

```
Client                                               Server                                                           
|                                              |                                            
| Registration information                     |                                            
|--------------------------------------------->|                                            
|                                              |                                            
|                                              | Verify correctness of provided information,
|                                              | check if username is available, etc. 
|                                              |------------------------------------------- 
|                                              |                                          | 
|                                              |<------------------------------------------ 
|                                              | -------------------------                  
|                                              |-| Verified successfully |                  
|                                              | -------------------------                                                           
|                                              |                                            
|                                              | Verify provided CSR                        
|                                              |--------------------                        
|                                              |                   |                        
|                                              |<-------------------                        
|                                              | ------------                               
|                                              |-| CSR okay |                               
|                                              | ------------                               
|                                              |                                            
|                                              | Signing CSR                                
|                                              |------------                                
|                                              |           |                                
|                                              |<-----------                                
|                                              |                                            
|    HTTP Status Code 201 + user federation ID |                                            
|<---------------------------------------------|                                            
|                                              |                                            
```
Fig. 2: Sequence diagram of a successful identity creation process.

#### 4.1.2 Authenticating a new client on a polyproto-core home server

Whenever a user would like to access their account from a new device, they must authenticate the new session with their home server. This is done by sending the home server a request containing their authentication information, such as their username and password, and a [certificate signing request (CSR)](#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) for the new client. The server verifies the correctness of the provided information and, given that the verification succeeds, signs the CSR and responds with the newly generated ID-Cert, along with a session token.

```
Client                                               Server                                                           
|                                                    |                                            
| Auth information, CSR                              |                                            
|--------------------------------------------------->|                                            
|                                                    |                                            
|                                                    | Verify correctness of provided auth
|                                                    | information
|                                                    |------------------------------------------- 
|                                                    |                                          | 
|                                                    |<------------------------------------------ 
|                                                    | -------------------------                  
|                                                    |-| Verified successfully |                  
|                                                    | -------------------------                                                           
|                                                    |                                            
|                                                    | Verify provided CSR                        
|                                                    |--------------------                        
|                                                    |                   |                        
|                                                    |<-------------------                        
|                                                    | ------------                               
|                                                    |-| CSR okay |                               
|                                                    | ------------                               
|                                                    |                                            
|                                                    | Signing CSR                                
|                                                    |------------                                
|                                                    |           |                                
|                                                    |<-----------                                
|                                                    |                                            
|      HTTP Status Code 201, ID-Cert + Session token |                                            
|<---------------------------------------------------|                                            
|                                                    |                                            
```
Fig. 3: Sequence diagram of a successful client authentication process.

The client is now authenticated and can use the session token and ID-Cert to perform actions on behalf of the user identified by the ID-Cert.

#### 4.1.3 Authenticating on a foreign server

Authenticating on a foreign server is similar to authenticating on a home server, with the difference being that the user must sign a challenge string with their private identity key, and send the signature to the foreign server, along with their ID-Cert. The foreign server must then verify the following to be true:

- The ID-Cert is valid and signed by the home server that the user claims to be from.
- The signature of the challenge string is valid and signed by the user's private identity key.
- The ID-Cert is not expired.

If the verification is successful, the foreign server can issue a session token to the user.

**Example:**
Say that Alice is on server A, and would like to authenticate on Server B using her existing identity.

Alice's client will send a request to server B, requesting a challenge string. After receiving the challenge string, Alice signs this string with their ID-Cert and sends the signature and her ID-Cert to Server B. Server B can now verify, that it was actually Alice who signed the string, and not a malicious outsider. If all goes well, server B will send a newly generated session token back to Alice's client. Alice's client can then authenticate with server B using this token.

```
Alice's Client                                  Server A              Server B
|                                               |                     |
| Challenge string request                      |                     |
|---------------------------------------------->|                     |
|                                               |                     |
|                              Challenge string |                     |
|<----------------------------------------------|                     |
|                                               |                     |        
|                                               |                     |
| Signed challenge, ID-Cert, Optional payload   |                     |
|-------------------------------------------------------------------->|
|                                               |                     |
|                                               |          Get pubkey |
|                                               |<--------------------|
|                                               |                     |
|                                               | Server A Pubkey     |
|                                               |-------------------->|
|                                               |                     |
|                                               |                     |
|                                               |                     |
|                                               |                     |
|                                               |                     |
|                                               |                     |
|                                               |       Session Token |
|<--------------------------------------------------------------------|
|                                               |                     |

```
Fig. 4: Sequence diagram of a successful identity verification.

The "optional payload" in the above diagram is optional, additional data a server may request from a user. This is most useful in the context of using the same identity for different, polyproto-core based services, as one service might require additional information about a user, which another service does not need. The payload is signed by the user's private identity key. 

!!! example

    Alice currently has a polyproto-core identity, which she created when signing up for "https://example.com/chat". When signing up for this service, she didn't need to provide any additional information on registration. However, when she wants to sign up for "https://example.com/social", she is asked to provide her email address, which she can provide as the "optional payload". The server can then store the email address in its' database, associate it with Alice's identity, and let Alice log in with her existing identity. 

If Alice's session token expires, she can repeat this process of requesting a challenge string and, together with her ID-Cert, exchange it for a session token.
However, if Alice wants to access this third party account from a completely new device, they will have to perform the steps described in section [4.1.2](#412-authenticating-a-new-client-on-a-polyproto-core-home-server) to obtain a valid ID-Cert for that session.

### 4.2 Challenge Strings

Challenge strings are generated by servers. They are a random, unique string of alphanumeric characters, which is used to verify that the user is in possession of their private identity key. The length of a challenge string must be greater than or equal to 32 characters, and shall not be greater than 256 characters. Challenge strings must have a lifetime, which is specified as a UNIX timestamp. The challenge must automatically count as failed, if the current (now) UNIX timestamp is greater than the specified lifetime.  The lifetime must always be indicated. The string is signed by the user's private identity key, and the signature is sent to the server, along with the user's ID-Cert. By verifying the signature of the challenge string with the user's ID-Cert, the server can verify that the user is in possession of their private identity key, and is who they claim to be.

The usage of challenge strings prevents replay attacks, as the challenge string is unique, meaning that it is different even for two identical requests. This means that a malicious server cannot simply replay a request to another server, as the signature of the challenge string would be different.


### 4.3 Abuse prevention

To protect users from malicious home servers secretly acting on the behalf of non-consenting users,
a mechanism is needed to prevent home servers from generating federation tokens for users without
their consent.

!!! example "Potential abuse scenario"

    A malicious home server can potentially request a federation token on behalf of one of its
    users, and use it to generate a session token on the user's behalf. This is a problem, as the
    malicious server can then impersonate the user on another server, as well as read unencrypted
    data (such as messages, in the context of a chat application) sent on the other server.

!!! abstract

    The above scenario is not unique to polyproto-core, and rather a problem other federated services/
    protocols, like ActivityPub, have as well. There is no real solution to this problem, but it can be
    mitigated a bit by making it more difficult for malicious home servers to do something like this
    without the user noticing.

Polyproto servers must notify users, when a new session token is generated for
them. This would make the malicious home server's actions more noticeable to the user. However, this does
not address the issue of the malicious home server being able to generate a federation token for a server
which you are not yet connected to, as the user would have no way to receive the notification of a 
session token being created for them, if they are not connected to that server. Clients
re-connecting to a server after being offline must be notified of any new session tokens that were
generated for them while they were offline. This `NEW_SESSION` gateway event must be sent to all
sessions, except for the new session. The information stored in a `NEW_SESSION` event can be found
in the [Gateway Events documentation](/docs/APIs/Core/WebSockets/gateway_events.md#new_session).

!!! note

    With proper safety precautions and strong encryption, it is extremely unlikely for a malicious
    server to be able to listen in on encrypted conversations, without all users in that 
    conversation noticing. MLS's forward secrecy guarantees ensure that, in theory, a malicious
    session cannot decrypt any messages sent before its' join epoch. If secrecy or confidentiality
    are of concern, users should host their own home server and use end-to-end encryption.

## 5. Users

Each client must have a user identity associated with it. A user is identified by a unique federation ID (FID), which consists of the user's username (which must be unique on the instance) and the instance's root domain. A FID is formatted as follows: `user@optionalsubdomain.domain.tld`, which makes for a globally unique user ID. Federation IDs are case-insensitive.

The following regex can be used to validate user IDs: `\b([A-Z0-9._%+-]+)@([A-Z0-9.-]+\.[A-Z]{2,})\b`.

!!! note

    Validating a federation ID with the above regex does not guarantee that the ID is valid. It only
    indicates that the federation ID is formatted correctly.

## 6. Encryption

!!! abstract "About MLS"

    Polyproto offers end-to-end encryption for messages via [Message Layer Security (MLS)](https://messaginglayersecurity.rocks/). polyproto-core compliant servers take on the role of both an Authentication Service and a Delivery Service in the context of MLS.

    MLS is a cryptographic protocol that provides confidentiality, integrity, and authenticity guarantees for group messaging applications. It builds on top of the [Double Ratchet Algorithm](https://signal.org/docs/specifications/doubleratchet/) and [X3DH](https://signal.org/docs/specifications/x3dh/) to provide these security guarantees.

Implementations of polyproto-core may opt to support encryption to secure communication channels. The selected security protocol for all polyproto-core implementations is the Messaging Layer Security protocol, provided that MLS can feasibly be integrated within the context of the given implementation. The MLS protocol has a built-in ability to negotiate protocol versions, cipher suites, extensions, credential types, and additional proposal types. For two implementations of polyproto-core to be compatible with each other in the context of encryption, they must have overlapping capabilities in these areas.

The following sections explain the additional behavior that polyproto-core implementations utilizing MLS must implement.

### 6.1. KeyPackages

!!! warning

    The sections 6.1 and 6.1.1 are not exhaustive and do not cover all aspects of MLS and KeyPackages. They exist solely to give a general overview of how KeyPackages are used in polyproto-core.
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
- `leaf_node` is a signed `LeafNodeTBS` struct as defined in section `7.2. Leaf Node Contents` in RFC9420. A `LeafNode` contains information representing a users' identity, in the form of the users' **ID-Cert** for a given session/client. The `LeafNodeTBS` is signed using the user's private identity key.
- `extensions` can be used to add additional information to the protocol, as defined in section `13. Extensibility` in RFC9420.

A `KeyPackage` is supposed to be used only once. Servers must ensure the following things:
-  That any `KeyPackage` is not given out to clients more than once.
-  That the `init_key` values of all `KeyPackages` are unique, as the `init_key` is what makes the `KeyPackage` one-time use.
-  That the contents of the `LeafNode` as well as the `init_key` were signed by the user who submitted the `KeyPackage`.

Because `KeyPackages` are supposed to be used only once, it is recommended that servers store multiple valid `KeyPackages` for each user. A server must notify a client when it is running low on `KeyPackages` for a user. Consult the Client-Server-API for more information on how servers should request new `KeyPackages` from clients. Servers should delete a `KeyPackage` when it is no longer valid.

Servers only store `KeyPackages` for home server users, i.e. not for foreign users.

!!! note "About keys"

    It is recommended that keys are to be generated using the `EdDSA` signature scheme, however, other signature schemes may be used as well.

#### 6.1.1 Last resort KeyPackages

A "last resort" `KeyPackage` is a `KeyPackage` which can be used multiple times. Such `KeyPackages` are only to be given out to clients when a server has no more valid, regular `KeyPackages` available for a user. This is to prevent DoS attacks, where a malicious client could request a large amount of `KeyPackages` for a user, causing other users not being able to adding the attacked user to an encrypted group or guild channel.

Once a server has given out a "last resort" `KeyPackage` to a client, the server should request a new "last resort" `KeyPackage` from the client from the user, once they connect to the server again. The old "last resort" `KeyPackage` should then be deleted.

### 6.2 Initial authentication

During the initial authentication process, a client must provide at least one [`KeyPackage`](#61-keypackages), as well as one ["last resort" `KeyPackage`](#611-last-resort-keypackages) to the server, in addition to the required registration information.

The public identity key inside the `LeafNode` of this `KeyPackage` is signed using the home servers' private key, so that home servers act as a certificate authority for their users' keys.

### 6.3 Multi-device support

polyproto-core servers and clients using encryption should implement multi-device support, as defined in the MLS specification (RFC9420).
Clients must not use the same keys on multiple devices. Instead, the MLS protocol assigns a new `LeafNode` to each device.

Each device provides its own `KeyPackages` as well as an own identity key. 

## 7. Keys and signatures

### 7.1 Home server signed certificates for public client identity keys (ID-Cert)

The home server signed public client identity key certificate, ID-Cert for short, is a public key certificate used to prove the validity of a public identity key. The ID-Cert is a user generated public identity key certificate signing request (CSR), signed by a user's home server, and includes information about the user's identity, as well as the public identity key of the user. Clients can receive an ID-Cert in exchange for a CSR.

A CSR includes the following information:

- The public identity key of the client.
- The federation ID of the user associated with the client.
- The session ID of the client. The session ID is a unique identifier for a session, which does not change when a client rotates their identity keys.
- Optionally, an expiry date for the certificate. This expiry date must be less than or equal to the expiry date of the home servers' public identity key certificate.

The resulting ID-Cert contains the following information, in addition to the information supplied through the CSR:

- Issuer information: The home servers' domain.
- Serial number: A unique identifier for the certificate.
- Signature algorithm: The algorithm used to sign the certificate.
- Signature: The signature of the certificate, generated using the home servers' private identity key.
- Expiry date: The expiry date of the certificate.

!!! info 

    See [7.2.1](#721-key-rotation) for more information on what an "associated client" is.

#### 7.1.1 Necessity of ID-Certs

The addition of a certificate may seem ubiquitous, but it is necessary to prevent a malicious foreign server from abusing public identity key caching to impersonate a user. Consider the following example which employs foreign server public identity key caching, but no home server issued identity key certificates:

!!! example "Potential abuse scenario"

    A malicious foreign server B can fake a message from Alice (Home server: Server A) to Bob (Home Server: Server B), by generating a new identity key pair and using it to sign the malicious message. The foreign server then sends that message to Bob, who will then request Alice's public identity key from Server B, who will then send Bob the malicious public identity key. Bob will succeed in verifying the signature of the message, and not notice that the message is malicious.

The above scenario is not possible with home server issued identity key certificates, as the malicious server cannot generate an identity key pair for Alice which is signed by Server A.

Should the expected lifetime of a servers' identity key come to an early end, perhaps due to being leaked and therefore needing to be rotated, the server should generate a new identity key pair + ID-Cert and send a [`SERVER_KEY_CHANGE`](/docs/APIs/Core/WebSockets/gateway_events.md#server_key_change) gateway event, as well as a [`LOW_KEY_PACKAGES`](/docs/APIs/Core/WebSockets/gateway_events.md#low_key_packages) event to all clients. The clients should then also re-generate their identity keys and request a new ID-Cert from the server (via sending a CSR), as well as respond to the [`LOW_KEY_PACKAGES`](/docs/APIs/Core/WebSockets/gateway_events.md#low_key_packages) event correctly.

!!! note

    A `LOW_KEY_PACKAGES` event is only sent by servers which use MLS encryption. Server/Clients not using MLS encryption can safely ignore this event.

### 7.2 User identity keys and message signing

As briefly mentioned section [#4](#4-federated-identity), users must hold on to an identity key pair at all times. This key pair is used to represent a user's identity and to verify message integrity, by having a user sign all messages they send with their private identity key. The key pair is generated by the user, and a user-generated identity key certificate signing request (CSR) is sent to the user's home server when first connecting to the server with a new client, or when rotating keys. The key is stored in the client's local storage. Upon receiving a new identity key CSR, a home server will sign this CSR and send the resulting public key certificate to the client. This certificate is proof that the home server attests to the clients key. Read section [7.3](#73-home-server-generated-certificates-for-public-client-identity-keys-id-cert) for more information on the certificate.

#### 7.2.1 Key rotation

A client may choose to rotate their identity key at any time. This is done by generating a new identity key pair, and sending the new public identity key to their home server, as part of a new Certificate Signing Request, at least one new `KeyPackage` and one corresponding 'last resort' `KeyPackage`. The home server will then generate the new ID-Cert, send it to the client, and let all associated clients know, that this clients' public identity key has changed. The server does this by sending a [`CLIENT_KEY_CHANGE`](/docs/APIs/Core/WebSockets/gateway_events.md#client_key_change) gateway event to those clients. For example, in the context of a chat application built with polyproto-chat, an associating relationship between two clients exists, if the two clients share a guild, a group or a direct message channel, if they are friends, or if they have a pending friend request between each other.

Before sending any messages to a server, a client that performed a key rotation should inform the server of that change, to ensure that the server has the correct ID-Cert cached for the client.

Home servers must keep track of the ID-Certs of all users (and their clients) registered on them, and must be able to provide a clients' ID-Cert for a given timestamp on request. This is to ensure messages sent by users, even ones sent a long time ago, can be verified by other servers and their users. This is because the public key of a user may change over time and users must sign all messages they send to servers. Likewise, a client should also keep all of its own ID-Certs stored perpetually, to potentially verify its identity in case of a migration.

```
                                                 Server                                                Client                           
                                                 |                                                     |                                 
                                                 |                                                     | Create CSR for own identity key 
                                                 |                                                     |-------------------------------- 
                                                 |                                                     |                               | 
                                                 |                                                     |<------------------------------- 
                                                 |                                                     |                                 
                                                 |      Request key rotation/CSR signing, CSR attached |                                 
                                                 |<----------------------------------------------------|                                 
                                                 |                                                     |                                 
                                                 | Verify validity of claims presented in the CSR      |                                 
                                                 |-----------------------------------------------      |                                 
                                                 |                                              |      |                                 
                                                 |<----------------------------------------------      |                                 
                                                 |                                                     |                                 
                                                 | Create ID-Cert for Client                           |                                 
                                                 |--------------------------                           |                                 
                                                 |                         |                           |                                 
                                                 |<-------------------------                           |                                 
                                                 |                                                     |                                 
                                                 | Respond with ID-Cert                                |                                 
                                                 |---------------------------------------------------->|                                 
------------------------------------------------ |                                                     |                                 
| Send CLIENT_KEY_CHANGE to associated clients |-|                                                     |                                 
------------------------------------------------ |                                                     |                                 
                                                 |                                                     |                                 
```
Fig. 5: Sequence diagram depicting the process of a client using a CSR to request a new ID-Cert from their home server.

#### 7.2.2 Message verification

Of course, in order for message signing to actually verify message integrity, clients **must** verify the signatures of all messages they receive. This is done by verifying the signature of the message with the ID-Cert of the sender and the ID-Cert of the senders' home server. Clients must also verify that the certificate attached to the message is valid and that the public key in the certificate matches the public key of the sender. 

**Example:** Given a signed message from Alice, like Bob would receive it from Server B in [Fig. 3](#fig-3), Bob's client would verify the signature of the message like so:

```
Server B                                        Bob                                         Server A
|                                               |                                           |
| Alice's signed message                        |                                           |
|---------------------------------------------->|                                           |
|                                               |                                           |
|                       Request Alice's ID-Cert |                                           |
|<----------------------------------------------|                                           |
|                                               |                                           |
| Alice's ID-Cert                               |                                           |
|---------------------------------------------->|                                           |
|                                               |                                           |
|                                               | Request Server A ID-Cert                  |
|                                               |------------------------------------------>|
|                                               |                                           |
|                                               |                          Server A ID-Cert |
|                                               |<------------------------------------------|
|                                               |                                           |
|                                               | Verify signature of Alice's message       |
|                                               |------------------------------------       |
|                                               |                                   |       |
|                                               |<-----------------------------------       |
|                                               |                                           |
```
Fig. 6: Sequence diagram of a successful message signature verification.

Bob's client may now choose to cache Server A's public identity key and Alice's ID-Cert, so that it does not have to request them again in the future, as long as the ID-Cert/Server public key do not change and are not expired. If Bob's client receives another message from Alice, it can now verify the signature of the message with the cached ID-Certs.

If the verification fails, Bob's client should try to re-request the key from Server B first. Should the verification fail again, Bob's client may try to request Alice's public identity key and certificate from Server A (Alice's home server), and try to verify the signature again. Should the verification still not succeed, the message should be treated with extreme caution.

!!! question "Why does Bob's client not request Alice's public identity key from Server A?"

    Bob's client could request Alice's public identity key from Server A, instead of Server B. However, this is discouraged, as it

    - Generates unnecessary load on Server A; Doing it this way distributes the load of public identity key more fairly, as the server that the message was sent on is the one that has to process the public identity key request.
    - Would expose unnecessary metadata to Server A; Server A does not need to know who exactly Alice is talking to, and when. Only Server B, Alice and Bob need to know this information. Always requesting the public identity key from Server A might expose this information to Server A.

    Clients should only use Server A as a fallback for public identity key verification, if Server B does not respond to the request for Alice's public identity key, or if the verification fails with the public identity key from Server B.

!!! info

    A failed signature verification does not always mean that the message is invalid. It may be that the user's identity key has changed, and that Server B has not yet received the new public identity key for some reason.

### 7.4 Best practices

#### 7.4.1 Signing keys/ID-Certs

- Instance/user signing keys should be rotated regularly (every 3-6 months). This is to ensure that a compromised key can only be used for a limited amount of time.
- When a server is asked to generate a new ID-Cert for a user, it must make sure that the CSR is valid and, if set, has an expiry date which is less than or equal to the expiry date of the server's own ID-Cert.
- Due to the fact that a `SERVER_KEY_CHANGE` gateway event is bound to generate a lot of traffic, servers should only manually generate a new identity key pair when absolutely necessary and instead choose a fitting expiry date interval for their identity key certificates. It might also be a good idea to stagger the sending of `SERVER_KEY_CHANGE` gateway events, to prevent a server from initiating a DDoS attack on itself.
- When a client or server receives the information that a user clients' identity key has been changed, the client/server in question should update their cached ID-Cert for the user in question, taking into account the session ID of the new identity key pair.

#### 7.4.2 Home server operation and design

- Employ a caching layer for your home server to handle the potentially large amount of requests for public key certificates without putting unnecessary strain on the database.

## 8. Account migration

Account migration allows users to move their account and associated data to another identity.
This allows users to switch home servers while not losing ownership of messages sent by them.

Migrating an account is done with the following steps:

1. The user creates a new account on a new home server.
2. The user requests the migration from the new home server, specifying the old account's
   federation ID.
3. The old user account confirms the migration request by sending a signed API request to the new home
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
Server A                               Alice A                                                Server B                                            Alice B 
|                                      |                                                      |                                                   |
|                                      |                                                      |      Migration Request (Signed, Alice A->Alice B) |
|                                      |                                                      |<--------------------------------------------------|
|                                      |                                                      |                                                   |
|                                      | Migration Request (Signed, Alice A->Alice B)         |                                                   |
|                                      |----------------------------------------------------->|                                                   |
|                                      |                                                      |                                                   |
|       Fetch full profile of Alice A (Attached: Migration Request, Signed, Alice A->Alice B) |                                                   |
|<--------------------------------------------------------------------------------------------|                                                   |
|                                      |                                                      |                                                   |
| Verify Signed Migration Request      |                                                      |                                                   |
|--------------------------------      |                                                      |                                                   |
|                               |      |                                                      |                                                   |
|<-------------------------------      |                                                      |                                                   |
|                                      |                                                      |                                                   |
| Full profile of Alice A              |                                                      |                                                   |
|-------------------------------------------------------------------------------------------->|                                                   |
|                                      |                                                      |                                                   |
|                                      |                                                      | Verify, replace Alice B profile with Alice A      |
|                                      |                                                      |---------------------------------------------      |
|                                      |                                                      |                                            |      |
|                                      |                                                      |<--------------------------------------------      |
|                                      |                                                      |                                                   |
|                                      |                                                      | New account data                                  |
|                                      |                                                      |-------------------------------------------------->|
|                                      |                                                      |                                                   |
| Deactivate Alice A's account         |                                                      |                                                   |
|-----------------------------         |                                                      |                                                   |
|                            |         |                                                      |                                                   |
|<----------------------------         |                                                      |                                                   |
|                                      |                                                      |                                                   |
| Set up redirect from Alice A to Alice B                                                     |                                                   |
|-------------------------------------------------------------------------------------------->|                                                   |
|                                      |                                                      |                                                   |
```
Fig. 7: Sequence diagram depicting a successful migration of Alice A's account to Alice B's account, where Server A is reachable and cooperative.

Alternatively, if Server A is offline or deemed uncooperative, the following sequence diagram depicts how the migration can be done without Server A's cooperation:

```
Server A     Alice A                                                                          Server B                                            Alice B 
|            |                                                                                |                                                   |
|            |                                                                                |      Migration Request (Signed, Alice A->Alice B) |
|            |                                                                                |<--------------------------------------------------|
|            |                                                                                |                                                   |
|            | Migration Request (Signed, Alice A->Alice B)                                   |                                                   |
|            |------------------------------------------------------------------------------->|                                                   |
|            |                                                                                |                                                   |
|       Fetch full profile of Alice A (Attached: Migration Request, Signed, Alice A->Alice B) |                                                   |
|<--------------------------------------------------------------------------------------------|                                                   |
|            |                                                                                |                                                   |
|            |                                                                                | Wait for response...                              |
|            |                                                                                |---------------------                              |
|            |                                                                                |                    |                              |
|            |                                                                                |<--------------------                              |
|            |                                                                                |                                                   |
|            |                       Server A offline/not cooperative, send profile or abort? |                                                   |
|            |<-------------------------------------------------------------------------------|                                                   |
|            |                                                                                |                                                   |
|            | Full profile of Self                                                           |                                                   |
|            |------------------------------------------------------------------------------->|                                                   |
|            |                                                                                |                                                   |
|            |                                                                                | Verify, replace Alice B profile with Alice A      |
|            |                                                                                |---------------------------------------------      |
|            |                                                                                |                                            |      |
|            |                                                                                |<--------------------------------------------      |
|            |                                                                                |                                                   |
|            |                                                                                | New account data                                  |
|            |                                                                                |-------------------------------------------------->|
|            |                                                                                |                                                   |
```
Fig. 8: Sequence diagram depicting a successful migration of Alice A's account to Alice B's account, where Server A is unreachable or uncooperative.

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
Alice A                                              Server C                                                              Alice B                                                 
|                                                    |                                                                     |                                                     
| Request allow message re-signing for Alice B       |                                                                     |                                                     
|--------------------------------------------------->|                                                                     |                                                     
|                                                    |                                                                     |                                                     
|          List of keys to verify + challenge string |                                                                     |                                                     
|<---------------------------------------------------|                                                                     |                                                     
|                                                    |                                                                     |                                                     
| Completed challenge for each key on the list       |                                                                     |                                                     
|--------------------------------------------------->|                                                                     |                                                     
|                                                    |                                                                     |                                                     
|                                                    | Verify challenge, unlock re-signing for Alice B                     |                                                     
|                                                    |------------------------------------------------                     |                                                     
|                                                    |                                               |                     |                                                     
|                                                    |<-----------------------------------------------                     |                                                     
|                                                    |                                                                     |                                                     
|                                                    |                   Request message re-signing for Alice A's messages |                                                     
|                                                    |<--------------------------------------------------------------------|                                                     
|                                                    |                                                                     |                                                     
|                                                    | List of old messages (including old signatures + certificates)      |                                                     
|                                                    |-------------------------------------------------------------------->|                                                     
|                                                    |                                                                     |                                                     
|                                                    |                                                                     | Verify that Server C has not tampered with messages 
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
Fig. 9: Sequence diagram depicting the re-signing procedure.