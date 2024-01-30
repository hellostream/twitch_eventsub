defmodule TwitchEventsub.EventsTest do
  use ExUnit.Case, async: true

  @eventsub_data_path Path.expand("../support/data", __DIR__)
  @eventsub_message_files File.ls!(@eventsub_data_path)

  doctest TwitchEventSub.Events, import: true

  describe "eventsub" do
    # Generate a bunch of tests for every batch of messages in the messages test
    # data files. This just makes sure we don't have any breaking changes in our
    # tag and event parsing.
    for file <- @eventsub_message_files do
      test "#{file}" do
        {messages, []} = Code.eval_file(unquote(file), @eventsub_data_path)

        for message <- messages do
          %{"subscription" => %{"type" => type}, "event" => payload} = message
          assert _event = TwitchEventSub.Events.from_payload(type, payload)
        end
      end
    end
  end
end
