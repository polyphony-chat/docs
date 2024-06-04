# `EncryptedPKM`

The `EncryptedPKM` type represents encrypted private key material (PKM) which actors can store on
their home server to back up their private keys securely, and retrieve them later.

## JSON representation

```json
{
    "serial_number": 3784567832,
    "key_data": "-----BEGIN[...]",
    "encryption_algorithm": [1, 2, 840, 113549, 1, 5, 13, 1, 1, 5]
}
```

### Fields

| Field                  | Type                                                             | Description                                                                                                                                                                                                                                                                          |
| ---------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `serial_number`        | Integer, Unsigned Integer as specified by the `UInt` ASN.1 type. | The serial number of the ID-Cert this key material is associated with.                                                                                                                                                                                                               |
| `key_data`             | String, PEM-encoded ASN.1 `SubjectPublicKeyInfo`                 | Custom `SubjectPublicKeyInfo`, where the `subject_public_key` field stores the encrypted private key, instead of a public key. Otherwise, this type is equal to `SubjectPublicKeyInfo`. This custom form of `SubjectPublicKeyInfo` is also commonly referred to as `PrivateKeyInfo`. |
| `encryption_algorithm` | Array of Integer, DER-encoded ASN.1 `AlgorithmIdentifier`        | Information about the algorithm used to encrypt the data held by the `key_data` field.                                                                                                                                                                                               |

All fields are required.
