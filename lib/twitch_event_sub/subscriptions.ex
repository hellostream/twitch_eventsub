defmodule TwitchEventSub.Subscriptions do
  @moduledoc """
  Twitch API.
  """

  require Logger

  @subscriptions TwitchEventSub.Subscriptions.Subscription.subscription_types()
  @subscription_types TwitchEventSub.Subscriptions.Subscription.subscription_type_names()

  @transport_methods [:conduit, :webhook, :websocket]

  @doc """
  Create an eventsub subscription.
  """
  @spec create(
          method :: :conduit | :webhook | :websocket,
          auth :: TwitchAPI.Auth.t(),
          type :: String.t(),
          opts :: keyword()
        ) :: TwitchAPI.response()
  def create(method, auth, type, opts)
      when method in @transport_methods and type in @subscription_types and is_list(opts) do
    version = Map.fetch!(@subscriptions, type)

    transport =
      case method do
        :conduit ->
          %{
            "method" => "conduit",
            "conduit_id" => Keyword.fetch!(opts, :conduit_id)
          }

        :webhook ->
          %{
            "method" => "webhook",
            "callback" => Keyword.fetch!(opts, :callback),
            "secret" => Keyword.fetch!(opts, :secret)
          }

        :websocket ->
          %{
            "method" => "websocket",
            "session_id" => Keyword.fetch!(opts, :session_id)
          }
      end

    # You can pass the condition with the subscription, or just the
    # subscription name and we will use the default condition available.
    condition =
      Keyword.get_lazy(opts, :condition, fn ->
        broadcaster_user_id = Keyword.fetch!(opts, :broadcaster_user_id)
        user_id = Keyword.fetch!(opts, :user_id)
        condition(type, broadcaster_user_id, user_id)
      end)

    TwitchAPI.create_eventsub_subscription(auth, type, version, transport, condition)
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

  defp condition("channel.ad_break." <> _, broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("channel.ban", broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("channel.channel_points_custom_reward." <> _, broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition(
         "channel.channel_points_custom_reward_redemption." <> _,
         broadcaster_user_id,
         _user_id
       ) do
    # There is an optional `reward_id` field, but we are not supporting this.
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("channel.charity_campaign." <> _, broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("channel.chat." <> _, broadcaster_user_id, user_id) do
    %{
      "broadcaster_user_id" => broadcaster_user_id,
      "user_id" => user_id
    }
  end

  defp condition("channel.chat_settings." <> _, broadcaster_user_id, user_id) do
    %{
      "broadcaster_user_id" => broadcaster_user_id,
      "user_id" => user_id
    }
  end

  defp condition("channel.cheer", broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("channel.follow", broadcaster_user_id, user_id) do
    %{
      "broadcaster_user_id" => broadcaster_user_id,
      "moderator_user_id" => user_id
    }
  end

  defp condition("channel.goal." <> _, broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("channel.guest_star_session." <> _, broadcaster_user_id, user_id) do
    %{
      "broadcaster_user_id" => broadcaster_user_id,
      "moderator_user_id" => user_id
    }
  end

  defp condition("channel.hype_train." <> _, broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("channel.moderator." <> _, broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("channel.poll." <> _, broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("channel.prediction." <> _, broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("channel.raid", broadcaster_user_id, _user_id) do
    %{"to_broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("channel.shield_mode." <> _, broadcaster_user_id, user_id) do
    %{
      "broadcaster_user_id" => broadcaster_user_id,
      "moderator_user_id" => user_id
    }
  end

  defp condition("channel.shoutout." <> _, broadcaster_user_id, user_id) do
    %{
      "broadcaster_user_id" => broadcaster_user_id,
      "moderator_user_id" => user_id
    }
  end

  defp condition("channel.subscribe", broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("channel.subscription." <> _, broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("channel.unban", broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("channel.update", broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("stream." <> _, broadcaster_user_id, _user_id) do
    %{"broadcaster_user_id" => broadcaster_user_id}
  end

  defp condition("user.update", _broadcaster_user_id, user_id) do
    %{"user_id" => user_id}
  end

  # Catch-all subscription, just attempt to use `broadcaster_user_id` condition.
  defp condition(type, broadcaster_user_id, _user_id) do
    Logger.warning("""
    [TwitchEventSub.Subscriptions] no default condition for subscription #{type}.
    Attempting to use a generic condition with just `broadcaster_user_id`.
    See: <https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/>
    """)

    %{"broadcaster_user_id" => broadcaster_user_id}
  end
end
