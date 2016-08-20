defmodule Lemmings.FbController do
  use Lemmings.Web, :controller
  require Logger

  def verify(conn,
    %{"hub.mode" => "subscribe", "hub.verify_token" => "post", "hub.challenge" => challenge})
  do
    text(conn, challenge)
  end

  def webhook(conn, %{"object" => "page", "entry" => entries} = params) do
    # X-Hub-Signature
    # %{
    #   "entry" => [
    #     %{
    #       "id" => "538011173054564",
    #       "messaging" => [
    #         %{
    #           "message" => %{"mid" => "mid.1471692872641:4dcb6ee75b71dc6447", "seq" => 3, "text" => "hi"}, 
    #           "recipient" => %{"id" => "538011173054564"},
    #           "sender" => %{"id" => "1354755267868296"},
    #           "timestamp" => 1471692872706
    #         }
    #       ],
    #       "time" => 1471692879592
    #     }
    #    ],
    #   "object" => "page"
    # }

    Enum.each(entries, fn %{"messaging" => messages} = _entry ->
      Enum.each(messages, fn message ->
        Lemmings.Messages.process_message(message)
      end)
    end)
    send_resp(conn, 200, "")
  end
end
