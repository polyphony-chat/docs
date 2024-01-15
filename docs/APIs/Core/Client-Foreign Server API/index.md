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

## <span class="group-h">Federated Identity</span>

Routes concerning federated identities, such as authentication and ID-Cert management.

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
| String, Base64  | The servers' public [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert).     |

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

--8<-- "snippets/glossary.md"

