defmodule TwitchEventSub.Events.ChannelPointsRedemption do
  @moduledoc """
  Cleared all chat messages.
  """
  use TwitchEventSub.Fields,
    fields: [
      :id,
      :broadcaster_id,
      :broadcaster_name,
      :channel,
      :user_id,
      :user_login,
      :user_name,
      :user_input,
      :status,
      :reward_id,
      :reward_title,
      :cost,
      :prompt,
      :redeemed_at
    ]
end
