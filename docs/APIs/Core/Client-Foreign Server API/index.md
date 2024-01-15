---
title: Client-Foreign Server API Routes
weight: -900
---

All API endpoints needed for Client-Home Server communication.
A "Client" in this context is a user/bot client, an authenticated user or another server.
This Page only includes routes, for which a client does not need a "Client-Home Server relationship" with the server.
If you'd like to see the routes, which require such a relationship, see the [Client-Home Server API documentation](../Client-Home%20Server%20API/index.md)

!!! bug "TODO"

    TODO: Add/rework routes according to the new section 4 of the spec.

---

--8<-- "snippets/api.md"

---

## <span class="group-h">Federation Tokens</span>

Routes concerning the creation, deletion and management of federation tokens.

---

### <span class="request-h"><span class="request request-get">GET</span> Token Generation Status</span>

`/p2core/token/status`

#### Request

##### Body

This request has no body.

##### cURL

```bash
curl -X GET "https://example.com/p2core/token/status"
```

#### Response

=== "200 OK"

##### Body

| Name      | Type    | Description                                                                    |
| --------- | ------- | ------------------------------------------------------------------------------ |
| `enabled` | boolean | Whether this server currently accepts new federation token generation requests |

```json
{
    "enabled": true
}
```

---

## <span class="group-h">Federated Identity</span>

Routes concerning federated identities, such as authentication and key management.

---

### <span class="request-h"><span class="request request-post">POST</span> Generate Session Token [:material-lock-outline:](#authorization "Authorization required")</span>

`/p2core/session/auth`

#### Request

##### Body

| Name                                                                                                                                                | Type                     | Description                                                   |
| --------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ | ------------------------------------------------------------- |
| `federation_token`                                                                                                                                  | Federation Token         | A valid federation token to authenticate with on this server. |
| `id_cert`                                                                                                                                           | ID-Cert, Binary Data     | The client's ID-Cert.                                         |
| `key_packages` :material-email-lock-outline:{title="This field is only required in polyproto-core implementations which support MLS encryption."}   | JSON-Array of KeyPackage | One or more KeyPackages                                       |
| `key_package_lr` :material-email-lock-outline:{title="This field is only required in polyproto-core implementations which support MLS encryption."} | KeyPackage               | A "Last-Resort" KeyPackage                                    |

```json
{
    "federation_token": {...},
    "id_cert": [...],
    "key_packages": [{...}, {...}],
    "key_package_lr": {...}
}
```

#### Response

=== "201 Created"

##### Body

| Name                                                     | Type        | Description                                                                                                                                                                                                                                                 |
| -------------------------------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `session_token`                                          | String      | The generated session token                                                                                                                                                                                                                                 |
| `extra` :material-help:{title="This field is optional."} | JSON Object | Implementation-specific data which might be sent along the session token, when the authentication succeeds. Read the documentation of the specific polyproto-core implementation to see if this field should be expected, and if so, what its contents are. |

```json
{
    "session_token": "eYjd34GsAdfgAd.4332hfiwodm3lo...",
    "extra": {...}
}
```

---

### <span class="request-h"><span class="request request-put">PUT</span> Rotate Server Identity Key [:material-lock-outline:](#authorization "Authorization required") [:material-shield-crown-outline:]("This route is only available to server administrators")</span>

`/p2core/key/server`

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

### <span class="request-h"><span class="request request-get">GET</span> Server ID-Cert</span>

`/p2core/key/server`

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
| ID-Cert, Binary  | The servers' public identity certificate, in binary format.     |

```json
[...]
```

---

### <span class="request-h"><span class="request request-get">GET</span> User ID-Cert(s)</span>

`/p2core/key/user/:user_id`

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

| Type                             | Description                                                  |
| -------------------------------- | ------------------------------------------------------------ |
| JSON-Array of ID-Cert(s), Binary | The user's public identity certificate(s), in binary format. |

```json
[...]
```

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

### <span class="request-h"><span class="request request-post">POST</span> Rotate session ID-Cert [:material-lock-outline:](#authorization "Authorization required")</span>

`/p2core/key/user/@me`

!!! info

    This endpoint has a twin, for when the server the client is interacting with, is its home server.
    See [Client-Home Server API/Rotate session ID-Cert](../Client-Home%20Server%20API/index.md#post-rotate-session-id-cert) for more information.

#### Request

##### Body

| Type             | Description                                                                 |
| ---------------- | --------------------------------------------------------------------------- |
| ID-Cert, Binary  | The new public identity certificate, in binary format.                      |

```json
[...]
```

#### Response

=== "201 Created"

##### Body

This response has no body.

---

--8<-- "snippets/glossary.md"

