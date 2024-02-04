defmodule TwitchEventSub.Fields.Resub do
  use TwitchEventSub.Fields,
    fields: [
      :cumulative_months,
      :duration_months,
      :streak_months,
      :tier,
      :is_prime?,
      :is_gift?,
      :gifter_is_anon?,
      :gifter_id,
      :gifter_name,
      :gifter_login
    ]
end
