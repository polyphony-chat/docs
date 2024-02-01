---
title: Client-Home Server API Routes
weight: -1000
---

All API endpoints needed for Client-Home Server communication.
This Page only includes routes which a client can request from its home server. For routes which
can also be accessed from a foreign server, or with no authentication at all, see the
[Client-Foreign Server API documentation](../Client-Foreign%20Server%20API/index.md)

!!! bug "Unfinished section"

    TODO: This section is not yet finished. It is missing descriptions for most routes, some error-code responses, etc.

--8<-- "snippets/api.md"

---

## <span class="group-h">Authentication</span>

Authentication endpoints, such as creating an identity and authenticating a client with an identity.

---

### <span class="request-h"><span class="request request-post">POST</span> Authenticate new Session</span>

`/p2core/session/trust`

Creates a new `id_cert` and a session token from a `csr`.

#### Request

##### Body

| Name                                                                                                                                                                                                                            | Type           | Description                                                                                                                         |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `actor_name`                                                                                                                                                                                                                      | String         | The actor name of the identity to authenticate as.                                                                                       |
| `csr`                                                                                                                                                                                                                           | String, Base64 | A [certificate signing request (CSR)](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) |
| `password` :material-help:{title="This field is optional."}                                                                                                                                                                     | String         | The password for this identity.                                                                                                     |
| `auth_payload` :material-help:{title="This field is optional."} :material-code-braces:{title="The actual contents of this attribute are implementation-specific. polyproto-core does not provide any defaults for this field."} | JSON-Object    | n. A.                                                                                                                                |

#### Response

=== "201 Created"

    ##### Body

    | Name      | Type           | Description                                                                                                                                                             |
    | --------- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | `id_cert` | String, Base64 | The [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) for this unique Identity-Session combination |
    | `token`   | String         | An authorization secret, called a "token", valid for this `id_cert`. |

---

## <span class="group-h">Federated Identity</span>

Client-Home Server API endpoints concerned with Federated Identity and managing ID-Certs.

---

### <span class="request-h"><span class="request request-post">POST</span> Rotate session ID-Cert [:material-lock-outline:](#authorization "Authorization required")</span>

`/p2core/session/idcert`

Rotate your keys for a given ID-Cert. The `session_id` in the supplied `csr` must correspond to the
session token used in the `authorization`-Header.

#### Request

##### Body

| Name  | Type           | Description                                                                                                                                                                                         |
| ----- | -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `csr` | String, Base64 | A [certificate signing request (CSR)](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) containing a new public key for this session ID. |

```json
{
    "csr": "mQINBGSDs58BEADCXP1ArorBtOvGnQdAD26gsOMasyLMqnJyUp8XXCdmTx5..."
}
```

#### Response

=== "201 Created"

    Contains your new ID-Cert, along with a new session token.

    ##### Body

    | Name      | Type           | Description                                                                                                                           |
    | --------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
    | `id_cert` | String, Base64 | The generated [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert). |
    | `token`   | String         | An authorization secret, called a "token", valid for this `id_cert`. |

    ```json
    { 
        "id_cert": "LS0tLS1CRUdJTiBQR1AgUFVCTElDIEtFWS0tLS0tCk1JSUJqRENDQWlNQ0NRRHdFTE1Ba0dBMVVFQ2d3R2FWTnZiV0ZwYm...",
        "token": "Afnaopgi7BXVafjkl34ulvkc..."
    }
    ```

---

## <span class="group-h">Encryption</span>

Client-Home Server API endpoints concerned with encryption, such as KeyPackage management.

---

### <span class="request-h"><span class="request request-post">POST</span> Add KeyPackage [:material-lock-outline:](#authorization "Authorization required") :material-file-question-outline:{title="This route is optional. Consult the documentation of a specific polyproto extension to check whether it exists."}</span>

`/p2core/keypackage/@me`

Add a KeyPackage to your KeyPackage store on the server. Only adds KeyPackages to the ID-Cert corresponding
to the session token used in the `authorization`-Header.

#### Request

##### Body

| Type                      | Description                                                                |
| ------------------------- | -------------------------------------------------------------------------- |
| JSON-Array of KeyPackages | One or more KeyPackages to add to the available KeyPackages for this actor. |

```json
[ {...}, {...} ]
```

#### Response

=== "201 Created"

    ##### Body

    This response has no body.

---

### <span class="request-h"><span class="request request-put">PUT</span> Replace Last Resort KeyPackage [:material-lock-outline:](#authorization "Authorization required") :material-file-question-outline:{title="This route is optional. Consult the documentation of a specific polyproto extension to check whether it exists."}</span>

`/p2core/keypackage_lr`

Replace a Last Resort KeyPackage with a new one. Only manipulates Last Resort KeyPackages for the ID-Cert
corresponding to the session token used in the `authorization`-Header.

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
