defmodule Lemmings.Messages do
  use GenServer
  require Logger

  @name __MODULE__

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
      user_id = message["recipient"]["id"]
      conversation = case Lemmings.Repo.get(Lemmings.Conversation, user_id) do
        nil ->
          conv_state = Lemmings.Conversation.new(user_id) |> :erlang.term_to_binary()
          %Lemmings.Conversation{user_id: user_id, state: conv_state}
        conversation ->
          conversation
      end

      with \
        conv_state <- :erlang.binary_to_term(conversation.state),
        {:ok, replies, new_conv_state} <- Lemmings.Conversation.handle_message(message["message"], user_id, conv_state),
        conversation <- Lemmings.Conversation.changeset(conversation, %{state: :erlang.term_to_binary(new_conv_state)})
      do
        case conversation.data.__meta__.state do
          :built -> Logger.info "Started new conversation for user_id=#{user_id}: #{inspect new_conv_state}"
          :loaded -> Logger.info "Updated conversation for user_id=#{user_id}: #{inspect conv_state} -> #{inspect new_conv_state}"
        end
        IO.inspect replies
        Lemmings.Repo.insert_or_update!(conversation)
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
