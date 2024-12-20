import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";

using TypeSpec.Http;

@service({
    title: "polyproto"
})
@server("https://example.com", "Example endpoint")
namespace polyproto;

model EncryptedPKM {
    key_data: string,
    serial_number: string
}

/**
 * A resource representing information about a discoverable service for an actor.
 */
model Service {
    @minLength(2)
    @maxLength(64)
    @doc("The name of the service that is being made discoverable. Must be formatted according to section #8.2: Namespaces in the core protocol specification")
    service: string,
    @doc("The base URL of the service provider, not including '/.p2/<service_name>'. Trailing slashes are allowed. If '(/).p2/<service_name>' is added to the URL specified here, a polyproto client should be able to access the HTTP API routes provided by the service.")
    url: url,
    @doc("Whether the service provider specified in the url field is the primary service provider for this service and actor.")
    primary: boolean
}