defmodule TwitchEventSub do
  @moduledoc """
  The behaviour and implementation of EventSub.
  """

  require Logger

  @doc """
  Handle events from Twitch EventSub.
  """
  @callback handle_event(type :: String.t(), event :: map()) :: any

  @doc false
  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour TwitchEventSub

      @impl true
      def handle_event(type, event) do
        TwitchEventSub.default_handle_event(type, event)
      end

      @before_compile {TwitchEventSub, :add_default_handle_event}

      defoverridable(handle_event: 2)
    end
  end

  @doc false
  defmacro add_default_handle_event(_env) do
    quote do
      def handle_event(type, event) do
        TwitchEventSub.default_handle_event(type, event)
      end
    end
  end

  @doc false
  def default_handle_event(type, event) do
    Logger.debug("[TwitchEventSub] Event #{type}: #{inspect(event)}")
  end
end
