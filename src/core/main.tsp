import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";
import "./routes";

using TypeSpec.Http;
using Routes;
using FederatedIdentity;
using Services;
using Migration;
using ResourceAddressingWithRelativeRoots;

namespace polyproto.core;

namespace models {
  model EncryptedPKM {
    /**
     * Custom variant of the X.509 `SubjectPublicKeyInfo`, where the `subject_public_key`
     * field stores the encrypted private key, instead of a public key. Otherwise equal to
     * `SubjectPublicKeyInfo`. Also referred to as `PrivateKeyInfo`.
     */
    key_data: string;

    @doc("The serial number of the ID-Cert this key material is associated with.")
    serialNumber: uint64;

    /**
     * Information about the algorithms used to encrypt the data held by the `key_data` field.
     * Order-sensitive; The encryption used for the first encryption operation must be the last
     * item of this array and vice versa. Represents a list of OIDs.
     */
    @minItems(1)
    encryptionAlgorithms: Array<Array<uint16>>;
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
    service: string;

    @doc("The base URL of the service provider, not including `/.p2/<service_name>`. Trailing slashes are allowed. If `(/).p2/<service_name>` is added to the URL specified here, a polyproto client should be able to access the HTTP API routes provided by the service.")
    url: url;

    @doc("Whether the service provider specified in the url field is the primary service provider for this service and actor.")
    primary: boolean;
  }

  /**
   * A key trial as sent from the server to an actor.
   *
   * Used to verify an actor's private identity key possession,
   * without revealing the private key itself
   */
  model KeyTrial {
    @minLength(32)
    @maxLength(256)
    @doc("The key trial, which the client should sign with their private identity key.")
    trial: string;

    @doc("The UNIX timestamp after which the key trial expires.")
    expires: uint64;
  }

  /**
   * A completed key trial, as an actor would send to the server.
   */
  model KeyTrialCompleted {
    @doc("The signature produced by signing the key trial string using a private identity key.")
    signature: string;

    @doc("The serial number of the ID-Cert corresponding to the private identity key used to sign the key trial string.")
    serialNumber: uint64;
  }

  /**
   * A message batch, as received from and sent to the server in the context of re-signing messages.
   * This type is generic over `T`, where `T` represents the content of the actual message. This
   * means, that the specific message content depends on the concrete implementation or extension
   * of the polyproto protocol.
   */
  model MessageBatch<T> {
    @doc("The ID-Cert that the following messages' signatures correspond to.")
    idCert: string;

    @doc("The actual message.")
    messages: {
      @doc("Signature of the whole message")
      signature: string;

      @doc("Arbitrary content `T`. This depends on the specific implementation or extension of the protocol.")
      content: T;
    }[];
  }

  model MessageBatchExample extends MessageBatch<string> {}

  /** The data is a gzipped tarball (.tar.gz) named `export1234567890-user@subdomain.example.com`, where
     *   - `export[numbers]` is the word `export` with 20 random digits appended to it
     *   - `user` is the actors' name
     *   - `subdomain.example.com` is the FQDN of the server the actor is registered on.
     *   This file archive contains a file `messages.p2mb` which is a JSON file containing [message batches](https://docs.polyphony.chat/Protocol%20Specifications/core/#721-message-batches)
     *   of all messages sent by the user. If the server where the data export was requested from has
     *   [RawR](https://docs.polyphony.chat/Protocol%20Specifications/core/#731-resource-addressing-with-relative-roots) enabled, the file archive will contain a
     *   folder named `rawr`. This folder contains all RawR content uploaded by the actor to that server.
     *   The files in this folder are named after the resource ID given to the resource. File extensions are only
     *   added if they were known to the server. An example file name might be
     *   `2c851bfb6daffa944fa1723c7bd4d362ffbc9defe292f2daaf05e895989d179b.jxl`, referencing the file
     *   which was hosted at `<server_url>/.p2/core/resource/2c851bfb6daffa944fa1723c7bd4d362ffbc9defe292f2daaf05e895989d179b.jxl`.
     *   In addition, the folder `rawr` contains a file named `access_properties.p2al`. This JSON
     *   file contains a data structure mapping each resource ID to an access properties object.
     *   In particular, the file is structured as an array containing objects. Each object has a key which is equal
     *   to the resource ID of a resource in the `rawr` directory and a value which is an object
     *   representing the access properties. An example of the contents of this file is given below:
     * 
```json
[
    {
        "2062a23e2a25b226ca4c546fec5ec06e0df9648281f45da8b5aaabebdf66cf4c.jxl": {
        "private": false,
        "public": false,
        "allowlist": ["user1@example.com", "instance.example.com"],
        "denylist": ["user2@example.com", "otherinstance@example.com"]
        }
    },
    {
        "a9144379a161e1fcf6b07801b70db6d6c481933bd634fe2409eb713723ab1a0a": {
        "private": true,
        "public": false,
        "allowlist": ["user1@example.com"],
        "denylist": []
        }
    }
]
```
     * 
     *   If the server where the data export was requested from is the actors' home server, the
     *   archive will contain a folder `certs` and a file `crypt_certs.p2epk`. `certs` will contain all ID-Certs
     *   the server has stored of the actor. The ID-Certs will be stored in
     *   [ASCII PEM format](https://web.archive.org/web/20250107131731/https://learn.microsoft.com/en-us/azure/iot-hub/reference-x509-certificates#:~:text=ASN.1%20encoding.-,ascii%20pem%20format,-A%20PEM%20certificate).
     *   The file `crypt_certs.p2epk` contains all [encrypted private key material](https://docs.polyphony.chat/Protocol%20Specifications/core/#63-private-key-loss-prevention-and-private-key-recovery)
     *   that the actor has uploaded to the server. Just like `messages.p2mb`, `crypt_certs.p2epk` is a standard
     *   JSON file.
     */
  model P2Export {}

  /**
   * `ResourceAccessProperties` define which actors may access an uploaded resource. Actors and
   * entire instances can have access granted or revoked.
   */
  model ResourceAccessProperties {
    @doc("Whether the resource should be private by default. Private resources can only be accessed by the uploader and by instances and actors declared in the `allowlist`.")
    private: boolean = false;

    @doc("Whether the resource should be publicly retrievable, i.e. without requiring authentication. If this is `true`, the allow- and denylists are ignored.")
    public: boolean = false;

    @doc("A list of actors and/or instances allowed to access this resource.")
    @example(#["user_i_like@example.com", "instance.example.com"])
    allowlist?: string[];

    @doc("A list of actors and/or instances who cannot have access to this resource.")
    @example(#["user_i_dislike@example.com", "other_instance.example.com"])
    denylist?: string[];
  }

  /**
   * When querying the server for a list of resources uploaded by you, you can optionally request
   * the resulting list to be sorted in a specific way. These are the four options you have.
   */
  enum ResourceListSorting {
    SizeAsc,
    SizeDesc,
    NewestFirst,
    OldestFirst,
  }

  /**
   * A cacheable response to an ID-Cert request.
   */
  model CacheableIDCert {
    @doc("The requested ID-Cert in ASCII PEM format.")
    @example("------BEGIN CERTIFICATE------...")
    idCertPem: string;

    @doc("UNIX timestamp that specifies when this specific id_cert has been marked as invalidated by the server. An ID-Cert is considered invalidated, if the server or actor choose to revoke the validity of the ID-Cert before the lifetime of the certificate was scheduled to end. If this property does not exist, the ID-Cert has not been invalidated.")
    @example(1736610000)
    invalidatedAt?: uint64;

    @doc("UNIX timestamp that specifies the time from which this cache entry may be treated as valid.")
    @example(1736606402)
    cacheNotValidBefore: uint64;

    @doc("UNIX timestamp that specifies a time until which this cache entry may be treated as valid.")
    @example(1736613602)
    cacheNotValidAfter: uint64;

    @doc("Signature generated by the home server, encoded in [Hexadecimal](https://en.wikipedia.org/wiki/Hexadecimal) (base-16). This signature can be verified using the home servers' public identity key. A server generates the `cacheSignature` by concatenating the serial number of the ID-Cert in question with the `cacheValidNotBefore` timestamp, the `cacheValidNotAfter` timestamp, and the `invalidatedAt` timestamp, if present. Clients must reject certificates of which the `cacheSignature` can not be verified to be correct.")
    @example("7ab2bbde7fe43c7481a3a61031546bab16bc1a8735b2f0cdd519958c7f2f99f8")
    @minLength(32)
    @maxLength(32)
    cacheSignature: string;
  }
}
