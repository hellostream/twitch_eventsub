defmodule TwitchEventSub.Fields.GiftPaidUpgrade do
  use TwitchEventSub.Fields,
    fields: [
      :gifter_is_anon?,
      :gifter_id,
      :gifter_name,
      :gifter_login
    ]
end
