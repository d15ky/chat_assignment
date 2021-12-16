defmodule ChatAssignmentWeb.UserSessionController do
  use ChatAssignmentWeb, :controller

  alias ChatAssignment.Accounts
  alias ChatAssignmentWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    case Accounts.get_user_by_email_and_password(email, password) do
      nil -> render(conn, "new.html", error_message: "Invalid login (username or email) or password")
      user when user.confirmed_at != nil -> UserAuth.log_in_user(conn, user, user_params)
      user when user.confirmed_at == nil -> render(conn, "new.html", error_message: "You need to confirm your email before you'll be able to login.")
    end

  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
