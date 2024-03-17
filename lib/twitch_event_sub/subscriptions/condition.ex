defmodule TwitchEventSub.Subscriptions.Condition do
  @moduledoc false

  @doc """
  Creating a new condition struct with a map of conditions.
  """
  @callback new(condition :: map()) :: struct()

  @doc """
  Create a new condition struct from the condition and subscription type.

  ## Examples

      iex> new("channel.update", %{broadcaster_user_id: "1234"})
      %TwitchEventSub.Subscriptions.Condition.ChannelUpdate{broadcaster_user_id: "1234"}

  """
  def new(type, condition) do
    condition_module = subscription_type_to_module(type)
    condition_module.new(condition)
  end

  @doc """
  Convert a subscription type to a condition module.

  ## Examples

      iex> subscription_type_to_module("automod.message.hold")
      TwitchEventSub.Subscriptions.Condition.AutomodMessageHold

  """
  def subscription_type_to_module(type) do
    type
    |> String.split(".")
    |> Enum.map_join(&Macro.camelize/1)
    |> then(&Module.concat(__MODULE__, &1))
  end

  @doc false
  defmacro __using__(_opts) do
    quote do
      @moduledoc false
      @behaviour TwitchEventSub.Subscriptions.Condition

      @impl TwitchEventSub.Subscriptions.Condition
      def new(condition) do
        struct(__MODULE__, condition)
      end

      defoverridable new: 1
    end
  end
end

# ------------------------------------------------------------------------------
# Condition modules
# ------------------------------------------------------------------------------

defmodule TwitchEventSub.Subscriptions.Condition.AutomodMessageHold do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.AutomodMessageUpdate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.AutomodSettingUpdate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.AutomodTermsUpdate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelUpdate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelFollow do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelAdBreakBegin do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelChatClear do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :user_id]
  defstruct [:broadcaster_user_id, :user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelChatClearUserMessages do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :user_id]
  defstruct [:broadcaster_user_id, :user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelChatMessage do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :user_id]
  defstruct [:broadcaster_user_id, :user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelChatMessageDelete do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :user_id]
  defstruct [:broadcaster_user_id, :user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelChatNotification do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :user_id]
  defstruct [:broadcaster_user_id, :user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelChatSettingsUpdate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :user_id]
  defstruct [:broadcaster_user_id, :user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelSubscribe do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelSubscriptionEnd do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelSubscriptionGift do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelSubscriptionMessage do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelCheer do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelRaid do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:from_broadcaster_user_id, :to_broadcaster_user_id]
  defstruct [:from_broadcaster_user_id, :to_broadcaster_user_id]
  # Either `to_broadcaster_user_id` or `from_broadcaster_user_id` is required.
  # We can't use `@enforce_keys` for this, so we will use pattern-matching.
  @impl TwitchEventSub.Subscriptions.Condition
  def new(%{to_broadcaster_user_id: _} = condition), do: struct(__MODULE__, condition)
  def new(%{from_broadcaster_user_id: _} = condition), do: struct(__MODULE__, condition)
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelBan do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelUnban do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelUnbanRequestCreate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelUnbanRequestResolve do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelModerate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelModeratorAdd do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelModeratorRemove do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelGuestStarSessionBegin do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelGuestStarSessionEnd do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelGuestStarGuestUpdate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelGuestStarSettingsUpdate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelChannelPointsCustomRewardAdd do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelChannelPointsAutomaticRewardAdd do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelChannelPointsCustomRewardUpdate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id, :reward_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelChannelPointsCustomRewardRemove do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id, :reward_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelChannelPointsCustomRewardRedemptionAdd do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id, :reward_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelChannelPointsCustomRewardRedemptionUpdate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id, :reward_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelPollBegin do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelPollProgress do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelPollEnd do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelPredictionBegin do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelPredictionProgress do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelPredictionLock do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelPredictionEnd do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelVipAdd do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelVipRemove do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelCharityCampaignDonate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelCharityCampaignStart do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelCharityCampaignProgress do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelCharityCampaignStop do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ConduitShard.Disabled do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:client_id]
  defstruct [:client_id, :conduit_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.DropEntitlementGrant do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:organization_id]
  defstruct [:organization_id, :category_id, :campaign_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ExtensionBitsTransactionCreate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:extension_client_id]
  defstruct [:extension_client_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelGoalBegin do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelGoalProgress do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelGoalEnd do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelHypeTrainBegin do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelHypeTrainProgress do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelHypeTrainEnd do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelShieldModeBegin do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelShieldModeEnd do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelShoutoutCreate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.ChannelShoutoutReceive do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id, :moderator_user_id]
  defstruct [:broadcaster_user_id, :moderator_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.StreamOnline do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.StreamOffline do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:broadcaster_user_id]
  defstruct [:broadcaster_user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.UserAuthorizationGrant do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:client_id]
  defstruct [:client_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.UserAuthorizationRevoke do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:client_id]
  defstruct [:client_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.UserUpdate do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:user_id]
  defstruct [:user_id]
end

defmodule TwitchEventSub.Subscriptions.Condition.UserWhisperMessage do
  use TwitchEventSub.Subscriptions.Condition
  @enforce_keys [:user_id]
  defstruct [:user_id]
end
