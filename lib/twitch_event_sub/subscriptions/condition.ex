defmodule TwitchEventSub.Subscriptions.Condition do
  @moduledoc false

  alias TwitchEventSub.Subscriptions.Subscription

  @subscription_type_names Subscription.subscription_type_names()

  @doc """
  Create a new condition struct using the name and condition attrs.

  ## Examples

      iex> new("channel.update", %{broadcaster_user_id: "1234"})
      %TwitchEventSub.Subscriptions.Condition.Channel.Update{broadcaster_user_id: "1234"}

      iex> new("channel.poll.begin", %{broadcaster_user_id: "1234"})
      %TwitchEventSub.Subscriptions.Condition.Channel.PollBegin{broadcaster_user_id: "1234"}

  """
  @spec new(Subscription.name(), condition_attrs :: map()) :: struct()
  def new(name, condition_attrs) when name in @subscription_type_names do
    condition_module = module_from_name(name)
    condition_module.new(condition_attrs)
  end

  @doc """
  Build the condition module name from the subscription type name.

  ## Examples

      iex> module_from_name("channel.ad_break.begin")
      TwitchEventSub.Subscriptions.Condition.Channel.AdBreakBegin

      iex> module_from_name("channel.channel_points_custom_reward.add")
      TwitchEventSub.Subscriptions.Condition.Channel.ChannelPointsCustomRewardAdd

  """
  @spec module_from_name(Subscription.name()) :: module()
  def module_from_name(name)

  for {name, _type} <- Subscription.subscription_types() do
    [group | module_name] = String.split(name, ".") |> Enum.map(&Macro.camelize/1)

    condition_module =
      module_name
      |> Enum.map_join(&Macro.camelize/1)
      |> then(&Module.concat([__MODULE__, group, &1]))

    def module_from_name(unquote(name)), do: unquote(condition_module)
  end

  # ----------------------------------------------------------------------------
  # Condition modules
  # ----------------------------------------------------------------------------
  # Create all of the condition modules.
  #
  # This generates all of the modules (and structs) for a condition based on the
  # subscription type definitions defined in the Subscription module.
  for {name, type} <- Subscription.subscription_types() do
    [group | module_name] = String.split(name, ".") |> Enum.map(&Macro.camelize/1)

    condition_module =
      module_name
      |> Enum.map_join(&Macro.camelize/1)
      |> then(&Module.concat([__MODULE__, group, &1]))

    defmodule condition_module do
      @moduledoc false
      @derive Jason.Encoder
      @enforce_keys type.condition.required
      defstruct type.condition.required ++ type.condition.optional
      def new(condition), do: struct(__MODULE__, condition)
    end
  end
end
