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

namespace Services {
    @tag("Services - Registration required")
    @useAuth(BearerAuth)
    namespace Registered {
        /**
         * Add a service to the list of services discoverable by other actors.
         */
        @route("/services")
        @post
        @summary("Add service to be discovered")
        @added(Version.`v1.0-beta.1`)
        @returnsDoc("A singular service object, representing the service that was added.")
        @errorsDoc("Returned, if the service and URL combination already exists in the list of discoverable services.")
        op registerService(service: polyproto.core.models.Service): {
            @statusCode statusCode: 201;
            @body body: polyproto.core.models.Service;
        } | {
            @statusCode statusCode: 409;
        };

        /**
         * Remove a service from the list of services discoverable by other actors.
         * If a primary service is removed and there are still other providers available for the same service,
         * the server will select a new primary service provider from the list of available providers.
         * This new provider will be returned in the response body.
         * @param url List of urls of the service providers to remove. The indices of the urls list must match the indices of the service name list.
         * @param sensitiveSolution: Required only when deleting a primary service provider.
         * @param name List of urls of the service providers to remove. The indices of the service name list must match the indices of the urls list.
         */
        @route("/services")
        @delete
        @summary("Delete discoverable service")
        @added(Version.`v1.0-beta.1`)
        @tag("Sensitive Actions")
        op unregisterService(
            @doc("Sensitive actions require a second factor of authentication to be executed. Read [section 4.1.2 of the protocol definition](https://docs.polyphony.chat/Protocol%20Specifications/core/#412-sensitive-actions) for more information.")
            @header(#{ name: "X-P2-Sensitive-Solution" })
            sensitiveSolution?: string,

            @query url: url[],
            @query name: string[],
        ): {
            @statusCode statusCode: 200;
            @body returnedBody?: {
                service: string;
                new_primary: url;
            }[];
        } | {
            @statusCode statusCode: 400 | 403 | 404;
        };

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
        @route("/services/primary")
        @put
        @tag("Sensitive Actions")
        @summary("Set primary service provider")
        @added(Version.`v1.0-beta.1`)
        op setPrimaryProvider(
            @doc("Sensitive actions require a second factor of authentication to be executed. Read [section 4.1.2 of the protocol definition](https://docs.polyphony.chat/Protocol%20Specifications/core/#412-sensitive-actions) for more information.")
            @header(#{ name: "X-P2-Sensitive-Solution" })
            sensitiveSolution: string,

            @body body: {
                url: url;
                @minLength(2) @maxLength(64) name: string;
            },
        ): {
            @statusCode statusCode: 200;

            @maxItems(2)
            @minItems(1)
            @body
            body: polyproto.core.models.Service[];
        } | {
            @statusCode statusCode: 400 | 403;
        };
    }

    @tag("Services - Registration not required")
    namespace Unregistered {
        /**
         * Fetch a list of all services that the actor has made discoverable. Clients should not expect
         * this list to be ordered in any particular way.
         * @returns JSON array of [service objects](./Types/service.md). A list of all services which the actor has
         * made discoverable.
         * @param fid The ID of the actor whose services should be returned.
         * @param limit The maximum number of services to return. Not specifying a limit will return all
         * services. Specifying a limit of `1` will return only the primary service provider for each service.
         */
        @route("/services/discover/")
        @get
        @summary("Discover services of actor")
        @added(Version.`v1.0-beta.1`)
        op getServicesOfActor(
            @path fid: string,
            @query @minValue(1) limit?: uint64,
        ):
            | polyproto.core.models.Service[]
            | {
                  @statusCode statusCode: 204;

                  @header(#{ name: "Content-Length" })
                  contentLength: 0;
              }
            | {
                  @statusCode statusCode: 404;
              }
            | {
                  @statusCode statusCode: 200;
                  @body body: polyproto.core.models.Service[];
              };

        /**
         * Get all service providers an actor is registered with, limited to a specific service.
         * Clients should not expect this list to be ordered in any particular way.
         * @returns JSON array of [service objects](./Types/service.md), filtered by the specified service.
         * @param fid The ID of the actor whose services should be returned.
         * @param limit The maximum number of services to return. Not specifying a limit will return all
         * services. Specifying a limit of `1` will return only the primary service provider for the specified service.
         * @param service The name of the service to discover providers of.
         */
        @route("/services/discover/{fid}/{service}")
        @get
        @summary("Discover single service of actor")
        @added(Version.`v1.0-beta.1`)
        op getSingleServiceOfActor(
            @path fid: string,
            @path service: string,
            @query @minValue(1) limit?: uint64,
        ):
            | polyproto.core.models.Service[]
            | {
                  @statusCode statusCode: 204;

                  @header(#{ name: "Content-Length" })
                  contentLength: 0;
              }
            | {
                  @statusCode statusCode: 404;
              }
            | {
                  @statusCode statusCode: 200;
                  @body body: polyproto.core.models.Service[];
              };
    }
}
