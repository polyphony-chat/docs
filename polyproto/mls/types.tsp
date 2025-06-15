import "@typespec/rest";
import "@typespec/openapi";

namespace polyproto.mls;

/**
 * Represents a client's capabilities and provides keys for group operations
 */
model KeyPackage {
  @doc("Unique identifier for this key package")
  id: string;

  @doc("The client's public key")
  publicKey: bytes;

  @doc("The client's capabilities and supported ciphersuites")
  capabilities: ClientCapabilities;

  @doc("The client's signature over the key package")
  signature: bytes;
}

/**
 * Client capabilities and supported features
 */
model ClientCapabilities {
  @doc("Supported MLS protocol versions")
  versions: string[];

  @doc("Supported ciphersuites")
  ciphersuites: string[];

  @doc("Supported extensions")
  extensions: string[];
}

/**
 * Represents a proposed change to the group state
 */
model Proposal {
  @doc("Unique identifier for this proposal")
  id: string;

  @doc("The type of proposal")
  type: ProposalType;

  @doc("The target of the proposal (e.g., member to remove)")
  target?: string;

  @doc("The key package for add proposals")
  keyPackage?: KeyPackage;

  @doc("The proposal sender's signature")
  signature: bytes;
}

/**
 * Types of proposals that can be made
 */
enum ProposalType {
  Add,
  Remove,
  Update,
  ReInit,
}

/**
 * Represents a commit message that initiates a new epoch
 */
model Commit {
  @doc("Unique identifier for this commit")
  id: string;

  @doc("The group ID this commit applies to")
  groupId: string;

  @doc("The epoch number this commit creates")
  epoch: int32;

  @doc("The proposals being committed")
  proposals: Proposal[];

  @doc("The commit sender's signature")
  signature: bytes;
}

/**
 * Welcome message for new group members
 */
model Welcome {
  @doc("The group ID the new member is being added to")
  groupId: string;

  @doc("The epoch number the new member is being added to")
  epoch: int32;

  @doc("The key package of the new member")
  keyPackage: KeyPackage;

  @doc("Encrypted group state for the new member")
  encryptedGroupState: bytes;
}

/**
 * Represents a group in MLS
 */
model Group {
  @doc("Unique identifier for the group")
  id: string;

  @doc("Current epoch number")
  epoch: int32;

  @doc("List of current group members")
  members: GroupMember[];

  @doc("Group's public key")
  publicKey: bytes;
}

/**
 * Represents a member in an MLS group
 */
model GroupMember {
  @doc("Unique identifier for the member")
  id: string;

  @doc("The member's key package")
  keyPackage: KeyPackage;

  @doc("The member's role in the group")
  role: MemberRole;
}

/**
 * Possible roles for group members
 */
enum MemberRole {
  Admin,
  Member,
}
