defmodule TwitchEventSub.Fields.Sub do
  use TwitchEventSub.Fields,
    fields: [
      :duration_months,
      :tier,
      :is_prime?
    ]
end
