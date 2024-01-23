defmodule TwitchEventSubTest do
  use ExUnit.Case
  doctest TwitchEventSub

  test "greets the world" do
    assert TwitchEventSub.hello() == :world
  end
end
