import "@typespec/http";
import "@typespec/versioning";
import "@typespec/openapi";
import "@typespec/openapi3";
import "../main.tsp";
import "./main.tsp";

using TypeSpec.Http;
using TypeSpec.Versioning;
using polyproto.core;

@useAuth(BearerAuth)
namespace polyproto.core.Routes.Migration {
    @tag("Migration - Registration required")
    @route("/migration/")
    namespace Registered {
        /**
         * This route is used by actors who would like to move their identity to another home server.
         * This specific route is called by the "old" actor, notifying the server about their intent
         * to move to another home server. To fulfill this action,
         *
         * 1. A key trial must be passed for all keys with which the actor has sent messages with
         *    on this server.
         * 2. The "new" actor named in this request must confirm setting up this redirect.
         *
         * @returns
         * - `200` if the link has been created
         * - `202` if the other account still needs to accept to establish the link.
         * @param newActorFid The FID of the actor, that this actor would like to be redirected to.
         */
        @route("/redirect")
        @post
        @added(Version.`v1.0-beta.3`)
        @summary("Set up a redirect for migrating identities")
        op setupRedirect(
            @body newActorFid: string,

            @doc("A list of completed `KeyTrial`s.")
            @header(#{ name: "X-P2-core-keytrial" })
            keyTrial: polyproto.core.Models.KeyTrialCompleted[],
        ): {
            @statusCode statusCode: 200 | 202;
        };

        /**
         * Stop an in-progress or existing redirection process.
         *
         * @param removeActorFid The FID of the actor to which a redirect should no longer exist
         */
        @route("/redirect")
        @delete
        @useAuth(BearerAuth)
        @added(Version.`v1.0-beta.3`)
        @summary("Remove a redirect for migrating identities")
        op removeRedirect(@query removeActorFid: string): {
            @statusCode statusCode: 204;

            @header(#{ name: "Content-Length" })
            contentLength: 0;
        } | {
            @statusCode statusCode: 400;
        };

        /**
         * Import a `P2Export` file. `messages` in this file must have been re-signed to the current
         * actor. Only messages classified as ["Information not tied to a specific context"](https://docs.polyphony.chat/Protocol%20Specifications/core/#:~:text=Example%3A%20Information%20not,without%0Aany%20issues.)
         * can be imported.
         * @returns
         * - `202`: The content has been accepted for processing, but processing has not been
         *   completed or may not have started.
         */
        @route("/data")
        @post
        @added(Version.`v1.0-beta.3`)
        @summary("Import data to server")
        @tag("Sensitive Actions")
        op importData(
            @doc("Sensitive actions require a second factor of authentication to be executed. Read [section 4.1.2 of the protocol definition](https://docs.polyphony.chat/Protocol%20Specifications/core/#412-sensitive-actions) for more information.")
            @header(#{ name: "X-P2-Sensitive-Solution" })
            sensitiveSolution: string,

            @body importData?: polyproto.core.Models.P2Export,
        ): {
            @statusCode statusCode: 202;

            @header(#{ name: "Content-Length" })
            contentLength: 0;
        };
    }

    @tag("Migration - Registration not required")
    namespace Unregistered {
        /**
         * Tell the homeserver of the "old" actor account that you intend to set up a redirect to
         * this actor
         * @param redirectSourceFid: The federation ID of the actor who should be the source of the
         * redirect.
         * @returns
         * - `200` if the link has been created
         * - `202` if the other account still needs to accept to establish the link.
         */
        @route("/redirect/extern")
        @post
        @added(Version.`v1.0-beta.3`)
        @summary("Set up a redirect for migrating identities")
        op setupRedirectExtern(@query redirectSourceFid: string): {
            @statusCode statusCode: 202 | 200;
        };

        /**
         * Tell the homeserver of the "old" actor account that you no longer intend to set up a
         * redirect to this actor
         * @param redirectSourceFid: The federation ID of the actor who should no longer be the source of the
         * redirect.
         * @returns
         * - `200` if the link has been removed
         */
        @route("/redirect/extern")
        @delete
        @added(Version.`v1.0-beta.3`)
        @summary("Remove a redirect for migrating identities")
        op removeRedirectExtern(@query redirectSourceFid: string): {
            @statusCode statusCode: 200;
        };

        /**
         * Stop an in-progress or existing re-signing process.
         * @returns
         * - `204` Action executed
         * - `404` No re-signing request found for mentioned actor
         * @param removeActorFid The FID of the actor to whom messages should no longer be re-signable for
         */
        @route("/messages")
        @delete
        @added(Version.`v1.0-beta.3`)
        @summary("Abort message re-signing")
        op removeResigningExtern(@query removeActorFid: string): {
            @statusCode statusCode: 404;
        } | {
            @statusCode statusCode: 204;

            @header(#{ name: "Content-Length" })
            contentLength: 0;
        };

        /**
         * Request allowing message re-signing. To fulfill this action, a key trial must be passed.
         * Unlocks message re-signing for messages signed with keys for which a key trial has been passed.
         * @param allowedResigningKeys List of PEM encoded `SubjectPublicKeyInfo`s. Only key pairs mentioned in this list are allowed to re-sign messages after the key trial has been passed.
         */
        @route("/messages")
        @post
        @added(Version.`v1.0-beta.3`)
        @summary("Request message re-signing")
        op requestAllowResigning(
            @body body: {
                newActorFid: string;
                allowedResigningKeys: string[];
            },

            @doc("A list of completed `KeyTrial`s.")
            @header(#{ name: "X-P2-core-keytrial" })
            keyTrial: polyproto.core.Models.KeyTrialCompleted[],
        ): {
            @statusCode statusCode: 200 | 403;
        };

        /**
         * Commit messages that have been re-signed to the server.
         * @param messages Messages. The distinct format of messages is up to the specific p2 extension to define.
         * @returns
         * - `200` On success. Returns another `MessageBatch`, if there are more messages to re-sign.
         *  If this endpoint is queried again while
         *  the previous batch of messages has not yet been re-signed (or only partially so), the
         *  returned message batch will contain those uncommitted messages again.
         * - `400` if re-signed messages are improperly formatted
         * - `403` if messages have been modified where the original keys have not passed the key
         *   trial, if a key trial has not been passed at all or if the messages have been signed
         *   with keys that were not on the `allowedResigningKeys` list.
         */
        @route("/messages/commit")
        @post
        @added(Version.`v1.0-beta.3`)
        @summary("Commit re-signed messages")
        op commitMessages(
            @body messages: polyproto.core.Models.MessageBatch<string>[],
        ): {
            @statusCode statusCode: 200;

            @doc("This header dictates the time a client should wait for before sending another batch of re-signed messages.")
            @header(#{ name: "Retry-After" })
            retryAfter: uint16;

            @doc("This header tells the client whether the route to commit re-signed messages has an upload size limit, and what the size of that limit is. A value of `0` means that there is no limit. This header not being present can also be interpreted as no limit existing.")
            @header(#{ name: "X-P2-Return-Body-Size-Limit " })
            sizeLimit?: uint64;

            @doc("Another message batch, if there are still messages left to re-sign.")
            @body
            message?: polyproto.core.Models.MessageBatch<string>[];
        } | {
            @statusCode _: 400 | 403;
        };

        /**
         * Fetch messages to be re-signed. Must only return messages where the signatures correlate to
         * ID-Certs for which a key trial has been passed. If this endpoint is queried again while
         * the previous batch of messages has not yet been re-signed (or only partially so), the
         * returned message batch will contain those uncommitted messages again.
         * @param limit How many messages to request from the server. Defaults to 300.
         * @param serialNumber If specified, query for non-re-signed messages corresponding to a specific ID-Cert.
         * @returns Messages. The distinct format of messages is up to the specific p2 extension to define.
         */
        @route("/messages")
        @get
        @added(Version.`v1.0-beta.3`)
        @summary("Fetch messages to-be-resigned")
        op getMessages(
            @query limit?: uint32 = 300,
            @query serialNumber?: string,
        ): {
            @statusCode statusCode: 200;

            @doc("This header tells the client whether the route to commit re-signed messages has an upload size limit, and what the size of that limit is, in bytes. A value of `\"0\"` means that there is no limit. This header not being present can also be interpreted as no limit existing. The value of this header is a string-formatted, unsigned 64-bit integer.")
            @header(#{ name: "X-P2-Return-Body-Size-Limit " })
            sizeLimit?: string;

            @body message: polyproto.core.Models.MessageBatch<string>[];
        } | {
            @statusCode statusCode: 403;
        };

        /**
         * Fetch key trials and their responses from other actors.
         * This route exists for transparency reasons, and allows actors in contact with the actor
         * mentioned in `fid` to verify, that it was the actor who initiated setting up a redirect or
         * the re-signing of messages and not a malicious home server.
         *
         * Only key trials which have at least one completion, and - more importantly - where the
         * `expiration` UNIX time stamp has passed, can be fetched.
         * @returns
         * - `204`: No keytrials found for specified actor
         * - `404`: Specified actor not known
         * - `200`: Completed key trials of requested actor
         * @param fid: The FID of the actor to query key trials for.
         * @param limit: How many response objects to query for at maximum. A value of `0` or not specifying this value at all means no maximum is defined.
         * @param id: Query for a specific key trial performed by an actor by the ID of the key trial.
         * @param notBefore: Return only key trials and their results performed at or after a specific point in time. UNIX 64 bit timestamp.
         * @param notAfter: Return only key trials and their results performed at or before a specific point in time. UNIX 64 bit timestamp.
         */
        @route("/keytrial/{fid}")
        @get
        @added(Version.`v1.0-beta.3`)
        @summary("Fetch key trials and key trial responses from actor")
        op getKeyTrials(
            @path fid: string,
            @query limit?: uint16 = 0,
            @query id?: string,
            @query notBefore?: uint64,
            @query notAfter?: uint64,
        ): {
            @statusCode statusCode: 204;

            @header(#{ name: "Content-Length" })
            contentLength: 0;
        } | {
            @statusCode statusCode: 404;
        } | {
            @statusCode statusCode: 200;
            @body response?: {
                keyTrial: polyproto.core.Models.KeyTrial;

                @minItems(1)
                keyTrialCompletion: polyproto.core.Models.KeyTrialCompleted[];
            }[];
        };

        /**
         * Delete all data associated with you from the server. Only deletes data associated with the
         * keys for which the `KeyTrial` has been passed.
         * @param breakRedirect If a redirect has been set up previously: Whether to break that redirect
         * with this action. Defaults to false.
         * @param keyTrial: A completed key trial.
         * @returns
         * - `204`: Action executed
         */
        @route("/data")
        @delete
        @added(Version.`v1.0-beta.3`)
        @summary("Delete own actor data from the server")
        op deleteData(
            @query breakRedirect?: boolean = false,

            @doc("A list of completed `KeyTrial`s.")
            @header(#{ name: "X-P2-core-keytrial" })
            keyTrial: polyproto.core.Models.KeyTrialCompleted[],
        ): {
            @statusCode statusCode: 204;

            @header(#{ name: "Content-Length" })
            contentLength: 0;
        } | {
            @statusCode statusCode: 403 | 401;
        };

        /**
         * Export all of your data for safekeeping or for importing it to another server.
         * Only exports data for which a key trial has been passed.
         * @returns
         * - `200` and the appropriate data if the key trial has been passed and is not yet expired.
         *   See the `P2Export` schema for more information.
         * - `204` if the server needs time to gather the data. A `Retry-After` header is included in
         *   the response, indicating to the actor the point in time at which they should query this
         *   endpoint again. If this point in time is after the expiry timestamp of the completed key trial,
         *   another key trial needs to be performed to access the data.
         * Contains all data of the user.
         */
        @route("/data")
        @get
        @added(Version.`v1.0-beta.3`)
        @summary("Export all data")
        op exportData(
            @doc("A list of completed `KeyTrial`s")
            @header(#{ name: "X-P2-core-keytrial" })
            keyTrial: polyproto.core.Models.KeyTrialCompleted[],
        ): {
            @statusCode statusCode: 200;
            @body body: polyproto.core.Models.P2Export;
        } | {
            @statusCode statusCode: 204;

            @header(#{ name: "Retry-After" })
            retryAfter: uint64;
        };
    }
}
