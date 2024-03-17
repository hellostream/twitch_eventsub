defmodule TwitchEventSub.Subscriptions.Subscription do
  @moduledoc false

  @type condition :: struct()
  @type method :: :conduit | :webhook | :websocket
  @type name :: String.t()
  @type version :: String.t()

  @type t :: %__MODULE__{
          condition: condition(),
          method: method(),
          name: name(),
          version: version()
        }

  @enforce_keys [:condition, :method, :name, :version]
  defstruct [:condition, :method, :name, :version]

  @methods [:conduit, :webhook, :websocket]

  @subscription_types %{
    "automod.message.hold" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "automod.message.update" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "automod.settings.update" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "automod.terms.update" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.update" => %{
      version: "2",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.follow" => %{
      version: "2",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.ad_break.begin" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.chat.clear" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :user_id],
        optional: []
      }
    },
    "channel.chat.clear_user_messages" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :user_id],
        optional: []
      }
    },
    "channel.chat.message" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :user_id],
        optional: []
      }
    },
    "channel.chat.message_delete" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :user_id],
        optional: []
      }
    },
    "channel.chat.notification" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :user_id],
        optional: []
      }
    },
    "channel.chat_settings.update" => %{
      version: "beta",
      conditions: %{
        required: [:broadcaster_user_id, :user_id],
        optional: []
      }
    },
    "channel.subscribe" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.subscription.end" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.subscription.gift" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.subscription.message" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.cheer" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.raid" => %{
      version: "1",
      conditions: %{
        required: [],
        optional: [:from_broadcaster_user_id, :to_broadcaster_user_id]
      }
    },
    "channel.ban" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.unban" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.unban_request.create" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.unban_request.resolve" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.moderate" => %{
      version: "beta",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.moderator.add" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.moderator.remove" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.guest_star_session.begin" => %{
      version: "beta",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.guest_star_session.end" => %{
      version: "beta",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.guest_star_guest.update" => %{
      version: "beta",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.guest_star_settings.update" => %{
      version: "beta",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.channel_points_automatic_reward.add" => %{
      version: "beta",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.channel_points_custom_reward.add" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: [:reward_id]
      }
    },
    "channel.channel_points_custom_reward.update" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: [:reward_id]
      }
    },
    "channel.channel_points_custom_reward.remove" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: [:reward_id]
      }
    },
    "channel.channel_points_custom_reward_redemption.add" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: [:reward_id]
      }
    },
    "channel.channel_points_custom_reward_redemption.update" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: [:reward_id]
      }
    },
    "channel.poll.begin" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.poll.progress" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.poll.end" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.prediction.begin" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.prediction.progress" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.prediction.lock" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.prediction.end" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.vip.add" => %{
      version: "beta",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.vip.remove" => %{
      version: "beta",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.charity_campaign.donate" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.charity_campaign.start" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.charity_campaign.progress" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.charity_campaign.stop" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "conduit.shard.disabled" => %{
      version: "1",
      conditions: %{
        required: [:client_id],
        optional: [:conduit_id]
      }
    },
    "drop.entitlement.grant" => %{
      version: "1",
      conditions: %{
        required: [:organization_id],
        optional: [:campaign_id, :category_id]
      }
    },
    "extension.bits_transaction.create" => %{
      version: "1",
      conditions: %{
        required: [:extension_client_id],
        optional: []
      }
    },
    "channel.goal.begin" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.goal.progress" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.goal.end" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.hype_train.begin" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.hype_train.progress" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.hype_train.end" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.shield_mode.begin" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.shield_mode.end" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.shoutout.create" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.shoutout.receive" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "stream.online" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "stream.offline" => %{
      version: "1",
      conditions: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "user.authorization.grant" => %{
      version: "1",
      conditions: %{
        required: [:client_id],
        optional: []
      }
    },
    "user.authorization.revoke" => %{
      version: "1",
      conditions: %{
        required: [:client_id],
        optional: []
      }
    },
    "user.update" => %{
      version: "1",
      conditions: %{
        required: [:user_id],
        optional: []
      }
    },
    "user.whisper.message" => %{
      version: "beta",
      conditions: %{
        required: [:user_id],
        optional: []
      }
    }
  }

  @subscription_type_names Map.keys(@subscription_types)

  def subscription_types, do: @subscription_types
  def subscription_type_names, do: @subscription_type_names

  @doc """
  Create a new subscription struct.
  """
  @spec new(condition_attrs :: map(), method(), name(), version()) :: t()
  def new(condition_attrs, method, name, version)
      when method in @methods and name in @subscription_type_names do
    %__MODULE__{
      condition: condition(name, condition_attrs),
      method: method,
      name: name,
      version: version
    }
  end

  @doc """
  Create a new condition struct using the name and condition attrs.

  ## Examples

      iex> condition("channel.update", %{broadcaster_user_id: "1234"})
      %TwitchEventSub.Subscriptions.Condition.Channel.Update{broadcaster_user_id: "1234"}

      iex> condition("channel.poll.begin", %{broadcaster_user_id: "1234"})
      %TwitchEventSub.Subscriptions.Condition.Channel.PollBegin{broadcaster_user_id: "1234"}

  """
  @spec condition(name(), condition_attrs :: map()) :: struct()
  def condition(name, condition_attrs) when name in @subscription_type_names do
    condition_module = condition_module_from_name(name)
    condition_module.new(condition_attrs)
  end

  @doc """
  Build the condition module name from the subscription type name.

  ## Examples

      iex> condition_module_from_name("channel.ad_break.begin")
      TwitchEventSub.Subscriptions.Condition.Channel.AdBreakBegin

      iex> condition_module_from_name("channel.channel_points_custom_reward.add")
      TwitchEventSub.Subscriptions.Condition.Channel.ChannelPointsCustomRewardAdd

  """
  @spec condition_module_from_name(name()) :: module()
  def condition_module_from_name(name)

  for {name, _type} <- @subscription_types do
    [group | module_name] = String.split(name, ".") |> Enum.map(&Macro.camelize/1)

    condition_module =
      module_name
      |> Enum.map_join(&Macro.camelize/1)
      |> then(&Module.concat([TwitchEventSub.Subscriptions, "Condition", group, &1]))

    def condition_module_from_name(unquote(name)), do: unquote(condition_module)
  end

  # Create all of the condition modules.
  #
  # This builds all of the modules for a condition based on the subscription
  # type definitions defined in the `@subscription_types` module attribute.
  for {name, type} <- @subscription_types do
    [group | module_name] = String.split(name, ".") |> Enum.map(&Macro.camelize/1)

    condition_module =
      module_name
      |> Enum.map_join(&Macro.camelize/1)
      |> then(&Module.concat([__MODULE__, "Condition", group, &1]))

    defmodule condition_module do
      @moduledoc false
      @enforce_keys type.conditions.required
      defstruct type.conditions.required ++ type.conditions.optional
      def new(condition), do: struct(__MODULE__, condition)
    end
  end
end
