defmodule ChatAssignmentWeb.UserRegistrationController do
  use ChatAssignmentWeb, :controller

  alias ChatAssignment.Accounts
  alias ChatAssignment.Accounts.User
  alias ChatAssignmentWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "User created successfully. You have to confirm email before you will be able to login.")
        |> redirect(to: Routes.user_session_path(conn, :new))
        |> halt()

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
