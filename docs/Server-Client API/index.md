# Server-Client API

### Authorization

**Bearer token**, unless specified otherwise.

### Server

`http://localhost:3001/api`

---

## Federation tokens

Routes concerning the creation, deletion and management of federation tokens.

### <p class="request-h"><span class="request request-get">GET</span> Generate Federation Token</p>

`http://localhost:3001/api/federation/token`

Ask your home server to generate a federation token for you. You can use this token to authenticate on another server.

The token is signed using the home server's public signing key, so that other servers can verify its authenticity.

#### Body

```json
{
    "server": "https://server.example.com"
}
```

#### Response

=== "200 OK"

    ##### Body

    ```json
    "exampletoken"
    ```

=== "404 Not Found"
    
    ##### Body

    ```json
    {
        "errcode": "PR_NOT_FEDERATED",
        "error": "The server you are trying to generate a token for does not federate with this server. Either this server does not have federation enabled or at least one of the servers has denied federation with the other. Check with a server administrator for more information."
    }
    ```