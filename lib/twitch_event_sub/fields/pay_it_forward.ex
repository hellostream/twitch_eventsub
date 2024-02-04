defmodule TwitchEventSub.Fields.PayItForward do
  @moduledoc """
  Pay it forward field from chat notification.
  """
  use TwitchEventSub.Fields,
    fields: [
      :gifter_is_anon?,
      :gifter_id,
      :gifter_name,
      :gifter_login
    ]
end
