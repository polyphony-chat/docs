import "../main.tsp";
import "./models";
import "./routes";

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
    `v0.1.0-alpha.0`,
    `v1.0-beta.1`,
}
