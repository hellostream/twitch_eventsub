defmodule TwitchEventSub.Events.ChatMessageDelete do
  @moduledoc """
  A chat message was deleted.
  """
  use TwitchEventSub.Fields,
    fields: [
      :broadcaster_id,
      :broadcaster_name,
      :channel,
      :user_id,
      :user_login,
      :user_name,
      :message_id
    ]
end
