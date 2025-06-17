import "./chat/main.tsp";
import "./core/main.tsp";
import "./mls/main.tsp";

namespace polyproto;

using Http;

namespace models.errors {
    @doc("""
        The client either does not have the access rights to access this resource, or this resource
        does not exist. The ambiguity about the actual error has the purpose of protecting the targeted
        resource from information leaks.
        """)
    model NotFoundOrForbidden {
        ...NotFoundResponse;
    }
}
