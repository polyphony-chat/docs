---
draft: false 
date: 2023-09-02
categories:
  - polyphony
  - updates
authors:
  - bitfl0wer
---

# Getting started with the Polyphony Client

<!-- more -->

Us labeling Chorus to be in a public-alpha state was really great news for me, for a lot of reasons! It marked a point in Polyphonys history where, after all these months of work, we agreed upon the fact that what we *have* is good enough to be shown to the public, and that's always a nice thing when investing so much of your free-time into a project. 
The other main reason why this is such a great thing is, because this alpha state (at least to me) means, that the public API is kind-of stable, or at least stable enough so that I, the project lead, can rely upon the fact that all the public methods will not, in fact, be replaced in 4 days.

This means, that I can finally start working on the Client! And I have done that! For the past 2? 3? Days, I've been tinkering around with Iced-rs (a really, really great UI framework for Rust, written in Rust) and the client repository to create the 'skeleton' of the application. While this is definitely not trivial, especially since I have *no* prior experience in desktop application development, it's also not too hard either.

While Iced is not mature yet, and "how-to" guides, as well as the promised Iced-book, are still largely missing, the maintainers have done a great job with providing a LOT of code examples and solid rustdocs. It's a fun library/framework to work with, and the Elm-inspired approach of dividing up State, Messages, View- and Update-Logic feels really intuitive and seems to make sure that your Application will never end up in an unexpected state.

That's all I have for today. Thanks for reading this! Here's a video of multi-user login already working ^^
 
<video controls width="auto">
    <source src="https://cloud.bitfl0wer.de/index.php/s/Gd556SnwAQYejYw/download/screenrec.mp4"/>
</video>

