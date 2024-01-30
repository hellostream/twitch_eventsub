[
  %{
    "subscription" => %{
      "id" => "f1c2a387-161a-49f9-a165-0f21d7a4e1c4",
      "type" => "channel.chat.notification",
      "version" => "1",
      "status" => "enabled",
      "cost" => 0,
      "condition" => %{
        "broadcaster_user_id" => "1337",
        "user_id" => "9001"
      },
      "transport" => %{
        "method" => "webhook",
        "callback" => "https://example.com/webhooks/callback"
      },
      "created_at" => "2023-04-11T10:11:12.123Z"
    },
    "event" => %{
      "broadcaster_user_id" => "1337",
      "broadcaster_user_name" => "Cool_User",
      "broadcaster_user_login" => "cool_user",
      "chatter_user_id" => "444",
      "chatter_user_login" => "cool_chatter",
      "chatter_user_name" => "Cool_Chatter",
      "chatter_is_anonymous" => false,
      "color" => "red",
      "badges" => [
        %{
          "set_id" => "moderator",
          "id" => "1",
          "info" => ""
        },
        %{
          "set_id" => "subscriber",
          "id" => "12",
          "info" => "16"
        },
        %{
          "set_id" => "sub-gifter",
          "id" => "1",
          "info" => ""
        }
      ],
      "system_message" => "chat message",
      "message_id" => "ab24e0b0-2260-4bac-94e4-05eedd4ecd0e",
      "message" => %{
        "text" => "chat-msg",
        "fragments" => [
          %{
            "type" => "emote",
            "text" => "chat-msg",
            "cheermote" => nil,
            "emote" => %{
              "id" => "emote-id",
              "emote_set_id" => "emote-set",
              "owner_id" => "emote-owner",
              "format" => [
                "static"
              ]
            },
            "mention" => nil
          }
        ]
      },
      "notice_type" => "announcement",
      "sub" => nil,
      "resub" => nil,
      "sub_gift" => nil,
      "community_sub_gift" => nil,
      "gift_paid_upgrade" => nil,
      "prime_paid_upgrade" => nil,
      "pay_it_forward" => nil,
      "raid" => nil,
      "unraid" => nil,
      "announcement" => %{
        "color" => "blue"
      },
      "bits_badge_tier" => nil,
      "charity_donation" => nil
    }
  }
]
