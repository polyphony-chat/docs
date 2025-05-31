import "./main.tsp";

using TypeSpec.Http;
using TypeSpec.OpenAPI;
using TypeSpec.Versioning;

@tag("Guild")
@useAuth(BearerAuth)
@route("/guilds")
namespace polyproto.chat.routes.guilds;

namespace responses {
    @doc("""
        Invalid request submitted. Root causes may be:
        
        - not including required body fields
        - a name or description that is too long or too short
        - inclusion of unexpected parameters.
        
        A human readable reason will be returned as a response body.
        """)
    @example(#{
        statusCode: 400,
        body: "The guild name is too long: Maximum allowed length is 32 characters",
    })
    model CreateGuildFailure {
        ...BadRequestResponse;
        ...Body<string>;
    }

    @doc("Guild is private or does not exist.")
    model GuildNotFound {
        ...NotFoundResponse;
    }
}

@post
@summary("Create new Guild")
@added(Version.`v0.1.0-alpha.0`)
op createGuild(name: string, description?: string, private: boolean):
    | {
          @statusCode _code: 201;
          @body _guild: polyproto.chat.models.guild.Guild;
      }
    | {
          @statusCode
          _code: 401;
      }
    | {
          @statusCode
          _code: 403;
      }
    | responses.CreateGuildFailure;

@get
@summary("Get Guild Information")
@added(Version.`v0.1.0-alpha.0`)
op getGuildInformation(@query guild_id: string): {
    @statusCode _code: 201;

    @body
    _guild: polyproto.chat.models.guild.Guild;
} | responses.GuildNotFound;
