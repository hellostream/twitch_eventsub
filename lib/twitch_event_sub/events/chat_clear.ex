defmodule TwitchEventSub.Events.ChatClear do
  @moduledoc """
  Cleared all chat messages.
  """
  use TwitchEventSub.Fields,
    fields: [
      :broadcaster_id,
      :broadcaster_name,
      :channel
    ]
end
