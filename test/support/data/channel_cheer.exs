[
  %{
    "subscription" => %{
      "id" => "f1c2a387-161a-49f9-a165-0f21d7a4e1c4",
      "type" => "channel.cheer",
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
      "bits" => 100,
      "broadcaster_user_id" => "146616692",
      "broadcaster_user_login" => "ryanwinchester_",
      "broadcaster_user_name" => "RyanWinchester_",
      "is_anonymous" => false,
      "message" => "Cheer100",
      "user_id" => "138679291",
      "user_login" => "bradkilshaw",
      "user_name" => "bradkilshaw"
    }
  }
]
