defmodule TwitchEventSub.Events.SubEnd do
  @moduledoc false
  use TwitchEventSub.Event,
    fields: [
      :broadcaster_id,
      :broadcaster_name,
      :channel,
      :user_id,
      :user_login,
      :user_name,
      :tier,
      :is_gift?
    ]
end
