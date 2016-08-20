defmodule Lemmings.Messages do
  use GenServer
  require Logger

  @name __MODULE__

  @access_token "EAALdLJLk4cwBAHpUgwZCvjdVliE6St2uUyz6TanTmDyIrOLSTGdegZA9W3oPILne8cJ1O8Egiwug7PxBQh2KBJU7H9iHqNiPZA1SjXbQ5SGR2dIiwrwpgCYmNosDCO0HzRf1cmZADo1HaIxaJFmZCVqVx7VYW6BXu3nrmHJTAogZDZD"

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def process_message(message) do
    :ok = GenServer.call(@name, {:message, message}, 5000)
  end

  # GenServer callbacks

  def init([]) do
    {:ok, nil}
  end

  # %{
  #   "message" => %{"mid" => "mid.1471694043779:4099767ee62ad45898", "seq" => 5, "text" => "poke"},
  #   "recipient" => %{"id" => "1050083538380516"},
  #   "sender" => %{"id" => "926133230843274"},
  #   "timestamp" => 1471694043786
  # }
  def handle_call({:message, message}, _from, state) do
    {:ok, pid} = Task.start(fn -> 
      user_id = message["sender"]["id"]
      conversation = case Lemmings.Repo.get(Lemmings.Conversation, user_id) do
        nil ->
          conv_state = Lemmings.Conversation.new(user_id) |> :erlang.term_to_binary()
          %Lemmings.Conversation{user_id: user_id, state: conv_state}
        conversation ->
          conversation
      end

      with \
        conv_state <- :erlang.binary_to_term(conversation.state),
        {:ok, replies, new_conv_state} <- Lemmings.Conversation.handle_message(message, user_id, conv_state),
        conversation <- Lemmings.Conversation.changeset(conversation, %{state: :erlang.term_to_binary(new_conv_state)})
      do
        case conversation.data.__meta__.state do
          :built -> Logger.info "Started new conversation for user_id=#{user_id}: #{inspect new_conv_state}"
          :loaded ->
            if conv_state != new_conv_state do
              Logger.info "Updated conversation for user_id=#{user_id}: #{inspect conv_state} -> #{inspect new_conv_state}"
            end
        end
        Lemmings.Repo.insert_or_update!(conversation)
        replies = List.wrap(replies)
        Task.start(fn ->
          Enum.each(replies, fn reply ->
            case reply do
              {:text, text} ->
                Logger.info "Reply #{inspect text}"
                json = %{
                  "recipient" => %{"id" => user_id},
                  "message" => %{"text" => text}
                }
                result = HTTPoison.post("https://graph.facebook.com/v2.6/me/messages", Poison.encode!(json), [{"Content-Type", "application/json"}],
                  params: [{"access_token", @access_token}]
                )
                case result do
                  {:ok, %{status_code: 200}} -> :ok
                  error ->
                    Logger.error "Failed to send response #{inspect json}, got #{inspect error}"
                end
              {:sleep, milliseconds} ->
                Process.sleep(milliseconds)
              other ->
                Logger.error "Invalid reply #{inspect reply}"
            end
          end)
        end)
      else
        {:error, reason} ->
          Logger.error "Failed to handle message for user #{user_id}: #{inspect reason}"
      end
    end)
    ref = Process.monitor(pid)
    receive do
      {:DOWN, ^ref, _, _, _} -> :ok
    end
    {:reply, :ok, state}
  end
end
