import "@typespec/http";
import "@typespec/versioning";
import "@typespec/openapi";
import "@typespec/openapi3";
import "../main.tsp";
import "./main.tsp";

using TypeSpec.Http;
using TypeSpec.Versioning;
using TypeSpec.OpenAPI;
using polyproto;
using Routes;

namespace Routes;

namespace FederatedIdentity {
    @tag("Federated Identity - Registration required")
    @useAuth(BearerAuth)
    namespace Registered {
        @route("/session/idcert")
        @summary("Rotate session ID-Cert")
        @added(Version.`v1.0-alpha.1`)
        @post
        /**
         * Rotate your keys for a given session. The `session_id` in the supplied `csr` must correspond to the
         * session token used in the `authorization`-Header.
         * @param csr A new [certificate signing request (CSR)](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) with the same session ID
         * @returns Contains your new ID-Cert, along with a new session token. 
        */
        op rotateIdCert(@body csr: string;): {
            @doc("Contains your new ID-Cert in PEM encoding, along with a new session token.")
            @statusCode statusCode: 201;
            @body newIdCert: {
                @doc("The generated [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) in PEM format.")
                @example("------BEGIN CERTIFICATE------...")
                id_cert: string,
                @doc("An authorization secret, called a \"token\", valid for this `id_cert`.")
                token: string
            }
        };

        @route("/session/keymaterial")
        @summary("Upload encrypted private key material")
        @added(Version.`v1.0-alpha.1`)
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

        @route("/session/keymaterial")
        @summary("Get encrypted private key material")
        @added(Version.`v1.0-alpha.1`)
        @get
        /**
         * Retrieve encrypted private key material from the server. The `serial_numbers`, if
         * provided, must match the serial numbers of ID-Certs that the client has uploaded key
         * material for. If no `serial_numbers` are provided, the server will return all key
         * material that the client has uploaded.
         */
        op getEncryptedPKM(@query serials?: uint64[]): {
            @statusCode statusCode: 200;
            @body encryptedPKMs: polyproto.core.models.EncryptedPKM[];
        } | {
            @doc("Returned, if no `serial_numbers` are provided and the client has not uploaded any key material.")
            @statusCode statusCode: 204;
        } | {
            @doc("Returned, if none of the `serial_numbers` match any known ID-Certs from this actor.")
            @statusCode statusCode: 404;
        };

        @route("/session/keymaterial")
        @tag("Sensitive Action")
        @summary("Delete encrypted private key material")
        @added(Version.`v1.0-alpha.1`)
        @delete
        /**
         * Delete encrypted private key material from the server. The `serial_number(s)`, must match
         * the serial numbers of ID-Certs that the client has uploaded key material for.
         */
        op deleteEncryptedPKM(
            @doc("Sensitive actions require a [challenge string solution](/docs/Protocol%20Specifications/core.md) to be executed.")
            @header({name: "X-P2-CHALLENGE-STRING-SOLUTION"}) challengeStringSolution: string,
            @query serials: uint64[]): {
            @statusCode statusCode: 204;
        } | {
            @doc("Returned, if none of the `serial_numbers` match any known ID-Certs from this actor.")
            @statusCode statusCode: 404;
        };
        
        @route("/session/keymaterial/size")
        @summary("Get encrypted private key material upload size limit")
        @added(Version.`v1.0-alpha.1`)
        @get
        @useAuth(NoAuth)
        /**
         * Retrieve the maximum upload size for encrypted private key material, in bytes.
         * 
         * @returns The upload size limit, in bytes.
         */
        op encryptedPKMsizeLimit(): {
            @header({name: "X-MAX-PAYLOAD-SIZE"}) size: uint32;
            @statusCode statusCode: 200;
        };
    }

    @tag("Federated Identity - Registration not required")
    namespace Unregistered {
        @route("/challenge")
        @summary("Get challenge string")
        @useAuth(BearerAuth)
        @added(Version.`v1.0-alpha.1`)
        @get
        /**
         * Request a challenge string. See the corresponding
         * [protocol definition chapter](/docs/Protocol%20Specifications/core/#)
         * for more information.
         */
        op challengeString(): {
            @statusCode statusCode: 200;
            @body challengeStringResponse: polyproto.core.models.ChallengeStringResponse
        };

        @route("/key/server")
        @summary("Rotate Server Identity Key")
        @added(Version.`v1.0-alpha.1`)
        @post
        @useAuth(BearerAuth)
        @tag("Sensitive Action")
        /**
         * Rotate the server's identity key. Requires server administrator permissions.
         * @returns The servers' new ID-Cert, encoded as PEM 
         */
        op name(@header({name: "X-P2-CHALLENGE-STRING-SOLUTION"}) challengeStringSolution: string): string;

        @route("/idcert/server")
        @get
        @added(Version.`v1.0-alpha.1`)
        @summary("Get Server ID-Cert")
        /**
         * Request the server's public identity certificate.
         * @returns The current ID-Cert of the server, or, if specified, the ID-Cert the server had
         * at the specified time.
         * @param timestamp An optional UNIX timestamp to retrieve the ID-Cert the server had at that
         * point in time, instead of the current one.
         */
        op serverIdCert(@query timestamp?: uint64): string;

        @route("/key/server")
        @get
        @added(Version.`v1.0-alpha.1`)
        @summary("Get Server Public Key")
        /**
         * Request the server's public key.
         * @returns The current public key of the server, or, if specified, the public key the server had
         * at the specified time. The public key is being returned as a PEM encoded X.509
         * `SubjectPublicKeyInfo`.
         * @param timestamp An optional UNIX timestamp to retrieve the public key the server had at that
         * point in time, instead of the current one.
         */
        op serverKey(@query timestamp?: {
            timestamp: uint64
        }): string;

        @route("/idcert/actor")
        @get
        @added(Version.`v1.0-alpha.1`)
        @summary("Get Actor ID-Cert(s)")
        /**
         * Request the ID-Certs of a specific actor. The specified actor must be registered on this server.
         * @param fid The ID of the actor whose ID-Cert(s) should be returned.
         * @param timestamp An optional UNIX timestamp to retrieve the ID-Cert the actor had at that
         * point in time, instead of the current one.
         * @param session_id Optionally, return only the ID-Certs matching a specific `session_id`.
         * @param body timestamp: UNIX-Timestamp. If specified, the server will return the ID-Cert(s) which the actor had at the specified time. session_id: Request the ID-Cert for a specific session ID.
         * @returns JSON-Array of Object(s), each object containing "id_cert" (PEM encoded ID-Cert) and "invalidated" (boolean). An ID-Cert is considered invalidated, if the server or actor choose to revoke the validity of the ID-Cert before the lifetime of the certificate was scheduled to end.
        */
        op actorCerts(@path fid: string, @query timestamp?: uint64, @query session_id?: string): {
            @statusCode statusCode: 200;
            @body response: {
                @doc("PEM encoded ID-Cert")
                @example("------BEGIN CERTIFICATE------...")
                id_cert: string,
                @example(false)
                @doc("Whether this specific id_cert has been marked as invalidated by the server. An ID-Cert is considered invalidated, if the server or actor choose to revoke the validity of the ID-Cert before the lifetime of the certificate was scheduled to end.")
                invalidated: boolean
            }[]
        };

        @route("/session/idcert/extern")
        @put
        @added(Version.`v1.0-alpha.1`)
        @useAuth(BearerAuth)
        @summary("Update session ID-Cert")
        /**
         * Lets a foreign server know that the ID-Cert of this session has changed.
         */
        op updateSessionCert(@body id_cert: string): {
            @statusCode statusCode: 201;
        };

        @route("/session")
        @delete
        @added(Version.`v1.0-alpha.1`)
        @summary("Delete/Revoke Session")
        @useAuth(BearerAuth)
        /**
         * Invalidate a session token by naming the session ID associated with it.
         */
        op deleteSession(@query session_id: string): {
            @statusCode statusCode: 204;
            @header({name: "Content-Length"}) contentLength: 0;
        } | {
            @statusCode statusCode: 404;
        };
    }
}