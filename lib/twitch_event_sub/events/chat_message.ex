defmodule TwitchEventSub.Events.ChatMessage do
  @moduledoc """
  A chat message.
  """
  use TwitchEventSub.Fields,
    fields: [
      :broadcaster_id,
      :broadcaster_name,
      :channel,
      :user_id,
      :user_login,
      :user_name,
      :id,
      :message,
      :color,
      :badges,
      # [
      #   %{
      #     "set_id" => "moderator",
      #     "id" => "1",
      #     "info" => ""
      #   },
      #   %{
      #     "set_id" => "subscriber",
      #     "id" => "12",
      #     "info" => "16"
      #   },
      #   %{
      #     "set_id" => "sub-gifter",
      #     "id" => "1",
      #     "info" => ""
      #   }
      # ],
      # "text",
      :message_type,
      # nil,
      :cheer,
      # nil,
      :reply,
      # nil
      :channel_points_custom_reward_id
    ]
end
