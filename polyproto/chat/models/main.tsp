namespace polyproto.chat.Models {
    model Guild {
        id: string;
        display_name: string;
        description?: string;
        icon?: url;
        owner_id: string;
        created_at: offsetDateTime;
    }

    model Channel {
        id: string;
        data: ChannelData | Encrypted<ChannelData>;
    }

    model ChannelData {
        parent_id: string;
        type: uint8;
        position: uint32;
        name: string;
        description: string;
        permissions: string;
    }

    enum ChannelType {
        Regular: 1,
    }

    model Encrypted<T> {
        data: T;
        mls_epoch_number: uint64;
        mls_group_id: string;
        _padding?: string;
    }

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

    model Reaction {
        emoji: string;
        fid: string;
    }

    model Embed {
        title: string;
        subtitle?: string;
        color?: string;
        content: string;
        attachments?: url[];
    }

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

    enum Availability {
        InvisibleOffline: 0,
        Online: 1,
        Idle: 2,
        DoNotDisturb: 3,
    }
}
