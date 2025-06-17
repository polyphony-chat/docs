import "@typespec/rest";
import "@typespec/openapi";
import "@typespec/http";
import "./main.tsp";
import "../main.tsp";

using TypeSpec.Http;
using polyproto.models.errors;

namespace polyproto.mls.routes {
  /**
   * Create a new MLS group
   */
  @post
  @route("/groups")
  op createGroup(@body keyPackage: KeyPackage): {
    @statusCode _s: 200;
    @body _b: Group;
  };

  /**
   * Get information about an MLS group
   */
  @get
  @route("/groups/{groupId}")
  op getGroup(@path groupId: string): {
    @statusCode _s: 200;
    @body _b: Group;
  } | NotFoundOrForbidden;

  /**
   * Submit a proposal to modify the group
   */
  @post
  @route("/groups/{groupId}/proposals")
  op submitProposal(
    @path groupId: string,
    @body proposal: Proposal,
  ): void | NotFoundOrForbidden;

  /**
   * Submit a commit to apply pending proposals
   */
  @post
  @route("/groups/{groupId}/commits")
  op submitCommit(
    @path groupId: string,
    @body commit: Commit,
  ): Welcome | NotFoundOrForbidden;

  /**
   * Get the current state of a group member
   */
  @get
  @route("/groups/{groupId}/members/{memberId}")
  op getMember(
    @path groupId: string,
    @path memberId: string,
  ): GroupMember | NotFoundOrForbidden;

  /**
   * Update a member's key package
   */
  @put
  @route("/groups/{groupId}/members/{memberId}")
  op updateMember(
    @path groupId: string,
    @path memberId: string,
    @body keyPackage: KeyPackage,
  ): void | NotFoundOrForbidden;

  /**
   * Remove a member from the group
   */
  @delete
  @route("/groups/{groupId}/members/{memberId}")
  op removeMember(
    @path groupId: string,
    @path memberId: string,
  ): void | NotFoundOrForbidden;

  /**
   * Get all pending proposals for a group
   */
  @get
  @route("/groups/{groupId}/proposals")
  op getProposals(@path groupId: string): Proposal[] | NotFoundOrForbidden;

  /**
   * Get the latest commit for a group
   */
  @get
  @route("/groups/{groupId}/commits/latest")
  op getLatestCommit(@path groupId: string): Commit | NotFoundOrForbidden;
}
