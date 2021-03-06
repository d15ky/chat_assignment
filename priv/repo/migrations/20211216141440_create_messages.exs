defmodule ChatAssignment.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text
      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create index(:messages, [:user_id])
  end
end
