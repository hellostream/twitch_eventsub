defmodule TwitchEventSub.HandlerTest do
  use ExUnit.Case, async: true

  doctest TwitchEventSub.Handler, import: true

  defmodule TestHandler do
    use TwitchEventSub.Handler

    @impl true
    def handle_event(%TwitchEventSub.Events.ChatMessage{} = event) do
      "Hello #{event.broadcaster_login}"
    end
  end

  def "test handler implementation" do
    event = %TwitchEventSub.Events.ChatMessage{broadcaster_login: "foo"}
    assert TestHandler.handle_event(event) == "Hello foo"
  end
end
