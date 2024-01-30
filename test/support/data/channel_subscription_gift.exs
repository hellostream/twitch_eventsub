[
  %{
    "subscription" => %{
      "id" => "f1c2a387-161a-49f9-a165-0f21d7a4e1c4",
      "type" => "channel.subscription.gift",
      "version" => "1",
      "status" => "enabled",
      "cost" => 0,
      "condition" => %{
        "broadcaster_user_id" => "1337"
      },
      "transport" => %{
        "method" => "webhook",
        "callback" => "https://example.com/webhooks/callback"
      },
      "created_at" => "2019-11-16T10:11:12.634234626Z"
    },
    "event" => %{
      "user_id" => "1234",
      "user_login" => "cool_user",
      "user_name" => "Cool_User",
      "broadcaster_user_id" => "1337",
      "broadcaster_user_login" => "cooler_user",
      "broadcaster_user_name" => "Cooler_User",
      "total" => 2,
      "tier" => "1000",
      "cumulative_total" => 284,
      "is_anonymous" => false
    }
  }
]
