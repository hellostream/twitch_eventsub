defmodule TwitchEventSub.Fields do
  @moduledoc """
  Fields derived from Twitch payloads.
  """

  @typedoc """
  Found in Twitch EventSub subscriptions `channel.shoutout.receive`.
  """
  @type broadcaster_id :: String.t()

  @typedoc """
  Found in Twitch EventSub subscriptions `channel.shoutout.receive`.
  """
  @type broadcaster_name :: String.t()

  @typedoc """
  Found in Twitch EventSub.
  """
  @type channel :: String.t()

  @typedoc """
  Found in Twitch EventSub.
  """
  @type duration_seconds :: String.t()

  @typedoc """
  Found in Twitch EventSub subscriptions `channel.follow`.
  """
  @type followed_at :: DateTime.t()

  @typedoc """
  Found in Twitch EventSub subscriptions `channel.shoutout.receive`.
  """
  @type from_broadcaster_name :: broadcaster_name()

  @typedoc """
  Found in Twitch EventSub subscriptions `channel.shoutout.receive`.
  """
  @type from_broadcaster_user_id :: broadcaster_id()

  @typedoc """
  Found in Twitch EventSub subscriptions `channel.shoutout.receive`.
  """
  @type from_channel :: channel()

  @typedoc """
  Found in Twitch EventSub.
  """
  @type is_automatic :: boolean()

  @typedoc """
  Found in Twitch EventSub.
  """
  @type requester_id :: String.t()

  @typedoc """
  Found in Twitch EventSub.
  """
  @type requester_login :: String.t()

  @typedoc """
  Found in Twitch EventSub.
  """
  @type requester_name :: String.t()

  @typedoc """
  Found in Twitch EventSub subscriptions `channel.shoutout.receive`.
  """
  @type started_at :: DateTime.t()

  @typedoc """
  Found in Follow event.
  """
  @type user_id :: String.t()
  
  @typedoc """
  Found in Follow event.
  """
  @type user_login :: String.t()
  
  @typedoc """
  Found in Follow event.
  """
  @type user_name :: String.t()

  @typedoc """
  Found in EventSub subscriptions `channel.shoutout.receive` payload.
  Included only with `raid` notices.
  The number of viewers raiding this channel from the broadcaster’s channel.
  """
  @type viewer_count :: non_neg_integer()
end
