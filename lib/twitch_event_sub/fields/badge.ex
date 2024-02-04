defmodule TwitchEventSub.Fields.Badge do
  @moduledoc """
  Badge field.
  """
  use TwitchEventSub.Fields,
    fields: [
      :id,
      :info,
      :set_id
    ]
end
