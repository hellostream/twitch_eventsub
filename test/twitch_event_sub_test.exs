defmodule TwitchEventSubTest do
  use ExUnit.Case, async: true
  doctest TwitchEventSub

  defmodule TestHandler do
    use TwitchEventSub

    @impl true
    def handle_event("channel.subscribe", event) do
      "Hello #{event["broadcaster_user_login"]}"
    end
  end

  test "test handler implementation" do
    event = %{"broadcaster_user_login" => "foo"}
    assert TestHandler.handle_event("channel.subscribe", event) == "Hello foo"
  end
end
