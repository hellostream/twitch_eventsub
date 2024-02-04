defmodule TwitchEventSub.Fields do
  @moduledoc """
  Fields derived from Twitch payloads.
  """

  @typedoc """
  Found in Twitch EventSub.
  """
  @type badge :: %{
          id: String.t(),
          info: String.t(),
          set_id: String.t()
        }

  @typedoc """
  Found in Twitch EventSub.
  """
  @type badges :: [badge()]

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
  Metadata pertaining to a cheermote.

   * `:prefix` - The name portion of the Cheermote string that you use in chat
     to cheer Bits. The full Cheermote string is the concatenation of {prefix} +
     {number of Bits}. For example, if the prefix is “Cheer” and you want to
     cheer 100 Bits, the full Cheermote string is Cheer100. When the Cheermote
     string is entered in chat, Twitch converts it to the image associated with
     the Bits tier that was cheered.
  * `:bits` - The amount of bits cheered.
  * `:tier` - The tier level of the cheermote.

  """
  @type cheermote :: %{
          prefix: String.t(),
          bits: non_neg_integer(),
          tier: non_neg_integer()
        }

  @typedoc """
  Found in Twitch EventSub.
  """
  @type color :: String.t()

  @typedoc """
  Found in Twitch EventSub.
  Is `nil` if from something like an anonymous sub gift.
  """
  @type cumulative_total :: non_neg_integer() | nil

  @typedoc """
  Found in Twitch EventSub.
  """
  @type duration_seconds :: String.t()

  @typedoc """
  Metadata pertaining to an emote.
  """
  @type emote :: %{
          __struct__: TwitchEventSub.Events.ChatMessage.Fragments.Emote,
          id: String.t(),
          emote_set_id: String.t(),
          owner_id: String.t(),
          format: [:animated | :static]
        }

  @typedoc """
  Found in Twitch EventSub.
  """
  @type emotes :: [emote()]

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
  @type is_anon? :: boolean()

  @typedoc """
  Found in Twitch EventSub.
  """
  @type is_auto? :: boolean()

  @typedoc """
  Found in Twitch EventSub.
  """
  @type is_gift? :: boolean()

  @typedoc """
  Found in Twitch EventSub.
  """
  @type is_prime? :: boolean()

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
  Found in Twitch EventSub subscriptions `channel.subscribe`.
  """
  @type tier :: :t1 | :t2 | :t3

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

  # Behaviour and implementation of Events.
  #
  # Use a list of `:fields` to build the struct and struct type for an event
  # module.
  #
  # This isn't great because we will only see the types in the LSP and docs.
  # However, it saves me a lot of time while writing this library.
  #
  # In the future I will either figure out some way to do codegen or manually
  # build the structs and types.
  #
  # ## Options
  #
  #   * `:fields` - A list of field names. Must match the types in `TwitchEventSub.Fields`.
  #      Required.
  #
  # ## Example
  #
  #     defmodule TwitchEventSub.Events.Foo
  #       use TwitchEventSub.Event, fields: [:foo, :bar]
  #     end
  #

  @doc false
  defmacro __using__(opts) do
    fields = Keyword.fetch!(opts, :fields)

    field_types =
      for field_name <- fields do
        {field_name, quote(do: TwitchEventSub.Fields.unquote(field_name))}
      end

    quote do
      @type t :: %__MODULE__{unquote_splicing(field_types)}
      defstruct(unquote(fields))
    end
  end
end
