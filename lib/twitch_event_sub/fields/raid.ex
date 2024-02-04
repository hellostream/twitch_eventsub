defmodule TwitchEventSub.Fields.Raid do
  use TwitchEventSub.Fields,
    fields: [
      :user_id,
      :user_name,
      :user_login,
      :viewer_count,
      :profile_image_url
    ]
end
