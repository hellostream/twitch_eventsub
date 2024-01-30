defmodule TwitchEventSub.Events do
  @moduledoc false
  require Logger

  @events %{
    "channel.ad_break.begin" => TwitchEventSub.Events.AdBreakBegin,
    "channel.follow" => TwitchEventSub.Events.Follow,
    "channel.shoutout.create" => TwitchEventSub.Events.ShoutoutCreate,
    "channel.shoutout.receive" => TwitchEventSub.Events.ShoutoutReceive,
    "channel.chat.clear" => TwitchEventSub.Events.ChatClear,
    "channel.chat.clear_user_messages" => TwitchEventSub.Events.ChatClearUserMessages,
    "channel.chat.message_delete" => TwitchEventSub.Events.ChatMessageDelete,
    "channel.chat.notification" => TwitchEventSub.Events.ChatNotification,
    "channel.chat.message" => TwitchEventSub.Events.ChatMessage,
    "channel.subscribe" => TwitchEventSub.Events.Sub,
    "channel.subscription.gift" => TwitchEventSub.Events.SubGift
  }

  # @event_names Map.keys(@events)

  # Generate the AST for all the module's struct types as a union
  # like `TwitchEventSub.Events.Follow.t() | TwitchEventSub.Events.ShoutoutReceive` etc...
  event_types =
    Map.values(@events)
    |> Enum.sort()
    |> Enum.reduce(&{:|, [], [{{:., [], [&1, :t]}, [], []}, &2]})

  @typedoc """
  The event type union of event struct types.
  """
  @type event :: unquote(event_types)

  @typedoc """
  The params for an event as an atom-keyed map.
  """
  @type event_params :: %{required(atom()) => any()}

  @fields %{
    "broadcaster_user_id" => :broadcaster_id,
    "broadcaster_user_name" => :broadcaster_name,
    "broadcaster_user_login" => :channel,
    "chatter_user_id" => :user_id,
    "chatter_user_name" => :user_name,
    "chatter_user_login" => :user_login,
    "color" => :color,
    "cooldown_ends_at" => :cooldown_ends_at,
    "cumulative_total" => :cumulative_total,
    "duration_seconds" => :duration_seconds,
    "emotes" => :emotes,
    "followed_at" => :followed_at,
    "from_broadcaster_user_id" => :from_broadcaster_id,
    "from_broadcaster_user_login" => :from_channel,
    "from_broadcaster_user_name" => :from_broadcaster_name,
    "is_automatic" => :is_auto?,
    "is_anonymous" => :is_anon?,
    "is_gift" => :is_gift?,
    "is_prime" => :is_prime?,
    "moderator_user_id" => :moderator_id,
    "moderator_user_login" => :moderator_login,
    "moderator_user_name" => :moderator_name,
    "requester_user_id" => :requester_id,
    "requester_user_login" => :requester_login,
    "requester_user_name" => :requester_name,
    "started_at" => :started_at,
    "target_cooldown_ends_at" => :target_cooldown_ends_at,
    "tier" => :tier,
    "to_broadcaster_user_id" => :to_broadcaster_id,
    "to_broadcaster_user_name" => :to_broadcaster_name,
    "to_broadcaster_user_login" => :to_channel,
    "total" => :total,
    "user_id" => :user_id,
    "user_login" => :user_login,
    "user_name" => :user_name,
    "viewer_count" => :viewer_count,
    ["message", "fragments", "cheermote"] => :cheermote,
    ["message", "fragments", "emote"] => :emote,
    ["message", "fragments", "mention"] => :mention,
    ["message", "fragments", "text"] => :text,
    ["message", "fragments", "type"] => :type,
    ["message", "text"] => :text,
    ["badges", "id"] => :id,
    ["badges", "info"] => :info,
    ["badges", "set_id"] => :set_id
  }

  @field_names Map.keys(@fields)

  @doc """
  Take a payload and return a `TwitchChat.Event` struct.

  ## Examples

      iex> payload = %{
      ...>   "broadcaster_user_id" => "146616692",
      ...>   "broadcaster_user_login" => "ryanwinchester_",
      ...>   "broadcaster_user_name" => "RyanWinchester_",
      ...>   "followed_at" => "2024-01-19T03:32:41.640955348Z",
      ...>   "user_id" => "589368619",
      ...>   "user_login" => "foobar",
      ...>   "user_name" => "FooBar"
      ...> }
      iex> from_payload("channel.follow", payload)
      %TwitchEventSub.Events.Follow{
        broadcaster_id: "146616692",
        broadcaster_name: "RyanWinchester_",
        channel: "ryanwinchester_",
        followed_at: ~U[2024-01-19 03:32:41.640955Z],
        user_id: "589368619",
        user_login: "foobar",
        user_name: "FooBar"
      }

  """
  @spec from_payload(String.t(), map()) :: TwitchChat.Event.event()
  def from_payload(event_type, payload)

  for {event, module} <- @events do
    def from_payload(unquote(event), payload) do
      payload
      |> Enum.flat_map(&payload_map/1)
      |> then(&struct(unquote(module), &1))
    end
  end

  defp payload_map({key, nil}), do: {field(key), nil}

  defp payload_map({"cooldown_ends_at" = key, val}) do
    {field(key), parse_datetime(val)}
  end

  defp payload_map({"duration_seconds" = key, val}) when is_binary(val) do
    {field(key), String.to_integer(val)}
  end

  defp payload_map({"followed_at" = key, val}) do
    {field(key), parse_datetime(val)}
  end

  defp payload_map({"is_automatic" = key, val}) when is_binary(val) do
    {field(key), val == "true"}
  end

  defp payload_map({"message", %{} = msg}) do
    fragments =
      Enum.map(msg["fragments"], fn fragment ->
        %{
          "cheermote" => cheermote,
          "emote" => emote,
          "mention" => mention,
          "text" => text,
          "type" => type
        } = fragment

        [
          {field(["message", "fragments", "cheermote"]), cheermote},
          {field(["message", "fragments", "emote"]), emote},
          {field(["message", "fragments", "mention"]), mention},
          {field(["message", "fragments", "text"]), text},
          {field(["message", "fragments", "type"]), type}
        ]
      end)

    [
      {field(["message", "text"]), msg["text"]},
      {field(["message", "fragments"]), fragments}
    ]
  end

  defp payload_map({"started_at" = key, val}) do
    {field(key), parse_datetime(val)}
  end

  defp payload_map({"target_cooldown_ends_at" = key, val}) do
    {field(key), parse_datetime(val)}
  end

  defp payload_map({"tier" = key, val}) do
    tier =
      case val do
        "1000" -> :t1
        "2000" -> :t2
        "3000" -> :t3
      end

    {field(key), tier}
  end

  defp payload_map({key, val}) when key in @field_names, do: {field(key), val}

  defp payload_map({key, val}) do
    Logger.warning("""
    [TwitchEventSub.Events] You have found an unexpected field: #{inspect({key, val})}.
    Please open an issue at <https://github.com/hellostream/twitch_event_sub>
    """)

    {key, val}
  end

  defp field(name), do: Map.fetch!(@fields, name)

  defp parse_datetime(val) do
    case DateTime.from_iso8601(val) do
      {:ok, datetime, 0} ->
        datetime

      {:ok, datetime, offset} ->
        Logger.error("[TwitchEventSub.Events] unexpected offset (#{offset}) parsing #{val}")
        datetime

      {:error, reason} ->
        raise "#{reason}: #{val}"
    end
  end
end
