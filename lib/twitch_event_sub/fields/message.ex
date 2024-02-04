defmodule TwitchEventSub.Fields.Message do
  @moduledoc false

  defmodule Fragments do
    defmodule Cheermote do
      defstruct [:prefix, :bits, :tier]
    end

    defmodule Emote do
      defstruct [:id, :emote_set_id, :owner_id, :format]
    end

    defmodule Mention do
      defstruct [:user_id, :user_name, :user_login]
    end

    defmodule Text do
      defstruct [:text]
    end
  end
end
