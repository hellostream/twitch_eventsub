defmodule TwitchEventSub.Events do
  @moduledoc false
  require Logger

  @events %{
    "channel.ad_break.begin" => TwitchEventSub.Events.AdBreakBegin,
    "channel.channel_points_custom_reward_redemption.add" =>
      TwitchEventSub.Events.ChannelPointsRedemption,
    "channel.follow" => TwitchEventSub.Events.Follow,
    "channel.shoutout.create" => TwitchEventSub.Events.ShoutoutCreate,
    "channel.shoutout.receive" => TwitchEventSub.Events.ShoutoutReceive,
    "channel.chat.clear" => TwitchEventSub.Events.ChatClear,
    "channel.chat.clear_user_messages" => TwitchEventSub.Events.ChatClearUserMessages,
    "channel.chat.message_delete" => TwitchEventSub.Events.ChatMessageDelete,
    "channel.chat.notification" => TwitchEventSub.Events.ChatNotification,
    "channel.chat.message" => TwitchEventSub.Events.ChatMessage,
    "channel.cheer" => TwitchEventSub.Events.Cheer,
    "channel.subscribe" => TwitchEventSub.Events.Sub,
    "channel.subscription.gift" => TwitchEventSub.Events.SubGift,
    "channel.subscription.message" => TwitchEventSub.Events.SubMessage
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
    "announcement" => :announcement,
    "badges" => :badges,
    "bits" => :bits,
    "bits_badge_tier" => :bits_badge_tier,
    "broadcaster_user_id" => :broadcaster_id,
    "broadcaster_user_name" => :broadcaster_name,
    "broadcaster_user_login" => :channel,
    "channel_points_custom_reward_id" => :custom_reward_id,
    "charity_donation" => :charity_donation,
    "chatter_is_anonymous" => :is_anon?,
    "chatter_user_id" => :user_id,
    "chatter_user_name" => :user_name,
    "chatter_user_login" => :user_login,
    "cheer" => :cheer,
    "cheermote" => :cheermote,
    "color" => :color,
    "community_gift_id" => :community_gift_id,
    "community_sub_gift" => :community_sub_gift,
    "cooldown_ends_at" => :cooldown_ends_at,
    "cumulative_total" => :cumulative_total,
    "cumulative_months" => :cumulative_months,
    "duration_months" => :duration_months,
    "duration_seconds" => :duration_seconds,
    "emote" => :emote,
    "emotes" => :emotes,
    "emote_set_id" => :set_id,
    "followed_at" => :followed_at,
    "format" => :format,
    "fragments" => :fragments,
    "from_broadcaster_user_id" => :from_broadcaster_id,
    "from_broadcaster_user_login" => :from_channel,
    "from_broadcaster_user_name" => :from_broadcaster_name,
    "gifter_is_anonymous" => :gifter_is_anon?,
    "gift_paid_upgrade" => :gift_paid_upgrade,
    "gifter_user_id" => :gifter_id,
    "gifter_user_name" => :gifter_name,
    "gifter_user_login" => :gifter_login,
    "id" => :id,
    "info" => :info,
    "is_automatic" => :is_auto?,
    "is_anonymous" => :is_anon?,
    "is_gift" => :is_gift?,
    "is_prime" => :is_prime?,
    "mention" => :mention,
    "message" => :message,
    "message_id" => :message_id,
    "message_type" => :message_type,
    "moderator_user_id" => :moderator_id,
    "moderator_user_login" => :moderator_login,
    "moderator_user_name" => :moderator_name,
    "notice_type" => :notice_type,
    "owner_id" => :owner_id,
    "pay_it_forward" => :pay_it_forward,
    "prime_paid_upgrade" => :prime_paid_upgrade,
    "profile_image_url" => :profile_image_url,
    "raid" => :raid,
    "recipient_user_id" => :recipient_id,
    "recipient_user_login" => :recipient_login,
    "recipient_user_name" => :recipient_name,
    "redeemed_at" => :redeemed_at,
    "reply" => :reply,
    "requester_user_id" => :requester_id,
    "requester_user_login" => :requester_login,
    "requester_user_name" => :requester_name,
    "resub" => :resub,
    "reward" => :reward,
    "set_id" => :set_id,
    "started_at" => :started_at,
    "streak_months" => :streak_months,
    "status" => :status,
    "sub" => :sub,
    "sub_gift" => :sub_gift,
    "sub_tier" => :tier,
    "system_message" => :system_message,
    "target_cooldown_ends_at" => :target_cooldown_ends_at,
    "target_user_id" => :user_id,
    "target_user_login" => :user_login,
    "target_user_name" => :user_name,
    "text" => :text,
    "tier" => :tier,
    "to_broadcaster_user_id" => :to_broadcaster_id,
    "to_broadcaster_user_name" => :to_broadcaster_name,
    "to_broadcaster_user_login" => :to_channel,
    "total" => :total,
    "type" => :type,
    "unraid" => :unraid,
    "user_id" => :user_id,
    "user_input" => :user_input,
    "user_login" => :user_login,
    "user_name" => :user_name,
    "viewer_count" => :viewer_count,
    ["reward", "cost"] => :cost,
    ["reward", "id"] => :reward_id,
    ["reward", "prompt"] => :reqard_prompt,
    ["reward", "title"] => :reward_title
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
      |> Enum.map(&payload_map/1)
      |> List.flatten()
      |> then(&struct(unquote(module), &1))
    end
  end

  defp payload_map({key, nil}), do: {field(key), nil}

  defp payload_map({"announcement" = key, %{} = val}) do
    announcement =
      Map.new(val, fn {k, v} -> {field(k), v} end)
      |> then(&struct(TwitchEventSub.Fields.Announcement, &1))

    {field(key), announcement}
  end

  defp payload_map({"badges" = key, val}) when is_list(val) do
    badges =
      Enum.map(val, fn badge ->
        badge
        |> Map.new(fn
          {k, ""} -> {field(k), nil}
          {k, v} -> {field(k), v}
        end)
        |> then(&struct(TwitchEventSub.Fields.Badge, &1))
      end)

    {field(key), badges}
  end

  defp payload_map({"bits_badge_tier" = key, %{"tier" => badge_tier}}) do
    tier = struct(TwitchEventSub.Fields.BitsBadgeTier, %{tier: badge_tier})
    {field(key), tier}
  end

  defp payload_map({"community_sub_gift" = key, %{} = val}) do
    community_sub_gift =
      Map.new(val, fn
        {"sub_tier" = k, v} ->
          tier =
            case v do
              "1000" -> :t1
              "2000" -> :t2
              "3000" -> :t3
            end

          {field(k), tier}

        {k, v} ->
          {field(k), v}
      end)
      |> then(&struct(TwitchEventSub.Fields.CommunitySubGift, &1))

    {field(key), community_sub_gift}
  end

  defp payload_map({"cooldown_ends_at" = key, val}) do
    {field(key), parse_datetime(val)}
  end

  defp payload_map({"duration_seconds" = key, val}) when is_binary(val) do
    {field(key), String.to_integer(val)}
  end

  defp payload_map({"followed_at" = key, val}) do
    {field(key), parse_datetime(val)}
  end

  defp payload_map({"gift_paid_upgrade" = key, %{} = val}) do
    community_sub_gift =
      val
      |> Map.new(fn {k, v} -> {field(k), v} end)
      |> then(&struct(TwitchEventSub.Fields.GiftPaidUpgrade, &1))

    {field(key), community_sub_gift}
  end

  defp payload_map({"is_automatic" = key, val}) when is_binary(val) do
    {field(key), val == "true"}
  end

  defp payload_map({"message", %{} = msg}) do
    fragments =
      Enum.map(msg["fragments"] || [], fn
        %{"type" => "cheermote", "cheermote" => cheermote} = _fragment ->
          cheermote
          |> Map.new(fn {k, v} -> {field(k), v} end)
          |> then(&struct(TwitchEventSub.Fields.Message.Fragments.Cheermote, &1))

        %{"type" => "emote", "emote" => emote} = _fragment ->
          emote
          |> Map.new(fn {k, v} -> {field(k), v} end)
          |> then(&struct(TwitchEventSub.Fields.Message.Fragments.Emote, &1))

        %{"type" => "mention", "mention" => mention} = _fragment ->
          mention
          |> Map.new(fn {k, v} -> {field(k), v} end)
          |> then(&struct(TwitchEventSub.Fields.Message.Fragments.Mention, &1))

        %{"type" => "text", "text" => text} = _fragment ->
          struct(TwitchEventSub.Fields.Message.Fragments.Text, text: text)
      end)

    [
      {field("text"), msg["text"]},
      {field("fragments"), fragments}
    ]
  end

  defp payload_map({"pay_it_forward" = key, %{} = val}) do
    pay_it_forward =
      val
      |> Map.new(fn {k, v} -> {field(k), v} end)
      |> then(&struct(TwitchEventSub.Fields.PayItForward, &1))

    {field(key), pay_it_forward}
  end

  defp payload_map({"prime_paid_upgrade" = key, %{"sub_tier" => sub_tier}}) do
    tier =
      case sub_tier do
        "1000" -> :t1
        "2000" -> :t2
        "3000" -> :t3
      end

    prime_paid_upgrade =
      struct(TwitchEventSub.Fields.PrimePaidUpgrade, [{field("sub_tier"), tier}])

    {field(key), prime_paid_upgrade}
  end

  defp payload_map({"redeemed_at" = key, %{} = val}) do
    {:ok, redeemed_at, _} = DateTime.from_iso8601(val)
    {field(key), redeemed_at}
  end

  defp payload_map({"reply" = key, %{} = val}) do
    reply =
      val
      |> Map.new(fn {k, v} -> {field(k), v} end)
      |> then(&struct(TwitchEventSub.Fields.Message.Reply, &1))

    {field(key), reply}
  end

  defp payload_map({"resub" = key, %{} = val}) do
    reply =
      val
      |> Map.new(fn
        {"sub_tier", sub_tier} ->
          tier =
            case sub_tier do
              "1000" -> :t1
              "2000" -> :t2
              "3000" -> :t3
            end

          {field("sub_tier"), tier}

        {k, v} ->
          {field(k), v}
      end)
      |> then(&struct(TwitchEventSub.Fields.Message.Resub, &1))

    {field(key), reply}
  end

  defp payload_map({"reward", %{} = val}) do
    Enum.map(val, fn {k, v} ->
      payload_map({["reward", k], v})
    end)
  end

  defp payload_map({["reward", "cost"] = key, val}) when is_binary(val) do
    {field(key), String.to_integer(val)}
  end

  defp payload_map({["reward", _] = key, val}) when is_binary(val) do
    {field(key), val}
  end

  defp payload_map({"started_at" = key, val}) do
    {field(key), parse_datetime(val)}
  end

  defp payload_map({"sub" = key, %{} = val}) do
    reply =
      val
      |> Map.new(fn
        {"sub_tier", sub_tier} ->
          tier =
            case sub_tier do
              "1000" -> :t1
              "2000" -> :t2
              "3000" -> :t3
            end

          {field("sub_tier"), tier}

        {k, v} ->
          {field(k), v}
      end)
      |> then(&struct(TwitchEventSub.Fields.Message.Sub, &1))

    {field(key), reply}
  end

  defp payload_map({"sub_gift" = key, %{} = val}) do
    reply =
      val
      |> Map.new(fn
        {"sub_tier", sub_tier} ->
          tier =
            case sub_tier do
              "1000" -> :t1
              "2000" -> :t2
              "3000" -> :t3
            end

          {field("sub_tier"), tier}

        {k, v} ->
          {field(k), v}
      end)
      |> then(&struct(TwitchEventSub.Fields.Message.SubGift, &1))

    {field(key), reply}
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

  defp payload_map({"unraid" = key, %{} = _val}) do
    {field(key), struct(TwitchEventSub.Fields.Unraid, %{})}
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
