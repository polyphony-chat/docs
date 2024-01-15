---
title: Client-Home Server API Routes
weight: -1000
---

All API endpoints needed for Client-Home Server communication.
A "Client" in this context is a user or bot client.
This Page only includes routes which a client can request from its home server. For routes which
can also be accessed from a foreign server, or with no authentication at all, see the
[Client-Foreign Server API documentation](../Client-Foreign%20Server%20API/index.md)

!!! bug "TODO"

    TODO: Add/rework routes according to the new section 4 of the spec.

--8<-- "snippets/api.md"

## <span class="group-h">Federation tokens</span>

Routes concerning the creation, deletion and management of federation tokens.

---

### <span class="request-h"><span class="request request-post">POST</span> Generate Federation Token [:material-lock-outline:](#authorization "Authorization required") </span>

`/p2core/token`

#### Request

##### Body

| Name     | Type   | Description                                             |
| -------- | ------ | ------------------------------------------------------- |
| `server` | String | The URL of the server the token should be generated for |

```json
{
    "server", "https://someserver.example.com"
}
```

##### cURL

```bash
curl -X POST https://example.com/p2core/token \
-H 'Authorization: Bearer <your_token>' \
-H 'Content-Type: application/json' \
-d '{"server":"https://someserver.example.com"}'
```

#### Response

=== "201 Created"

##### Body

The generated Federation Token

```json
"aC73Bd8Klaq51Ghmla84Aui..."
```

---

### <span class="request-h"><span class="request request-put">PUT</span> Manage Token Generation Status [:material-lock-outline:](#authorization "Authorization required") [:material-shield-crown-outline:]("This route is only available to server administrators")</span>

`/p2core/token/status`

#### Request

##### Body

| Name      | Type    | Description                                                                |
| --------- | ------- | -------------------------------------------------------------------------- |
| `enabled` | boolean | Whether this server should accept new federation token generation requests |

```json
{
    "enabled": true
}
```

#### Response

=== "204 No Content"

##### Body

This response has no body.

---

### <span class="request-h"><span class="request request-delete">DELETE</span> Federation Tokens for Self [:material-lock-outline:](#authorization "Authorization required")</span>

`/p2core/token/@me`

#### Request

##### Body

This request has no body.

#### Response

=== "204 No Content"

##### Body

| Type | Description                              |
| ---- | ---------------------------------------- |
| uint | The number of deleted federation tokens. |

```json
3
```

---

### <span class="request-h"><span class="request request-delete">DELETE</span> Federation Tokens for User [:material-lock-outline:](#authorization "Authorization required") [:material-shield-crown-outline:]("This route is only available to server administrators")</span>

`/p2core/token/:user_id`

#### Request

##### Parameters

| Name      | Type      | Description                                     |
| --------- | --------- | ----------------------------------------------- |
| `user_id` | Snowflake | `user_id` to delete all generation tokens from. |

##### Body 

This request has no body.

#### Response

=== "204 No Content"

##### Body

This response has no body.

---

### <span class="request-h"><span class="request request-delete">DELETE</span> Federation Tokens for everyone [:material-lock-outline:](#authorization "Authorization required") [:material-shield-crown-outline:]("This route is only available to server administrators")</span>

`/p2core/token/@all`

#### Request

##### Body 

This request has no body.

#### Response

=== "204 No Content"

##### Body

This response has no body.

---

## <span class="group-h">Federated Identity</span>

Client-Home Server API endpoints which are concerned with Federated Identity, managing keys, etc.

---

### <span class="request-h"><span class="request request-post">POST</span> Rotate session ID-Cert [:material-lock-outline:](#authorization "Authorization required")</span>

`/p2core/key/user/@me`

!!! info

    This endpoint has a twin, which can be accessed by any server, not just the home server of the user.
    See [Client-Foreign Server API/Rotate session ID-Cert](../Client-Foreign%20Server%20API/index.md#post-rotate-session-id-cert) for more information.

#### Request

##### Body

| Type | Description |
| ---- | ----------- |
| String | The client's public key, encoded in ASCII |

```json
"-----BEGIN PGP PUBLIC KEY BLOCK-----
mQINBGSDs58BEADCXP1ArorBtOvGnQdAD26gsOMasyLMqnJyUp8XXCdmTx5+gREs
vtItmjIshHU6CLUyTwO2IqIb2Fds+AmDsdM1Qx/vM0fVtPAS13T3Tu9rknldJvvN
GyT3urrgvZ1leqQnwvuHd3WMdtgQ29lc7F/XaP4v2RIlqUiV+bnBoe/6LL7HXTaW
zy2oKXr/odOD4+476J5APxxXCWVLXr3qfAXmSBQERznYuuRmhyL...
-----END PGP PUBLIC KEY BLOCK-----"
```

#### Response

=== "201 Created"

##### Body

| Type   | Description                                                          |
| ------ | -------------------------------------------------------------------- |
| String | The server generated ID-Cert for this public key, encoded in Base64. |

```json
"LS0tLS1CRUdJTiBQR1AgUFVCTElDIEtFWS0tLS0tCk1JSUJqRENDQWlNQ0NRRHdFTE1Ba0dBMVVFQ2d3R2FWTnZiV0ZwYm..."
```

---

### <span class="request-h"><span class="request request-post">POST</span> Add KeyPackage [:material-lock-outline:](#authorization "Authorization required")</span>

`/p2core/keypackage/@me`

#### Request

##### Body

| Type | Description |
| ---- | ----------- |
| JSON-Array of KeyPackages | One or more KeyPackages to add to the available KeyPackages for this user. |

```json
[ {...}, {...} ]
```

#### Response

=== "201 Created"

##### Body

This response has no body.

---

### <span class="request-h"><span class="request request-put">PUT</span> Replace Last Resort KeyPackage [:material-lock-outline:](#authorization "Authorization required")</span>

`/p2core/keypackage_lr`

#### Request

##### Body

| Type | Description |
| ---- | ----------- |
| KeyPackage | The KeyPackage to replace the current Last Resort KeyPackage with. |

```json
{...}
```

#### Response

=== "204 No Content"

##### Body

This response has no body.

---

--8<-- "snippets/glossary.md"
