defmodule TwitchEventSub.Events.ChatClearUserMessages do
  @moduledoc """
  A user has been banned or timed out.
  """
  use TwitchEventSub.Fields,
    fields: [
      :broadcaster_id,
      :broadcaster_name,
      :channel,
      :user_id,
      :user_login,
      :user_name
    ]
end
