defmodule TwitchEventSub.Fields.CharityDonation do
  use TwitchEventSub.Fields,
    fields: [
      :charity_name,
      :amount,
      :decimal_place,
      :currency
    ]
end
