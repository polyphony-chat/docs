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

@useAuth(BearerAuth)
namespace Migration {

    @tag("Migration - Registration required")
    @route("/migration/")
    namespace Registered {
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
         * @returns
         * - `200` if the link has been created
         * - `202` if the other account still needs to accept to establish the link. Contains a key trial 
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
         * @returns 
         * - `200` if the link has been created
         * - `202` if the other account still needs to accept to establish the link.
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
         * @returns
         * - `204` Action executed
         * - `404` No re-signing request found for mentioned actor
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
         * @returns a key trial 
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
         * @returns 
         * - `200` On success
         * - `400` if re-signed messages are improperly formatted
         * - `403` if messages have been modified where the original keys have not passed the key
         *   trial, if a key trial has not been passed at all or if the messages have been signed
         *   with keys that were not on the `allowedResigningKeys` list.
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
         * @returns 
         * - `200` if the key trials were processed and deemed to be valid
         * - `202`, if the server needs additional time to process the key trials
         * - `400`, if one or more completed key trials were faulty. Contains faulty key trials in the response body.
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
         * @returns
         * - `204`: No keytrials found for specified actor
         * - `404`: Specified actor not known
         * - `200`: Completed key trials of requested actor
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
         * @returns
         * - `202` and a key trial, if one still needs to be passed
         * - `204`: Action executed
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
         * @returns - `202` and a key trial, if one still needs to be passed
         * - `200` and the appropriate data if the key trial has been passed and is not yet expired.
         *   The data is a gzipped tarball (.tar.gz) named `export1234567890-user@subdomain.example.com`, where
         *   - `export[numbers]` is the word `export` with 20 random digits appended to it
         *   - `user` is the actors' name
         *   - `subdomain.example.com` is the FQDN of the server the actor is 
         *   This file archive contains a file `messages.json` which is a JSON `MessageBatch` of all
         *   messages sent by the user. Note the [definition of the word "message" in polyproto](https://docs.polyphony.chat/Protocol%20Specifications/core/#:~:text=software%20for%20clients.-,message%2C%20messages,-%3A%20In%20the%20context).
         *   If the server where the data export was requested from has [RawR](https://docs.polyphony.chat/Protocol%20Specifications/core/#731-resource-addressing-with-relative-roots)
         *   enabled, the file archive will contain a folder named `rawr`. This folder contains all
         *   RawR-content uploaded by the actor to that server. The files in this folder are named after
         *   the resource ID. File extensions are only added if they were known to the server. An
         *   example file name might be `2c851bfb6daffa944fa1723c7bd4d362ffbc9defe292f2daaf05e895989d179b.jxl`,
         *   referencing the file which was hosted at `<server_url>/.p2/core/resource/2c851bfb6daffa944fa1723c7bd4d362ffbc9defe292f2daaf05e895989d179b.jxl`.
         * - `204` if the server needs time to gather the data. A `Retry-After` header is included in
         *   the response, indicating to the actor the point in time at which they should query this
         *   endpoint again. If this point in time is after the expiry timestamp of the completed key trial,
         *   another key trial needs to be performed to access the data.
         * Contains all data of the user.
         */
        op exportData(): {
            @statusCode statusCode: 202;
            @body body: polyproto.core.models.KeyTrial;
        } | {
            @statusCode statusCode: 200;
            @body body: File;
        } | {
            @statusCode statusCode: 204;
            @header({name: "Retry-After"}) retryAfter: uint64;
        };
    }
}

/* TODO things that are missing:
 *  - RawR routes
    - The description of the RawR .tar.gz file format could be added into the p2 spec 
 */