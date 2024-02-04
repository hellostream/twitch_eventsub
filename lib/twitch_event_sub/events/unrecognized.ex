defmodule TwitchEventSub.Events.Unrecognized do
  @moduledoc false
  use TwitchEventSub.Fields,
    fields: [
      :msg
    ]
end
