defmodule TwitchEventSub.Fields.Message.Reply do
  @moduledoc """
  A message reply struct.
  """
  use TwitchEventSub.Fields,
    fields: [
      :parent_message_id,
      :parent_message_body,
      :parent_user_id,
      :parent_user_login,
      :parent_user_name,
      :thread_message_id,
      :thread_user_id,
      :thread_user_login,
      :thread_user_name
    ]
end
