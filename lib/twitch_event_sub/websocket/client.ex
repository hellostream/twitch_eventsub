if Code.ensure_loaded?(WebSockex) do
  defmodule TwitchEventSub.WebSocket.Client do
    @moduledoc false
    use WebSockex

    alias TwitchEventSub.Subscriptions

    require Logger

    @opaque state :: %{
              optional(:broadcaster_user_id) => %{},
              optional(:user_id) => %{},
              optional(:conditions) => %{},
              auth: TwitchAPI.Auth.t(),
              handler: module(),
              keepalive_timeout: pos_integer(),
              subscriptions: [String.t()],
              url: String.t()
            }

    @spec start_link(keyword()) :: GenServer.on_start()
    def start_link(opts) do
      if Keyword.get(opts, :start?, true) do
        Logger.info("[TwitchEventSub] connecting...")
        url = Keyword.fetch!(opts, :url)
        WebSockex.start_link(url, __MODULE__, Map.new(opts))
      else
        :ignore
      end
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
      %{"session" => %{"id" => session_id}} = payload

      Subscriptions.create_many(
        state.auth,
        :websocket,
        state.subscriptions,
        Map.put(state, :session_id, session_id)
      )
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
