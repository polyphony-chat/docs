=== "405 Method Not Allowed"

    Indicates that the server knows the request method, but the target resource doesn't support this method.
    Returns the `Allow` header field with a list of supported methods.

    ##### Header

    ```http
    Allow: <http-methods>
    ```