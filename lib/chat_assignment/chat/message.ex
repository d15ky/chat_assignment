defmodule ChatAssignment.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    belongs_to :user, ChatAssignment.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :user_id])
    |> cast_assoc(:user)
    |> assoc_constraint(:user)
    |> validate_required([:content])
  end
end
