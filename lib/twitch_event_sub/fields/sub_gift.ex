defmodule TwitchEventSub.Fields.SubGift do
  use TwitchEventSub.Fields,
    fields: [
      :community_gift_id,
      :cumulative_total,
      :duration_months,
      :tier,
      :recipient_id,
      :recipient_name,
      :recipient_login
    ]
end
