---
title: Server-Client API Routes
---

--8<-- "snippets/api.md"

## Federation tokens

Routes concerning the creation, deletion and management of federation tokens.

---

### <span class="request-h"><span class="request request-get">GET</span> Generate Federation Token [:material-pail-outline:](../../rate-limits.md "Bucket: federation-token-generation") [:material-lock-outline:](#authorization "Authorization required") </span> 

`http://localhost:3001/api/federation/token`

Ask your home server to generate a federation token for you. You can use this token to identify yourself on another server.

Federation tokens are signed using the home server's public signing key, so that other servers can verify its authenticity.

#### Request

##### Body

| Name     | Type     | Description                                             |
| -------- | -------- | ------------------------------------------------------- |
| `server` | `String` | The URL of the server the token should be generated for |

```json
{
    "server": "https://server.example.com"
}
```

#### Response

=== "200 OK"

    ##### Body

    | Name | Type                                                  | Description                    |
    | ---- | ----------------------------------------------------- | ------------------------------ |
    | -*   | [`Federation Token`](../../types.md#federation-token) | The generated federation token |

    ```json
    "exampletoken"
    ```

--8<-- "snippets/errors/401-unauthorized.md"

--8<-- "snippets/errors/404-not_federated.md"

---

### <span class="request-h"><span class="request request-get">GET</span> Get token generation status [:material-pail-outline:](../../rate-limits.md "Bucket: ip/global") [:material-lock-open-outline:](#authorization "Authorization not required")</span>

`http://localhost:3001/api/federation/generation`

Check whether the server currently allows token generation.

#### Request

```bash
curl --request GET \
     --url http://localhost:3001/api/federation/token/generation \
     --header 'Authorization: Bearer exampletoken'
```

#### Response

=== "200 OK"

    ##### Body

    A key-value pair indicating whether token generation is enabled using a boolean.

    ```json
    {
        "enabled": true
    }
    ```

---

### <span class="request-h"><span class="request request-delete">DELETE</span> Delete all Federation Tokens for self [:material-pail-outline:](../../rate-limits.md "Bucket: ip/global") [:material-lock-outline:](#authorization "Authorization required")</span>

`http://localhost:3001/api/federation/token/@me`

Ask your home server to invalidate all federation tokens which have been created for you and are still valid (unused). Doing this manually is not usually required.

#### Request

```bash
curl --request DELETE \
     --url http://localhost:3001/api/federation/token/@me \
     --header 'Authorization: Bearer exampletoken'
```

#### Response

=== "200 OK"

    ##### Body

    A JSON array of all the tokens that have been deleted.

    ```json
    [
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHBpcmF0aW9uIjoxMjM0NTY3ODkwLCJmb3JfZmVkZXJhdGlvbl9pZCI6ImV4YW1wbGVAc2VydmVyLmV4YW1wbGUuY29tIiwiZm9yX2F1dGhlbnRpY2F0aW9uX29uIjoib3RoZXJzZXJ2ZXIuZXhhbXBsZS5jb20iLCJub25jZSI6ImV4YW1wbGVub25jZSJ9.3NBVGBU65PzoeZXHtaN-HDxXUxhdkJTXtTjnxL_5tgw",
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHBpcmF0aW9uIjoxMjM0NTY3ODkwLCJmb3JfZmVkZXJhdGlvbl9pZCI6ImV4YW1wbGVAc2VydmVyLmV4YW1wbGUuY29tIiwiZm9yX2F1dGhlbnRpY2F0aW9uX29uIjoieWV0YW5vdGhlcnNlcnZlci5leGFtcGxlLmNvbSIsIm5vbmNlIjoiYW5vdGhlcmV4YW1wbGVub25jZSJ9.yGx6abxh_fTWQmx0KrWlTz9GviaF_F34ADR9z06i2eM"
    ]
    ```

--8<-- "snippets/errors/401-unauthorized.md"

---

### <span class="request-h"><span class="request request-delete">DELETE</span> Delete all Federation Tokens for user [:material-pail-outline:](../../rate-limits.md "Bucket: ip/global") [:material-lock-outline:](#authorization "Authorization required") [:material-shield-crown-outline:]("This route is only available to server administrators")</span>

`http://localhost:3001/api/federation/token/:user_id/@all`

Revoke all valid federation tokens for a specific user.

#### Path Variables

| Name      | Type        | Description                                        |
| --------- | ----------- | -------------------------------------------------- |
| `user_id` | [`Snowflake`](../../types.md#snowflake) | The ID of the user whose tokens should be revoked. |

#### Request

```bash
curl --request DELETE \
     --url http://localhost:3001/api/federation/token/:user_id/@all \
     --header 'Authorization: Bearer exampletoken'
```

#### Response

=== "200 OK"

    ##### Body

    An unsigned integer indicating the number of tokens that have been deleted.

    ```json
    12
    ```

--8<-- "snippets/errors/401-unauthorized.md"

--8<-- "snippets/errors/403-not_administrator.md"

=== "404 Not Found"

    ##### Body

    ```json
    {
        "message": "User not found"
    }
    ```


---

### <span class="request-h"><span class="request request-delete">DELETE</span> Delete all Federation Tokens [:material-pail-outline:](../../rate-limits.md "Bucket: ip/global") [:material-lock-outline:](#authorization "Authorization required") [:material-shield-crown-outline:]("This route is only available to server administrators")</span>

`http://localhost:3001/api/federation/token/@all`

Revoke all valid federation tokens.

#### Request

```bash
curl --request DELETE \
     --url http://localhost:3001/api/federation/token/@all \
     --header 'Authorization: Bearer exampletoken'
```

#### Response

=== "200 OK"

    ##### Body

    An unsigned integer indicating the number of tokens that have been deleted.

    ```json
    421
    ```

--8<-- "snippets/errors/401-unauthorized.md"

--8<-- "snippets/errors/403-not_administrator.md"

---

### <span class="request-h"><span class="request request-put">PUT</span> Manage token generation [:material-pail-outline:](../../rate-limits.md "Bucket: ip/global") [:material-lock-outline:](#authorization "Authorization required") [:material-shield-crown-outline:]("This route is only available to server administrators")</span>

`http://localhost:3001/api/federation/token/generation`

Enable or disable token generation. When disabled, the server will not allow the creation of new federation tokens.

#### Request

##### Body

| Name      | Type | Description                                               |
| --------- | ---- | --------------------------------------------------------- |
| `enabled` | bool | `true` to enable token generation, `false` to disable it. |

```json
{
    "enabled": true
}
```

#### Response

=== "204 No Content"

    No response body.

--8<-- "snippets/errors/401-unauthorized.md"

--8<-- "snippets/errors/403-not_administrator.md"

---

## Federated Identity

Routes concerning identifying and authenticating as a user on another server.

---

### <span class="request-h"><span class="request request-post">POST</span> Generate session token [:material-pail-outline:](../../rate-limits.md "Bucket: auth/login") [:material-lock-open-outline:](#authorization "Authorization not required")</span>

`http://localhost:3001/api/federation/session`

Get a session token to authenticate as a foreign user on this server.

#### Request

##### Body

| Name                        | Type                                                      | Description                                                            |
| --------------------------- | --------------------------------------------------------- | ---------------------------------------------------------------------- |
| `federation_token`          | [Federation token](../../types.md#federation-token)       | A valid federation token generated by the clients' home server         |
| `public_profile` (optional) | [Public user profile](../../types.md#public-user-profile) | The users' public user profile. Required on first connection to server |

!!! bug "TODO"

    TODO: Add cURL example

#### Response

=== "201 Created"

    ##### Body

    | Name            | Type     | Description                                              |
    | --------------- | -------- | -------------------------------------------------------- |
    | `session_token` | `String` | The session token that has been generated for the client |

    ```json
    {
        "session_token": "exampletoken"
    }
    ```