if Code.ensure_loaded?(Plug) do
  defmodule TwitchEventSub.Plug.BodyReader do
    @moduledoc false
    # A custom body reader for Twitch EventSub message verification.
    # See the `TwitchEventSub.Plug` module for how to use it.

    @doc false
    def read_body(conn, opts) do
      {:ok, body, conn} = Plug.Conn.read_body(conn, opts)

      case Plug.Conn.get_req_header(conn, "twitch-eventsub-message-signature") do
        [] ->
          {:ok, body, conn}

        [_signature] ->
          conn = put_in(conn.assigns[:raw_body], body)
          {:ok, body, conn}
      end
    end
  end
end
