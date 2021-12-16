defmodule ChatAssignment.Repo do
  use Ecto.Repo,
    otp_app: :chat_assignment,
    adapter: Ecto.Adapters.Postgres
end
