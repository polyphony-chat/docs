import "./main.tsp";

using TypeSpec.Http;
using TypeSpec.OpenAPI;
using TypeSpec.Versioning;

@tag("Guild")
@useAuth(BearerAuth)
@route("/guilds")
namespace polyproto.chat.routes.guilds;

@post
@summary("Create new Guild")
@added(Version.`v0.1.0-alpha.0`)
@errorsDoc("""
    Invalid request submitted. Root causes may be:
    
    - not including required body fields
    - a name or description that is too long or too short
    - inclusion of unexpected parameters.
    
    A human readable reason will be returned as a response body.
    """)
op createGuild(name: string, description?: string, private: boolean):
    | {
          @statusCode _code: 201;
          @body _guild: polyproto.chat.models.guild.Guild;
      }
    | {
          @doc("Returned on unauthenticated access")
          @statusCode
          _code: 401;
      }
    | {
          @doc("Returned if permissions are lacking")
          @statusCode
          _code: 403;
      }
    | {
          @statusCode
          _code: 400;

          @body
          reason: string;
      };

@get
@summary("Get Guild Information")
@added(Version.`v0.1.0-alpha.0`)
op getGuildInformation(@query guild_id: string): {
    @statusCode _code: 201;

    @doc("Contains the newly created guild")
    @body
    _guild: polyproto.chat.models.guild.Guild;
} | {
    @doc("Returned when querying a private guild, or a guild that does not exist")
    @statusCode
    _code: 404;
};
