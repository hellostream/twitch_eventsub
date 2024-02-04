defmodule TwitchEventSubTest do
  use ExUnit.Case, async: true
  doctest TwitchEventSub

  defmodule TestHandler do
    use TwitchEventSub

    @impl true
    def handle_event(%TwitchEventSub.Events.ChatMessage{} = event) do
      "Hello #{event.channel}"
    end
  end

  test "test handler implementation" do
    event = %TwitchEventSub.Events.ChatMessage{channel: "foo"}
    assert TestHandler.handle_event(event) == "Hello foo"
  end
end
