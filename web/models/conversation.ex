defmodule Lemmings.Conversation do
  use Lemmings.Web, :model
  require Logger

  @primary_key {:user_id, :binary, autogenerate: false}

  schema "conversations" do
    field :state, :binary

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :state])
    |> validate_required([:user_id, :state])
  end

  def new(_user_id) do
    %{s: :new, history: []}
  end

  def handle_message(message, user_id, state) do
    case message do
      %{"message" => %{"text" => text}} -> handle_text_message(text, user_id, state)
      %{"read" => _} -> {:ok, [], state}
      %{"delivery" => _} -> {:ok, [], state}
      other ->
        Logger.error "Unhandled message: #{inspect other}"
        {:error, :unhandled}
    end
  end

  def handle_text_message("reset", user_id, state) do
    {:ok, {:text, "conversation state cleared"}, new(user_id)}
  end
  def handle_text_message("hi", _user_id, %{s: :new} = state) do
    replies = [
      {:typing, 2000},
      {:quick_replies, """
      Hallo! Ich bin der POSTROM Bot!
      Ich helfe dir, deinen Stromverbrauch unter Kontrolle zu halten und Geld damit zu sparen!
      Dazu kannst du auch tolle Ermäßigungen bei Post-Dienstleistungen bekommen.
      Hast du deine Stromzähler seit langem nicht gesehen? Es ist mal wieder an der Zeit, ihn abzustauben!
      """, ["Stromzähler prüfen", "Günstigeren finden"]},
    ]
    {:ok, replies, %{state | s: :said_hello}}
  end
  
  def handle_text_message("A", _user_id, %{s: :said_hello} = state) do
    replies = [
      {:text, "you choose A"},
    ]
    {:ok, replies, %{state | s: :choose_a }}
  end
  
  def handle_text_message("hi", _user_id, %{s: :new} = state) do
    replies = [
      {:text, "welcome"},
      {:typing, 2000},
      {:text, "asds"},
    ]
    {:ok, replies, %{state | s: :said_hello}}
  end
  
  def handle_text_message("hi", _user_id, %{s: :new} = state) do
    replies = [
      {:text, "welcome"},
      {:typing, 2000},
      {:text, "asds"},
    ]
    {:ok, replies, %{state | s: :said_hello}}
  end
  
  def handle_text_message("hi", _user_id, %{s: :new} = state) do
    replies = [
      {:text, "welcome"},
      {:quick_replies, "hello", [{"asd", "asd"}, {"qwe", "qeqw"}]}
    ]
    {:ok, replies, %{state | s: :said_hello}}
  end
  
  
  
  
  
  def handle_text_message(text, _user_id, state) do
    # state = %{state | history: [text | state.history]}
    {:ok, [], state}
  end
end
