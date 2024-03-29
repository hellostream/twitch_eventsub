defmodule TwitchEventSub do
  @moduledoc """
  The behaviour and implementation of EventSub.

  ## Example implementation

      defmodule ExampleHandler do
        use TwitchEventSub

        @impl TwitchEventSub
        def handle_event("channel.follow", event) do
          # Do something with a follow.
        end
      end

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
  def default_handle_event(type, _event) do
    Logger.debug("[TwitchEventSub] unhandled #{type} event")
  end
end
