defmodule TwitchEventSub.Events.ChatMessage do
  @moduledoc """
  A chat message.
  """

  defmodule Fragments do
    defmodule Cheermote do
      defstruct [:prefix, :bits, :tier]
    end

    defmodule Emote do
      defstruct [:id, :emote_set_id, :owner_id, :format]
    end

    defmodule Mention do
      defstruct [:user_id, :user_name, :user_login]
    end
  end

  use TwitchEventSub.Event,
    fields: [
      :broadcaster_id,
      :broadcaster_name,
      :channel,
      :user_id,
      :user_login,
      :user_name,
      :id,
      :message,
      :color,
      :badges,
      # [
      #   %{
      #     "set_id" => "moderator",
      #     "id" => "1",
      #     "info" => ""
      #   },
      #   %{
      #     "set_id" => "subscriber",
      #     "id" => "12",
      #     "info" => "16"
      #   },
      #   %{
      #     "set_id" => "sub-gifter",
      #     "id" => "1",
      #     "info" => ""
      #   }
      # ],
      # "text",
      :message_type,
      # nil,
      :cheer,
      # nil,
      :reply,
      # nil
      :channel_points_custom_reward_id
    ]
end

# defmodule TwitchEventSub.Events.Message do
#   @type t :: %__MODULE__{text: String.t(), fragments: Fragments.t()}
#   @enforce_keys [:text]
#   defstruct [:text, :fragments]
# end

# defmodule TwitchEventSub.Events.Message.Fragments do
#   @type t :: %__MODULE__{type: String.t(), fragments: Fragments.t()}
#   @enforce_keys [:text]
#   defstruct [:text, :fragments]
# end
