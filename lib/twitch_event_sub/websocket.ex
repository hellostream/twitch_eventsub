defmodule TwitchEventSub.WebSocket do
  @moduledoc """
  TwitchEventSub is a library for connecting to Twitch chat with Elixir.
  """
  use Supervisor

  @doc """
  Start the TwitchEventSub supervisor.
  """
  @spec start_link(keyword()) :: Supervisor.on_start()
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    children = [
      {TwitchEventSub.WebSocketClient, opts}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
