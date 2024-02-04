defmodule TwitchEventSub.Events.Follow do
  @moduledoc false
  use TwitchEventSub.Fields,
    fields: [
      :broadcaster_id,
      :broadcaster_name,
      :channel,
      :followed_at,
      :user_id,
      :user_login,
      :user_name
    ]
end
