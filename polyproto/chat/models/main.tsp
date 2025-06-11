import "./errors.tsp";
import "../main.tsp";

using Versioning;

namespace polyproto.chat.models {
    namespace channel {
        @added(Version.`v0.1.0-alpha.0`)
        model Channel {
            id: string;
            data: ChannelData | EncryptedMessageData;
        }
        @added(Version.`v0.1.0-alpha.0`)
        model ChannelData {
            parent_id: string;
            type: uint8;
            position: uint32;
            name: string;
            description: string;
            permissions: string;
        }

        @added(Version.`v0.1.0-alpha.0`)
        enum ChannelType {
            Regular: 1,
            Thread: 2,
            Forum: 3,
        }
    }

    namespace guild {
        @added(Version.`v0.1.0-alpha.0`)
        model Guild {
            id: string;
            display_name: string;
            description?: string;
            icon?: url;
            owner_id: string;
            created_at: offsetDateTime;
        }
    }

    namespace message {
        @added(Version.`v0.1.0-alpha.0`)
        model Message {
            version: uint64;
            uid: string;
            author: string;
            content: string;
            timestamp: uint64;
            attachments?: url[];
            embeds?: Embed[];
            reactions?: Reaction[];
            signature: string;
        }

        @added(Version.`v0.1.0-alpha.0`)
        model Reaction {
            emoji: string;
            fid: string;
        }

        @added(Version.`v0.1.0-alpha.0`)
        model Embed {
            title: string;
            subtitle?: string;
            color?: string;
            content: string;
            attachments?: url[];
        }
    }

    namespace actor {
        @added(Version.`v0.1.0-alpha.0`)
        model Actor {
            fid: string;
            display_name?: string;
            pronouns?: string;
            about?: string;
            avatar?: url;
            availability: Availability;
            status?: string;
            timezone?: string;
        }

        @added(Version.`v0.1.0-alpha.0`)
        enum Availability {
            InvisibleOffline: 0,
            Online: 1,
            Idle: 2,
            DoNotDisturb: 3,
        }
    }

    @added(Version.`v0.1.0-alpha.0`)
    @doc("""
        "EncryptedMessageData" is encrypted message data with unencrypted metadata. The amount of
        metadata that is not encrypted is kept to an absolute minimum but is required, so that the
        server can know who to attempt to deliver the message to.
        
        Namely, this unencrypted metadata is the `dest_id`, short for "destination identifer".
        This is the identifier of the channel, group or user to which the message should be
        delivered.
        """)
    model EncryptedMessageData {
        data: string;
        dest_id: string;
    }
}
