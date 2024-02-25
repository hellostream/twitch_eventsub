defmodule TwitchEventSub.Events.Cheer do
  @moduledoc """
  Cleared all chat messages.
  """
  use TwitchEventSub.Fields,
    fields: [
      :broadcaster_id,
      :broadcaster_name,
      :channel,
      :is_anon?,
      :message,
      :user_id,
      :user_login,
      :user_name,
      :bits
    ]
end
