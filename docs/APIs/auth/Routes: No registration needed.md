---
title: "Authentication Routes: No registration needed"
weight: -900
---

All API endpoints needed for implementing polyproto-auth.
This Page only includes routes, for which a client does not need a "Client-Home Server relationship"
with the server.

!!! bug "Unfinished section"

    TODO: This section is not yet finished. It is missing descriptions for most routes, some error-code responses, etc.

--8<-- "snippets/api.md"

---

### <span class="request-h"><span class="request request-post">POST</span> Create Identity</span>

`/.p2/core/v1/register`

Creates an identity on a given server.

#### Request

##### Body

TODO: Re-evaluate if `auth_payload` is needed here.

| Name                                                                                                                                                                                                                            | Type        | Description                               |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ----------------------------------------- |
| `actor_name`                                                                                                                                                                                                                    | String      | The preferred name for this new identity. |
| `auth_payload` :material-help:{title="This field is optional."} :material-code-braces:{title="The actual contents of this attribute are implementation-specific. polyproto-core does not provide any defaults for this field."} | JSON-Object | n. A.                                     |

```json
{
    "actor_name": "alice",
    "auth_payload": {
        "password": "3c4589y70masfnmAML2"
    }
}
```

#### Response

=== "201 Created"


        ##### Body

        | Name                                                                                                                                                                                                                       | Type        | Description                                                               |
        | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ------------------------------------------------------------------------- |
        | `fid`                                                                                                                                                                                                                      | String      | The [Federation ID](../../Glossary.md#federation-id) of the new identity. |
        | `payload` :material-help:{title="This field is optional."} :material-code-braces:{title="The actual contents of this attribute are implementation-specific. polyproto-core does not provide any defaults for this field."} | JSON-Object | -                                                                         |

        ```json
        {
            "fid": "xenia@example.com",
            "payload": {
                "some_account_information": "important information",
                "is_awesome": true
            }
        }
        ```

=== "409 Conflict"

        Returned when the requested actor name is already taken within the namespace.

        ##### Body

        ```json
        {
            "errcode": 409,
            "error": "P2CORE_FEDERATION_ID_TAKEN"
        }
        ```

---

### <span class="request-h"><span class="request request-post">POST</span> Identify</span>

`/.p2/core/v1/session/identify`

Identify on a foreign server and receive a session token.

#### Request

##### Body

| Name                                                                                                                                                                                                                            | Type                | Description                                                                                                                                                                                                                                  |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `challenge`                                                                                                                                                                                                                     | String              | The [completed challenge](../types.md#completed-challenge-string), consisting of a UTF-8 encoded signature value and the original challenge string. The signature value must have been created using the private identity key of that actor. |
| `id_cert`                                                                                                                                                                                                                       | String, PEM, Base64 | The client's [ID-Cert](/Protocol%20Specifications/core/#71-home-server-signed-certificates-for-public-client-identity-keys-id-cert), encoded in PEM & Base64.                                                                                |
| `auth_payload` :material-help:{title="This field is optional."} :material-code-braces:{title="The actual contents of this attribute are implementation-specific. polyproto-core does not provide any defaults for this field."} | JSON-Object         | -                                                                                                                                                                                                                                            |

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
    | `payload` :material-help:{title="This field is optional."} :material-code-braces:{title="The actual contents of this attribute are implementation-specific. polyproto-core does not provide any defaults for this field."} | JSON-Object | -                                                                     |

    ```json
    {
        "token": "G5a6hjv2ijcnr3ghjHV74jahUH675678rbnFGNHJV...",
        "payload": {
            "my_custom_response_attribute": "my_custom_response_value"
        }
    }
    ```
---

### <span class="request-h"><span class="request request-put">PUT</span> Revoke session authentication [:material-lock-outline:](#authorization "Authorization required")</span>

`/.p2/core/v1/session/revoke`

Revoke the current session's authentication by having the server invalidate the session token.
Can also be seen as a "logout" operation.

#### Request

##### Body

This request has no body.

#### Response

=== "204 No Content"

    ##### Body

    This response has no body.


---
