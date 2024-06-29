# Service

A resource representing information about a discoverable service for an actor. You can learn more about
services and discoverability by reading [section #9](/Protocol Specifications/core#9-services) of
the core protocol specification.

This resource contains information about the name of the service that is being made discoverable,
the URL of the service provider, and whether this service provider is the primary service provider
for the actor.

## JSON representation

```json
{
    "service": "example-service",
    "url": "https://example.com/",
    "primary": true
}
```

### Fields

| Field     | Type        | Description                                                                                                                                                                                                                                                      |
| --------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `service` | String      | The name of the service that is being made discoverable. Must be formatted according to [section #8.2: Namespaces](/Protocol Specifications/core#82-namespaces) in the core protocol specification                                                               |
| `url`     | String, URL | The base URL of the service provider, not including `/.p2/<service_name>`. Trailing slashes are allowed. If `(/).p2/<service_name>` is added to the URL specified here, a polyproto client should be able to access the HTTP API routes provided by the service. |
| `primary` | Boolean     | Whether the service provider specified in the `url` field is the primary service provider for this service and actor.                                                                                                                                            |

All fields are required.

## Glossary

--8<-- "snippets/glossary.md"
