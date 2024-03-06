---
draft: false
date: 2023-08-29
categories:
  - chorus
  - updates
authors:
  - bitfl0wer
---

# chorus Alpha 0.1.0

We are alpha now! As of 2 days ago, the first Alpha of Chorus, Version 0.1.0, has been released for everyone to look at and use on crates.io!

<!-- more -->

So, is the library complete now? No. And yes! It's, well, complicated... Let me explain!

Chorus is at a point where I can comfortably say that, if you take voice-support out of the calculation for a bit, the foundation feels rock-solid, easy to work with and easily expandable. However, to stay with our house/building metaphor for a bit, the walls aren't painted yet, there's barely any furniture and not all of the electrical outlets have been installed yet.

Okay, enough with this bad metaphor; What I meant to convey is, that a lot of the API endpoints have not yet been implemented, and there are at least a few points we haven't addressed yet - like Gateway Error Handling, to name an example.

But for an early Alpha, this, in my opinion, is absolutely acceptable. Implementing API endpoints is something that probably someone who is entirely new to Rust could do, given that we've streamlined the procedure so much, and the other stuff can comfortably be fixed without having to do any major changes to the internals.

I, for one, am currently experimenting around with the Polyphony Client, which, by the way, will likely be written with Iced as a GUI Framework, not GTK. I have no prior experience in GUI/Desktop Application development, but I am feeling more confident than ever and I'm eager to learn all there is to know about these topics.

That's that! Seeya next time.
Cheers,

Flori
