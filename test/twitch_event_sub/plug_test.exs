defmodule TwitchEventSub.PlugTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias TwitchEventSub.Plug

  defmodule TestHandler do
    use TwitchEventSub

    @impl TwitchEventSub
    def handle_event(type, event) do
      {type, event}
    end
  end

  @opts [handler: TestHandler, secret: "somesecret"]

  @msg_id "123abc"
  @timestamp "2030-01-01T12:31:00Z"
  @secret "somesecret"

  @notification_body """
  {
    "subscription": {"type": "channel.follow"},
    "event": {
      "user_id": "1234",
      "user_login": "cool_user",
      "user_name": "Cool_User",
      "broadcaster_user_id": "1337",
      "broadcaster_user_login": "cooler_user",
      "broadcaster_user_name": "Cooler_User",
      "followed_at": "2020-07-15T18:16:11.17106713Z"
    }
  }
  """

  test "notification succeeds" do
    conn = build_conn(@notification_body)
    assert resp = Plug.call(conn, Plug.init(@opts))
    assert 200 = resp.status
  end

  test "notification fails" do
    conn = build_conn(@notification_body) |> assign(:raw_body, "foo")
    assert resp = Plug.call(conn, Plug.init(@opts))
    assert 401 = resp.status
  end

  defp build_conn(body) do
    hmac_msg = @msg_id <> @timestamp <> body
    hmac = :crypto.mac(:hmac, :sha256, @secret, hmac_msg)
    hmac = "sha256=" <> Base.encode16(hmac, case: :lower)

    conn(:post, "/twitch/callback", Jason.decode!(body))
    |> put_req_header("twitch-eventsub-message-type", "notification")
    |> put_req_header("twitch-eventsub-message-id", @msg_id)
    |> put_req_header("twitch-eventsub-message-timestamp", @timestamp)
    |> put_req_header("twitch-eventsub-message-signature", hmac)
    |> assign(:raw_body, body)
  end
end
