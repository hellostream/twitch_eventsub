defmodule TwitchEventSub.Events.AdBreakBegin do
  @moduledoc false
  use TwitchEventSub.Event,
    fields: [
      :broadcaster_id,
      :broadcaster_name,
      :channel,
      :duration_seconds,
      :is_auto?,
      :requester_id,
      :requester_login,
      :requester_name,
      :started_at
    ]
end
