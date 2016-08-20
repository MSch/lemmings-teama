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
    %{s: :new, history: [], anbieter: nil, meter_levels: []}
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

  def handle_text_message(input, _user_id, %{s: :meter_check} = state) do
    error_replies = [
      {:text, "nope. try again"}
    ]
    case Integer.parse(input) do
      {meter_level, rest} ->
        cond do
          meter_level < 1000 ->
            {:ok, error_replies, state}
          meter_level > 10000000 ->
            {:ok, error_replies, state}
          not String.downcase(rest) in ["", " kw", " kwh", " kw/h", " kilowatt", " kilowattstunden"] ->
            {:ok, error_replies, state}
          true ->
            replies = [
              {:text, "#{meter_level} Kilowatt. Super!"}
            ]
            {:ok, replies, %{state | s: :meter_level_given, meter_levels: [meter_level | state.meter_levels]}}
        end
      :error ->
        {:ok, error_replies, state}
    end
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
          {:text, """
          Das ist derzeit nicht der günstigste Deal. 
          Du kannst den Tarifrechner auf post.at verwenden, um einen günstigeren Tarif zu finden!
          https://post.at/energiekosten-rechner/
          """},
          {:typing, 2000},
          {:text, """
          Wenn du mir sagst, wann deine Vertragsbindung bei deinem Stromanbieter endet (DD-MM-YY), 
          kann ich dich rechtzeitig daran erinnern, Stromanbieter zu wechseln!
          """}
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
