defmodule TwitchEventSub.Events.SubGift do
  @moduledoc false
  use TwitchEventSub.Event,
    fields: [
      :broadcaster_id,
      :broadcaster_name,
      :channel,
      :user_id,
      :user_login,
      :user_name,
      :total,
      :tier,
      :cumulative_total,
      :is_anon?
    ]
end
