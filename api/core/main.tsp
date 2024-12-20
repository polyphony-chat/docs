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
    /**
     * Custom variant of the X.509 `SubjectPublicKeyInfo`, where the `subject_public_key`
     * field stores the encrypted private key, instead of a public key. Otherwise equal to
     * `SubjectPublicKeyInfo`. Also referred to as `PrivateKeyInfo`.
     */
    key_data: string,
    @doc("The serial number of the ID-Cert this key material is associated with.")
    serial_number: uint64,
    /**
     * Information about the algorithms used to encrypt the data held by the `key_data` field.
     * Order-sensitive; The encryption used for the first encryption operation must be the last
     * item of this array and vice versa.
     */
    @minItems(1)
    encryption_algorithms: Array<Array<uint16>>
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