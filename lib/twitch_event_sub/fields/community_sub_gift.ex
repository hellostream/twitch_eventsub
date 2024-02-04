defmodule TwitchEventSub.Fields.CommunitySubGift do
  @moduledoc """
  Community sub gift field in chat notification.
  """
  use TwitchEventSub.Fields,
    fields: [
      :id,
      :total,
      :tier,
      # :1000, - First level of paid or Prime subscription.
      # :2000, - Second level of paid subscription.
      # :3000, - Third level of paid subscription.
      :cumulative_total
    ]
end
