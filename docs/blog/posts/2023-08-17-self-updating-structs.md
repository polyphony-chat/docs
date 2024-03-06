---
draft: false 
date: 2023-08-17
categories:
  - chorus
  - updates
authors:
  - bitfl0wer
---

# Self-updating structs, moving blog posts to GitHub, and more!

Introducing self-updating structs, explaining how they work, and what they are good for. Also, moving blog posts to GitHub, and other improvements.

<!-- more -->

It has been a while since the last update post - 1 month to be precise! I haven't gotten around to writing one of these, mostly because of personal time- and energy constraints. However, now that these resources are finally replenishing again, I figured that it is once again time!

## Moving Blog Posts to GitHub

This is a pretty self-explanatory point. I thought, that opencollective would find more use by me and other polyphony-curious folk, however, this didn't go as planned. Also, opencollective made their Discord embeds really poopy, which is why I am moving all the blog posts over to GitHub.

## A big one: Self-updating structs

Ideally, you want entities like Channels, Guilds, or Users to react to Gateway events. A Gateway event is basically a message from Spacebar/Discord to you, which says: "Hey, User `x` has changed their name to `y`!". If you can reflect those changes immediately within your code, you save yourself from having to make a lot of requests and potentially getting rate-limited.

This is exactly what Self-updating structs set out to solve. The first implementation was done by @SpecificProtagonist and me (thank you a lot again, btw) on the 21st of July. However: This implementation, being in its' infancy, has had some design flaws, which to me made pretty clear, that this whole thing needed to be thought through a little better.

The second iteration of these Self-updating structs was finished... today, actually, by me. It saves memory compared to the first iteration by storing unique objects only once, instead of `n = how many times they are being referenced`-times. While this way of doing things is really efficient, it also has been a pain in the ass to make, which is precisely the reason why this took me so long. I've learned a lot along the way though.

The public API has also gotten a *lot* better in "v2". This is mostly because I am a big believer in writing tests for your code, and through writing what are essentialy real-world-simulation-examples, I noticed how repetitive or stupid some things were, and thus could improve upon them.

Having this whole thing finished is a big relief. This self-updating thing is an essential feature for any Discord/Spacebar compatible library, and I think that we implemented it very nicely.

## Documentation and other improvements

@kozabrada123 took it upon himself to re-write a lot of the codes' Documentation. Thanks for that! This will massively improve the ease of use of this library - both when developing *for* and *with* it. koza also improved our CI/CT pipeline by incorporating build-caching into it, which speeds up builds.

This has been the last month of Polyphony. In the coming weeks, I will be working on
- Implementing self-updating-struct behavior for every struct which needs it
- Fixing bugs
- Adding more features, like emojis, 2FA, Guild Settings, etc.!

See ya next time!