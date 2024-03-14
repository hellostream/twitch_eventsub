defmodule TwitchEventSub.Subscriptions do
  @moduledoc """
  Twitch API.
  """

  require Logger

  @subscriptions %{
    "channel.update" => 2,
    "channel.follow" => 2,
    "channel.ad_break.begin" => 1,
    "channel.chat.clear" => 1,
    "channel.chat.clear_user_messages" => 1,
    "channel.chat.message" => 1,
    "channel.chat.message_delete" => 1,
    "channel.chat.notification" => 1,
    "channel.chat_settings.update" => "beta",
    "channel.subscribe" => 1,
    "channel.subscription.end" => 1,
    "channel.subscription.gift" => 1,
    "channel.subscription.message" => 1,
    "channel.cheer" => 1,
    "channel.raid" => 1,
    "channel.ban" => 1,
    "channel.unban" => 1,
    "channel.moderator.add" => 1,
    "channel.moderator.remove" => 1,
    "channel.guest_star_session.begin" => "beta",
    "channel.guest_star_session.end" => "beta",
    "channel.guest_star_guest.update" => "beta",
    "channel.guest_star_settings.update" => "beta",
    "channel.channel_points_custom_reward.add" => 1,
    "channel.channel_points_custom_reward.update" => 1,
    "channel.channel_points_custom_reward.remove" => 1,
    "channel.channel_points_custom_reward_redemption.add" => 1,
    "channel.channel_points_custom_reward_redemption.update" => 1,
    "channel.poll.begin" => 1,
    "channel.poll.progress" => 1,
    "channel.poll.end" => 1,
    "channel.prediction.begin" => 1,
    "channel.prediction.progress" => 1,
    "channel.prediction.lock" => 1,
    "channel.prediction.end" => 1,
    "channel.charity_campaign.donate" => 1,
    "channel.charity_campaign.start" => 1,
    "channel.charity_campaign.progress" => 1,
    "channel.charity_campaign.stop" => 1,
    "conduit.shard.disabled" => 1,
    "drop.entitlement.grant" => 1,
    "extension.bits_transaction.create" => 1,
    "channel.goal.begin" => 1,
    "channel.goal.progress" => 1,
    "channel.goal.end" => 1,
    "channel.hype_train.begin" => 1,
    "channel.hype_train.progress" => 1,
    "channel.hype_train.end" => 1,
    "channel.shield_mode.begin" => 1,
    "channel.shield_mode.end" => 1,
    "channel.shoutout.create" => 1,
    "channel.shoutout.receive" => 1,
    "stream.online" => 1,
    "stream.offline" => 1,
    "user.authorization.grant" => 1,
    "user.authorization.revoke" => 1,
    "user.update" => 1
  }

  @subscription_types Map.keys(@subscriptions)

  @doc """
  Create an eventsub subscription using websockets.
  """
  def create(auth, type, channel_id, user_id, session_id) when type in @subscription_types do
    version = Map.fetch!(@subscriptions, type)
    condition = condition(type, channel_id, user_id)
    TwitchAPI.create_eventsub_websocket_subscription(auth, session_id, type, version, condition)
  end

  @doc """
  List all eventsub subscriptions.
  """
  def list(auth, params \\ %{}) do
    TwitchAPI.list_eventsub_subscriptions(auth, params)
  end

  # ----------------------------------------------------------------------------
  # Subscription conditions...
  # ----------------------------------------------------------------------------

  defp condition("channel.ad_break." <> _, channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("channel.ban", channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("channel.channel_points_custom_reward." <> _, channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("channel.channel_points_custom_reward_redemption." <> _, channel_id, _user_id) do
    # There is an optional `reward_id` field, but we are not supporting this.
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("channel.charity_campaign." <> _, channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("channel.chat." <> _, channel_id, user_id) do
    %{
      "broadcaster_user_id" => channel_id,
      "user_id" => user_id
    }
  end

  defp condition("channel.chat_settings." <> _, channel_id, user_id) do
    %{
      "broadcaster_user_id" => channel_id,
      "user_id" => user_id
    }
  end

  defp condition("channel.cheer", channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("channel.follow", channel_id, user_id) do
    %{
      "broadcaster_user_id" => channel_id,
      "moderator_user_id" => user_id
    }
  end

  defp condition("channel.goal." <> _, channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("channel.guest_star_session." <> _, channel_id, user_id) do
    %{
      "broadcaster_user_id" => channel_id,
      "moderator_user_id" => user_id
    }
  end

  defp condition("channel.hype_train." <> _, channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("channel.moderator." <> _, channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("channel.poll." <> _, channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("channel.prediction." <> _, channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("channel.raid", channel_id, _user_id) do
    %{"to_broadcaster_user_id" => channel_id}
  end

  defp condition("channel.shield_mode." <> _, channel_id, user_id) do
    %{
      "broadcaster_user_id" => channel_id,
      "moderator_user_id" => user_id
    }
  end

  defp condition("channel.shoutout." <> _, channel_id, user_id) do
    %{
      "broadcaster_user_id" => channel_id,
      "moderator_user_id" => user_id
    }
  end

  defp condition("channel.subscribe", channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("channel.subscription." <> _, channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("channel.unban", channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("channel.update", channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("conduit.shard." <> _, _channel_id, _user_id) do
    # %{"client_id" => client_id}
    raise "We do not yet support conduits subscriptions"
  end

  defp condition("extensions." <> _, _channel_id, _user_id) do
    # %{"extension_client_id" => client_id}
    raise "We do not yet support extension subscriptions"
  end

  defp condition("drop.entitlement" <> _, _channel_id, _user_id) do
    # Optional fields: `category_id` and `campaign_id`...
    # %{"organization_id" => organization_id}
    raise "We do not yet support drops subscriptions"
  end

  defp condition("stream." <> _, channel_id, _user_id) do
    %{"broadcaster_user_id" => channel_id}
  end

  defp condition("user.authorization." <> _, _channel_id, _user_id) do
    # %{"client_id" => client_id}
    raise "We do not yet support user auth subscriptions"
  end

  defp condition("user.update", _channel_id, user_id) do
    %{"user_id" => user_id}
  end

  # Catch-all subscription, just attempt to use `broadcaster_user_id` condition.
  defp condition(type, channel_id, _user_id) do
    Logger.warning("""
    [TwitchEventSub.TwitchClient] unexpected subscription: #{type}
    Please create an issue at <https://github.com/hellostream/twitch_eventsub>
    """)

    %{"broadcaster_user_id" => channel_id}
  end
end
