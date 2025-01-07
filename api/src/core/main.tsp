import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";
import "./routes";

using TypeSpec.Http;
using Routes;
using FederatedIdentity;
using Services;
using Migration;

namespace polyproto.core;

namespace models {
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
         * item of this array and vice versa. Represents a list of OIDs.
         */
        @minItems(1)
        encryption_algorithms: Array<Array<uint16>>
    }
    
    /**
     * A resource representing information about a discoverable service for an actor. You can learn more about
     * services and discoverability by reading [section #9](/Protocol Specifications/core#9-services) of
     * the core protocol specification.
     *
     * This resource contains information about the name of the service that is being made discoverable,
     * the URL of the service provider, and whether this service provider is the primary service provider
     * for the actor.
     */
    model Service {
        @minLength(2)
        @maxLength(64)
        @doc("The name of the service that is being made discoverable. Must be formatted according to [section #8.2: Namespaces](/Protocol Specifications/core#82-namespaces) in the core protocol specification")
        service: string,
        @doc("The base URL of the service provider, not including `/.p2/<service_name>`. Trailing slashes are allowed. If `(/).p2/<service_name>` is added to the URL specified here, a polyproto client should be able to access the HTTP API routes provided by the service.")
        url: url,
        @doc("Whether the service provider specified in the url field is the primary service provider for this service and actor.")
        primary: boolean
    }

    /**
     * A challenge string response, as received from a server when requesting a challenge string.
     * 
     * From the polyproto protocol definition: "verify an actor's private identity key possession,
     * without revealing the private key itself. These strings, ranging from 32 to 256 characters,
     * have a UNIX timestamp lifetime. If the current timestamp surpasses this lifetime, the
     * challenge fails. The actor signs the string, sending the signature and their ID-Cert to the
     * server, which then verifies the signature's authenticity."
     */
    model ChallengeStringResponse {
        @minLength(32)
        @maxLength(256)
        @doc("The challenge string, which the client should sign with its private identity key.") 
        challenge: string,
        @doc("The UNIX timestamp after which the challenge expires.")
        expires: uint64
    }

    /**
     * A key trial as sent from the server to an actor.
     */
    model KeyTrial {
        @minLength(32)
        @maxLength(256)
        @doc("The key trial, which the client should sign with all of their private identity keys.") 
        trial: string;
        @minLength(1)
        @maxLength(256)
        @doc("A unique identifying string to differentiate this specific key trial from other key trials that may be open at the same time.")
        id: string,
        @doc("The UNIX timestamp after which the key trial expires.")
        expires: uint64;
    }

    /**
     * A completed key trial, as an actor would send to the server.
     */
    model KeyTrialCompleted {
        @doc("The signature produced by signing the key trial string using a private identity key.")
        signature: string;
        @doc("The unique identifying string, differentiating this specific key trial from other key trials that may be open at the same time.")
        id: string,
        @doc("The serial number of the ID-Cert corresponding to the private identity key used to sign the key trial string.")
        serial_number: uint64;
    }

    /**
     * A message batch, as received from and sent to the server in the context of re-signing messages.
     * This type is generic over `T`, where `T` represents the content of the actual message. This
     * means, that the specific message content depends on the concrete implementation or extension
     * of the polyproto protocol.
     */
    model MessageBatch<T> {
        @doc("The ID-Cert that the following messages' signatures correspond to.")    
        idCert: string,
        @doc("The actual message.")
        messages: {
            @doc("Signature of the whole message")
            signature: string,
            @doc("Arbitrary content `T`. This depends on the specific implementation or extension of the protocol.")
            content: T
        }[];
    }

    model MessageBatchExample extends MessageBatch<string> {}

    /** The data is a gzipped tarball (.tar.gz) named `export1234567890-user@subdomain.example.com`, where
     *   - `export[numbers]` is the word `export` with 20 random digits appended to it
     *   - `user` is the actors' name
     *   - `subdomain.example.com` is the FQDN of the server the actor is registered on.
     *   This file archive contains a file `messages.json` which is a JSON `MessageBatch` of all
     *   messages sent by the user. Note the [definition of the word "message" in polyproto](https://docs.polyphony.chat/Protocol%20Specifications/core/#:~:text=software%20for%20clients.-,message%2C%20messages,-%3A%20In%20the%20context).
     *   If the server where the data export was requested from has [RawR](https://docs.polyphony.chat/Protocol%20Specifications/core/#731-resource-addressing-with-relative-roots)
     *   enabled, the file archive will contain a folder named `rawr`. This folder contains all
     *   RawR-content uploaded by the actor to that server. The files in this folder are named after
     *   the resource ID. File extensions are only added if they were known to the server. An
     *   example file name might be `2c851bfb6daffa944fa1723c7bd4d362ffbc9defe292f2daaf05e895989d179b.jxl`,
     *   referencing the file which was hosted at `<server_url>/.p2/core/resource/2c851bfb6daffa944fa1723c7bd4d362ffbc9defe292f2daaf05e895989d179b.jxl`.
     *   If the server where the data export was requested from is the actors' home server, the
     *   archive will contain two folders `certs` and `crypt_certs`. `certs` will contain all ID-Certs
     *   the server has stored of the actor. `crypt_certs` will contain all encrypted private key
     *   material that the actor has uploaded to the server.
     */
    model P2Export {}
}
