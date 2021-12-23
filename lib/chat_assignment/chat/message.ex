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
    |> cast(attrs, [:content])
    |> validate_required([:content, :user_id])
    |> cast_assoc(:user)
    |> assoc_constraint(:user)
  end
end
