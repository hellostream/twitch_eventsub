defmodule TwitchEventSub.Events.Unrecognized do
  @moduledoc false
  use TwitchEventSub.Event,
    fields: [
      :msg
    ]
end
