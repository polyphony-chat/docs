---
title: "MLS Routes: No registration needed"
weight: -900
---

!!! bug "TODO"

    This is a work in progress. MLS-related content is currently being migrated over from the polyproto-core specification.
    This document is not yet complete. Feel free to contribute by opening a pull request on the docs repository.
    The API **will** change (possibly drastically) in the future.

## <span class="group-h">Encryption</span>

Client-Foreign Server API endpoints concerned with encryption related tasks.

---

### <span class="request-h"><span class="request request-get">GET</span> KeyPackage(s) </span>

`/.p2/core/v1/keypackage/:fid`

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