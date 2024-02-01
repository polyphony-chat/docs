---
title: Client-Foreign Server API Routes
weight: -900
---

All API endpoints needed for Client-Home Server communication.
A "Client" in this context is a user or bot client, an authenticated user or another server.
This Page only includes routes, for which a client does not need a "Client-Home Server relationship" with the server.
Routes explicitly requiring a Client->Home Server relationship are documented [here](../Client-Home%20Server%20API/index.md)

!!! bug "Unfinished section"

    TODO: This section is not yet finished. It is missing descriptions for most routes, some error-code responses, etc.

---

--8<-- "snippets/api.md"

---

## <span class="group-h">Authentication</span>

Routes concerning authentication.

---

### <span class="request-h"><span class="request request-get">GET</span> Challenge string</span>

`/p2core/challenge`

Request a challenge string. See [the type definition](../types.md#challenge-string) or the corresponding
[protocol definition chapter](/Protocol%20Specifications/core/#) for more information.

#### Request

##### Body

This request has no body.

#### Response

    === "200 OK"

    ##### Body

    | Name            | Type   | Description                                                                                                       |
    | --------------- | ------ | ----------------------------------------------------------------------------------------------------------------- |
    | `challenge`     | String | The [challenge string](../types.md#challenge-string), which the client should sign with its private identity key. |
    | `lifetime_unix` | String | The UNIX timestamp after which the challenge expires.                                                             |

    ```json
    {
        "challenge": "UH675678rbnFGNHJV2ijcnr3ghjHV74jah...",
        "lifetime_unix": "1620000000"
    }
    ```

---

### <span class="request-h"><span class="request request-post">POST</span> Identify</span>

`/p2core/session/identify`

Identify on a foreign server and receive a session token.

#### Request

##### Body

| Name                                                                                                                                                                                                                            | Type           | Description                                                                                                                                             |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `challenge`                                                                                                                                                                                                                     | String         | The [completed challenge string](../types.md#completed-challenge-string), signed with the client's private identity key.                                |
| `id_cert`                                                                                                                                                                                                                       | String, Base64 | The client's [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert), encoded in Base64. |
| `auth_payload` :material-help:{title="This field is optional."} :material-code-braces:{title="The actual contents of this attribute are implementation-specific. polyproto-core does not provide any defaults for this field."} | JSON-Object    | n. A.                                                                                                                                                    |

```json
{
    "completed_challenge": {
        "challenge": "UH675678rbnFGNHJV2ijcnr3ghjHV74jah...",
        "signature": "Ac4hjv2ijcnr3ghjHV74jahUH675678rbnFGNHJV..."
    },
    "id_cert": "gA3hjv2ijcnr3ghjHV74jahUH675678rbnFGNHJV...",
    "auth_payload": {
        "my_custom_attribute": "my_custom_value"
    }
}
```

#### Response

=== "201 Created"

    ##### Body

    | Name                                                                                                                                                                                                                       | Type        | Description                                                           |
    | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | --------------------------------------------------------------------- |
    | `token`                                                                                                                                                                                                                    | String      | A session token, to be used for further identification/authentication |
    | `payload` :material-help:{title="This field is optional."} :material-code-braces:{title="The actual contents of this attribute are implementation-specific. polyproto-core does not provide any defaults for this field."} | JSON-Object | n.A.                                                                  |

    ```json
    {
        "token": "G5a6hjv2ijcnr3ghjHV74jahUH675678rbnFGNHJV...",
        "payload": {
            "my_custom_response_attribute": "my_custom_response_value"
        }
    }
    ```

---

## <span class="group-h">Federated Identity</span>

Routes concerning federated identities, such as authentication and ID-Cert management.

---

### <span class="request-h"><span class="request request-put">PUT</span> Rotate Server Identity Key [:material-lock-outline:](#authorization "Authorization required") [:material-shield-crown-outline:]("This route is only available to server administrators")</span>

`/p2core/key/server`

Rotate the server's identity key.

#### Request

##### Body

This request has no body.

#### Response

=== "200 OK"

    ##### Body

    | Type   | Description                                                    |
    | ------ | -------------------------------------------------------------- |
    | String | The servers' new public identity key, in ASCII-representation. |

    ```json
    "-----BEGIN PGP PUBLIC KEY BLOCK-----
    mQINBGSDs58BEADCXP1ArorBtOvGnQdAD26gsOMasyLMqnJyUp8XXCdmTx5+gREs
    vtItmjIshHU6CLUyTwO2IqIb2Fds+AmDsdM1Qx/vM0fVtPAS13T3Tu9rknldJvvN
    GyT3urrgvZ1leqQnwvuHd3WMdtgQ29lc7F/XaP4v2RIlqUiV+bnBoe/6LL7HXTaW
    zy2oKXr/odOD4+476J5APxxXCWVLXr3qfAXmSBQERznYuuRmhyL...
    -----END PGP PUBLIC KEY BLOCK-----"
    ```

---

### <span class="request-h"><span class="request request-get">GET</span> Server Public Identity Key</span>

`/p2core/key/server`

Request the server's public identity key.

#### Request

##### Body

| Name                                                         | Type   | Description                                                                                         |
| ------------------------------------------------------------ | ------ | --------------------------------------------------------------------------------------------------- |
| `timestamp` :material-help:{title="This field is optional."} | String | UNIX-Timestamp. If specified, the server will return the ID-Cert which it had at the specified time |

```json
{
    "timestamp": "1620000000"
}
```

#### Response

=== "200 OK"

##### Body

    | Type             | Description                                                    |
    | ---------------- | -------------------------------------------------------------- |
    | String, Base64  | The servers' public [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert).     |

    ```json
    [...]
    ```

---

### <span class="request-h"><span class="request request-get">GET</span> User ID-Cert(s)</span>

`/p2core/key/user/:user_id`

Request the ID-Cert or ID-Certs of a specific user. The specified user must be registered on this
server

#### Request

##### Parameters

| Name      | Type      | Description                                                                 |
| --------- | --------- | --------------------------------------------------------------------------- |
| `user_id` | Snowflake | The ID of the user whose ID-Cert(s) should be returned.                     |

##### Body

| Name                                                         | Type   | Description                                                                                                  |
| ------------------------------------------------------------ | ------ | ------------------------------------------------------------------------------------------------------------ |
| `timestamp` :material-help:{title="This field is optional."} | String | UNIX-Timestamp. If specified, the server will return the ID-Cert(s) which the user had at the specified time |

```json
{
    "timestamp": "1620000000"
}
```

#### Response

=== "200 OK"

    ##### Body

    | Type                           | Description                                                   |
    | ------------------------------ | ------------------------------------------------------------- |
    | JSON-Array of Strings (Base64) | The user's public identity certificate(s), encoded in Base64. |

    ```json
    [...]
    ```

---

### <span class="request-h"><span class="request request-post">POST</span> Rotate session ID-Cert [:material-lock-outline:](#authorization "Authorization required")</span>

`/p2core/session/idcert/extern`

#### Request

##### Body

| Type           | Description                                                                                                                                         |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| String, Base64 | The new [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) for this session ID. |

```json
[...]
```

#### Response

=== "201 Created"

    ##### Body

    This response has no body.

    ---

## <span class="group-h">Encryption</span>

Client-Foreign Server API endpoints which are concerned with encryption related tasks.

---

### <span class="request-h"><span class="request request-get">GET</span> KeyPackage(s) [:material-lock-outline:](#authorization "Authorization required")</span>

`/p2core/keypackage/:user_id`

#### Request

##### Parameters

| Name      | Type      | Description                                                                 |
| --------- | --------- | --------------------------------------------------------------------------- |
| `user_id` | Snowflake | The ID of the user whose KeyPackage(s) should be returned.                  |

##### Body

This request has no body.

#### Response

=== "200 OK"

    ##### Body

    | Type                                | Description                                                                                                                                   |
    | ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
    | JSON-Array of KeyPackage(s), Binary | The user's KeyPackage(s), in binary format. Each entry in the array corresponds to a different client the requested user is authenticated on. |

    ```json
    [...]
    ```

---

## <span class="group-h">Other</span>

Routes not fitting into another category.

---

### <span class="request-h"><span class="request request-get">GET</span> Events [:material-lock-outline:](#authorization "Authorization required")</span>

`/p2core/events`

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

--8<-- "snippets/glossary.md"

