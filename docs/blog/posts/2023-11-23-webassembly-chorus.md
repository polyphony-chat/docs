---
draft: false 
date: 2023-11-23
categories:
  - chorus
  - polyphony
  - updates
authors:
  - bitfl0wer
---

# Porting chorus to WebAssembly + Client Update

What the current state of GUI libraries in Rust means for Polyphony and chorus, and why we are porting chorus to WebAssembly.

<!-- more -->

Hi all!

To make this part of the post short: The web-based client will be worked on *before* the native one, if there even ever will be one. The reason is that no currently available native Rust GUI library meets the standards I'd like to see when using it to build an application I am putting my name behind. I'd like to have
- accessibility
- great styling
- cross compilation
- memory safety

and the current state of Rust GUIs essentially tells me to "pick three", which is unacceptable to me. A WebAssembly based application is the best we'll get for now, and I am fine with that.

Compiling to WebAssembly isn't all that easy though: The `wasm32-unknown-unknown` target intentionally makes no assumptions about the environment it is deployed in, and therefore does not provide things like a `net` or `filesystem` implementation (amongst other things). Luckily, adding support for this compilation target only took me a full 40h work week [:)], and we are now the first Rust Discord-API library (that I know of) to support this target.

You might not have yet heard much about WebAssembly: In the past, web developers could only really use three languages - HTML, CSS, and JavaScript - to write code that browsers could understand directly. With WebAssembly, developers can write code in many other languages, then use WASM to convert it into a form the browser can run.

This is particularly helpful for programs that require a lot of computing power, like video games or design software. Before, running such programs in a browser would be slow or impossible. WebAssembly can make these run smoothly, right in your web browser.

Overall, WebAssembly is expanding the kinds of applications that can be run on the web, making the web a more flexible and powerful place to work and play. Compiling Chorus for WASM allows us to leverage this fairly new technology and bring all of Rusts benefits into a web context.

The next blog post will likely be about progress with the web-based client. See ya until then! :)