---
title: "Authentication Routes: Registration needed"
weight: -1000
---

All API endpoints needed for implementing polyproto-auth.
This Page only includes routes which a client can request from its home server. For routes which
can also be accessed from a foreign server, or with no authentication at all, see the
[Client-Foreign Server API documentation](../Client-Foreign%20Server%20API/index.md)

!!! bug "Unfinished section"

    TODO: This section is not yet finished. It is missing descriptions for most routes, some error-code responses, etc.

--8<-- "snippets/api.md"

---

### <span class="request-h"><span class="request request-post">POST</span> Authenticate new Session</span>

`/p2core/session/trust`

Creates a new `id_cert` and a session token from a `csr`.

#### Request

##### Body

| Name                                                                                                                                                                                                                            | Type           | Description                                                                                                                         |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `actor_name`                                                                                                                                                                                                                      | String         | The actor name of the identity to authenticate as.                                                                                       |
| `csr`                                                                                                                                                                                                                           | String, PEM | A [certificate signing request (CSR)](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) |                                                                                                  |
| `auth_payload` :material-help:{title="This field is optional."} :material-code-braces:{title="The actual contents of this attribute are implementation-specific. polyproto-core does not provide any defaults for this field."} | JSON-Object    | n. A.                                                                                                                                |

#### Response

=== "201 Created"

    ##### Body

    | Name      | Type        | Description                                                                                                                                                             |
    | --------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | `id_cert` | String, PEM | The [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) for this unique Identity-Session combination |
    | `token`   | String      | An authorization secret, called a "token", valid for this `id_cert`.                                                                                                    |
