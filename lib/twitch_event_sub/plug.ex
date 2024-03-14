if Code.ensure_loaded?(Plug) do
  defmodule TwitchEventSub.Plug do
    @moduledoc """
    Plug for TwitchEventSub webhooks.

    ## Usage

    For the plug to work, you need to add the `:raw_body` assign to the `conn`
    when your plugs read the body. We provide a custom body reader for you in
    `TwitchEventSub.Plug.BodyReader` and you should use this to read the body.

    If you are using `Phoenix` (and `Plug.Parsers`), then it would look something
    like this:

        # In Phoenix this would be in MyAppWeb.Endpoint.
        plug Plug.Parsers,
          parsers: [:urlencoded, :json],
          pass: ["text/*"],
          body_reader: {TwitchEventSub.Plug.BodyReader, :read_body, []},
          json_decoder: Jason

    Next, you would use this plug for a Twitch Webhook callback path. Something
    like this if you are using Phoenix:

        # This passes some application config as the plug options.
        forward "/twitch/callback", TwitchEventSub.Plug, Application.fetch_env!(:my_app, TwitchEventSub)

    ## Options (required)

     * `:webhook_secret` - The secret you pass when you subscribe to an event.
     * `:handler` - The module that implements `TwitchEventSub` to handle events.

    """
    @behaviour Plug

    require Logger

    @doc false
    @impl Plug
    def init(opts), do: opts

    @doc false
    @impl Plug
    def call(%Plug.Conn{} = conn, opts) do
      if valid_twitch_request?(conn, opts) do
        conn
        |> Plug.Conn.get_req_header("twitch-eventsub-message-type")
        |> handle_notification(conn, opts)
      else
        conn
        |> Plug.Conn.send_resp(401, "Not Authorized")
        |> Plug.Conn.halt()
      end
    end

    ## Helpers

    defp valid_twitch_request?(conn, opts) do
      with(
        secret <- Keyword.fetch!(opts, :webhook_secret),
        [msg_id] <- Plug.Conn.get_req_header(conn, "twitch-eventsub-message-id"),
        [timestamp] <- Plug.Conn.get_req_header(conn, "twitch-eventsub-message-timestamp"),
        [signature] <- Plug.Conn.get_req_header(conn, "twitch-eventsub-message-signature")
      ) do
        hmac_msg = msg_id <> timestamp <> conn.assigns.raw_body
        hmac = :crypto.mac(:hmac, :sha256, secret, hmac_msg)
        hmac = "sha256=" <> Base.encode16(hmac, case: :lower)
        Plug.Crypto.secure_compare(hmac, signature)
      else
        _ -> false
      end
    end

    ## Notifications

    defp handle_notification(["notification"], conn, opts) do
      handler = Keyword.fetch!(opts, :handler)
      %{"subscription" => %{"type" => type}, "event" => event} = conn.params
      handler.handle_event(type, event)

      conn
      |> Plug.Conn.send_resp(200, "")
      |> Plug.Conn.halt()
    end

    ## Callback verification

    defp handle_notification(["webhook_callback_verification"], conn, _opts) do
      challenge = Map.fetch!(conn.params, "challenge")
      challenge_length = String.length(challenge)

      conn
      |> Plug.Conn.put_resp_header("content-length", challenge_length)
      |> Plug.Conn.put_resp_header("content-type", "text/plain")
      |> Plug.Conn.send_resp(200, challenge)
      |> Plug.Conn.halt()
    end

    ## Revocation

    defp handle_notification(["revocation"], conn, _opts) do
      %{"subscription" => %{"status" => status, "type" => type}} = conn.params
      Logger.warning("[TwitchEventSub.Plug] Twitch revoked subscription #{type}: #{status}")

      conn
      |> Plug.Conn.send_resp(200, "")
      |> Plug.Conn.halt()
    end
  end
end
