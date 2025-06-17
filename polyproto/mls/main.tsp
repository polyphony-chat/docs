import "./types.tsp";
import "./operations.tsp";
import "../main.tsp";

using Http;
using Versioning;
using OpenAPI;

@service(#{ title: "polyproto mls APIs" })
@info(#{
    license: #{
        name: "MIT License",
        url: "https://raw.githubusercontent.com/polyphony-chat/docs/refs/heads/main/LICENSE",
    },
})
@server("https://example.com", "Example endpoint")
@route("/.p2/mls/v1/")
@versioned(Version)
namespace polyproto.mls;

enum Version {
    `v0.1.0-alpha.3`,
}
