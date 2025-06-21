import "@typespec/http";
import "@typespec/versioning";
import "@typespec/openapi";
import "@typespec/openapi3";
import "../main.tsp";
import "./federated_identity.tsp";
import "./migration.tsp";
import "./services.tsp";
import "./rawr.tsp";

using TypeSpec.Http;
using TypeSpec.Versioning;
using TypeSpec.OpenAPI;

@service(#{ title: "polyproto core APIs" })
@info(#{
    license: #{
        name: "MIT License",
        url: "https://raw.githubusercontent.com/polyphony-chat/docs/refs/heads/main/LICENSE",
    },
})
@server("https://example.com", "Example endpoint")
@route("/.p2/core/v1/")
@versioned(Version)
namespace polyproto.core;

enum Version {
    `v1.0-beta.3`,
}
