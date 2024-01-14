---
weight: -700
---

# Types

Type definitions required for using the polyproto-core API.

## Snowflake

Snowflakes are really hella cool
TODO

## Federation ID

## Federation Token

A federation token is a json object blah blah blah
TODO

## Public User Profile

A public user profile contains the following fields:

    pub id: Snowflake,
    pub username: Option<String>,
    pub discriminator: Option<String>,
    pub avatar: Option<String>,
    pub accent_color: Option<u8>,
    pub banner: Option<String>,
    pub theme_colors: Option<Vec<u8>>,
    pub pronouns: Option<String>,
    pub bot: Option<bool>,
    pub bio: Option<String>,
    pub premium_type: Option<u8>,
    pub premium_since: Option<DateTime<Utc>>,
    pub public_flags: Option<u32>,


| Name                | Type                            | Description                           |
| ------------------- | ------------------------------- | ------------------------------------- |
| id                  | [Snowflake](#snowflake)         | The users ID on their home server     |
| fid                 | [Federation ID](#federation-id) | The users' globally unique identifier |
| username (optional) | String                          | The users' display name               |
| avatar (optional)   | String                          | The users' avatar hash                |