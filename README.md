# TwitchEventSub

Twitch EventSub connection for Elixir.

## Installation

The package can be installed by adding `twitch_eventsub` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:twitch_eventsub, "~> 0.1.0"}
  ]
end
```

### Setup

* You need to create an app on the [Twitch Developer Console](https://dev.twitch.tv/console/apps/create)
   to get the `client_id`. Also, add the redirect URL from the instructions in the token generator
   linked below if you use that.
 * To get an OAuth token for EventSub, it's easiest of you are logged in as the broadcaster of the
   channel you want to use the bot for and then you can use the [Twitch OAuth Token Generator](https://twitchapps.com/tokengen/)
   with the `client_id` of the app you created.

For scopes, I just use all the `read` scopes except for `whisper` and `stream_key`. If you want to
do the same, just paste the below into the `scopes` field on the token generator page:

```
analytics:read:extensions analytics:read:games bits:read channel:read:ads channel:read:charity channel:read:goals channel:read:guest_star channel:read:hype_train channel:read:polls channel:read:predictions channel:read:redemptions channel:read:subscriptions channel:read:vips moderation:read moderator:read:automod_settings moderator:read:blocked_terms moderator:read:chat_settings moderator:read:chatters moderator:read:followers moderator:read:guest_star moderator:read:shield_mode moderator:read:shoutouts user:read:blocked_users user:read:broadcast user:read:email user:read:follows user:read:subscriptions channel:bot chat:read user:bot user:read:chat
```

If you want to do moderation things with this token, then you can add the required scopes for
your actions found here [https://dev.twitch.tv/docs/authentication/scopes](https://dev.twitch.tv/docs/authentication/scopes/).

#### Config options (EventSub)

 * `:user_id` - The twitch user ID of the broadcaster.
 * `:handler` - A module that `use`s `TwitchEventSub` and implements the `TwitchEventSub.Handler` behaviour.
 * `:client_id` - The client ID of the application you used for the token.
 * `:access_token` - The OAuth token you generated with the correct scopes for your subscriptions.
 * `:keepalive_timeout` - Optional. The keepalive timeout in seconds. Specifying an invalid,
   but numeric value will return the nearest acceptable value. Defaults to `10`.
 * `:start?` - Optional. A boolean value of whether or not to start the eventsub socket.
   Defaults to `false` if there are no `event_sub` config options.
 * `:subscriptions` - Optional. The list of subscriptions to create. See below for more info.
   Defaults to:

```elixir
# Default subscriptions.
~w[
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

```elixir
# config/runtime.exs

# Add to the existing bot config.
config :my_app,
  event_sub: [
    user_id: "123456",
    channels: ["mychannel"],
    handler: MyApp.TwitchEventHandler,
    client_id: System.get_env("TWITCH_CLIENT_ID"),
    access_token: System.get_env("TWITCH_ACCESS_TOKEN")
  ]
```

### Handler module

Create a bot module to deal with chat messages or events:

```elixir
<<<<<<< HEAD
defmodule MyApp.TwitchEventHandler do
||||||| parent of 9706251 (simplifying)
defmodule MyApplication.TwitchEventHandler do
=======
defmodule MyApp.TwitchEvents do
>>>>>>> 9706251 (simplifying)
  use TwitchEventSub

  @impl true
  def handle_event("channel.follow", event) do
    # TODO: Do something when you get a follow?
  end
end
```

### Starting

Examples of adding Twitch EventSub websocket to your application's supervision tree below.

##### Handler example:

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
