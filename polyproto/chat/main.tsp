import "../main.tsp";

using Http;
using Versioning;
using OpenAPI;

@service(#{ title: "polyproto chat APIs" })
@info(#{
    license: #{
        name: "MIT License",
        url: "https://raw.githubusercontent.com/polyphony-chat/docs/refs/heads/main/LICENSE",
    },
})
@server("https://example.com", "Example endpoint")
@route("/.p2/chat/v1/")
@versioned(Version)
namespace polyproto.chat;

enum Version {
    `v1.0-beta.1`,
}
