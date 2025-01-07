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
        @route("/{rid}")
        @get
        @added(Version.`v1.0-alpha.1`)
        @summary("Get resource by resource ID")
        /**
         * Retrieve a [RawR](https://docs.polyphony.chat/Protocol%20Specifications/core/#731-resource-addressing-with-relative-roots)
         * resource by specifying the ID of the resource.
         * @param rid: Resource Identifier - unique identifier for a resource.
         * @returns
         * - `200`: File found and retrieved.
         * - `401`: Server or resource requires authentication to access this endpoint.
         * - `403`: Server or resource not accessible for the actor making this request.
         * - `404`: Resource not found.
         */
        op getResource(@path rid: string): {
            @statusCode _ : 403 | 401 | 404;
        } | {
            @statusCode _ : 200;
            @body body: File;
        };
    }

    @tag("Resource addressing with relative roots - Registration required")
    @useAuth(BearerAuth)
    namespace Registered {
        @route("/{rid}")
        @post
        @added(Version.`v1.0-alpha.1`)
        @summary("Upload RawR resource")
        op postResource(@path rid: string, @header({name: "Content-Length"}) contentLength: uint64): {
            // TODO
        };
    }

}

// rawr x3