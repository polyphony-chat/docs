import "./errors.tsp";
import "../main.tsp";

using Versioning;

namespace polyproto.chat.models {
    namespace channel {
        @added(Version.`v0.1.0-alpha.0`)
        model Channel {
            id: string;
            data: ChannelData | EncryptedRoutedData;
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
    // TODO: This is likely wrong? Encrypted data can only be parsed
    // when... it is unencrypted, so data: T likely makes no sense...
    model EncryptedRoutedData {
        data: string;
        mls_epoch_number: uint64;
        mls_group_id: string;
        _padding?: string;
    }
}
