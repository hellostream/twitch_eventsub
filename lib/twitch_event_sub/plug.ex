if Code.ensure_loaded?(Plug) do
  defmodule TwitchEventSub.Plug do
    @moduledoc """
    Plug for TwitchEventSub
    """
    @behaviour Plug

    def init(opts), do: opts

    def call(conn, opts) do
      conn
      |> Plug.Conn.get_req_header("twitch-eventsub-message-type")
      |> handle_notification(conn.params, opts)

      conn
    end

    defp handle_notification(["notification"], params, opts) do
      handler = Keyword.fetch!(opts, :handler)
      handler.handle_event("", %{})
    end

    defp handle_notification(["webhook_callback_verification"], params, opts) do
      handler = Keyword.fetch!(opts, :handler)
      handler.handle_event("", %{})
    end

    defp handle_notification(["revokation"], params, opts) do
      handler = Keyword.fetch!(opts, :handler)
      handler.handle_event("", %{})
    end

    defp handle_notification(_, _, _), do: :ok
  end
end
