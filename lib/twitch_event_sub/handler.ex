defmodule TwitchEventSub.Handler do
  @moduledoc """
  The behaviour and implementation of EventSub Handler.
  """

  @callback handle_event(TwitchEventSub.Events.event()) :: any

  @doc false
  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour TwitchEventSub.Handler

      @impl true
      def handle_event(event) do
        Logger.debug("[TwitchEventSub.Handler] Event: #{inspect(event)}")
      end

      defoverridable(handle_event: 1)
    end
  end
end
