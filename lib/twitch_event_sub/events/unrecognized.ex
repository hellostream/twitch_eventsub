defmodule TwitchEventSub.Events.Unrecognized do
  @moduledoc false
  use TwitchChat.Event,
    fields: [
      :msg
    ]
end
