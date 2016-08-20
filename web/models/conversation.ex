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
    %{s: :new, history: [], anbieter: nil}
  end

  def handle_message(message, user_id, state) do
    case message do
      %{"message" => %{"text" => text}} -> handle_text_message(text, user_id, state)
      %{"postback" => %{"payload" => payload}} -> handle_text_message(payload, user_id, state)
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
      {:buttons, """
      Hallo! Ich bin der POSTROM Bot!
      Ich helfe dir, deinen Stromverbrauch unter Kontrolle zu halten und Geld damit zu sparen!
      Dazu kannst du auch tolle Ermäßigungen bei Post-Dienstleistungen bekommen.
      Hast du deinen Stromzähler seit langem nicht gesehen? Es ist mal wieder an der Zeit, ihn abzustauben!
      """, ["Stromzähler prüfen", "Günstigerer Strom", "Energiespar-Tipp"]},
    ]
    {:ok, replies, %{state | s: :said_hello}}
  end
  
  def handle_text_message("Stromzähler prüfen", _user_id, %{s: :said_hello} = state) do
    replies = [
      {:text, """
      Bitte lies deinen Strom-Zählerstand ab, damit du in einem Monat sehen kannst wie viel du verbraucht hast. 
      Bitte schreib mir den Zahl vom Stromzähler.
      """},
    ]
    {:ok, replies, %{state | s: :meter_check}}
  end
  
  def handle_text_message("Günstigerer Strom", _user_id, %{s: :said_hello} = state) do
    replies = [
      {:text, """
      Bitte sag mir, bei welchem Stromanbieter du gerade Strom beziehst! 
      (Tipp: Du kannst die Info auf deiner Stromrechnung finden!)
      """},
    ]
    {:ok, replies, %{state | s: :cheap_strom}}
  end
  
  def handle_text_message("Energiespar-Tipp", _user_id, %{s: :said_hello} = state) do
    replies = [
      {:text, "Hier noch ein Energiespar-Tipp:"},
      {:buttons, """
      Elektrogeräte sind Stromfresser, auch wenn sie gar nicht gebraucht werden und damit schädlich fürs Klima. 
      Die Kosten für den Standby-Betrieb läppern sich im Jahr zu ordentlichen Beträgen. 
      Steck das Gerät aus oder verwende stattdessen schaltbare Steckdosen - das spart bis zu 70% Energie!
      """, ["Stromzähler prüfen", "Günstigerer Strom"]},
    ]
    {:ok, replies, %{state | s: :said_hello}}
  end

  def handle_text_message(anbieter, _user_id, %{s: :cheap_strom} = state) do
    replies = case anbieter do
      "Wien Energie" ->
        [
          {:text, "Dein Anbieter ist der günstigste! Gratulation"}
        ]
      _ ->
        [
          {:text, "nope"}
        ]
    end
    {:ok, replies, %{state | s: :cheap_strom2, anbieter: anbieter}}
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
