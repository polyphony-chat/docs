---
title: "Core Routes: Registration needed"
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

## <span class="group-h">Federated Identity</span>

Client-Home Server API endpoints concerned with Federated Identity and managing ID-Certs.

---

### <span class="request-h"><span class="request request-post">POST</span> Rotate session ID-Cert [:material-lock-outline:](#authorization "Authorization required")</span>

`/.p2/core/v1/session/idcert`

Rotate your keys for a given session. The `session_id` in the supplied `csr` must correspond to the
session token used in the `authorization`-Header.

#### Request

##### Body

| Type        | Description                                                                                                                                                                     |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| String, PEM | A new [certificate signing request (CSR)](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert) with the same session ID |

```text
mQINBGSDs58BEADCXP1ArorBtOvGnQdAD26gsOMasyLMqnJyUp8XXCdmTx5...
```

#### Response

=== "201 Created"

    Contains your new ID-Cert, along with a new session token.

    ##### Body

    | Name      | Type        | Description                                                                                                                           |
    | --------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------- |
    | `id_cert` | String, PEM | The generated [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert). |
    | `token`   | String      | An authorization secret, called a "token", valid for this `id_cert`.                                                                  |

    ```json
    { 
        "id_cert": "LS0tLS1CRUdJTiBQR1AgUFVCTElDIEtFWS0tLS0tCk1JSUJqRENDQWlNQ0NRRHdFTE1Ba0dBMVVFQ2d3R2FWTnZiV0ZwYm...",
        "token": "Afnaopgi7BXVafjkl34ulvkc..."
    }
    ```

---

### <span class="request-h"><span class="request request-post">POST</span> Upload encrypted private key material [:material-lock-outline:](#authorization "Authorization required")</span>

`/.p2/core/v1/session/keymaterial`

Upload encrypted private key material to the server for later retrieval. The upload size must not exceed
the server's maximum upload size for this route. This is usually not more than 10kb and can be as
low as 800 bytes, depending on the server configuration.

#### Request

##### Body

Array of objects, each containing the following fields:

| Name                                                            | Type                                 | Description                                                            |
| --------------------------------------------------------------- | ------------------------------------ | ---------------------------------------------------------------------- |
| `key_data`                                                      | String, PEM-encoded `PrivateKeyInfo` | The encrypted private key material, PEM-encoded                        |
| `serial_number`:material-help:{title="This field is optional."} | String                               | The serial number of the ID-Cert this key material is associated with. |

```json
[
    {
        "key_data": "LS0tLS1CRUdJTiBQR1AgUFVCTElDIEtFWS0tLS0tCk1JSUJqRENDQWlNQ0NRRHdFTE1Ba0dBMVVFQ2d3R2FWTnZiV0ZwYm...",
        "serial_number": "123456789"
    },
    {
        "key_data": "LS01tLS2aXJUQWlNQ0NRRHdFTE1Ba0dBMVVFQ2d3R2FWTnZiV0ZwYmGa7cadSH9vAVKOMb478bnm43v5VS789...",
        "serial_number": "987654321"
    }
]
```

#### Response

=== "201 Created"

    ##### Body

    This response has no body.

=== "404 Not Found"

    Used, if the `serial_number` does not match any known ID-Cert from this actor.

    ##### Body

    This response has no body.

=== "409 Conflict"

    Status code for when the server already has key material for the given `serial_number`. The client
    would need to delete the existing key material before uploading new key material.

    ##### Body

    This response has no body.

=== "413 Request Entity Too Large"

    Uploaded key material exceeds the server's maximum upload size.

    ##### Body

    This response has no body.

---

### <span class="request-h"><span class="request request-get">GET</span> Get encrypted private key material [:material-lock-outline:](#authorization "Authorization required")</span>

`/.p2/core/v1/session/keymaterial`

Retrieve encrypted private key material from the server. The `serial_numbers`, if provided, must
match the serial numbers of ID-Certs that the client has uploaded key material for. If no `serial_numbers`
are provided, the server will return all key material that the client has uploaded.

#### Request

##### Body

| Type                                                            | Description                                                      |
| --------------------------------------------------------------- | ---------------------------------------------------------------- |
| Array of String:material-help:{title="This field is optional."} | The serial number(s) of the ID-Certs to get key material for. |

```json
["123456789", "987654321"]
```

#### Response

=== "200 OK"

    ##### Body

    Array of objects, each containing the following fields:

    | Name            | Type                                 | Description                                                            |
    | --------------- | ------------------------------------ | ---------------------------------------------------------------------- |
    | `key_data`      | String, PEM-encoded `PrivateKeyInfo` | The encrypted private key material, PEM-encoded                        |
    | `serial_number` | String                               | The serial number of the ID-Cert this key material is associated with. |

    ```json
    [
        {
            "key_data": "LS0tLS1CRUdJTiBQR1AgUFVCTElDIEtFWS0tLS0tCk1JSUJqRENDQWlNQ0NRRHdFTE1Ba0dBMVVFQ2d3R2FWTnZiV0ZwYm...",
            "serial_number": "123456789"
        },
        {
            "key_data": "LS01tLS2aXJUQWlNQ0NRRHdFTE1Ba0dBMVVFQ2d3R2FWTnZiV0ZwYmGa7cadSH9vAVKOMb478bnm43v5VS789...",
            "serial_number": "987654321"
        }
    ]
    ```

=== "204 No Content"

    Returned, if no `serial_numbers` are provided and the client has not uploaded any key material.

    ##### Body

    This response has no body.

=== "404 Not Found"

    Returned, if none of the `serial_numbers` match any known ID-Certs from this actor.

    ##### Body

    This response has no body.

---

### <span class="request-h"><span class="request request-delete">DELETE</span> Delete encrypted private key material [:material-lock-outline:](#authorization "Authorization required") :material-eye-lock-outline:{title="This route is considered a sensitive action."} </span>

`/.p2/core/v1/session/keymaterial`

Delete encrypted private key material from the server. The `serial_number(s)`, must match the
serial numbers of ID-Certs that the client has uploaded key material for.

#### Request

##### Body

| Type            | Description                                                      |
| --------------- | ---------------------------------------------------------------- |
| Array of String | The serial number(s) of the ID-Certs to delete key material for. |

```json
["123456789", "987654321"]
```

#### Response

=== "204 No Content"

    ##### Body

    This response has no body.

=== "404 Not Found"

    Returned, if none of the `serial_numbers` match any known ID-Certs from this actor.

    ##### Body

    This response has no body.

---

### <span class="request-h"><span class="request request-options">OPTIONS</span> Get encrypted private key material upload size limit</span>

`/.p2/core/v1/session/keymaterial`

Retrieve the maximum upload size for encrypted private key material, in bytes.

#### Response

=== "200 OK"

    ##### Headers

    | Name               | Type   | Description                      |
    | ------------------ | ------ | -------------------------------- |
    | X-Max-Payload-Size | Number | The upload size limit, in bytes. |

    ##### Body

    This response has no body.

---

TODO: Add routes concerned with account and data migration.

---

## Glossary

--8<-- "snippets/glossary.md"
