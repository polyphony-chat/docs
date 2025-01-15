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

        @route("/idcert")
        @summary("Get a new ID-Cert")
        @added(Version.`v1.0-alpha.1`)
        @post
        @tag("Sensitive Actions")
        /**
         * Request a new ID-Cert, usually done when wanting to authenticate a new session, or after
         * an ID-Cert has been revoked, to re-authenticate a session.
         */
        op newIdCert(
            @doc("Sensitive actions require a second factor of authentication to be executed. Read [section 4.1.2 of the protocol definition](https://docs.polyphony.chat/Protocol%20Specifications/core/#412-sensitive-actions) for more information.")
            @header({name: "X-P2-Sensitive-Solution"}) sensitiveSolution: string,
            @body csr: string;
            ): {
                @doc("Contains your new ID-Cert in PEM encoding, along with a new session token.")
                @statusCode statusCode: 201;
                @body newIdCert: {
                    @doc("The generated [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) in PEM format.")
                    @example("------BEGIN CERTIFICATE------...")
                    id_cert: string,
                    @doc("An authorization secret, called a \"session token\", valid for this `id_cert`/session.")
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
            @header({name: "Content-Length"}) contentLength: 0;
        } | {
            @doc("Returned, if none of the `serial_numbers` match any known ID-Certs from this actor.")
            @statusCode statusCode: 404;
        };

        @route("/session/keymaterial")
        @tag("Sensitive Actions")
        @summary("Delete encrypted private key material")
        @added(Version.`v1.0-alpha.1`)
        @delete
        /**
         * Delete encrypted private key material from the server. The `serial_number(s)`, must match
         * the serial numbers of ID-Certs that the client has uploaded key material for.
         */
        op deleteEncryptedPKM(
            @doc("Sensitive actions require a second factor of authentication to be executed. Read [section 4.1.2 of the protocol definition](https://docs.polyphony.chat/Protocol%20Specifications/core/#412-sensitive-actions) for more information.")
            @header({name: "X-P2-Sensitive-Solution"}) sensitiveSolution: string,
            @query serials: uint64[]): {
            @statusCode statusCode: 204;
            @header({name: "Content-Length"}) contentLength: 0;
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

        @route("/session")
        @delete
        @added(Version.`v1.0-alpha.1`)
        @summary("Delete/Revoke Session")
        @useAuth(BearerAuth)
        /**
         * Invalidate a session and its' associated ID-Cert by providing the session ID associated
         * with it.
         */
        op deleteSession(
            @doc("Sensitive actions require a second factor of authentication to be executed. Read [section 4.1.2 of the protocol definition](https://docs.polyphony.chat/Protocol%20Specifications/core/#412-sensitive-actions) for more information.")
            @header({name: "X-P2-Sensitive-Solution"}) sensitiveSolution: string,
            @query session_id: string
            ): {
            @statusCode statusCode: 204;
            @header({name: "Content-Length"}) contentLength: 0;
        } | {
            @statusCode statusCode: 404;
        };

        @route("/key/server")
        @summary("Rotate Server Identity Key")
        @added(Version.`v1.0-alpha.1`)
        @post
        @useAuth(BearerAuth)
        @tag("Sensitive Actions")
        /**
         * Rotate the server's identity key. Requires server administrator permissions.
         * @returns The servers' new ID-Cert, encoded as PEM 
         */
        op name(@doc("Sensitive actions require a second factor of authentication to be executed. Read [section 4.1.2 of the protocol definition](https://docs.polyphony.chat/Protocol%20Specifications/core/#412-sensitive-actions) for more information.")
        @header({name: "X-P2-Sensitive-Solution"}) sensitiveSolution: string,): string;
    }

    @tag("Federated Identity - Registration not required")
    namespace Unregistered {
        @route("/challenge")
        @summary("Receive a challenge string")
        @useAuth(BearerAuth)
        @added(Version.`v1.0-alpha.1`)
        @get
        /**
         * Request a challenge string. See the corresponding
         * [protocol definition chapter](https://docs.polyphony.chat/Protocol%20Specifications/core/#42-challenge-strings)
         * for more information.
         */
        op challengeString(): {
            @statusCode statusCode: 200;
            @body challengeStringResponse: polyproto.core.models.ChallengeStringResponse
        };

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
        op serverIdCert(@query timestamp?: uint64): polyproto.core.models.CacheableIDCert;

        @route("/idcert/actor")
        @get
        @added(Version.`v1.0-alpha.1`)
        @summary("Get Actor ID-Cert(s)")
        /**
         * Request the ID-Certs of a specific actor. The specified actor must be registered on this server.
         * @param fid The ID of the actor whose ID-Cert(s) should be returned.
         * @param notBefore: Return only ID-Certs from at or after a specific point in time. UNIX 64 bit timestamp.
         * @param notAfter: Return only ID-Certs from at or before a specific point in time. UNIX 64 bit timestamp.
         * @param session_id Optionally, return only the ID-Certs matching a specific `session_id`.
         * @returns JSON-Array of Object(s).
        */
        op actorCerts(@path fid: string, @query notBefore?: uint64, @query notAfter?: uint64, @query session_id?: string): {
            @statusCode statusCode: 200;
            @body response: polyproto.core.models.CacheableIDCert[]
        };

        @route("/session/idcert/extern")
        @put
        @added(Version.`v1.0-alpha.1`)
        @useAuth(BearerAuth)
        @summary("Update session ID-Cert")
        /**
         * Lets a foreign server know that the ID-Cert of a session has changed. This route is also
         * used to inform foreign servers about the revocation of an ID-Cert. The ID-Cert passed as
         * body in this route must belong to the actor making the request.
         * @returns 201 on success, 400 if the body is somehow invalid.
         */
        op updateSessionCert(@body id_cert: string): {
            @statusCode statusCode: 201;
        } | {
            @statusCode statusCode: 400;
        };
    }
}
