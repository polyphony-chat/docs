---
draft: false 
date: 2024-02-07
categories:
  - polyproto
authors:
  - bitfl0wer
title: Account migration in polyproto
---

Account migration is an important and difficult thing to get right in federated systems. In this blog
post, I will outline how I imagine account migration to work in polyproto, and what benefits this
approach brings.

<!-- more -->

# Account migration in polyproto

It seems that striking a good balance between user experience, convenience and privacy
has been a difficult task for many federated systems, when it comes to account migration.
polyprotos' approach to how data is distributed and stored, and how identities are managed, makes it
possible to have a very smooth and secure account migration process.

## The problem

Using Mastodon as an example;
When a user wants to move from one instance to another, they have to
create a new account on the new instance, and follow all the people they were following on the
old account. All the toots and other data from the old account are left behind, and you do not have a
way of porting them over to the new account. This is a problem that has been around for a long time,
and it is not just a problem with Mastodon, but with many other federated systems as well.

## How polyproto works, briefly

In polyproto, your federation ID, e.g. `xenia@example.com`, is what identifies you. If you want to 
use this identity on a client, your client will generate a key pair for a certificate signing request,
and send this request to your home server. Given that you didn't provide any invalid data, your home
server will sign the certificate, and send it back to you.

Any data you send to anyone - be it a chat message, a social media post, or anything else - is signed
using your private key. This signature can be verified by anyone using your public key, which is part
of the certificate you received from your home server. To check a certificates' validity, you can
ask the home server for its root certificate, and verify the signature on the certificate you received.

This means:

- All the data you send is cryptographically tied to your identity
- Anyone can verify that the data was actually sent by you
- Anyone can verify that the data was not tampered with by anyone else
- Everybody can verify that you are who you say you are

This is even true when you are sending data to a different server than your home server. 

## Migrating an account on polyproto

### Low data centralization

Fundamentally, the process of migrating an account in polyproto relies mostly on changing data ownership,
rather than moving data around. This works best in scenarios where data is highly distributed, and
not stored in a central location.

!!! example

    This might be the case in a social chat messaging system
    similar to Discord, where messages are stored on the servers of the people hosting the chat rooms.

When you want to move your account from one server to another, you:

1. First, create a new account on the new server
2. Then, you configure the new account to back-reference the old account
3. Next, if you are able to, you tell your old home server about the move
4. Last but not least, you verify to the servers storing your data that you are the same person as
  the one who created the old account. The servers then update the data ownership to your new account.
  This is done by using your old private key(s), in a way that does not reveal your private key(s) to
  anyone else. 

If applicable, your friends and followers will also be notified about the move, keeping
existing relationships intact.

!!! note

    This entire process does not rely on the old server being online.
    This means that the process can be completed even if the old server is down, or if the old server
    is not cooperating with the user. 
    
    However, including the homeserver in the process adds to the
    general user experience. If you, for example, have included your federation ID as part of another,
    non-polyproto social media profile, the old server can automatically refer people to the new account.

### Moving data

Should data actually need to be moved, for example when the old server is going to be shut down, or
if the centralization of data is higher, the migration process is extended by a few steps:

1. Using the old account, your client requests a data export from your old home server.
2. The old home server sends you a data export. Your client will check the signatures on the exported
   data, to make sure that the data was not tampered with.
3. You then import the data into your new account on the new home server.
4. 

## Conclusion

polyproto's approach to account migration is very user-friendly, and does not require the user to do
anything that is not already part of the normal usage of the system. The process is also very secure,
as it relies on the cryptographic properties of X.509 certificates, and also works across a highly
distributed data model, which, in my opinion, is how the internet *should* be.

The biggest drawback to this approach is that there are a whole lot of web requests involved. 
Depending on the amount of data, this can take some minutes or possibly even hours.

It is also worth noting that all of this does not require any new or young technology. polyproto
relies on [X.509 certificates](https://en.wikipedia.org/wiki/X.509), which have been around for a 
long time, and are widely used in many different applications. This means that the technology is
well understood, and that there are already many great tools in all sorts of programming languages
available to work with it. From my point of view, there is no need to reinvent the wheel.

I hope that this article has given you a good understanding of how account migration works in polyproto.
If you have any questions or feedback, feel free to reach out to me via E-Mail, where I can
be reached under `flori@polyphony.chat`. OpenPGP is supported, and my public key can be found on
[keys.openpgp.org (click to download pubkey)](https://keys.openpgp.org/vks/v1/by-fingerprint/1AFF5E2D2145C795AB117C2ADCAE4B6877C6FC4E)
