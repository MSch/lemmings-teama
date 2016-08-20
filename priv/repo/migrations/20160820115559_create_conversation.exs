defmodule Lemmings.Repo.Migrations.CreateConversation do
  use Ecto.Migration

  def up do
    """
    CREATE EXTENSION IF NOT EXISTS pg_buffercache;

    CREATE EXTENSION IF NOT EXISTS pg_freespacemap;

    CREATE EXTENSION IF NOT EXISTS pgrowlocks;

    CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

    CREATE EXTENSION IF NOT EXISTS btree_gist;

    CREATE EXTENSION IF NOT EXISTS btree_gin;

    CREATE EXTENSION IF NOT EXISTS intarray;

    CREATE TABLE conversations (
      user_id varchar NOT NULL PRIMARY KEY,
      state bytea NOT NULL,
      inserted_at timestamptz NOT NULL DEFAULT current_timestamp,
      updated_at timestamptz NOT NULL
    )
    """
    |> String.split("\n\n")
    |> Enum.reject(fn sql -> String.strip(sql) |> String.length == 0 end)
    |> Enum.each(&execute/1)
  end
end

# dropdb lemmings_dev && createdb lemmings_dev && mix ecto.migrate
