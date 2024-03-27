defmodule TwitchEventSub.Subscriptions do
  @moduledoc """
  Twitch API.
  """

  alias TwitchEventSub.Subscriptions.Subscription

  require Logger

  @doc """
  Create many Twitch event sub subscriptions.
  """
  @spec create_many(
          auth :: TwitchAPI.Auth.t(),
          method :: :conduit | :webhook | :websocket,
          subscriptions :: [String.t()],
          opts :: map()
        ) :: :ok
  def create_many(%TwitchAPI.Auth{} = auth, method, subscriptions, opts)
      when is_list(subscriptions) do
    broadcaster_id = Map.fetch!(opts, :broadcaster_user_id)
    user_id = Map.fetch!(opts, :user_id)

    Enum.each(subscriptions, fn name ->
      condition =
        with nil <- get_in(opts, [:conditions, name]) do
          condition(name, broadcaster_id, user_id)
        end

      subscription = Subscription.new(%{method: method, name: name, condition: condition})

      create(auth, subscription, opts)
    end)
  end

  @doc """
  Create an eventsub subscription.
  """
  @spec create(
          auth :: TwitchAPI.Auth.t(),
          subscription :: Subscription.t(),
          opts :: map()
        ) :: {:ok, Req.Response.t()} | {:error, term()}
  def create(%TwitchAPI.Auth{} = auth, %Subscription{} = subscription, opts) do
    params = %{
      "type" => subscription.name,
      "version" => subscription.version,
      "condition" => subscription.condition,
      "transport" => transport(subscription.method, opts)
    }

    TwitchAPI.post(auth, "/eventsub/subscriptions", json: params, success: 202)
  end

  @doc """
  List all eventsub subscriptions.
  """
  @spec list(TwitchAPI.Auth.t(), params :: map()) :: {:ok, Req.Response.t()} | {:error, term()}
  def list(%TwitchAPI.Auth{} = auth, params \\ %{}) do
    TwitchAPI.get(auth, "/eventsub/subscriptions", json: params)
  end

  # ----------------------------------------------------------------------------
  # Helpers
  # ----------------------------------------------------------------------------

  defp transport(:conduit, opts) do
    %{
      "method" => "conduit",
      "conduit_id" => opts.conduit_id
    }
  end

  defp transport(:webhook, opts) do
    %{
      "method" => "webhook",
      "callback" => opts.callback,
      "secret" => opts.secret
    }
  end

  defp transport(:websocket, opts) do
    %{
      "method" => "websocket",
      "session_id" => opts.session_id
    }
  end

  # ----------------------------------------------------------------------------
  # Subscription conditions...
  # ----------------------------------------------------------------------------

  defp condition("channel.ad_break." <> _, broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("channel.ban", broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("channel.channel_points_custom_reward." <> _, broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition(
         "channel.channel_points_custom_reward_redemption." <> _,
         broadcaster_user_id,
         _user_id
       ) do
    # There is an optional `reward_id` field, but we are not supporting this.
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("channel.charity_campaign." <> _, broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("channel.chat." <> _, broadcaster_user_id, user_id) do
    %{
      broadcaster_user_id: broadcaster_user_id,
      user_id: user_id
    }
  end

  defp condition("channel.chat_settings." <> _, broadcaster_user_id, user_id) do
    %{
      broadcaster_user_id: broadcaster_user_id,
      user_id: user_id
    }
  end

  defp condition("channel.cheer", broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("channel.follow", broadcaster_user_id, user_id) do
    %{
      broadcaster_user_id: broadcaster_user_id,
      moderator_user_id: user_id
    }
  end

  defp condition("channel.goal." <> _, broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("channel.guest_star_session." <> _, broadcaster_user_id, user_id) do
    %{
      broadcaster_user_id: broadcaster_user_id,
      moderator_user_id: user_id
    }
  end

  defp condition("channel.hype_train." <> _, broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("channel.moderator." <> _, broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("channel.poll." <> _, broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("channel.prediction." <> _, broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("channel.raid", broadcaster_user_id, _user_id) do
    %{to_broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("channel.shield_mode." <> _, broadcaster_user_id, user_id) do
    %{
      broadcaster_user_id: broadcaster_user_id,
      moderator_user_id: user_id
    }
  end

  defp condition("channel.shoutout." <> _, broadcaster_user_id, user_id) do
    %{
      broadcaster_user_id: broadcaster_user_id,
      moderator_user_id: user_id
    }
  end

  defp condition("channel.subscribe", broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("channel.subscription." <> _, broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("channel.unban", broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("channel.update", broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("stream." <> _, broadcaster_user_id, _user_id) do
    %{broadcaster_user_id: broadcaster_user_id}
  end

  defp condition("user.update", _broadcaster_user_id, user_id) do
    %{user_id: user_id}
  end

  # Catch-all subscription, just attempt to use `broadcaster_user_id` condition.
  defp condition(type, broadcaster_user_id, _user_id) do
    Logger.warning("""
    [TwitchEventSub.Subscriptions] no default condition for subscription #{type}.
    Attempting to use a generic condition with just `broadcaster_user_id`.
    See: <https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/>
    """)

    %{broadcaster_user_id: broadcaster_user_id}
  end
end
