import "@typespec/http";
import "@typespec/versioning";
import "@typespec/openapi";
import "@typespec/openapi3";
import "../main.tsp";

using TypeSpec.Http;
using TypeSpec.Versioning;
using TypeSpec.OpenAPI;
using polyproto;
@service({
    title: "polyproto core APIs";
})
@info({license: {name: "MIT License", url: "https://raw.githubusercontent.com/polyphony-chat/docs/refs/heads/main/LICENSE"}})
@server("https://example.com", "Example endpoint")


@route("/.p2/core/v1/")
@versioned(Version)
namespace Routes;

enum Version {
    "v1.0-alpha.1"
}

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

namespace Services {
    
    @tag("Services - Registration required")
    @useAuth(BearerAuth)
    namespace Registered {
        @route("/services")
        @post
        @summary("Add service to be discovered")
        @added(Version.`v1.0-alpha.1`)
        @returnsDoc("A singular service object, representing the service that was added.")
        @errorsDoc("Returned, if the service and URL combination already exists in the list of discoverable services.")
        /**
         * Add a service to the list of services discoverable by other actors.
         */
        op registerService(service: polyproto.core.models.Service): {
            @statusCode statusCode: 201;
            @body body: polyproto.core.models.Service;
        } | {
            @statusCode statusCode: 409;
        };

        @route("/services")
        @delete
        @summary("Delete discoverable service")
        @added(Version.`v1.0-alpha.1`)
        /**
         * Remove a service from the list of services discoverable by other actors.
         * If a primary service is removed and there are still other providers available for the same service,
         * the server will select a new primary service provider from the list of available providers.
         * This new provider will be returned in the response body.
         * @param url List of urls of the service providers to remove. The indices of the urls list must match the indices of the service name list.
         * @param name List of urls of the service providers to remove. The indices of the service name list must match the indices of the urls list.
         */
        op unregisterService(@query url: url[], @query name: string[]): {
            @statusCode statusCode: 200;
            @body returnedBody?: {
                service: string,
                new_primary: url
            }[]     
        } | {
            @statusCode statusCode: 400 | 404;
        };

        @route("/services/primary")
        @put
        @summary("Set primary service provider")
        @added(Version.`v1.0-alpha.1`)
        /**
         * Set a primary service provider for a given service namespace. This is used to indicate, which service 
         * provider should be used by default by other actors, when multiple service providers are available 
         * for a given service namespace. The service specified by the arguments in the body must be a
         * valid, already existing service.
         * @returns An array of at minimum one, and at maximum 2 [service](./Types/service.md) objects.
         * The response will contain the updated previous primary service provider, if there was one, along
         * with the new primary service provider.
         * @param body URL of a service provider and name of a service.
         */
        op setPrimaryProvider(@body body: {url: url, @minLength(2) @maxLength(64) name: string}): {
            @statusCode statusCode: 200;
            @maxItems(2)
            @minItems(1)
            @body body: polyproto.core.models.Service[];
        };
    }

    @tag("Services - Registration not required")
    namespace Unregistered {
        @route("/services/discover/")
        @get
        @summary("Discover services of actor")
        @added(Version.`v1.0-alpha.1`)
        /**
         * Fetch a list of all services that the actor has made discoverable. Clients should not expect 
         * this list to be ordered in any particular way.
         * @returns JSON array of [service objects](./Types/service.md). A list of all services which the actor has
         * made discoverable.
         * @param fid The ID of the actor whose services should be returned.
         * @param limit The maximum number of services to return. Not specifying a limit will return all
         * services. Specifying a limit of `1` will return only the primary service provider for each service.
         */
        op getServicesOfActor(@path fid: string, @query @minValue(1) limit?: uint64): polyproto.core.models.Service[] | {
            @statusCode statusCode: 204;
            @header({name: "Content-Length"}) contentLength: 0;
        } | {
            @statusCode statusCode: 404;
        } | {
            @statusCode statusCode: 200;
            @body body: polyproto.core.models.Service[];
        };

        @route("/services/discover/{fid}/{service}")
        @get
        @summary("Discover single service of actor")
        @added(Version.`v1.0-alpha.1`)
        /**
         * Get all service providers an actor is registered with, limited to a specific service.
         * Clients should not expect this list to be ordered in any particular way.
         * @returns JSON array of [service objects](./Types/service.md), filtered by the specified service.
         * @param fid The ID of the actor whose services should be returned.
         * @param limit The maximum number of services to return. Not specifying a limit will return all
         * services. Specifying a limit of `1` will return only the primary service provider for the specified service.
         * @param service The name of the service to discover providers of.
         */
        op getSingleServiceOfActor(@path fid: string, @path service: string, @query @minValue(1) limit?: uint64): polyproto.core.models.Service[] | {
            @statusCode statusCode: 204;
            @header({name: "Content-Length"}) contentLength: 0;
        } | {
            @statusCode statusCode: 404;
        } | {
            @statusCode statusCode: 200;
            @body body: polyproto.core.models.Service[];
        };
    }
}

@useAuth(BearerAuth)
namespace Migration {

    @tag("Migration - Registration required")
    @route("/migration/")
    namespace Registered {
        //TODO: Add routes concerned with data migration.
        @route("/redirect")
        @post
        @added(Version.`v1.0-alpha.1`)
        @summary("Set up a redirect for migrating identities")
        /**
         * This route is used by actors who would like to move their identity to another home server.
         * This specific route is called by the "old" actor, notifying the server about their intent
         * to move to another home server. To fulfill this action,
         * 
         * 1. A key trial must be passed
         * 2. The "new" actor named in this request must confirm setting up this redirect.
         * 
         * @returns `200` if the link has been created, `202` if the other account still needs to accept to establish the link. Returns a key trial 
         * @param newActorFid The FID of the actor, that this actor would like to be redirected to.
         */
        op setupRedirect(@body newActorFid: string): {
            @statusCode statusCode: 200 | 202;
            @body body: polyproto.core.models.KeyTrial;
        };

        @route("/redirect")
        @delete
        @added(Version.`v1.0-alpha.1`)
        @summary("Remove a redirect for migrating identities")
        /**
         * Stop an in-progress or existing redirection process.
         * @returns A key trial
         * @param removeActorFid The FID of the actor to which a redirect should no longer exist
         */
        op removeRedirect(@query removeActorFid: string): {
            @statusCode statusCode: 200;
            @body body: polyproto.core.models.KeyTrial;
        } | {
            @statusCode statusCode: 400;
        };

        @route("/data")
        @post
        @added(Version.`v1.0-alpha.1`)
        @summary("Import data to server")
        /**
         * //TODO
         */
        op importData(@body importData?: polyproto.core.models.MessageBatch<string>[]): {
            @statusCode statusCode: 202;
            @body body: polyproto.core.models.KeyTrial;
        } | {
            @statusCode statusCode: 204;
            @header({name: "Content-Length"}) contentLength: 0;
        };
    }

    @tag("Migration - Registration not required")
    namespace Unregistered {
        @route("/redirect/extern")
        @post
        @added(Version.`v1.0-alpha.1`)
        @summary("Set up a redirect for migrating identities")
        /**
         * Tell the homeserver of the "old" actor account that you intend to set up a redirect to
         * this actor
         * @returns `200` if the link has been created, `202` if the other account still needs to accept to establish the link.
         */
        op setupRedirectExtern(@body redirectSourceFid: string): {
            @statusCode statusCode: 202 | 200
        };

        @route("/messages")
        @delete
        @added(Version.`v1.0-alpha.1`)
        @summary("Abort message re-signing")
        /**
         * Stop an in-progress or existing re-signing process.
         * @returns `204`: Action executed; `404`: No re-signing request found for mentioned actor
         * @param removeActorFid The FID of the actor to whom messages should no longer be re-signable for
         */
        op removeResigningExtern(@query removeActorFid: string): {
            @statusCode statusCode: 404;
        } | {
            @statusCode statusCode: 204;
            @header({name: "Content-Length"}) contentLength: 0;
        };

        @route("/messages")
        @post
        @added(Version.`v1.0-alpha.1`)
        @summary("Request message re-signing")
        /**
         * Request allowing message re-signing. To fulfill this action, a key trial must be passed.
         * @returns Returns a key trial 
         * @param allowedResigningKeys List of PEM encoded `SubjectPublicKeyInfo`s. Only key pairs mentioned in this list are allowed to re-sign messages after the key trial has been passed.
         */
        op requestAllowResigning(@body body: { newActorFid: string, allowedResigningKeys: string[] }): {
            @statusCode statusCode: 200;
            @body body: polyproto.core.models.KeyTrial;
        };

        @route("/messages/commit")
        @post
        @added(Version.`v1.0-alpha.1`)
        @summary("Commit re-signed messages")
        /**
         * Commit messages that have been re-signed to the server.
         * @param messages Messages. The distinct format of messages is up to the specific p2 extension to define.
         * @returns `200` On success; `400` if re-signed messages are improperly formatted; `403` if messages have been modified where the original keys have not passed the key trial, if a key trial has not been passed at all or if the messages have been signed with keys that were not on the `allowedResigningKeys` list.
         */
        op commitMessages(@body messages: polyproto.core.models.MessageBatch<string>[]): {
            @statusCode statusCode: 200 | 400 | 403;
        };

        @route("/messages")
        @get
        @added(Version.`v1.0-alpha.1`)
        @summary("Fetch messages to-be-resigned")
        /**
         * Fetch messages to be re-signed.
         * @param limit How many messages to request from the server. Defaults to 100.
         * @returns Messages. The distinct format of messages is up to the specific p2 extension to define.
         */
        op getMessages(@query limit?: uint32 = 100): {
            @statusCode statusCode: 200;
            @body message: polyproto.core.models.MessageBatch<string>[];
        } | {
            @statusCode statusCode: 403;
        };

        @route("/keytrial")
        @post
        @added(Version.`v1.0-alpha.1`)
        @summary("Complete key trial")
        /**
         * Complete a key trial. After the successful completion of the key trial, the action that
         * required this key trial to be performed may be executed until the `expires` UNIX timestamp
         * of the key trial has been reached. After that point, another key trial must be performed
         * before executing the action.
         * 
         * If only a subset of all trialed keys had a trial completed for them, the server must only
         * allow changes which concern information tied to these exact keys.
         * 
         * @param body Completed key trials.
         * @returns Returns `200` if the key trials were processed and deemed to be valid. Returns `202`, if the server needs additional time to process the key trials. 400 is received if one or more completed key trials were faulty. Contains faulty key trials in the response body.
         */
        op keyTrialRedirectExtern(@body body: polyproto.core.models.KeyTrialCompleted[]): {
            @doc("Returns `200` if the key trials were processed and deemed to be valid. Returns `202`, if the server needs additional time to process the key trials.")
            @statusCode statusCode: 202 | 200
        } | {
            @doc("Received if one or more completed key trials were faulty. Contains faulty key trials in the response body.")
            @statusCode statusCode: 400;
            @body body: polyproto.core.models.KeyTrialCompleted[];
        };

        @route("/keytrial/{fid}")
        @get
        @added(Version.`v1.0-alpha.1`)
        @summary("Fetch key trials and key trial responses from actor")
        /**
         * Fetch key trials and their responses from other actors.
         * This route exists for transparency reasons, and allows actors in contact with the actor
         * mentioned in `fid` to verify, that it was the actor who initiated setting up a redirect or
         * the re-signing of messages and not a malicious home server.
         * 
         * Only key trials which have at least one completion, and - more importantly - where the
         * `expiration` UNIX time stamp has passed, can be fetched.
         * @returns `204`: No keytrials found for specified actor; `404`: Specified actor not known; `200`: Completed key trials of requested actor
         */
        op getKeyTrials(@path fid: string, @query limit?: uint16 = 0): {
            @statusCode statusCode: 204;
            @header({name: "Content-Length"}) contentLength: 0;
        } | {
            @statusCode statusCode: 404;
        } | {
            @statusCode statusCode: 200;
            @body response?: {
                keyTrial: polyproto.core.models.KeyTrial,
                @minItems(1)
                keyTrialCompletion: polyproto.core.models.KeyTrialCompleted[]
            }[]
        };

        @route("/data")
        @delete
        @added(Version.`v1.0-alpha.1`)
        @summary("Delete own actor data from the sever")
        /**
         * Delete all data associated with you from the server.
         * @param breakRedirect If a redirect has been set up previously: Whether to break that redirect
         * with this action. Defaults to false.
         * @returns `202` and a key trial, if one still needs to be passed; `204`: Action executed
         */
        op deleteData(@query breakRedirect?: boolean = false): {
            @statusCode statusCode: 202;
            @body response: polyproto.core.models.KeyTrial;
        } | {
            @statusCode statusCode: 204;
            @header({name: "Content-Length"}) contentLength: 0;
        };

        @route("/data")
        @get
        @added(Version.`v1.0-alpha.1`)
        @summary("Export all data")
        /**
         * Export all of your data for safekeeping or for importing it to another server
         * @returns `202` and a key trial, if one still needs to be passed; `200` and the
         * appropriate data if the key trial has been passed and is not yet expired.
         * Contains all data of the user.
         */
        op exportData(): {
            @statusCode statusCode: 202;
            @body body: polyproto.core.models.KeyTrial;
        } | {
            @statusCode statusCode: 200;
            @body body: polyproto.core.models.MessageBatch<string>[]; 
        };
    }
}