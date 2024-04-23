defmodule TwitchEventSub do
  @moduledoc """
  TwitchEventSub websocket client supervisor.
  See the `t:option/0` type for the required options.
  """
  use Supervisor

  @typedoc """
  The IDs of the channels we're subscribing to or something.
  """
  @type channel_ids :: [String.t()]

  @typedoc """
  The module that implements `TwitchEventSub`.
  """
  @type handler :: module()

  @typedoc """
  The keepalive timeout in seconds. Specifying an invalid, numeric value will
  return the nearest acceptable value. Optional. Defaults to `10`.
  """
  @type keepalive_timeout :: pos_integer()

  @typedoc """
  Tell the websocket client whether or not it should be started.
  Optional. Defaults to `true`.
  """
  @type start? :: boolean() | nil

  @typedoc """
  A subscription for EventSub. Optional. Defaults to a bunch.
  Check `TwitchEventSub.Websocket.Client` for the defaults.
  """
  @type subscription :: String.t() | %{condition: map(), name: String.t()}

  @typedoc """
  A websocket URL to connect to. Optional.
  Defaults to `"wss://eventsub.wss.twitch.tv/ws"`.
  """
  @type url :: String.t()

  @typedoc """
  The user ID of the broadcaster or bot user we are using for subscriptions.
  """
  @type user_id :: String.t()

  @typedoc """
  The options accepted (or required) by the `TwitchEventSub.Supervisor`.
  """
  @type option ::
          {:auth_store_callback_module, module()}
          | {:auth_store_name, TwitchAPI.AuthStore.name()}
          | {:channel_ids, channel_ids()}
          | {:handler, handler()}
          | {:keepalive_timeout, keepalive_timeout()}
          | {:start?, start?()}
          | {:subscriptions, [subscription()]}
          | {:url, url()}
          | {:user_id, user_id()}

  @default_url "wss://eventsub.wss.twitch.tv/ws"
  @default_keepalive_timeout 30

  # The options accepted (and required) by the websocket client.
  @required_opts ~w[channel_ids handler user_id]a
  @allowed_opts @required_opts ++ ~w[auth_store_callback_module auth_store_name subscriptions]a

  # NOTE: `channel.chat.message` is still better in IRC, because we get more info.

  @default_subs ~w[
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

  @doc false
  @spec start_link([option()]) :: Supervisor.on_start()
  def start_link(opts) do
    if not Enum.all?(@required_opts, &Keyword.has_key?(opts, &1)) do
      raise ArgumentError,
        message:
          "missing required options (#{inspect(@required_opts)}), got: #{inspect(Keyword.keys(opts))}"
    end

    keepalive = Keyword.get(opts, :keepalive_timeout, @default_keepalive_timeout)
    query = URI.encode_query(keepalive_timeout_seconds: keepalive)

    url =
      opts
      |> Keyword.get(:url, @default_url)
      |> URI.parse()
      |> URI.append_query(query)
      |> URI.to_string()

    subscriptions = Keyword.get(opts, :subscriptions, @default_subs)

    opts =
      opts
      |> Keyword.take(@allowed_opts)
      |> Keyword.merge(url: url, subscriptions: subscriptions)

    Supervisor.start_link(__MODULE__, opts)
  end

  @doc false
  @impl true
  def init(opts) do
    # We need a way to reference the auth store in the websocket client.
    auth_store_name = Keyword.get(opts, :auth_store_name) || :erlang.phash2(self())
    auth_store_callbacks = Keyword.get(opts, :auth_store_callback_module, TwitchAPI.AuthFile)

    children = [
      {TwitchAPI.AuthStore, callback_module: auth_store_callbacks, name: auth_store_name},
      {TwitchEventSub.WebSocket.Client, [{:auth_store, auth_store_name} | opts]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
