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

---

## <span class="group-h">Authentication</span>

Authentication endpoints, such as creating an identity and authenticating a client with an identity.

---

### <span class="request-h"><span class="request request-post">POST</span> Create Identity</span>

`/p2core/identity`

#### Request

##### Body

| Name                                                                                                                                                                                                                           | Type        | Description                                   |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- | --------------------------------------------- |
| `username`                                                                                                                                                                                                                     | String      | The preferred username for this new identity. |
| `password` :material-help:{title="This field is optional."}                                                                                                                                                                    | String      | The password for this new identity.           |
| `auth_payload` :material-help:{title="This field is optional."} :material-code-braces:{title="The actual contents of this attribute are implementation-specific. polyproto-core does not provide any defaults for this field."} | JSON-Object | n.A.                                              |

```json
{
  "username": "alice",
  "password": "s3cr3t",
  "auth_payload": {
    "email": "alice@example.com"
}
```

#### Response

=== "201 Created"

    ##### Body

    | Name                                                                                                                                                                                                                       | Type        | Description                                                               |
    | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ------------------------------------------------------------------------- |
    | `fid`                                                                                                                                                                                                                      | String      | The [Federation ID](../../Glossary.md#federation-id) of the new identity. |
    | `payload` :material-help:{title="This field is optional."} :material-code-braces:{title="The actual contents of this attribute are implementation-specific. polyproto-core does not provide any defaults for this field."} | JSON-Object | n.A. |

    ```json
    {
    "fid": "xenia@example.com",
    "payload": {
        "some_account_information": "important information"
    }
    }
    ```

=== "409 Conflict"

    ##### Body

    ```json
    {
        "errcode": 409,
        "error": "P2CORE_FEDERATION_ID_TAKEN"
    }
    ```

---

### <span class="request-h"><span class="request request-post">POST</span> Authenticate Session</span>

`/p2core/session/trust`

#### Request

##### Body

| Name                                                                                                                                                                                                                            | Type           | Description                                                                                                                         |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `username`                                                                                                                                                                                                                      | String         | The username of the identity to authenticate.                                                                                       |
| `csr`                                                                                                                                                                                                                           | String, Base64 | A [certificate signing request (CSR)](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) |
| `password` :material-help:{title="This field is optional."}                                                                                                                                                                     | String         | The password for this identity.                                                                                                     |
| `auth_payload` :material-help:{title="This field is optional."} :material-code-braces:{title="The actual contents of this attribute are implementation-specific. polyproto-core does not provide any defaults for this field."} | JSON-Object    | n.A.                                                                                                                                |

#### Response

=== "201 Created"

    ##### Body

    | Name      | Type           | Description                                                                                                                                                             |
    | --------- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | `id_cert` | String, Base64 | The [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) for this unique Identity-Session combination |

=== "409 Conflict"

    ##### Body

    ```json
    {
        "errcode": 409,
        "error": "P2CORE_SESSION_ID_TAKEN"
    }
    ```

---

## <span class="group-h">Federated Identity</span>

Client-Home Server API endpoints which are concerned with Federated Identity, managing keys, etc.

---

### <span class="request-h"><span class="request request-post">POST</span> Rotate session ID-Cert [:material-lock-outline:](#authorization "Authorization required")</span>

`/p2core/session/idcert`

#### Request

##### Body

| Type   | Description                               |
| ------ | ----------------------------------------- |
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

## <span class="group-h">Encryption</span>

Client-Home Server API endpoints which are concerned with encryption, such as KeyPackage management.

---

### <span class="request-h"><span class="request request-post">POST</span> Add KeyPackage [:material-lock-outline:](#authorization "Authorization required")</span>

`/p2core/keypackage/@me`

#### Request

##### Body

| Type                      | Description                                                                |
| ------------------------- | -------------------------------------------------------------------------- |
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

| Type       | Description                                                        |
| ---------- | ------------------------------------------------------------------ |
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
