# TwitchEventSub

Twitch EventSub for Elixir.

## Installation

The package can be installed by adding `twitch_eventsub` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hello_twitch_eventsub, "~> 0.2.1"}
  ]
end
```

If you are using the websocket eventsub, add:

      {:websockex, "~> 0.4"},

If you are using webhooks with Plug (and you are not already using Phoenix or Plug, add:

      {:plug, "~> 1.15"},

### Setup

- You need to create an app on the [Twitch Developer Console](https://dev.twitch.tv/console/apps/create)
  to get the `client_id` and `client_secret`.

#### Generating the OAuth token

- Add a `redirect_uri` to your app on the developer console that looks like:
  `http://localhost:42069/oauth/callback`
- [Optional] set `TWITCH_CLIENT_ID`, `TWITCH_CLIENT_SECRET`, and `TWITCH_AUTH_SCOPE`
  environment variables. For the auth scope you can use the example in the code
  block further down this page.
- Run `mix help auth.token` to see the available options.
- To use the defaults, run `mix twitch.auth --output priv`.

##### Example Scopes

For scopes, I just use all the `read` scopes except for `whisper` and `stream_key`.
If you want to do the same, just paste the below into the `scopes` field on the
token generator page:

```
analytics:read:extensions analytics:read:games bits:read channel:read:ads channel:read:charity channel:read:goals channel:read:guest_star channel:read:hype_train channel:read:polls channel:read:predictions channel:read:redemptions channel:read:subscriptions channel:read:vips moderation:read moderator:read:automod_settings moderator:read:blocked_terms moderator:read:chat_settings moderator:read:chatters moderator:read:followers moderator:read:guest_star moderator:read:shield_mode moderator:read:shoutouts user:read:blocked_users user:read:broadcast user:read:email user:read:follows user:read:subscriptions channel:bot chat:read user:bot user:read:chat
```

If you want to do moderation things with this token, then you can add the required scopes for
your actions found here [https://dev.twitch.tv/docs/authentication/scopes](https://dev.twitch.tv/docs/authentication/scopes/).

#### Config files example (if using `.twitch.json` for local dev)

```elixir
# config/runtime.exs

twitch_access_token =
  case config_env() do
    :prod ->
      System.fetch_env!("TWITCH_ACCESS_TOKEN")

    _dev_or_test ->
      File.read!(".twitch.json")
      |> Jason.decode!()
      |> Map.fetch!("access_token")
  end

config :my_app,
  event_sub: [
    user_id: "123456",
    channel_ids: ["123456"],
    handler: MyApp.TwitchEvents,
    # Webhook secret is only if you are using webhooks.
    webhook_secret: System.fetch_env!("TWITCH_WEBHOOK_SECRET")
  ]
```

#### Config options (EventSub)

- `:user_id` - The twitch user ID of the user that your token is for.
- `:channel_ids` - The twitch user ID of the broadcaster channels that you are subscribing to.
- `:handler` - A module that `use`s `TwitchEventSub` and implements the `TwitchEventSub.Handler` behaviour.
- `:subscriptions` - Optional. The list of subscriptions to create. See below for more info.
  Defaults to:

```elixir
# Default subscriptions.
~w[
  channel.chat.message channel.chat.notification
  channel.ad_break.begin channel.cheer channel.follow channel.subscription.end
  channel.channel_points_custom_reward_redemption.add
  channel.channel_points_custom_reward_redemption.update
  channel.charity_campaign.donate channel.charity_campaign.progress
  channel.goal.begin channel.goal.progress channel.goal.end
  channel.hype_train.begin channel.hype_train.progress channel.hype_train.end
  channel.shoutout.create channel.shoutout.receive
  stream.online stream.offline
]
```

All of the above subscriptions will work without passing conditions, as long as you
provide the `broadcaster_user_id` and `user_id` fields to the config.

Other subscriptions require different conditions, so if you add them, you need to add the subscription
as a map, and include the condition. Example:

```elixir
config :my_app,
  event_sub: [
    subscriptions: [
      "channel.chat.message",
      "channel.chat.notification",
      "channel.ad_break.begin",
      "channel.cheer",
      # etc...
      # Add a map of attrs for subscriptions.
      # Required fields are `:name`, and `:condition`.
      # See the Twitch docs for the required and optional conditions.
      %{
        name: "channel.channel_points_custom_reward_redemption.add",
        condition: %{
          broadcaster_user_id: "1337",
          reward_id: "92af127c-7326-4483-a52b-b0da0be61c01"
        }
      }
    ]
  ]
```

#### Config options (Websocket-specific)

- `:url` - Optional. The URL for the Twitch EventSub websocket server. Defaults to Twitch.
- `:keepalive_timeout` - Optional. The keepalive timeout in seconds. Specifying an invalid,
  but numeric value will return the nearest acceptable value. Defaults to `10`.
- `:start?` - Optional. A boolean value of whether or not to start the eventsub socket.
  Defaults to `false` if there are no `event_sub` config options.

#### Config options (Webhook-specific)

- `:webhook_secret` - The secret to be used when creating and receiving subscriptions.

### Handler module

Create a bot module to deal with chat messages or events:

```elixir
defmodule MyApp.TwitchEvents do
  use TwitchEventSub

  @impl true
  def handle_event("channel.follow", event) do
    # TODO: Do something when you get a follow?
  end
end
```

### Starting Websocket

Examples of adding Twitch EventSub websocket to your application's supervision tree below.

```elixir
# lib/my_app/application.ex in `start/2` function:
defmodule MyApp.Application do
  # ...
  def start(_type, _args) do
    children = [
      # ... existing stuff ...
      # Add the bot.
      {TwitchEventSub.WebSocket, Application.fetch_env!(:my_app, :event_sub)}
    ]

    # ...
  end
  # ...
end
```
