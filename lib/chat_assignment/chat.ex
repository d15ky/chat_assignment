defmodule ChatAssignment.Chat do
  import Ecto.Query, only: [from: 2]

  alias ChatAssignment.Chat.Message
  alias ChatAssignment.Repo

  def last_messages(amount \\ 10) do
    query = from m in Message, limit: ^amount, order_by: [desc: m.inserted_at], preload: [:user]
    Repo.all(query)
  end

  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end
end
