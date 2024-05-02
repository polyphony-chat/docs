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

`/p2core/challenge`

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

`/p2core/key/server`

Rotate the server's identity key.

#### Request

##### Body

This request has no body.

#### Response

=== "200 OK"

    ##### Body

    | Type        | Description                                          |
    | ----------- | ---------------------------------------------------- |
    | String, PEM | The servers' new public identity key, encoded as PEM |

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
    | String, PEM, Base64  | The servers' public [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert).     |

    ```json
    [...]
    ```

---

### <span class="request-h"><span class="request request-get">GET</span> Actor ID-Cert(s)</span>

`/p2core/key/actor/:fid`

Request the ID-Certs of a specific actor. The specified actor must be registered on this
server.

#### Request

##### Parameters

| Name  | Type                  | Description                                              |
| ----- | --------------------- | -------------------------------------------------------- |
| `fid` | String, Federation ID | The ID of the actor whose ID-Cert(s) should be returned. |

##### Body

| Name                                                          | Type   | Description                                                                                                   |
| ------------------------------------------------------------- | ------ | ------------------------------------------------------------------------------------------------------------- |
| `timestamp` :material-help:{title="This field is optional."}  | String | UNIX-Timestamp. If specified, the server will return the ID-Cert(s) which the actor had at the specified time |
| `session_id` :material-help:{title="This field is optional."} | String | Request the ID-Cert for a specific session ID.                                                                |

```json
{
    "timestamp": "1620000000",
    "session_id": "593b30d8-0c98-4393-9331-988281b46782"
}
```

#### Response

=== "200 OK"

    ##### Body

    | Type                                | Description                                                          |
    | ----------------------------------- | -------------------------------------------------------------------- |
    | JSON-Array of Strings (PEM, Base64) | The actor's public identity certificate(s), encoded in PEM (Base64). |

    ```json
    [...]
    ```

---

### <span class="request-h"><span class="request request-post">POST</span> Update session ID-Cert [:material-lock-outline:](#authorization "Authorization required")</span>

`/p2core/session/idcert/extern`

Lets a foreign server know that the ID-Cert of this session has changed.

#### Request

##### Body

| Type                | Description                                                                                                                                         |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| String, PEM, Base64 | The new [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) for this session ID. |

```json
[...]
```

#### Response

=== "201 Created"

    ##### Body

    This response has no body.

    ---

## <span class="group-h">Encryption</span>

Client-Foreign Server API endpoints concerned with encryption related tasks.

---

### <span class="request-h"><span class="request request-get">GET</span> KeyPackage(s) [:material-lock-outline:](#authorization "Authorization required") :material-file-question-outline:{title="This route is optional. Consult the documentation of a specific polyproto extension to check whether it exists."}</span>

`/p2core/keypackage/:fid`

Request KeyPackages - initial encryption keying material - for a specific actor from the server.
The requested actor must be registered on this server.

#### Request

##### Parameters

| Name  | Type                  | Description                                                            |
| ----- | --------------------- | ---------------------------------------------------------------------- |
| `fid` | String, Federation ID | The Federation ID of the actor whose KeyPackage(s) should be returned. |

##### Body

This request has no body.

#### Response

=== "200 OK"

    ##### Body

    | Type                                | Description                                                                                                                                   |
    | ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
    | JSON-Array of KeyPackage(s), Base64 | The actor's KeyPackage(s), Base64 encoded. Each entry in the array corresponds to a different client the requested actor is authenticated on. |

    ```json
    [...]
    ```

---

## <span class="group-h">Other</span>

Routes not fitting into another category.

---

### <span class="request-h"><span class="request request-get">GET</span> Events [:material-lock-outline:](#authorization "Authorization required") :material-file-question-outline:{title="This route is optional. Consult the documentation of a specific polyproto extension to check whether it exists."}</span>

`/p2core/events`

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

--8<-- "snippets/glossary.md"

