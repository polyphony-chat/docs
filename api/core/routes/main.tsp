import "@typespec/http";
import "../main.tsp";

using TypeSpec.Http;
using polyproto;

@service({
    title: "polyproto core APIs"
})
@server("https://example.com", "Example endpoint")

@route("/.p2/core/v1/")
namespace Routes;

@tag("Federated Identity")
namespace FederatedIdentity {
    @tag("Federated Identity")
    @tag("Registration required")
    @useAuth(BearerAuth)
    namespace Registered {
        @route("/session/idcert")
        @summary("Rotate session ID-Cert")
        @post
        /**
         * Rotate your keys for a given session. The `session_id` in the supplied `csr` must correspond to the
         * session token used in the `authorization`-Header.
         * @param csr A new [certificate signing request (CSR)](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) with the same session ID
         */
        op rotateIdCert(@body csr: string;): {
            @doc("Contains your new ID-Cert, along with a new session token.")
            @statusCode statusCode: 201;
            @body newIdCert: {
                @doc("The generated [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) in PEM format.")
                id_cert: string,
                @doc("An authorization secret, called a \"token\", valid for this `id_cert`.")
                token: string
            }
        };

        @route("/session/keymaterial")
        @summary("Upload encrypted private key material")
        @post
        /**
         * Upload encrypted private key material to the server for later retrieval. The size of
         * the individual array elements must not exceed 
         * the server's maximum upload size for this route. This is usually not more than 10kb and can be as 
         * low as 800 bytes, depending on the server configuration.
         * @param pkm Array of encrypted private key material objects.
         */
        op uploadEncryptedPKM(@body @minItems(1) pkm: 
            polyproto.core.models.EncryptedPKM[]): {
            @statusCode statusCode: 201;
        } | {
            @doc("Used, if the `serial_number` does not match any known ID-Cert from this actor.")
            @statusCode statusCode: 404;
        } | {
            @doc("Status code for when the server already has key material for the given `serial_number`. The client would need to delete the existing key material before uploading new key material.")
            @statusCode statusCode: 409;
        } | {
            @doc("Uploaded key material exceeds the server's maximum upload size.")
            @statusCode statusCode: 413;
        };
    }

    @tag("Federated Identity")
    @tag("Registration not required")
    namespace Unregistered {

    }
}