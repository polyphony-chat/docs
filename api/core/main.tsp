import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";

using TypeSpec.Http;

@service({
    title: "polyproto"
})
@server("https://example.com", "Example endpoint")
namespace polyproto;