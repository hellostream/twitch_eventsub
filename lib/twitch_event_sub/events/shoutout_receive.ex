defmodule TwitchEventSub.Events.ShoutoutReceive do
  @moduledoc false
  use TwitchEventSub.Fields,
    fields: [
      :from_broadcaster_id,
      :from_broadcaster_name,
      :from_channel,
      :started_at,
      :to_broadcaster_id,
      :to_broadcaster_name,
      :to_channel,
      :viewer_count
    ]
end
