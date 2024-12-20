# `EncryptedPKM`

The `EncryptedPKM` type represents encrypted private key material (PKM) which actors can store on
their home server to back up their private keys securely, and retrieve them later.

## JSON representation

```json
{
    "serial_number": 29387459782,
    "key_data": "-----BEGIN[...]",
    "encryption_algorithms": [[1, 2, 840, 113549, 1, 5, 13, 1, 1, 5]]
}
```

### Fields

| Field                   | Type                                                                                   | Description                                                                                                                                                                                                                          |
| ----------------------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `serial_number`         | Unsigned integer up to 64 bits in size, representing a positive integer `SerialNumber` | The serial number of the ID-Cert this key material is associated with.                                                                                                                                                               |
| `key_data`              | String, PEM-encoded ASN.1 `SubjectPublicKeyInfo`                                       | Custom variant of the X.509 `SubjectPublicKeyInfo`, where the `subject_public_key` field stores the encrypted private key, instead of a public key. Otherwise equal to `SubjectPublicKeyInfo`. Also referred to as `PrivateKeyInfo`. |
| `encryption_algorithms` | Array of Array of Integer, DER-encoded ASN.1 `AlgorithmIdentifier`                     | Information about the algorithms used to encrypt the data held by the `key_data` field. Order-sensitive; The encryption used for the first encryption operation must be the last item of this array and vice versa.                  |

All fields are required.

---

## Glossary

--8<-- "snippets/glossary.md"
