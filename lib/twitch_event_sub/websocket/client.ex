if Code.ensure_loaded?(Websockex) do
  defmodule TwitchEventSub.WebSocket.Client do
    @moduledoc false
    use WebSockex

    require Logger

    alias TwitchEventSub.Subscriptions

    @default_url "wss://eventsub.wss.twitch.tv/ws"
    @default_keepalive_timeout 30

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

    # NOTE: `extension.bits_transaction.create` requires `extension_client_id`.

    # The options accepted (and required) by the websocket client.
    @required_opts ~w[user_id client_id access_token handler channel_ids]a
    @allowed_opts @required_opts ++ ~w[subscriptions]

    @opaque state :: %{
              auth: TwitchAPI.Auth.t(),
              channel_ids: [String.t()],
              handler: module(),
              keepalive_timeout: pos_integer(),
              subscriptions: [String.t()],
              url: String.t(),
              user_id: String.t()
            }

    @doc """
    Starts the connection to the EventSub WebSocket server.

    ## Options

     * `:client_id` - Twitch app client id.
     * `:access_token` - Twitch app access token with required scopes for the
        provided `:subscriptions`.
     * `:subscriptions` - The subscriptions for EventSub.
     * `:url` - A websocket URL to connect to. Defaults to "wss://eventsub.wss.twitch.tv/ws".
     * `:keepalive_timeout` - The keepalive timeout in seconds. Specifying an invalid,
        but numeric value will return the nearest acceptable value. Defaults to `10`.
     * `:start?` - A boolean value of whether or not to start the eventsub socket.

    """
    @spec start_link(keyword()) :: GenServer.on_start()
    def start_link(opts) do
      if Keyword.get(opts, :start?, true) do
        do_start(opts)
      else
        :ignore
      end
    end

    defp do_start(opts) do
      Logger.info("[TwitchEventSub] connecting...")

      if not Enum.all?(@required_opts, &Keyword.has_key?(opts, &1)) do
        raise ArgumentError,
          message: "missing one of the required options, got: #{inspect(Keyword.keys(opts))}"
      end

      {client_id, opts} = Keyword.pop!(opts, :client_id)
      {access_token, opts} = Keyword.pop!(opts, :access_token)
      auth = TwitchAPI.Auth.new(client_id, access_token)

      keepalive = Keyword.get(opts, :keepalive_timeout, @default_keepalive_timeout)
      query = URI.encode_query(keepalive_timeout_seconds: keepalive)

      url =
        opts
        |> Keyword.get(:url, @default_url)
        |> URI.parse()
        |> URI.append_query(query)
        |> URI.to_string()

      state =
        opts
        |> Keyword.take(@allowed_opts)
        |> Keyword.merge(url: url, auth: auth)
        |> Map.new()

      WebSockex.start_link(url, __MODULE__, state)
    end

    # ----------------------------------------------------------------------------
    # Websockex Callbacks
    # ----------------------------------------------------------------------------

    @impl WebSockex
    def handle_frame({:text, msg}, state) do
      case Jason.decode(msg) do
        {:ok, %{"metadata" => metadata, "payload" => payload}} ->
          handle_message(metadata, payload, state)
          {:ok, state}

        _ ->
          Logger.warning("[TwitchEventSub] Unhandled message: #{msg}")
          {:ok, state}
      end
    end

    def handle_frame({type, msg}, state) do
      Logger.debug("[TwitchEventSub] unhandled frame #{inspect(type)}: #{inspect(msg)}")
      {:ok, state}
    end

    @impl WebSockex
    def handle_cast({:send, {type, msg} = frame}, state) do
      Logger.debug("[TwitchEventSub] sending #{type} frame with payload: #{msg}")
      {:reply, frame, state}
    end

    @impl WebSockex
    def handle_info({:delayed_event, event}, state) do
      state.handler.handle_event(event)
      {:ok, state}
    end

    @impl WebSockex
    def terminate(close_reason, _state) do
      Logger.error("[TwitchEventSub] terminating #{inspect(close_reason)}")
    end

    # ----------------------------------------------------------------------------
    # Message Handling
    # ----------------------------------------------------------------------------

    @spec handle_message(metadata :: map(), payload :: map(), state()) :: term()
    defp handle_message(metadata, payload, state)

    # ## Welcome message
    #
    # When you connect, Twitch replies with a welcome message.
    #
    # The `message_type` field is set to `session_welcome`. This message contains
    # the WebSocket session’s ID that you use when subscribing to events.
    #
    # NOTE: (IMPORTANT) By default, you have 10 seconds from the time you receive
    # the Welcome message to subscribe to an event, unless otherwise specified
    # when connecting. If you don’t subscribe within this timeframe, the
    # server closes the connection.
    #
    #     {
    #       "metadata": {
    #         "message_id": "96a3f3b5-5dec-4eed-908e-e11ee657416c",
    #         "message_type": "session_welcome",
    #         "message_timestamp": "2023-07-19T14:56:51.634234626Z"
    #       },
    #       "payload": {
    #         "session": {
    #           "id": "AQoQILE98gtqShGmLD7AM6yJThAB",
    #           "status": "connected",
    #           "connected_at": "2023-07-19T14:56:51.616329898Z",
    #           "keepalive_timeout_seconds": 10,
    #           "reconnect_url": null
    #         }
    #       }
    #     }
    #
    defp handle_message(%{"message_type" => "session_welcome"}, payload, state) do
      Logger.info("[TwitchEventSub] connected")

      subscriptions = Map.get(state, :subscriptions, @default_subs)
      auth = state.auth
      channel_ids = state.channel_ids
      user_id = state.user_id
      session_id = get_in(payload, ["session", "id"])

      for channel_id <- channel_ids, type <- subscriptions do
        Subscriptions.create(
          auth,
          type,
          channel_id,
          user_id,
          session_id
        )
      end
    end

    # ## Keepalive message
    #
    # The keepalive messages indicate that the WebSocket connection is healthy.
    # The server sends this message if Twitch doesn’t deliver an event
    # notification within the keepalive_timeout_seconds window specified in
    # the Welcome message.
    #
    # If your client doesn’t receive an event or keepalive message for longer
    # than keepalive_timeout_seconds, you should assume the connection is lost
    # and reconnect to the server and resubscribe to the events. The keepalive
    # timer is reset with each notification or keepalive message.
    #
    #     {
    #       "metadata": {
    #         "message_id": "84c1e79a-2a4b-4c13-ba0b-4312293e9308",
    #         "message_type": "session_keepalive",
    #         "message_timestamp": "2023-07-19T10:11:12.634234626Z"
    #       },
    #       "payload": {}
    #     }
    #
    defp handle_message(%{"message_type" => "session_keepalive"}, _payload, _state) do
      Logger.info("[TwitchEventSub] keepalive")
    end

    # ## Notification message
    #
    # A notification message is sent when an event that you subscribe to occurs.
    # The message contains the event’s details.
    #
    #     {
    #       "metadata": {
    #         "message_id": "befa7b53-d79d-478f-86b9-120f112b044e",
    #         "message_type": "notification",
    #         "message_timestamp": "2022-11-16T10:11:12.464757833Z",
    #         "subscription_type": "channel.follow",
    #         "subscription_version": "1"
    #       },
    #       "payload": {
    #         "subscription": {
    #           "id": "f1c2a387-161a-49f9-a165-0f21d7a4e1c4",
    #           "status": "enabled",
    #           "type": "channel.follow",
    #           "version": "1",
    #           "cost": 1,
    #           "condition": {
    #             "broadcaster_user_id": "12826"
    #           },
    #           "transport": {
    #             "method": "websocket",
    #             "session_id": "AQoQexAWVYKSTIu4ec_2VAxyuhAB"
    #           },
    #           "created_at": "2022-11-16T10:11:12.464757833Z"
    #         },
    #         "event": {
    #           "user_id": "1337",
    #           "user_login": "awesome_user",
    #           "user_name": "Awesome_User",
    #           "broadcaster_user_id": "12826",
    #           "broadcaster_user_login": "twitch",
    #           "broadcaster_user_name": "Twitch",
    #           "followed_at": "2023-07-15T18:16:11.17106713Z"
    #         }
    #       }
    #     }
    # 
    defp handle_message(%{"message_type" => "notification"} = meta, %{"event" => event}, state) do
      %{"subscription_type" => type} = meta
      Logger.debug("[TwitchEventSub] notification #{type}: #{inspect(event, pretty: true)}")
      add_delayed_event(type, event)
      state.handler.handle_event(type, event)
    end

    # ## Reconnect message
    #
    # A reconnect message is sent if the edge server that the client is connected
    # to needs to be swapped. This message is sent 30 seconds prior to closing the
    # connection, specifying a new URL for the client to connect to. Following the
    # reconnect flow will ensure no messages are dropped in the process.
    #
    # The message includes a URL in the `reconnect_url` field that you should
    # immediately use to create a new connection. The connection will include the
    # same subscriptions that the old connection had. You should not close the old
    # connection until you receive a Welcome message on the new connection.
    #
    # NOTE: Use the reconnect URL as is; do not modify it.
    #
    # The old connection receives events up until you connect to the new URL and
    # receive the welcome message to ensure an uninterrupted flow of notifications.
    #
    # NOTE: Twitch sends the old connection a close frame with code `4004` if
    # you connect to the new socket but never disconnect from the old socket or
    # you don’t connect to the new socket within the specified timeframe.
    #
    #     {
    #       "metadata": {
    #         "message_id": "84c1e79a-2a4b-4c13-ba0b-4312293e9308",
    #         "message_type": "session_reconnect",
    #         "message_timestamp": "2022-11-18T09:10:11.634234626Z"
    #       },
    #       "payload": {
    #         "session": {
    #           "id": "AQoQexAWVYKSTIu4ec_2VAxyuhAB",
    #           "status": "reconnecting",
    #           "keepalive_timeout_seconds": null,
    #           "reconnect_url": "wss://eventsub.wss.twitch.tv?...",
    #           "connected_at": "2022-11-16T10:11:12.634234626Z"
    #         }
    #       }
    #     }
    #
    defp handle_message(%{"message_type" => "session_reconnect"}, _payload, _state) do
      Logger.debug("[TwitchEventSub] reconnect message")
    end

    # ## Revocation message
    #
    # A revocation message is sent if Twitch revokes a subscription. The
    # `subscription` object’s `type` field identifies the subscription that was
    # revoked, and the `status` field identifies the reason why the subscription was
    # revoked. Twitch revokes your subscription in the following cases:
    #
    #  - The user mentioned in the subscription no longer exists. The
    #    notification’s `status` field is set to user_removed.
    #  - The user revoked the authorization token that the subscription relied on.
    #    The notification’s `status` field is set to `authorization_revoked`.
    #  - The subscribed to subscription type and version is no longer supported.
    #    The notification’s `status` field is set to `version_removed`.
    #
    # You’ll receive this message once and then no longer receive messages for the
    # specified user and subscription type.
    #
    # Twitch reserves the right to revoke a subscription at any time.
    #
    #     {
    #       "metadata": {
    #         "message_id": "84c1e79a-2a4b-4c13-ba0b-4312293e9308",
    #         "message_type": "revocation",
    #         "message_timestamp": "2022-11-16T10:11:12.464757833Z",
    #         "subscription_type": "channel.follow",
    #         "subscription_version": "1"
    #       },
    #       "payload": {
    #         "subscription": {
    #           "id": "f1c2a387-161a-49f9-a165-0f21d7a4e1c4",
    #           "status": "authorization_revoked",
    #           "type": "channel.follow",
    #           "version": "1",
    #           "cost": 1,
    #           "condition": {
    #             "broadcaster_user_id": "12826"
    #           },
    #           "transport": {
    #             "method": "websocket",
    #             "session_id": "AQoQexAWVYKSTIu4ec_2VAxyuhAB"
    #           },
    #           "created_at": "2022-11-16T10:11:12.464757833Z"
    #         }
    #       }
    #     }
    #
    defp handle_message(%{"message_type" => "revocation"}, payload, _state) do
      %{"subscription" => %{}} = payload
      Logger.error("[TwitchEventSub] sub revoked: #{inspect(payload)}")
    end

    # ## Close message
    #
    # Twitch sends a Close frame when it closes the connection. The following
    # table lists the reasons for closing the connection.
    #
    # Code 	Reason 	Notes
    # 4000 	Internal server error 	Indicates a problem with the server (similar to an HTTP 500 status code).
    # 4001 	Client sent inbound traffic 	Sending outgoing messages to the server is prohibited with the exception of pong messages.
    # 4002 	Client failed ping-pong 	You must respond to ping messages with a pong message. See Ping message.
    # 4003 	Connection unused 	When you connect to the server, you must create a subscription within 10 seconds or the connection is closed. The time limit is subject to change.
    # 4004 	Reconnect grace time expired 	When you receive a session_reconnect message, you have 30 seconds to reconnect to the server and close the old connection. See Reconnect message.
    # 4005 	Network timeout 	Transient network timeout.
    # 4006 	Network error 	Transient network error.
    # 4007 	Invalid reconnect 	The reconnect URL is invalid.
    #
    defp handle_message(_metadata, payload, _state) do
      # TODO: match ^
      Logger.error("[TwitchEventSub] closed: #{inspect(payload)}")
    end

    # --------------------------------------------------------------------------
    # Custom Delayed Events
    # --------------------------------------------------------------------------
    # Delayed events are events we create based on other events that have some
    # sort of timed effect.
    #
    # For example `channel.ad_break.begin` has a `duration_seconds` property,
    # but we do not have an `channel.ad_break.end` event. So, we can use the
    # ad-break duration to create our own `channel.ad_break.end` event.
    #
    # This is exactly what we do.

    defp add_delayed_event("channel.ad_break.begin", event) do
      Process.send_after(
        self(),
        {:delayed_event, "channel.ad_break.end", event},
        event.duration_seconds * 1000
      )
    end

    defp add_delayed_event("channel.shoutout.create", event) do
      cooldown_duration = DateTime.diff(event.cooldown_ends_at, DateTime.utc_now(), :millisecond)

      cooldown_target_duration =
        DateTime.diff(event.target_cooldown_ends_at, DateTime.utc_now(), :millisecond)

      Process.send_after(
        self(),
        {:delayed_event, "channel.shoutout.cooldown.end", event},
        cooldown_duration
      )

      Process.send_after(
        self(),
        {:delayed_event, "channel.shoutout.cooldown.to_broadcaster.end", event},
        cooldown_target_duration
      )
    end

    # No-op for any other events.
    defp add_delayed_event(_type, _event), do: :ok
  end
end
