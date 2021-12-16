defmodule ChatAssignmentWeb.UserSessionController do
  use ChatAssignmentWeb, :controller

  import Phoenix.HTML.Link, only: [link: 2]

  alias ChatAssignment.Accounts
  alias ChatAssignmentWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"login" => login, "password" => password} = user_params

    case Accounts.get_user_by_login_and_password(login, password) do
      nil ->render_with_error(conn, "Invalid login (username or email) or password")
      user when user.confirmed_at != nil -> UserAuth.log_in_user(conn, user, user_params)
      user when user.confirmed_at == nil -> render_with_error(conn,
      ["You need to ", link("confirm your email", to: Routes.user_confirmation_path(conn, :new)), " before you'll be able to login."])
    end

  end

  defp render_with_error(conn, message) do
    conn
    |> put_flash(:error, message)
    |> render("new.html")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
