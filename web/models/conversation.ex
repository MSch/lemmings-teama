defmodule Lemmings.Conversation do
  use Lemmings.Web, :model

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
    %{history: []}
  end

  def handle_message(message, user_id, state) do
    %{"text" => text} = message
    with {:ok, replies, state} <- handle_text_message(text, user_id, state) do
      {:ok, replies, state}
    else
      {:error, _reason} = e -> e
    end
  end

  def handle_text_message("reset", user_id, state) do
    handle_text_message("hi", user_id, new(user_id))
  end
  def handle_text_message("hi", _user_id, state) do
    {:ok, {:text, "welcome"}, state}
  end
  def handle_text_message(text, _user_id, state) do
    state = %{state | history: [text | state.history]}
    {:ok, [], state}
  end
end
