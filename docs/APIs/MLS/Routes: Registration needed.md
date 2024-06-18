---
title: "MLS Routes: Registration needed"
weight: -1000
---

!!! bug "TODO"

    This is a work in progress. MLS-related content is currently being migrated over from the polyproto-core specification.
    This document is not yet complete. Feel free to contribute by opening a pull request on the docs repository.
    The API **will** change (possibly drastically) in the future.

## <span class="group-h">Encryption</span>

Client-Home Server API endpoints concerned with encryption, such as KeyPackage management.

---

### <span class="request-h"><span class="request request-post">POST</span> Add KeyPackage </span>

`/.p2/core/v1/keypackage/@me`

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

### <span class="request-h"><span class="request request-put">PUT</span> Replace Last Resort KeyPackage </span>

`/.p2/core/v1/keypackage_lr`

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

## Glossary

--8<-- "snippets/glossary.md"
