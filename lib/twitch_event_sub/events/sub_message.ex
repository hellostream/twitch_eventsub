defmodule TwitchEventSub.Events.SubMessage do
  @moduledoc false
  use TwitchEventSub.Fields,
    fields: [
      :broadcaster_id,
      :broadcaster_name,
      :channel,
      :user_id,
      :user_login,
      :user_name,
      :emotes,
      :text,
      :tier,
      :cumulative_months,
      :duration_months,
      :streak_months
    ]
end
