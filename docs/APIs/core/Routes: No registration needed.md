---
title: "Core Routes: No registration needed"
weight: -900
---

All API endpoints needed for Client-Home Server communication.
This Page only includes routes, for which a client does not need a "Client-Home Server relationship" with the server.

!!! bug "Unfinished section"

    TODO: This section is not yet finished. It is missing descriptions for most routes, some error-code responses, etc.

---

--8<-- "snippets/api.md"

---

## <span class="group-h">Federated Identity</span>

Routes concerning federated identities, such as authentication and ID-Cert management.

---

### <span class="request-h"><span class="request request-get">GET</span> Challenge string</span>

`/.p2/core/v1/challenge`

Request a challenge string. See [the type definition](../types.md#challenge-string) or the corresponding
[protocol definition chapter](/Protocol%20Specifications/core/#) for more information.

#### Request

##### Body

This request has no body.

#### Response

=== "200 OK"

    ##### Body

    | Name        | Type    | Description                                                                                                       |
    | ----------- | ------- | ----------------------------------------------------------------------------------------------------------------- |
    | `challenge` | String  | The [challenge string](../types.md#challenge-string), which the client should sign with its private identity key. |
    | `expires`   | integer | The UNIX timestamp after which the challenge expires. u64 integer                                                 |

    ```json
    {
        "challenge": "UH675678rbnFGNHJV2ijcnr3ghjHV74jah...",
        "expires": "1620000000"
    }
    ```

---

### <span class="request-h"><span class="request request-put">PUT</span> Rotate Server Identity Key [:material-lock-outline:](#authorization "Authorization required") [:material-shield-crown-outline:]("This route is only available to server administrators")</span>

`/.p2/core/v1/key/server`

Rotate the server's identity key.

#### Request

##### Body

This request has no body.

#### Response

=== "200 OK"

    ##### Body

    | Type        | Description                              |
    | ----------- | ---------------------------------------- |
    | String, PEM | The servers' new ID-Cert, encoded as PEM |

    ```json
    -----BEGIN CERTIFICATE-----
    MIIH/TCCBeWgAwIBAgIQaBYE3/M08XHYCnNVmcFBcjANBgkqhkiG9w0BAQsFADBy
    MQswCQYDVQQGEwJVUzEOMAwGA1UECAwFVGV4YXMxEDAOBgNVBAcMB0hvdXN0b24x
    ETAPBgNVBAoMCFNTTCBDb3JwMS4wLAYDVQQDDCVTU0wuY29tIEVWIFNTTCBJbnRl
    cm1lZGlhdGUgQ0EgUlNBIFIzMB4XDTIwMDQwMTAwNTgzM1oXDTIxMDcxNjAwN...
    -----END CERTIFICATE-----
    ```

---

### <span class="request-h"><span class="request request-get">GET</span> Server Public ID-Cert</span>

`/.p2/core/v1/idcert/server`

Request the server's public identity certificate.

#### Request

##### Body

| Name                                                         | Type   | Description                                                                                        |
| ------------------------------------------------------------ | ------ | -------------------------------------------------------------------------------------------------- |
| `timestamp` :material-help:{title="This field is optional."} | String | UNIX-Timestamp. If specified, the server will return the ID-Cert that it had at the specified time |

```json
{
    "timestamp": "1620000000"
}
```

#### Response

=== "200 OK"

    ##### Body

    | Type        | Description                                                                                                                                              |
    | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | String, PEM | The servers' public [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert), PEM encoded. |

    ```json
    -----BEGIN CERTIFICATE-----
    MIIH/TCCBeWgAwIBAgIQaBYE3/M08XHYCnNVmcFBcjANBgkqhkiG9w0BAQsFADBy
    MQswCQYDVQQGEwJVUzEOMAwGA1UECAwFVGV4YXMxEDAOBgNVBAcMB0hvdXN0b24x
    ETAPBgNVBAoMCFNTTCBDb3JwMS4wLAYDVQQDDCVTU0wuY29tIEVWIFNTTCBJbnRl
    cm1lZGlhdGUgQ0EgUlNBIFIzMB4XDTIwMDQwMTAwNTgzM1oXDTIxMDcxNjAwN...
    -----END CERTIFICATE-----
    ```

---

### <span class="request-h"><span class="request request-get">GET</span> Server Public Key</span>

`/.p2/core/v1/key/server`

Request the server's public key.

#### Request

##### Body

| Name                                                         | Type   | Description                                                                                           |
| ------------------------------------------------------------ | ------ | ----------------------------------------------------------------------------------------------------- |
| `timestamp` :material-help:{title="This field is optional."} | String | UNIX-Timestamp. If specified, the server will return the public key that it had at the specified time |

```json
{
    "timestamp": "1620000000"
}
```

#### Response

=== "200 OK"

    ##### Body

    | Type        | Description                                                                                  |
    | ----------- | -------------------------------------------------------------------------------------------- |
    | String, PEM | PEM encoded X.509 `SubjectPublicKeyInfo` information about the server's public identity key. |

    ```json
    -----BEGIN PUBLIC KEY-----
    MIIH/TCCBeWgAwIBAgIQaBYE3/M08XHYCnNVmcFBcjANBgkqhkiG9w0BAQsFADBy
    MQswCQYDVQQGEwJVUzEOMAwGA1UECAwFVGV4YXMxEDAOBgNVBAcMB0hvdXN0b24x
    ETAPBgNVBAoMCFNTTCBDb3JwMS4wLAYDVQQDDCVTU0wuY29tIEVWIFNTTCBJbnRl
    cm1lZGlhdGUgQ0EgUlNBIFIzMB4XDTIwMDQwMTAwNTgzM1oXDTIxMDcxNjAwN...
    -----END PUBLIC KEY-----
    ```

---

### <span class="request-h"><span class="request request-get">GET</span> Actor ID-Cert(s)</span>

`/.p2/core/v1/idcert/actor/:fid`

Request the ID-Certs of a specific actor. The specified actor must be registered on this
server.

#### Request

##### Parameters

| Name  | Type                  | Description                                              |
| ----- | --------------------- | -------------------------------------------------------- |
| `fid` | String, Federation ID | The ID of the actor whose ID-Cert(s) should be returned. |

##### Body

| Name                                                          | Type                    | Description                                                                                                   |
| ------------------------------------------------------------- | ----------------------- | ------------------------------------------------------------------------------------------------------------- |
| `timestamp` :material-help:{title="This field is optional."}  | Unsigned 64-Bit Integer | UNIX-Timestamp. If specified, the server will return the ID-Cert(s) which the actor had at the specified time |
| `session_id` :material-help:{title="This field is optional."} | String                  | Request the ID-Cert for a specific session ID.                                                                |

```json
{
    "timestamp": "1620000000",
    "session_id": "593b30d8-0c98-4393-9331-988281b46782"
}
```

#### Response

=== "200 OK"

    ##### Body

    JSON-Array of Object(s), each object containing "id_cert" (PEM encoded ID-Cert) and "invalidated" (boolean).

    ```json
    [
        {
            "id_cert": " -----BEGIN CERTIFICATE-----MIIH/TC...",
            "invalidated": false
        }
    ]
    ```

    !!! note

        The `invalidated` array contains a boolean for each ID-Cert in the `idcerts` array. The
        position of the boolean in the `invalidated` array corresponds to the position of the
        ID-Cert in the `idcerts` array.

---

### <span class="request-h"><span class="request request-put">PUT</span> Update session ID-Cert [:material-lock-outline:](#authorization "Authorization required")</span>

`/.p2/core/v1/session/idcert/extern`

Lets a foreign server know that the ID-Cert of this session has changed.

#### Request

##### Body

| Type                | Description                                                                                                                                         |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| String, PEM, Base64 | The new [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) for this session ID. |

```text
[...]
```

#### Response

=== "201 Created"

    ##### Body

    This response has no body.

    ---

---

### <span class="request-h"><span class="request request-delete">DELETE</span> Delete Session</span>

`/.p2/core/v1/session`

Invalidate a session token by naming the session ID associated with it.

#### Request

##### Body

| Name         | Type   | Description                   |
| ------------ | ------ | ----------------------------- |
| `session_id` | String | The session ID to invalidate. |

```json
{
    "session_id": "593b30d8-0c98-4393-9331-988281b46782"
}
```

#### Response

=== "204 No Content"

    This response has no body.

---

## <span class="group-h">Services</span>

Routes concerned with the "Services" and "Discoverability" sections of the core polyproto specification.

---

### <span clas="request-h"><span class="request request-get">GET</span> Discover services of actor</span>

`.p2/core/v1/services/discover/:fid`

Fetch a list of all services that the actor has made discoverable.

#### Request

##### Parameters

| Name  | Type                  | Description                                              |
| ----- | --------------------- | -------------------------------------------------------- |
| `fid` | String, Federation ID | The ID of the actor whose services should be returned.   |

##### Body

| Name  | Type             | Description                               |
| ----- | ---------------- | ----------------------------------------- |
| limit | Unsigned Integer | The maximum number of services to return. |

The body is optional. Not specifying a limit will return all services.

```json
{
    "limit": 5
}
```

#### Response

=== "200 OK"

    ##### Body

    JSON array of [service objects](./Types/service.md). A list of all services which the actor has
    made discoverable.

    ```json
    [
        {
            "service": "example-service",
            "url": "https://example.com/",
            "primary": true
        }
    ]
    ```

=== "204 No Content"

    Returned, if the actor has not made any services discoverable.

    ##### Body

    This response has no body.

=== "404 Not Found"

    Returned, if the specified actor does not exist.

    ##### Body

    This response has no body.

---

### <span clas="request-h"><span class="request request-post">GET</span> Discover single service of actor</span>

`.p2/core/v1/services/discover/:fid/:service`

Get all service providers an actor is registered with, limited to a specific service.

#### Request

##### Parameters

| Name      | Type                  | Description                                                        |
| --------- | --------------------- | ------------------------------------------------------------------ |
| `fid`     | String, Federation ID | The ID of the actor whose discoverable entries should be returned. |
| `service` | String                | The service name to filter the query by.                           |

##### Body

| Name           | Type    | Description                                                           | Default |
| -------------- | ------- | --------------------------------------------------------------------- | ------- |
| `only_primary` | Boolean | If set to `true`, only the primary service provider will be returned. | `true`  |

If omitted, servers must only return the primary service provider.

```json
{
    "only_primary": false
}
```

#### Response

=== "200 OK"

    ##### Body

    JSON array of [service objects](./Types/service.md), filtered by the specified service. Will
    be an array, regardless of the `only_primary` parameter.

    ```json
    [
        {
            "service": "example-service",
            "url": "https://example.com/",
            "primary": true
        },
        {
            "service": "example-service",
            "url": "https://other.example.com/",
            "primary": false
        }
    ]
    ```

=== "204 No Content"

    Returned, if there are no discoverable entries for the specified service.

    ##### Body

    This response has no body.

=== "404 Not Found"

    Returned, if the specified actor does not exist.

    ##### Body

    This response has no body.

---

## <span class="group-h">Other</span>

Routes not fitting into another category.

---

### <span class="request-h"><span class="request request-get">GET</span> Events [:material-lock-outline:](#authorization "Authorization required") :material-file-question-outline:{title="This route is optional. Consult the documentation of a specific polyproto extension to check whether it exists."}</span>

`/.p2/core/v1/events`

Fetch Gateway events via REST.

#### Request

##### Body

This request has no body.

#### Response

=== "200 OK"

    ##### Body

    | Type                                      | Description                                                                                                                |
    | ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
    | JSON-Array of [Events](../types.md#event) | All WebSocket Events this session has missed since disconnecting from the WebSocket, or since last querying this endpoint. |

=== "409 No Content"

    Returned if there are no events to inform the client about.

    ##### Body

    This response has no body.

---

TODO: "All challenge strings and their responses created in the context of account migration must be made public to ensure that a chain of trust can be maintained"

TODO: Add routes concerned with account and data migration.

---

## Glossary

--8<-- "snippets/glossary.md"

