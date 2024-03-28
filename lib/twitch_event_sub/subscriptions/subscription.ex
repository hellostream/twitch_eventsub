defmodule TwitchEventSub.Subscriptions.Subscription do
  @moduledoc false

  alias TwitchEventSub.Subscriptions.Condition

  require Logger

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
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "automod.message.update" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "automod.settings.update" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "automod.terms.update" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.update" => %{
      version: "2",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.follow" => %{
      version: "2",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.ad_break.begin" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.chat.clear" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id, :user_id],
        optional: []
      }
    },
    "channel.chat.clear_user_messages" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id, :user_id],
        optional: []
      }
    },
    "channel.chat.message" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id, :user_id],
        optional: []
      }
    },
    "channel.chat.message_delete" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id, :user_id],
        optional: []
      }
    },
    "channel.chat.notification" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id, :user_id],
        optional: []
      }
    },
    "channel.chat_settings.update" => %{
      version: "beta",
      condition: %{
        required: [:broadcaster_user_id, :user_id],
        optional: []
      }
    },
    "channel.subscribe" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.subscription.end" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.subscription.gift" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.subscription.message" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.cheer" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.raid" => %{
      version: "1",
      condition: %{
        required: [],
        optional: [:from_broadcaster_user_id, :to_broadcaster_user_id]
      }
    },
    "channel.ban" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.unban" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.unban_request.create" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.unban_request.resolve" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.moderate" => %{
      version: "beta",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.moderator.add" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.moderator.remove" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.guest_star_session.begin" => %{
      version: "beta",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.guest_star_session.end" => %{
      version: "beta",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.guest_star_guest.update" => %{
      version: "beta",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.guest_star_settings.update" => %{
      version: "beta",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.channel_points_automatic_reward.add" => %{
      version: "beta",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.channel_points_custom_reward.add" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: [:reward_id]
      }
    },
    "channel.channel_points_custom_reward.update" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: [:reward_id]
      }
    },
    "channel.channel_points_custom_reward.remove" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: [:reward_id]
      }
    },
    "channel.channel_points_custom_reward_redemption.add" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: [:reward_id]
      }
    },
    "channel.channel_points_custom_reward_redemption.update" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: [:reward_id]
      }
    },
    "channel.poll.begin" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.poll.progress" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.poll.end" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.prediction.begin" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.prediction.progress" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.prediction.lock" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.prediction.end" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.vip.add" => %{
      version: "beta",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.vip.remove" => %{
      version: "beta",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.charity_campaign.donate" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.charity_campaign.start" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.charity_campaign.progress" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.charity_campaign.stop" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "conduit.shard.disabled" => %{
      version: "1",
      condition: %{
        required: [:client_id],
        optional: [:conduit_id]
      }
    },
    "drop.entitlement.grant" => %{
      version: "1",
      condition: %{
        required: [:organization_id],
        optional: [:campaign_id, :category_id]
      }
    },
    "extension.bits_transaction.create" => %{
      version: "1",
      condition: %{
        required: [:extension_client_id],
        optional: []
      }
    },
    "channel.goal.begin" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.goal.progress" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.goal.end" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.hype_train.begin" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.hype_train.progress" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.hype_train.end" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "channel.shield_mode.begin" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.shield_mode.end" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.shoutout.create" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "channel.shoutout.receive" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id, :moderator_user_id],
        optional: []
      }
    },
    "stream.online" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "stream.offline" => %{
      version: "1",
      condition: %{
        required: [:broadcaster_user_id],
        optional: []
      }
    },
    "user.authorization.grant" => %{
      version: "1",
      condition: %{
        required: [:client_id],
        optional: []
      }
    },
    "user.authorization.revoke" => %{
      version: "1",
      condition: %{
        required: [:client_id],
        optional: []
      }
    },
    "user.update" => %{
      version: "1",
      condition: %{
        required: [:user_id],
        optional: []
      }
    },
    "user.whisper.message" => %{
      version: "beta",
      condition: %{
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
  @spec new(%{
          required(:condition) => map(),
          required(:method) => method(),
          required(:name) => name(),
          optional(:version) => version()
        }) ::
          t()
  def new(%{condition: condition_attrs, method: method, name: name} = attrs)
      when method in @methods and name in @subscription_type_names do
    %__MODULE__{
      condition: Condition.new(name, condition_attrs),
      method: method,
      name: name,
      version: attrs[:version] || version_for_type(name)
    }
  end

  defp version_for_type(name), do: get_in(@subscription_types, [name, :version])
end
