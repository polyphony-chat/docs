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

@route("/resource/")
namespace ResourceAddressingWithRelativeRoots {
    @tag("Resource addressing with relative roots - Registration not required")
    namespace Unregistered {
        /**
         * Retrieve a [RawR](https://docs.polyphony.chat/Protocol%20Specifications/core/#731-resource-addressing-with-relative-roots)
         * resource by specifying the ID of the resource.
         * @param rid: Resource Identifier - unique identifier for a resource.
         * @returns
         * - `200`: File found and retrieved.
         * - `308`: URI root has changed.
         * - `401`: Server or resource requires authentication to access this endpoint.
         * - `403`: Server or resource not accessible for the actor making this request.
         * - `404`: Resource not found.
         */
        @route("/{rid}")
        @get
        @useAuth(BearerAuth | NoAuth)
        @added(Version.`v1.0-beta.1`)
        @summary("Get resource by resource ID")
        op getResource(@path rid: string):
            | {
                  @statusCode _: 200;
                  @body body: File;
              }
            | {
                  @statusCode _: 308;

                  @header({
                      name: "Location",
                  })
                  location: url;

                  @body reason: "ROOT_CHANGED";
              }
            | {
                  @statusCode _: 403;
                  @body reason: "ACCESS_FORBIDDEN";
              }
            | {
                  @statusCode _: 401;
                  @body reason: "NEEDS_AUTHENTICATION";
              }
            | {
                  @statusCode _: 404;
                  @body reason: "NOT_FOUND";
              };

        /**
         * Query the server for information about a RawR resource.
         * This route accepts a Bearer token, but public resources may also be queried without
         * specifying a token.
         * @param rid The resource ID of the resource which you'd like to query information of.
         *
         * @returns
         * - `200`: Found, contains resource information
         * - `308`: URI root has changed.
         * - `401`: Server or resource requires authentication to access this endpoint.
         * - `403`: Server or resource not accessible for the actor making this request.
         * - `404`: Resource not found.
         */
        @route("/{rid}/info/")
        @get
        @useAuth(BearerAuth | NoAuth)
        @added(Version.`v1.0-beta.1`)
        @summary("Retrieve information about a RawR resource")
        op getResourceInfos(@path rid: string):
            | {
                  @statusCode statusCode: 200;
                  @body body: {
                      resourceId: string;
                      size: uint64;
                      access: polyproto.core.models.ResourceAccessProperties;
                  }[];
              }
            | {
                  @statusCode _: 308;

                  @header({
                      name: "Location",
                  })
                  location: url;

                  @body reason: "ROOT_CHANGED";
              }
            | {
                  @statusCode _: 403;
                  @body reason: "ACCESS_FORBIDDEN";
              }
            | {
                  @statusCode _: 401;
                  @body reason: "NEEDS_AUTHENTICATION";
              }
            | {
                  @statusCode _: 404;
                  @body reason: "NOT_FOUND";
              };
    }

    @tag("Resource addressing with relative roots - Registration required")
    @useAuth(BearerAuth)
    namespace Registered {
        /**
         * Upload a [RawR](https://docs.polyphony.chat/Protocol%20Specifications/core/#731-resource-addressing-with-relative-roots)
         * resource to your home server.
         * @param rid: The resource ID of the resource you would like to upload.
         * @param resourceAccessProperties ResourceAccessProperties. See the corresponding schema definition for more information.
         * @param contentLength: The size of the resource in bytes.
         * @param file: The resource itself
         * @returns
         * - `204`: Upload successful.
         * - `403`: Uploading forbidden.
         * - `409`: RID already exists on this server. Choose a different RID.
         * - `411`: `Content-Length` header not specified.
         * - `413`: Resource too large.
         * - `414`: RID too long.
         */
        @route("/{rid}")
        @post
        @added(Version.`v1.0-beta.1`)
        @summary("Upload RawR resource")
        op postResource(
            @path rid: string,

            @header({
                name: "Content-Length",
            })
            contentLength: uint64,

            @query
            resourceAccessProperties: polyproto.core.models.ResourceAccessProperties,

            @body file: File,
        ):
            | {
                  @statusCode _: 403;
                  @body reason: "UPLOAD_FORBIDDEN";
              }
            | {
                  @statusCode _: 409;
                  @body reason: "DUPLICATE_RID";
              }
            | {
                  @statusCode _: 411;
                  @body reason: "LENGTH_REQUIRED";
              }
            | {
                  @statusCode _: 413;
                  @body body: {
                      reason: "TOO_LARGE";

                      @doc("The server may tell the client how much more content they are allowed to store, in bytes.")
                      remainingStorageBytes?: uint64;
                  };
              }
            | {
                  @statusCode _: 414;
                  reason: "RID_TOO_LONG";
                  charLimit: uint8 = 64;
              }
            | {
                  @statusCode _: 204;

                  @header({
                      name: "Content-Length",
                  })
                  contentLength: 0;
              };

        @route("/{rid}")
        @delete
        @added(Version.`v1.0-beta.1`)
        @summary("Delete RawR resource")
        op deleteResource(@path rid: string): {
            @statusCode _: 204;
        };

        /**
         * Replace the access properties of a [RawR](https://docs.polyphony.chat/Protocol%20Specifications/core/#731-resource-addressing-with-relative-roots)
         * resource with updated access properties.
         * @param rid The resource ID of the resource which the access properties should be modified of.
         * @param resourceAccessProperties ResourceAccessProperties. See the corresponding schema definition for more information.
         */
        @route("/{rid}")
        @put
        @added(Version.`v1.0-beta.1`)
        @summary("Update RawR resource access properties")
        op modifyResource(
            @path rid: string,

            @body
            resourceAccessProperties: polyproto.core.models.ResourceAccessProperties,
        ): {
            @header({
                name: "Content-Length",
            })
            contentLength: 0;

            @statusCode _: 204;
        };

        /**
         * Query the server for a list of resources you've uploaded.
         * @param limit Optional; How many results you'd like to retrieve at maximum. Defaults to `50`.
         * @param sort Whether the list should be sorted in a specific way. Available options are `SizeAsc`, `SizeDesc`, `NewestFirst` and `OldestFirst`.
         */
        @route("/resources")
        @get
        @added(Version.`v1.0-beta.1`)
        @summary("List your uploaded resources")
        op getResourceList(
            @query limit?: uint32 = 50,
            @query sort?: polyproto.core.models.ResourceListSorting,
        ): {
            @statusCode statusCode: 200;
            @body body: {
                resourceId: string;
                size: uint64;
                access: polyproto.core.models.ResourceAccessProperties;
            }[];
        } | {
            @statusCode _: 204;

            @header({
                name: "Content-Length",
            })
            contentLength: 0;
        };
    }
}

// rawr x3
