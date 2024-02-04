defmodule TwitchEventSub.Events.ChatNotification do
  use TwitchEventSub.Fields,
    fields: [
      :broadcaster_id,
      :broadcaster_name,
      :channel,
      :user_id,
      :user_name,
      :user_login,
      :is_anon?,
      :color,
      :badges,
      :system_message,
      :message_id,
      :message,
      :notice_type,
      # Event notice objects
      :sub,
      :resub,
      :sub_gift,
      :community_sub_gift,
      :gift_paid_upgrade,
      :prime_paid_upgrade,
      :raid,
      :unraid,
      :pay_it_forward,
      :announcement,
      :charity_donation,
      :bits_badge_tier
    ]
end
